function Add-NAVAppStorage {
    param(
        [Parameter(Mandatory=$true)][String]$Environment,
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$true)][String]$Version,
        [Parameter(Mandatory=$true)][array]$Source 
    )
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
        [string]$Destination = Join-Path -Path (Get-AzureStorage) -ChildPath "$Environment\$Name\$Version"
        if (!(Test-Path -path $Destination)) 
        {
            New-Item $Destination -Type Directory
        }
        Copy-item -Path $Source –Destination $Destination -Recurse -Force
    }
}

Export-ModuleMember -Function 'Add-NAVAppStorage'