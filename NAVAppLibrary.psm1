Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
$ErrorActionPreference = "stop"

# NAVAPP STORAGE
. (Join-Path $PSScriptRoot "private/Get-AzureStorage.ps1")

. (Join-Path $PSScriptRoot "public/NavApp/Storage/Upload-NavAppToStorage.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Storage/Download-NAVAppFromStorage.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Storage/Remove-NAVAppFromStorage.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Storage/Get-LatestNavAppVersionFromStorage.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Storage/Get-NavAppStorage.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Storage/Get-StoragePath.ps1")


# NAVAPP Handling
# private
. (Join-Path $PSScriptRoot "public/NavApp/Helper/Sort-NavAppListDependency.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Helper/ConvertTo-NavAppObject.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Helper/Get-DependentNavAppList.ps1")  
. (Join-Path $PSScriptRoot "public/NavApp/Local/Publish-NavAppsLocal.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Docker/Publish-NavAppsDocker.ps1")

# public
. (Join-Path $PSScriptRoot "public/NavApp/Publish-NavApps.ps1")
. (Join-Path $PSScriptRoot "public/NavApp/Install-AllNAVApp.ps1")


# DevEnv Handling
. (Join-Path $PSScriptRoot "public/DevEnv/New-NAVDevEnv.ps1")
. (Join-Path $PSScriptRoot "public/DevEnv/Stop-NAVDEVEnv.ps1")
. (Join-Path $PSScriptRoot "public/DevEnv/Remove-NAVDEVEnv.ps1")
. (Join-Path $PSScriptRoot "public/DevEnv/Start-NAVDEVEnv.ps1")

#Docker
. (Join-Path $PSScriptRoot "public/Docker/New-DBContainerIfNotExist.ps1")
. (Join-Path $PSScriptRoot "public/Docker/Wait-DockerContainerHealthy.ps1")


#Database
. (Join-Path $PSScriptRoot "public/Database/Restore-DBBackup.ps1")
. (Join-Path $PSScriptRoot "public/Database/New-DatabaseUserIfNotExist.ps1")
