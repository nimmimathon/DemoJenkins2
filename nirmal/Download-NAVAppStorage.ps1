function Download-NAVAppStorage {
    param(
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$false)][String]$Version,   
        [Parameter(Mandatory=$true)][string]$Destination
    )  
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
        $Storagepath = Join-Path -Path (Get-AzureStorage) -ChildPath "$Environment\$Name\"
        If([string]::IsNullOrEmpty($Version))
        {  
            $VersionList = Get-ChildItem $Storagepath -Directory | Select Name
            $Sorted = $VersionList | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) }
            $Version = ($Sorted | select -Last 1 | ft -hidetableheaders | Out-String).trim()
        }
        Copy-item -Path "$Storagepath\$Version" –Destination $Destination -Recurse -Force
    }
}
Export-ModuleMember -Function 'Download-NAVAppStorage'