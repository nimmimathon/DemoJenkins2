function Build-NAVDEVEnv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$NAVContainerName,
        [Parameter(Mandatory = $true)][String]$DBContainerImage,
        [Parameter(Mandatory = $true)][String]$LocalBackupPath,
        [Parameter(Mandatory = $true)][String]$DockerBackupPath,
        [Parameter(Mandatory = $false)][switch]$OverwriteExisting,
        [Parameter(Mandatory = $true)][String]$password,
        [Parameter(Mandatory = $true)][String]$DBContainerName,
        [Parameter(Mandatory = $true)][String]$databaseName,
        [Parameter(Mandatory = $true)][String]$licenseFilePath,
        [Parameter(Mandatory = $true)][String]$DBBakFilepath,
        [Parameter(Mandatory = $true)][String]$mdfpath,
        [Parameter(Mandatory = $true)][String]$ldfpath
    )
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
        $ErrorActionPreference = "stop"
        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        $credential = New-Object pscredential 'admin', $securePassword
        Create-DBContainer -DBContainerName $DBContainerName -DBContainerImage $DBContainerImage -LocalBackupPath $LocalBackupPath -DockerBackupPath $DockerBackupPath -SAPassword $password
        Write-host "DB Container Created Successfully"
        Create-Database -DBContainerName $DBContainerName -DBBakFilepath $DBBakFilepath -mdfpath $mdfpath -ldfpath $ldfpath -password $password -dbname $databaseName
        Write-host "DB Created Successfully"
        $artifactUrl = Get-NavArtifactUrl -nav 2018 -cu 18 na
        $auth = 'UserPassword'
        $DatabaseCredential = New-Object System.Management.Automation.PSCredential ("SA", (ConvertTo-SecureString $password -AsPlainText -Force))
        $databaseInstance = ''
        Write-host "started NAV container creation"
        #If BccontainerHelper module is already installed, please comment below install and import commands
        install-Module BcContainerHelper -Force -AllowClobber
        Import-Module BcContainerHelper -WarningAction SilentlyContinue | out-null
        New-BcContainer `
            -accept_eula `
            -TimeZoneId 'W. Europe Standard Time' `
            -auth UserPassword `
            -Credential $credential `
            -containerName $NAVContainerName `
            -artifactUrl $artifactUrl `
            -licenseFile $licenseFilePath `
            -includeCSide `
            -doNotExportObjectsToText `
            -updateHosts  `
            -databaseServer $DBContainerName `
            -databaseInstance $databaseInstance `
            -databaseName $databaseName `
            -databaseCredential $databaseCredential
        
        Start-Sleep -Seconds 30
        New-NavContainerNavUser -containerName $NAVContainerName -Credential $credential -ChangePasswordAtNextLogOn $false
    }
}
Export-ModuleMember -Function 'Build-NAVDEVEnv'
