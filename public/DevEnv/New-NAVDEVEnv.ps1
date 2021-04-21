function New-NAVDEVEnv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$PSLibaryPath,
        [Parameter(Mandatory = $true)][String]$NAVContainerName,
        [Parameter(Mandatory = $false)][String]$NAVVersion = '2018:18-w1',                
        [Parameter(Mandatory = $false)][String]$LicenseFilePath,

        [Parameter(Mandatory = $true)][PSCredential]$Credential,
        [Parameter(Mandatory = $false)][String]$DBContainerName,
        [Parameter(Mandatory = $false)][String]$DatabaseName = 'nav',
        [Parameter(Mandatory = $false)][String]$DBSAPassword = 'MySuperSecurePassword1!',
        [Parameter(Mandatory = $false)][String]$DBBackupFilePath,
        [Parameter(Mandatory = $false)][switch]$OverwriteExistingDB        
    )
    process {
        if (-not (Get-Module -ListAvailable -Name BcContainerHelper)) {
            Install-Module -Name BcContainerHelper -AllowClobber -Force
        } 
        Import-Module -Name BcContainerHelper -WarningAction SilentlyContinue | out-null
        
        
        if([string]::IsNullOrEmpty($DBBackupFilePath)) {
            if ( Test-Path -Path $DBBackupFilePath) {
                throw "Backupfile doesnt exist"
            }
        }
        
        if([string]::IsNullOrEmpty($DBContainerName)) {
            $DBContainerName = "${NAVContainerName}DB"
        }
        
        $ContainerBackupPath = 'C:\Backup'
        $LocalBackupPath = Split-Path -Path $DBBackupFilePath
        $BackupFileName = Split-Path -Path $DBBackupFilePath -Leaf -Resolve
        
        write-host ("create Database container {0} if not exist" -f $DBContainerName)
        $DBContainerId = New-DBContainerIfNotExist -ContainerName $DBContainerName -LocalBackupPath $LocalBackupPath -ContainerBackupPath $ContainerBackupPath -SAPassword $DBSAPassword
        $DBServer = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DBContainerId
        write-host ("Database container {0} - IP: {1}" -f $DBContainerName, $DBServer)
        Wait-DockerContainerHealthy -ContainerName $DBContainerName
        write-host ("{0} is ready" -f $DBContainerName)
        
        write-host ("create new DB User")
        New-DatabaseUserIfNotExist -DatabaseServer $DBServer -SACredential (New-Object pscredential 'sa', (ConvertTo-SecureString -String $DBSAPassword -AsPlainText -Force)) -NewUserCredential $Credential
        
        if(-not ([string]::IsNullOrEmpty($DBBackupFilePath))) {
            write-host ("Start to restore {0}" -f $BackupFileName)
            Restore-DBBackup -Server $DBServer -ServerBackupFilePath (Join-Path -Path $ContainerBackupPath -Child $BackupFileName) -Credential $Credential
            write-host ("Backup restored {0}" -f $BackupFileName)
        }

        #NAV Version Format: 2018:18-w1
        $SplitHelper = $NAVVersion.Split(':')
        $NAVVersion = $SplitHelper.Get(0)
        $SplitHelper = $SplitHelper.Get(1).Split('-')
        $NavArtifactUrl = Get-NavArtifactUrl -nav $NAVVersion -cu $SplitHelper.Get(0) -country $SplitHelper.Get(1)

        $additionalParameters = @()
        $additionalParameters += ("-v $PSLibaryPath:c:\PSLibary")

        New-BcContainer `
                -accept_eula `
                -containerName $NAVContainerName `
                -artifactUrl $NavArtifactUrl `
                -auth UserPassword `
                -Credential $Credential `
                -includeCSide `
                -memoryLimit 4G `
                -doNotExportObjectsToText `
                -updateHosts  `
                -additionalParameters $additionalParameters `
                -databaseServer $DBContainerName `
                -databaseName $DatabaseName `
                -databaseCredential $Credential


        if(-not [string]::IsNullOrEmpty($LicenseFilePath)) {
            Import-BcContainerLicense -containerName $NAVContainerName -licenseFile $LicenseFilePath
        }
        New-NavContainerNavUser -containerName $NAVContainerName -Credential $Credential -ChangePasswordAtNextLogOn $false
    }
}
Export-ModuleMember -Function 'New-NAVDEVEnv'
