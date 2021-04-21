# To Deploy NAV extensions
. (Join-Path $PSScriptRoot "private/Get-AzureStorage.ps1")
. (Join-Path $PSScriptRoot "public/Get-AppINFOMain.ps1")
. (Join-Path $PSScriptRoot "public/Download-DependentApps.ps1")
. (Join-Path $PSScriptRoot "public/Get-DependentApp.ps1")
. (Join-Path $PSScriptRoot "public/Get-InstalledApp.ps1")
. (Join-Path $PSScriptRoot "public/Compile-NAVApp.ps1")
. (Join-Path $PSScriptRoot "public/Get-NAVSymbols.ps1")
. (Join-Path $PSScriptRoot "public/Install-NAVApp.ps1")

# To Build NAV DEV Environment
. (Join-Path $PSScriptRoot "public/Build-NAVDEVEnv.ps1")
. (Join-Path $PSScriptRoot "public/Create-DBContainer.ps1")
. (Join-Path $PSScriptRoot "public/Create-Database.ps1")
