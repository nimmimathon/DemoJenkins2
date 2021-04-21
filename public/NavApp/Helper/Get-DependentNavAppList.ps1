function Get-DependentNavAppList {
    Param  (
        [Parameter(Mandatory=$true)][String]$AppId,
        [Parameter(Mandatory=$false)][array]$AppList
    ) 
    $requiredAppList = @()   
    foreach ($PublishedApp in $AppList) {
        if (($PublishedApp.Dependencies) | Where-Object { $AppId -eq $_.Id }) {
            $requiredAppList += Get-DependentNavAppList -AppId $PublishedApp.Id -AppList $AppList
            $requiredAppList += $PublishedApp
        }
    }
    # $requiredAppList
    return $requiredAppList | Sort-Object Id | Get-Unique -AsString
}

Export-ModuleMember -Function 'Get-DependentNavAppList'