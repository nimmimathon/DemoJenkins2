function Restore-DBBackup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$Server,
        [Parameter(Mandatory = $true)][String]$ServerBackupFilePath,
        [Parameter(Mandatory = $false)][String]$ServerDatabasePath = 'C:/Database',
        [Parameter(Mandatory = $true)][PSCredential]$Credential,
        [Parameter(Mandatory = $false)][String]$DBName = 'nav',
        [Parameter(Mandatory = $false)][switch]$OverwriteExisting
    )
    process {
        if (-not (Get-Module -ListAvailable -Name SqlServer)) {
            Install-Module -Name SqlServer -AllowClobber -Force
        } 
        Import-Module -Name SqlServer -WarningAction SilentlyContinue | out-null
        
        
        $user = $Credential.GetNetworkCredential().UserName
        $password = $Credential.GetNetworkCredential().password

        try {
            $ServerDatabasePath = Join-Path -Path $ServerDatabasePath -Child $DBName

            $folderCreationQuery = "USE [master];
                                    GO
                                    SET NOCOUNT ON

                                    -- 1 - Variable declaration
                                    DECLARE @DBName sysname
                                    DECLARE @FolderPath nvarchar(500)
                                    DECLARE @DirTree TABLE (subdirectory nvarchar(255), depth INT)

                                    -- 2 - Initialize variables
                                    SET @DBName = '$DBName'
                                    SET @FolderPath = '$ServerDatabasePath' 

                                    -- 3 - @DataPath values
                                    INSERT INTO @DirTree(subdirectory, depth)
                                    EXEC master.sys.xp_dirtree @FolderPath

                                    -- 4 - Create the @DataPath directory
                                    IF NOT EXISTS (SELECT 1 FROM @DirTree WHERE subdirectory = @DBName)
                                    EXEC master.dbo.xp_create_subdir @FolderPath

                                    -- 5 - Remove all records from @DirTree
                                    DELETE FROM @DirTree

                                    SET NOCOUNT OFF

                                    GO"
            Invoke-Sqlcmd -Query $folderCreationQuery -ServerInstance $Server -Username $user -Password $password 
            

            $mdfpath = Join-Path -Path $ServerDatabasePath -Child "${DBName}.mdf"
            $ldfpath = Join-Path -Path $ServerDatabasePath -Child "${DBName}.ldf"
            
            $fileListQuery = "USE [master]
                              RESTORE FILELISTONLY FROM DISK = N'$ServerBackupFilePath'
                              GO"
            $Filelist = Invoke-Sqlcmd -ServerInstance $Server -Query $fileListQuery -Username $user -Password $password
            $Data = $Filelist.LogicalName[0]
            $Log = $Filelist.LogicalName[1]

            $restoreQuery = "USE [master]
                            RESTORE DATABASE [$dbname] FROM  DISK = N'$ServerBackupFilePath' WITH FILE = 1, MOVE N'$Data' TO N'$mdfpath', MOVE N'$Log' TO N'$ldfpath',  NOUNLOAD,  STATS = 5
                            GO"
                            
            Invoke-Sqlcmd -Query $restoreQuery -ServerInstance $Server -Username $user -Password $password

        }
        catch {
            throw $_
        }
    }
}
Export-ModuleMember -Function 'Restore-DBBackup'
