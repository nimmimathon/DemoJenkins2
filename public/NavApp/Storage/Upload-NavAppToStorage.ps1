function Upload-NavAppToStorage {
    param(
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Location,
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$true)][String]$Version,
        [Parameter(Mandatory=$true)][array]$Source 
    )
    process {
        [string]$AppPath = Get-NavAppStoragePath -Environment $Environment -Location $Location -Name $Name -Version $Version
        if (!(Test-Path -Path $AppPath))  {
            New-Item $AppPath -Type Directory | Out-Null
        }
        Copy-item -Path $Source -Destination $AppPath -Recurse -Force
    }
}

Export-ModuleMember -Function 'Upload-NavAppToStorage'