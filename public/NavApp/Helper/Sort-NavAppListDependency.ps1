function Sort-NavAppListDependency {
    param(
        [Parameter(Mandatory=$true)][array]$NavAppList
    )   
    $ClonedAppList = Get-ClonedObject $NavAppList
    foreach ($NavApp in $ClonedAppList) {
        $NavApp.Id = [String]$NavApp.Id
        foreach ($Dependency in $NavApp.Dependencies) {
            $Dependency.Id = [String]$Dependency.Id
        }
    }

    foreach($NavApp in $ClonedAppList) {
        $NavApp.dependencies = ($NavApp.Dependencies | Where-Object { $ClonedAppList.Id -contains $_.Id })
    }
    $ClonedAppList = Topology-Sorting $ClonedAppList

    $Sorted = @()
    foreach ($App in $ClonedAppList) {
        foreach ($OrgApp in $NavAppList) {
            if ([string]$App.Id -eq [string]$OrgApp.Id) {
                $Sorted += $OrgApp
            }
        }
    }
    return $Sorted
}


function Topology-Sorting {
    Param (
        [array]$AppList
    )
    process {
        $RemovedAppList = $AppList | Where-Object { $_.Dependencies.Count -eq 0 }
        $AppList = @($AppList | Where-Object { $RemovedAppList -notcontains $_ })
        $SortedList = New-Object System.Collections.ArrayList
        foreach ($RemovedApp in $RemovedAppList) {
            $null = $SortedList.Add($RemovedApp)
            for ($i = 0; $i -lt $AppList.length; $i++) {
                $AppList[$i].Dependencies = @($AppList[$i].Dependencies | Where-Object { $RemovedApp.Id -notcontains $_.Id })
            }
        }
        if ($AppList.Count -gt 0) {
            if ($RemovedAppList.Count -eq 0) {
                $AppList
                throw 'dependencies error'
            }
            Topology-Sorting -AppList $AppList | ForEach-Object {
                $null = $SortedList.Add($_)
            }
        }
        return $SortedList
    }
}


function Get-ClonedObject {
    param($DeepCopyObject)
    $ObjDeepCopy = [Management.Automation.PSSerializer]::DeSerialize([Management.Automation.PSSerializer]::Serialize($DeepCopyObject))
    return $ObjDeepCopy
}


Export-ModuleMember -Function 'Sort-NavAppListDependency'   