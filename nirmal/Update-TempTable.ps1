function Update-TempTable {
    param(
        [Parameter(Mandatory=$true)][string]$dbname,
        [Parameter(Mandatory=$true)][string]$TempTableName,
        [Parameter(Mandatory=$true)][string]$NameFilePath
    )  
    process {

$qcd = "USE [$dbname]
DECLARE @sql NVARCHAR(MAX)  
	Create table dbo.$TempTableName
(Name VARCHAR(10)
)
    SET @sql = N'BULK INSERT [dbo].[$TempTableName] FROM ''' +'$NameFilePath'
        + ''' WITH ( FIELDTERMINATOR ='','',ROWTERMINATOR = ''\n'',FIRSTROW = 1 )'
    SELECT  @sql
    EXEC sp_executesql @sql
GO"

Invoke-Sqlcmd -Query $qcd
}
}
Export-ModuleMember -Function 'Update-TempTable'