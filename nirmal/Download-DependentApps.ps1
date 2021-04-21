function Download-DependentApps($ver, $env, $tkes) {
    process {    
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force  
        $Environment = "$env"
        $Name = "$ver"
        [string]$Dest = "$tkes"
        $Storagepath = Join-Path -Path (Get-AzureStorage) -ChildPath "$Environment\$Name\"
        If([string]::IsNullOrEmpty($Version))
        {  
            $VersionList = Get-ChildItem $Storagepath -Directory | Select Name
            $Sorted = $VersionList | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) }
            $Version = ($Sorted | select -Last 1 | ft -hidetableheaders | Out-String).trim()
            $SrcFinal = "$Storagepath"+"$Version"
            mkdir -Path $Dest -Name $Name -WarningAction SilentlyContinue | out-null
            $DDestFinal = $Dest+'\'+$Name
            Copy-item -Path $SrcFinal -Destination "$DDestFinal\" -Recurse -Force
        }
        Write-Host "Successfully Downloaded dependent App $Name"
        $ConfigPath1 = "${SrcFinal}\app.json"
        $Configdep += Get-Content -Raw -Path $ConfigPath1 -ErrorAction Stop | ConvertFrom-Json
        return $Configdep
    }
}
Export-ModuleMember -Function 'Download-DependentApps' 