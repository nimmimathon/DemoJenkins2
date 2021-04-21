function Get-DependentApp($apps, $env) { 
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
        $Environment = "$env"
        $Name = "$apps"
        $applicationsublist = @()
        $Storagepath = Join-Path -Path (Get-AzureStorage) -ChildPath "$Environment\$Name\"
        If([string]::IsNullOrEmpty($Version))
        {  
            $VersionList = Get-ChildItem $Storagepath -Directory | Select Name
            $Sorted = $VersionList | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) }
            $Version = ($Sorted | select -Last 1 | ft -hidetableheaders | Out-String).trim()
        }
        $FilePath = Join-Path -Path "$Storagepath" -ChildPath "$Version"
        $FinalFile = "$FilePath"+'\app.json'
        $Config = Get-Content -Raw -Path $FinalFile -ErrorAction Stop | ConvertFrom-Json
        for($i=0; $i -lt $Config.dependencies.Count; $i++)
        {
            $applicationsublist += $Config.dependencies[$i].Name
        }
        return $applicationsublist
    } 
}
Export-ModuleMember -Function 'Get-DependentApp'