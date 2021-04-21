function Remove-NAVAppFromStorage {
    param(
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Location,
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$false)][String]$Version
    )  
    process {
        If([string]::IsNullOrEmpty($Version)) {
            $Version = Get-LatestNavAppVersionFromStorage -Environment $Environment -Location $Location -Name $Name
        }
        $AppPath = Get-NavAppStoragePath -Environment $Environment -Location $Location -Name $Name -Version $Version
        
        Remove-Item -Path $AppPath -Recurse -Force
    }
}
Export-ModuleMember -Function 'Remove-NAVAppFromStorage'