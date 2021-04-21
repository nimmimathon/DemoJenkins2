function Create-DBContainer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][String]$DBContainerName,
        [Parameter(Mandatory = $false)][String]$DBContainerImage,
        [Parameter(Mandatory = $false)][String]$LocalBackupPath,
        [Parameter(Mandatory = $false)][String]$DockerBackupPath,
        [Parameter(Mandatory = $false)][String]$OverwriteExisting,        
        [Parameter(Mandatory = $false)][String]$SAPassword
    )
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
        $ErrorActionPreference = "stop"
        try {         
            $ServerId = docker ps -aqf "name=$DBContainerName"
            if ( ($null -eq $ServerId) -or $OverwriteExisting ) {
                if (($LocalBackupPath -eq '') -or -not (Test-Path -Path $LocalBackupPath) ) {
                    throw 'Cannot find local backuppath'
                }
                if (-not $ServerId -eq '' ) {
                    docker rm "$ContainerName" -f  | Out-Null 
                }
                $DockerContainer = docker run --storage-opt size=120G --name $DBContainerName --hostname $DBContainerName --restart unless-stopped `
                    -d -e sa_password="$SAPassword" `
                    -e ACCEPT_EULA=Y `
                    -v "${LocalBackupPath}:${DockerBackupPath}" `
                    $DBContainerImage
                # -P `
                $ServerId = $DockerContainer.SubString(0, 12)
                return @($ServerId);
            }      
        }
        catch {
            throw $_
        }
    }
}
Export-ModuleMember -Function 'Create-DBContainer'