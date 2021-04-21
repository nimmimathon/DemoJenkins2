function  Wait-DockerContainerHealthy {
    Param  (
        [Parameter(Mandatory=$true)][String]$ContainerName,
        [Parameter(Mandatory=$false)][int]$Timeout = 1000
        
    ) 
    $TimemoutAt = (Get-Date) + ( New-TimeSpan -Seconds $Timeout)
    write-host ("Wait for container {0} to be ready. Timeout in {1} seconds" -f $ContainerName, $Timeout)

    do {
        if ($TimemoutAt -le (Get-Date)) {
            throw "TIMEOUT. Container is not ready"
        }
        Start-Sleep -Seconds 1
    } while (-not ( ( docker inspect -f '{{.State.Health.Status}}' $ContainerName ) -eq "healthy" ))

}

Export-ModuleMember -Function 'Wait-DockerContainerHealthy'
