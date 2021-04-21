function Get-LatestNavAppVersionFromStorage {
    param(
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Location,
        [Parameter(Mandatory=$true)][String]$Name
    )  
    process {
        $Storagepath = Get-NavAppStoragePath -Environment $Environment -Location $Location -Name $Name
        $VersionList = Get-ChildItem $Storagepath -Directory | Select-Object Name
        $Sorted = $VersionList | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) }
        $Version = ($Sorted | Select-Object -Last 1 | Format-Table -hidetableheaders | Out-String).trim()
        return $Version
    }
}
Export-ModuleMember -Function 'Get-LatestNavAppVersionFromStorage'