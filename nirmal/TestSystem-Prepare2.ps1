function TestSystem-Prepare2 {
    param (
        [Parameter(Mandatory=$false)][String]$Server = 'localhost',
        [Parameter(Mandatory=$true)][String]$Database
    )

    Write-Host "Entered Cleanup function"
    [string] $UserSqlQuery= $("SELECT [Name] FROM [dbo].[Company]")
    
    # declaration not necessary, but good practice
    $resultsDataTable = New-Object System.Data.DataTable
    $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
    foreach ($Company in $resultsDataTable) {
        Write-Host "Testsystem Prepare2 - " + $Company.Name
        $Company.Name = $Company.Name -replace "\.", "_" 
        # Add Prepare Functions
        TestSystem-Prepare2-Customer $Server $Database $Company.Name
        TestSystem-Prepare2-SalesHeader $Server $Database $Company.Name
        TestSystem-Prepare2-SalesInvoiceHeader $Server $Database $Company.Name
        TestSystem-Prepare2-SalesCr_MemoHeader $Server $Database $Company.Name
        TestSystem-Prepare2-ReminderHeader $Server $Database $Company.Name
        TestSystem-Prepare2-IssuedReminderHeader $Server $Database $Company.Name
        TestSystem-Prepare2-PaymentPlanHeader $Server $Database $Company.Name
        TestSystem-Prepare2-PostedPay_PlanHeader $Server $Database $Company.Name
    }
}


# executes a query and populates the $datatable with the data
function ExecuteSqlQuery ($Server, $Database, $SQLQuery) {
    $Datatable = New-Object System.Data.DataTable
    
    $Connection = New-Object System.Data.SQLClient.SQLConnection
    $Connection.ConnectionString = "server='$Server';database='$Database';trusted_connection=true;"
    $Connection.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.CommandTimeout = 0;
    $Command.Connection = $Connection
    $Command.CommandText = $SQLQuery
    $Reader = $Command.ExecuteReader()
    $Datatable.Load($Reader)
    $Connection.Close()
    
    return $Datatable
}

function TestSystem-Prepare2-Customer ($Server, $Database, $Company) {
$TableToUpdate = '$Customer'
$RowToUpdate ='Name'
[string] $UserSqlQuery= "USE [$Database]
 DECLARE @Name NVARCHAR(50)
 DECLARE NameCursor CURSOR FOR 
 SELECT [$RowToUpdate] FROM [dbo].[$Company$TableToUpdate]
 OPEN NameCursor
 FETCH NEXT FROM NameCursor INTO @Name
 WHILE(@@FETCH_STATUS = 0) 
 BEGIN
	update [dbo].[$Company$TableToUpdate] set [Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Search Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() )
	WHERE  CURRENT OF NameCursor
	FETCH NEXT FROM NameCursor INTO @Name
END
 CLOSE NameCursor
DEALLOCATE NameCursor"
$resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
return $resultsDataTable
}

function TestSystem-Prepare2-SalesHeader ($Server, $Database, $Company) {
 $TableToUpdate = '$Sales Header'
$RowToUpdate ='Bill-to Name'
[string] $UserSqlQuery= "USE [$Database]
 DECLARE @Name NVARCHAR(50)
 DECLARE NameCursor CURSOR FOR 
 SELECT [$RowToUpdate] FROM [dbo].[$Company$TableToUpdate]
 OPEN NameCursor
 FETCH NEXT FROM NameCursor INTO @Name
 WHILE(@@FETCH_STATUS = 0) 
 BEGIN
	update [dbo].[$Company$TableToUpdate] set [Bill-to Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Bill-to Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ),[Bill-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Customer Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Customer Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() )
	WHERE  CURRENT OF NameCursor
	FETCH NEXT FROM NameCursor INTO @Name
END
 CLOSE NameCursor
DEALLOCATE NameCursor"
    $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
    return $resultsDataTable
}
function TestSystem-Prepare2-SalesInvoiceHeader ($Server, $Database, $Company) {
 $TableToUpdate = '$Sales Invoice Header'
 $RowToUpdate ='Bill-to Name'
[string] $UserSqlQuery= "USE [$Database]
 DECLARE @Name NVARCHAR(50)
 DECLARE NameCursor CURSOR FOR 
 SELECT [$RowToUpdate] FROM [dbo].[$Company$TableToUpdate]
 OPEN NameCursor
 FETCH NEXT FROM NameCursor INTO @Name
 WHILE(@@FETCH_STATUS = 0) 
 BEGIN
	update [dbo].[$Company$TableToUpdate] set [Bill-to Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ),[Bill-to Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Bill-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Customer Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Customer Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() )
	WHERE  CURRENT OF NameCursor
	FETCH NEXT FROM NameCursor INTO @Name
END
 CLOSE NameCursor
DEALLOCATE NameCursor"
    $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
    return $resultsDataTable
}
function TestSystem-Prepare2-SalesCr_MemoHeader ($Server, $Database, $Company) {
 $TableToUpdate = '$Sales Cr_Memo Header'
 $RowToUpdate ='Bill-to Name'
[string] $UserSqlQuery= "USE [$Database]
 DECLARE @Name NVARCHAR(50)
 DECLARE NameCursor CURSOR FOR 
 SELECT [$RowToUpdate] FROM [dbo].[$Company$TableToUpdate]
 OPEN NameCursor
 FETCH NEXT FROM NameCursor INTO @Name
 WHILE(@@FETCH_STATUS = 0) 
 BEGIN
	update [dbo].[$Company$TableToUpdate] set [Bill-to Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Bill-to Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Bill-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Ship-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Customer Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Customer Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Sell-to Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() )
	WHERE  CURRENT OF NameCursor
	FETCH NEXT FROM NameCursor INTO @Name
END
 CLOSE NameCursor
DEALLOCATE NameCursor"
    $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
    return $resultsDataTable
}
function TestSystem-Prepare2-ReminderHeader ($Server, $Database, $Company) {
    $TableToUpdate = '$Reminder Header'
 $RowToUpdate ='Name'
[string] $UserSqlQuery= "USE [$Database]
 DECLARE @Name NVARCHAR(50)
 DECLARE NameCursor CURSOR FOR 
 SELECT [$RowToUpdate] FROM [dbo].[$Company$TableToUpdate]
 OPEN NameCursor
 FETCH NEXT FROM NameCursor INTO @Name
 WHILE(@@FETCH_STATUS = 0) 
 BEGIN
	update [dbo].[$Company$TableToUpdate] set [Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() )
	WHERE  CURRENT OF NameCursor
	FETCH NEXT FROM NameCursor INTO @Name
END
 CLOSE NameCursor
DEALLOCATE NameCursor"
    $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
    return $resultsDataTable
}

