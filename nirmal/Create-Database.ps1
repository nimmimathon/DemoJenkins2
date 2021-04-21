function Create-Database {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][String]$DBContainerName,
        [Parameter(Mandatory = $false)][String]$ContainerImage,
        [Parameter(Mandatory = $false)][String]$DBBakFilepath,
        [Parameter(Mandatory = $false)][String]$mdfpath,
        [Parameter(Mandatory = $false)][String]$ldfpath,       
        [Parameter(Mandatory = $false)][String]$password,
        [Parameter(Mandatory = $false)][String]$dbname,
        [Parameter(Mandatory = $false)][switch]$OverwriteExisting
    )
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
        $ErrorActionPreference = "stop"
        #If SqlServer module is already installed, please comment below install and import commands
        Install-Module -Name SqlServer -AllowClobber -Force
        Import-Module -Name "SqlServer" -WarningAction SilentlyContinue | out-null
        try {
            Start-Sleep -Seconds 30 
            #$dbname = 'nav'
            $mdffilename = $dbname + '.mdf'
            $mdfpath1 = $mdfpath + '\' + $mdffilename
            $ldffilename = $dbname + '.ldf'
            $ldfpath1 = $ldfpath + '\' + $ldffilename  
            $ContainerId = (docker ps -aqf "name=$DBContainerName")
            $DockerContainerId = docker inspect -f '{{.Id}}' $ContainerId
            $SQLServerName = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $containerId
            $DBBakFilepath
            $qcd1 = "RESTORE FILELISTONLY FROM DISK = N'$DBBakFilepath'"
            $qcd1
            $p = Invoke-Sqlcmd -Query $qcd1
            $Data = $p.LogicalName[0]
            $Log = $p.LogicalName[1]
            $PSServerSession = New-PSSession -ContainerId $DockerContainerId
            $qcd = "USE [master]
        RESTORE DATABASE [$dbname] FROM  DISK = N'$DBBakFilepath' WITH  FILE = 1,  MOVE N'$Data' TO N'$mdfpath1',  MOVE N'$Log' TO N'$ldfpath1',  NOUNLOAD,  STATS = 5
        GO"
            Invoke-Sqlcmd -Query $qcd -ServerInstance $SQLServerName -Username 'sa' -Password $password

        }
        catch {
            throw $_
        }
    }
}
Export-ModuleMember -Function 'Create-Database'
