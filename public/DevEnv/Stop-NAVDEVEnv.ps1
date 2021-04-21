function Stop-NAVDEVEnv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$NAVContainerName,
        [Parameter(Mandatory = $false)][String]$DBContainerName
    )
    process {
        if([string]::IsNullOrEmpty($DBContainerName)) {
            $DBContainerName = "${NAVContainerName}DB"
        }
        
        write-host("Stop container {0} if running" -f $NAVContainerName)
        (docker stop $NAVContainerName) | Out-Null
        write-host("Stop container {0} if running" -f $DBContainerName)
        (docker stop $DBContainerName) | Out-Null
    }
}

Export-ModuleMember -Function 'Stop-NAVDEVEnv'
