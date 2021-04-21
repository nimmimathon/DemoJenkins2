function Get-StoragePath {
    param(
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Location
    )  
    process {
        return Join-Path -Path (Get-AzureStorage) -ChildPath "$Environment\$Location\"
    }
}
Export-ModuleMember -Function 'Get-StoragePath'
