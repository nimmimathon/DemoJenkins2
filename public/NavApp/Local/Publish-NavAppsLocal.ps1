function Publish-NavAppsLocal {
    Param  (
        [Parameter(Mandatory=$true)][String]$ServerInstance,
        [Parameter(Mandatory=$true)][array]$AppsFilePath
    ) 

    $PublishedAppList = @()
    $AppToInstallList = @()
    $DependentList = @()
    $AppToPublishList = @()
    
    $InstalledAppList = @()
    foreach ($NavApp in (Get-NAVAppInfo -ServerInstance $ServerInstance -Tenant 'default')) {
        $ConvertedPublishedApp = ConvertTo-NavAppObject -NavAppInfo $NavApp
        $InstalledAppList += $ConvertedPublishedApp
    }

    foreach ($PublishedApp in (Get-NAVAppInfo -ServerInstance $ServerInstance)) {
        $ConvertedPublishedApp = ConvertTo-NavAppObject -NavAppInfo (Get-NAVAppInfo -ServerInstance $ServerInstance -Id $PublishedApp.AppId -Version $PublishedApp.Version)
        $InListApp = $PublishedAppList | Where-Object { $ConvertedPublishedApp.Id -eq $_.Id }
        if ($InListApp.Count -eq 0) {
            $PublishedAppList += $ConvertedPublishedApp
        } 
        else {
            if (([regex]::Replace($ConvertedPublishedApp.Version, '\d+', { $args[0].Value.PadLeft(20) })) -ge ([regex]::Replace($InListApp.Version, '\d+', { $args[0].Value.PadLeft(20) }) )) {
                $InListApp.Version = $ConvertedPublishedApp.Version
            }
        }
    }

    foreach ($AppFilePath in $AppsFilePath) {
        $AppToPublish = ConvertTo-NavAppObject -NavAppInfo (Get-NAVAppInfo -Path $AppFilePath)

        # search for versions > than AppToPublish
        $PublishedApp = ([array]$PublishedAppList | Where-Object { $_.Id -eq $AppToPublish.Id })
        $PublishedApp = $PublishedApp | Where-Object { ([regex]::Replace($_.Version, '\d+', { $args[0].Value.PadLeft(20) })) -ge ([regex]::Replace($AppToPublish.Version, '\d+', { $args[0].Value.PadLeft(20) }) )}
        
        if ($PublishedApp.Count -eq 0) {
            $AppToPublish | Add-Member -Name AppFile -MemberType NoteProperty -Value $AppFilePath
            $AppToPublishList += $AppToPublish
        }
        else {
            if (($InstalledAppList | Where-Object { $PublishedApp.Id -eq $_.Id }).length -eq 0) {
                $AppToInstallList += $PublishedApp                
                write-host -ForegroundColor Cyan ("'{0}' v{1} already deployed but not installed. will be installed" -f $PublishedApp.Name, $PublishedApp.Version, $ServerInstance)
            }
            else {
                write-host -ForegroundColor Magenta ("'{0}' will be skipped. v{1} is already deployed on {2}" -f $PublishedApp.Name, $PublishedApp.Version, $ServerInstance)
            }
        }
    }

    if (($AppToPublishList.Count -eq 0) -and ($AppToInstallList.Count -eq 0)) {
        throw "Nothing to deploy or install"
    }

    if ($AppToPublishList.Count -gt 0) {
        foreach ($AppToPublish in (Sort-NavAppListDependency -NavAppList $AppToPublishList)) {
            write-host -ForegroundColor Green ("Publish '{0}' v{1} to {2}" -f $AppToPublish.Name, $AppToPublish.Version, $ServerInstance)
            Publish-NAVApp -ServerInstance $ServerInstance -Path $AppToPublish.AppFile -SkipVerification -WarningAction SilentlyContinue
            $DependentList += Get-DependentNavAppList -AppId $AppToPublish.Id -AppList $PublishedAppList | Where-Object { $AppToPublishList.Id -notcontains $_.Id }
        }  
    }
    foreach ($NavApp in $AppToInstallList) {
        $AppToPublishList += $NavApp
        if (($DependentList | Where-Object { $NavApp.Id -eq $_.Id }).Count -eq 0) {
            $DependentList += Get-DependentNavAppList -AppId $NavApp.Id -AppList $PublishedAppList | Where-Object { $NavApp.Id -notcontains $_.Id }
        }
    }
    
    $AppsToReplace = @($AppToPublishList | Where-Object { $PublishedAppList.Id -contains $_.Id })
    $DependentList = $DependentList | Sort-Object Id | Get-Unique -AsString
    $DependentList = @($DependentList | Where-Object { $AppsToReplace.Id -notcontains $_.Id })
    $DependentList = @($PublishedAppList | Where-Object { $DependentList.Id -contains $_.Id })

    $AppsToUninstall = (Sort-NavAppListDependency -NavAppList ($DependentList + $AppsToReplace))
    for ($i = $AppsToUninstall.Count -1; $i -ge 0 ; $i--) {
        $AppToUninstall = $AppsToUninstall[$i]
        write-host ("Uninstall App '{0}' v{1} from {2}" -f $AppToUninstall.Name, $AppToUninstall.Version, $ServerInstance)
        Uninstall-NAVApp -ServerInstance $ServerInstance -Name $AppToUninstall.Name -Publisher $AppToUninstall.Publisher -Version $AppToUninstall.Version -Force -WarningAction SilentlyContinue
    }    
    
    #sync
    Sync-NavTenant -ServerInstance $ServerInstance -Force
    write-host ("Sync Server Instance '{0}'" -f $ServerInstance)
    foreach ($AppToPublish in (Sort-NavAppListDependency -NavAppList $AppToPublishList)) {
        write-host ("Sync App '{0}' on {1}" -f $AppToPublish.Name, $ServerInstance)
        Sync-NAVApp -ServerInstance $ServerInstance -Name $AppToPublish.Name -Publisher $AppToPublish.Publisher -Version $AppToPublish.Version -WarningAction SilentlyContinue
    }

    #install / dataupgrad    
    $AppsToInstall = (Sort-NavAppListDependency -NavAppList ($AppsToReplace + $DependentList))   
    foreach ($AppToInstall in $AppsToInstall) {
        if ( $DependentList.Id -contains $AppToInstall.Id ) {
            write-host -ForegroundColor Green ("Reinstall '{0}' v{1} on {2}" -f $AppToInstall.Name, $AppToInstall.Version, $ServerInstance)
            Install-NAVApp -ServerInstance $ServerInstance -Name $AppToInstall.Name -Publisher $AppToInstall.Publisher -Version $AppToInstall.Version -WarningAction SilentlyContinue
        }
        else {
            if ( $AppsToReplace.Id -contains $AppToInstall.Id) {
                write-host -ForegroundColor Green ("NavDataUpgrade '{0}' v{1} on {2}" -f $AppToInstall.Name, $AppToInstall.Version, $ServerInstance)
                try { ## you dont know if the version was installed before or not ; if they was installed before you need to installed otherwise dataupgrade
                    Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Name $AppToInstall.Name -Publisher $AppToInstall.Publisher -Version $AppToInstall.Version -WarningAction SilentlyContinue
                }
                catch {
                    Install-NAVApp -ServerInstance $ServerInstance -Name $AppToInstall.Name -Publisher $AppToInstall.Publisher -Version $AppToInstall.Version -WarningAction SilentlyContinue
                }
            }
            else {
                write-host -ForegroundColor Green ("Install '{0}' v{1} on {2}" -f $AppToInstall.Name, $AppToInstall.Version, $ServerInstance)
                Install-NAVApp -ServerInstance $ServerInstance -Name $AppToInstall.Name -Publisher $AppToInstall.Publisher -Version $AppToInstall.Version -WarningAction SilentlyContinue
            }
        }
    }
    
    # unpublish old versions
    foreach ($AppToUnpublish in $AppsToReplace) {
        Get-NAVAppInfo -ServerInstance $ServerInstance -Name $AppToUnpublish.Name |  ForEach-Object {
            if (-not($AppToUnpublish.Version -eq $_.Version)) {
                write-host ("Unpublish '{0}' v{1} from {2}" -f $_.Name, $_.Version, $ServerInstance)
                Unpublish-NAVApp -ServerInstance $ServerInstance -Name $_.Name -Publisher $_.Publisher -Version $_.Version -WarningAction SilentlyContinue
            }
        }
    }
}

Export-ModuleMember -Function 'Publish-NavAppsLocal'