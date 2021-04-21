function Download-NAVAppFromStorage {
    param(
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Location,
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$false)][String]$Version,   
        [Parameter(Mandatory=$true)][string]$Destination
    )  
    process {
        If([string]::IsNullOrEmpty($Version)) {
            $Version = Get-LatestNavAppVersionFromStorage -Environment $Environment -Location $Location -Name $Name
        }

        $AppPath = Get-NavAppStoragePath -Environment $Environment -Location $Location -Name $Name -Version $Version
        if (!(Test-Path -Path $Destination))  {
            New-Item $Destination -Type Directory | Out-Null
        }
        Copy-item -Path $AppPath –Destination $Destination -Recurse -Force
    }
}
Export-ModuleMember -Function 'Download-NAVAppFromStorage'