function Get-InstalledApp {
    param(
        [Parameter(Mandatory=$true)][String]$Server
    )  
    process {
$InstalledApps = Get-NavContainerAppInfo -tenant default -tenantSpecificProperties -containerName $Server | Where-Object IsInstalled -eq true | Select-Object Name, Version -InformationAction SilentlyContinue
$finalarray=@()
foreach($i in $InstalledApps ){
$versionvalue=$i.version.major.tostring()+'.'+$i.version.minor.tostring()+'.'+$i.version.Build.tostring()+'.'+$i.version.revision.tostring();
    $obj = New-Object System.Object
    $obj | Add-Member -type NoteProperty -name  "Name" -value $i.name
    $obj | Add-Member -type NoteProperty -name "Version" -value $versionvalue
    $finalarray += $obj
}
return $finalarray
    }
}
Export-ModuleMember -Function 'Get-InstalledApp'