function TestSystem-Prepare2-IssuedReminderHeader ($Server, $Database, $Company) {
     $TableToUpdate = '$Issued Reminder Header'
 $RowToUpdate ='Name'
[string] $UserSqlQuery= "USE [$Database]
 DECLARE @Name NVARCHAR(50)
 DECLARE NameCursor CURSOR FOR 
 SELECT [$RowToUpdate] FROM [dbo].[$Company$TableToUpdate]
 OPEN NameCursor
 FETCH NEXT FROM NameCursor INTO @Name
 WHILE(@@FETCH_STATUS = 0) 
 BEGIN
	update [dbo].[$Company$TableToUpdate] set [Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() )
	WHERE  CURRENT OF NameCursor
	FETCH NEXT FROM NameCursor INTO @Name
END
 CLOSE NameCursor
DEALLOCATE NameCursor"
    $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
    return $resultsDataTable
}

function TestSystem-Prepare2-PaymentPlanHeader ($Server, $Database, $Company) {
 $TableToUpdate = '$AUD-PP Payment Plan Header'
 $RowToUpdate ='Name'
[string] $UserSqlQuery= "USE [$Database]
 DECLARE @Name NVARCHAR(50)
 DECLARE NameCursor CURSOR FOR 
 SELECT [$RowToUpdate] FROM [dbo].[$Company$TableToUpdate]
 OPEN NameCursor
 FETCH NEXT FROM NameCursor INTO @Name
 WHILE(@@FETCH_STATUS = 0) 
 BEGIN
	update [dbo].[$Company$TableToUpdate] set [Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() )
	WHERE  CURRENT OF NameCursor
	FETCH NEXT FROM NameCursor INTO @Name
END
 CLOSE NameCursor
DEALLOCATE NameCursor"
    $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
    return $resultsDataTable
}

function TestSystem-Prepare2-PostedPay_PlanHeader ($Server, $Database, $Company) {
   $TableToUpdate = '$AUD-PP Posted Pay_ Plan Header'
 $RowToUpdate ='Name'
[string] $UserSqlQuery= "USE [$Database]
 DECLARE @Name NVARCHAR(50)
 DECLARE NameCursor CURSOR FOR 
 SELECT [$RowToUpdate] FROM [dbo].[$Company$TableToUpdate]
 OPEN NameCursor
 FETCH NEXT FROM NameCursor INTO @Name
 WHILE(@@FETCH_STATUS = 0) 
 BEGIN
	update [dbo].[$Company$TableToUpdate] set [Name]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Name 2]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() ), [Contact]=(SELECT TOP 1 Name FROM dbo._RandomFirstName ORDER BY NEWID() )
	WHERE  CURRENT OF NameCursor
	FETCH NEXT FROM NameCursor INTO @Name
END
 CLOSE NameCursor
DEALLOCATE NameCursor"
    $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 
    return $resultsDataTable
}

Export-ModuleMember -Function 'TestSystem-Prepare2'

