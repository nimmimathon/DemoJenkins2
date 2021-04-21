function Publish-NavAppsDocker {
    Param  (
        [Parameter(Mandatory=$true)][String]$ContainerName,
        [Parameter(Mandatory=$true)][String]$ServerInstance,
        [Parameter(Mandatory=$true)][array]$AppsFilePath
    ) 
    write-host ("Using 'Publish-NavAppsDocker'")
    $containerPath = 'c:\TmpApps'
    try {
        $AppsFilePathContainer = @()
        write-host ("Upload Apps into container {0}" -f $ContainerName)
        foreach ($AppFile in $AppsFilePath) {
            $containerFilePath = (Join-Path -Path $containerPath -ChildPath (Split-Path $AppFile -leaf))
            Copy-FileToBcContainer -containerName $ContainerName -localPath $AppFile -containerPath $containerFilePath | Out-Null   
            $AppsFilePathContainer += $containerFilePath
        }
        $AppsFilePathContainer
        Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
            Param($ServerInstance, $AppsFilePath)
            Import-Module 'C:\PSLibary\NAVAppLibrary.psm1' -Force
            Publish-NavAppsLocal -ServerInstance $ServerInstance -AppsFilePath $AppsFilePath
        } -ArgumentList ($ServerInstance, $AppsFilePathContainer)   
    }
    catch {
        throw $_
    }
    finally {
        Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
            param($AppPath)
            Remove-Item $AppPath -Recurse -Force
        } -ArgumentList ($containerPath)
    }
}

Export-ModuleMember -Function 'Publish-NavAppsDocker'
