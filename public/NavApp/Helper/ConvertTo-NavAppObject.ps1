function ConvertTo-NavAppObject {
    Param (
        [Parameter(Mandatory=$true)]$NavAppInfo
    )
    process {
        $AppObject = New-Object -TypeName PSObject
        $AppObject | Add-Member -Name Id -MemberType NoteProperty -Value $NavAppInfo.AppId
        $AppObject | Add-Member -Name Name -MemberType NoteProperty -Value $NavAppInfo.Name
        $AppObject | Add-Member -Name Publisher -MemberType NoteProperty -Value $NavAppInfo.Publisher
        $AppObject | Add-Member -Name Version -MemberType NoteProperty -Value $NavAppInfo.Version
        
        $Dependencies = @()
        foreach ($Dependency in $NavAppInfo.dependencies) {
            $DependencyObject = New-Object -TypeName PSObject
            $DependencyObject | Add-Member -Name Id -MemberType NoteProperty -Value $Dependency.AppId
            $DependencyObject | Add-Member -Name MinVersion -MemberType NoteProperty -Value $Dependency.MinVersion
            $Dependencies += $DependencyObject
        }
        $AppObject | Add-Member -Name Dependencies -MemberType NoteProperty -Value $Dependencies
        
        return $AppObject
    }
}

Export-ModuleMember -Function 'ConvertTo-NavAppObject'