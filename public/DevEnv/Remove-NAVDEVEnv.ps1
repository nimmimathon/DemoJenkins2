function Remove-NAVDEVEnv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$NAVContainerName,
        [Parameter(Mandatory = $false)][String]$DBContainerName
    )
    process {
        if([string]::IsNullOrEmpty($DBContainerName)) {
            $DBContainerName = "${NAVContainerName}DB"
        }
        
        Stop-NAVDEVEnv -NAVContainerName $NAVContainerName -DBContainerName $DBContainerName
        
        write-host("Remove container '{0}' if exist" -f $NAVContainerName)
        Remove-BcContainer -containerName $NAVContainerName
        write-host("Remove container '{0}' if exist" -f $DBContainerName)
        (docker rm $DBContainerName) | out-null
    }
}

Export-ModuleMember -Function 'Remove-NAVDEVEnv'