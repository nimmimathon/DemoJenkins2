function Start-NAVDEVEnv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$NAVContainerName,
        [Parameter(Mandatory = $false)][String]$DBContainerName
    )
    process {
        if([string]::IsNullOrEmpty($DBContainerName)) {
            $DBContainerName = "${NAVContainerName}DB"
        }
        
        write-host("Start container '{0}' if not started" -f $DBContainerName)
        (docker start $DBContainerName) | Out-Null
        Wait-DockerContainerHealthy -ContainerName $DBContainerName
        write-host("Start container '{0}' if not started" -f $NAVContainerName)
        (docker start $NAVContainerName) | Out-Null
        Wait-DockerContainerHealthy -ContainerName $NAVContainerName
    }
}

Export-ModuleMember -Function 'Start-NAVDEVEnv'
