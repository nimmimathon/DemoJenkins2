function  Install-AllNAVApp {
    Param  (
        [Parameter(Mandatory=$false)][String]$ContainerName,
        [Parameter(Mandatory=$true)][String]$ServerInstance,
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Location  
    ) 
    $AppFileList = @()
    $StoragePath = (Get-ChildItem (Get-StoragePath -Environment $Environment -Location $Location))
    foreach($AppFolder in $StoragePath) {
        $LatestVersion = (Get-LatestNavAppVersionFromStorage -Environment $Environment -Location $Location -Name $AppFolder.Name)
        $LatestVersionPath = Get-NavAppStoragePath -Environment $Environment -Location $Location -Name $AppFolder.Name -Version $LatestVersion 
        $AppFileList += (Get-ChildItem $LatestVersionPath -Filter *.app).Fullname
    }
    
    Publish-NavApps -ContainerName $ContainerName -ServerInstance $ServerInstance -AppsFilePath $AppFileList
}

Export-ModuleMember -Function 'Install-AllNAVApp'
