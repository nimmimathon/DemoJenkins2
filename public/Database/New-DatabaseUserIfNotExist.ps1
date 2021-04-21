function New-DatabaseUserIfNotExist {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][String]$Server,
        [Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$SACredential,
        [Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$NewUserCredential
    )
    process {
        $NewUser = $NewUserCredential.GetNetworkCredential().UserName
        $NewUserPassword = $NewUserCredential.GetNetworkCredential().password

        $SAUser = $SACredential.GetNetworkCredential().UserName
        $SAPassword = $SACredential.GetNetworkCredential().password

        $res = Invoke-Sqlcmd -ServerInstance $Server -Credential $SACredential -Database tempdb -Query "select loginname from master.dbo.syslogins where name = '$NewUser'"
        if (-not $res) {
            Invoke-Sqlcmd -ServerInstance $Server -Username $SAUser -Password $SAPassword -Database tempdb -Query "create login $NewUser with password = '$NewUserPassword';"
            Invoke-Sqlcmd -ServerInstance $Server -Username $SAUser -Password $SAPassword -Database tempdb -Query "EXEC master..sp_addsrvrolemember @loginame = N'$NewUser', @rolename = N'sysadmin';"
        }
        else {
            write-host ("user {0} already exists" -f $NewUser)
        }
    }
}

Export-ModuleMember -Function 'New-DatabaseUserIfNotExist'