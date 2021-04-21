function Install-NAVApp {
    param(
        [Parameter(Mandatory=$true)][String]$Server,
        [Parameter(Mandatory=$true)][String]$LocalPath,
        [Parameter(Mandatory=$false)][array]$Installedones,
        [Parameter(Mandatory=$true)][array]$finalNversion
    )  
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
        #install-module navcontainerhelper -Scope CurrentUser -Force -SkipPublisherCheck -WarningAction SilentlyContinue  
        #import-module navcontainerhelper -Force -Scope Global -WarningAction SilentlyContinue 
        $match = 0
        $versionmatch = 0
        $count = 0
        $dependentarrayLength = $finalNversion.Count
        [bool] $counter = $false
        while ($counter -eq $false) {
           foreach($f in $finalNversion )
            {
                $Match = 0
                $versionmatch = 0
                $Installedones = Get-InstalledApp -Server $Server
                foreach($g in $Installedones ) 
                {
                    if ($f.name -eq $g.name -and $f.version -le $g.version) 
                    {
                        #echo "match found loop"
                        $Match = 1
                        $count++
                        if($count -eq $dependentarrayLength)
                        {
                            $counter = $true 
                        }
                        break
                    }
                    elseif ($f.Name -eq $g.name -and $f.version -gt $g.version)
                    {
                        $versionmatch = 1
                    }
                }
            if ($match -eq 0)
            {
                $localPath1 = $LocalPath+'\'+$f.Name+'\'+$f.version+'\'+'*.app'
                $k = Get-ChildItem -Path $localPath1
                $st = $k.FullName
                Publish-NavContainerApp -containerName $Server -appFile $st -skipVerification -ErrorAction Continue
                Sync-NavContainerApp -containerName $Server -appName $f.Name -appVersion $f.version -Force -ErrorAction Continue
                Install-NavContainerApp -containerName $Server -appName $f.Name -appVersion $f.version -Force -ErrorAction Continue
            }
            if($versionmatch -eq 1)
            {
                $localPath1 = $LocalPath+'\'+$f.Name+'\'+$f.version+'\'+'*.app'
                $k = Get-ChildItem -Path $localPath1
                $st = $k.FullName
                Publish-NavContainerApp -containerName $Server -appFile $st -skipVerification -ErrorAction Continue
                Sync-NavContainerApp -containerName $Server -appName $f.Name -appVersion $f.version -Force -ErrorAction Continue
                Start-NavContainerAppDataUpgrade -containerName $Server -appName $f.Name -appVersion $f.version
            }    
        }
    }
        Write-Host 'Apps installed successfully'
        #return $
    }
}
Export-ModuleMember -Function 'Install-NAVApp'