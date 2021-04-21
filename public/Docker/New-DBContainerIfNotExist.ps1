function New-DBContainerIfNotExist {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$ContainerName,
        [Parameter(Mandatory = $false)][String]$ContainerImage = 'microsoft/mssql-server-windows-developer',
        [Parameter(Mandatory = $true)][String]$LocalBackupPath,
        [Parameter(Mandatory = $false)][STring]$ContainerBackupPath = 'c:\Backup',
        [Parameter(Mandatory = $false)][switch]$OverwriteExisting,        
        [Parameter(Mandatory = $true)][String]$SAPassword
    )
         
        $ServerId = docker ps -aqf "name=$ContainerName"
        if([string]::IsNullOrEmpty($ServerId) -or $OverwriteExisting) {
            if( -not (Test-Path -Path $LocalBackupPath) ) {
                throw 'Cannot find local backuppath'
            }
            
            if (-not [string]::IsNullOrEmpty($ServerId) ) {
                docker rm "$ContainerName" -f  | Out-Null 
            }

            $DockerContainer = docker run --storage-opt size=120G --name $ContainerName --hostname $ContainerName --restart unless-stopped `
                -d -e sa_password="$SAPassword" `
                -e ACCEPT_EULA=Y `
                -v "${LocalBackupPath}:${ContainerBackupPath}" `
                -p 1433:1433 `
                $ContainerImage

            $ServerId = $DockerContainer.SubString(0, 12)
        }      
        return $ServerId
}

Export-ModuleMember -Function 'New-DBContainerIfNotExist'