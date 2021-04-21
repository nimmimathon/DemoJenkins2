function Get-AzureStorage {
    param(
    )  
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
	    $AzureStr = '\\amsnavappconf.file.core.windows.net\navappfile\'
        return $AzureStr
    }
}
Export-ModuleMember -Function 'Get-AzureStorage'
    