function Get-NavAppStoragePath {
    param(
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Location,
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$false)][String]$Version
    )  
    process {
        $Storagepath = Join-Path -Path (Get-StoragePath -Environment $Environment -Location $Location) -ChildPath "$Name\"
        If(-not [string]::IsNullOrEmpty($Version)) {
            $Storagepath = Join-Path -Path $Storagepath -ChildPath "$Version\"
        }
        return $Storagepath
    }
}
Export-ModuleMember -Function 'Get-NavAppStoragePath'
    