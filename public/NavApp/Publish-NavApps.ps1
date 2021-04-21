function  Publish-NavApps {
    Param  (
        [Parameter(Mandatory=$false)][String]$ContainerName,
        [Parameter(Mandatory=$true)][String]$ServerInstance,
        [Parameter(Mandatory=$true)][array]$AppsFilePath    
    ) 
    
    If([string]::IsNullOrEmpty($ContainerName)) {
        Publish-NavAppsLocal -ServerInstance $ServerInstance -AppsFilePath $AppsFilePath
    }
    else {
        Publish-NavAppsDocker -ContainerName $ContainerName -ServerInstance $ServerInstance -AppsFilePath $AppsFilePath
    }
}

Export-ModuleMember -Function 'Publish-NavApps'
