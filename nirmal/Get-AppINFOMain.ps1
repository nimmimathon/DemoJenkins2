function Get-AppINFOMain {
    param(
        [Parameter(Mandatory=$true)][string]$RepositoryURL,
        [Parameter(Mandatory=$true)][securestring]$Password
    )  
    process {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
        $ErrorActionPreference="SilentlyContinue" 
        Stop-Transcript | out-null
        $ErrorActionPreference = "Continue"
        Start-Transcript -path C:\output.txt -append
        $Environment = 'testing2'
        $LocalPath = 'C:\tmp'
        $Server ='testcont11'
        $ServerInstance ='Nav'
        $DevPort ='7049'
        [bool]$IsHttps = $false
        $UserName = 'admin'
        $ALCompilerPath = 'C:\tmp\alc\extension\bin\'
        $OldLocation
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
$getNameVersion = @()
$finalNversion = @()
$Installedones = @()
$repofolder = 'GITCloned'
mkdir -Path "$LocalPath" -Name $repofolder -Force -WarningAction SilentlyContinue | out-null
Write-Host "successfully cloned repository $RepositoryURL"
$path = "$LocalPath"+'\'+"$repofolder"+'\'
Set-Location -Path $path
git clone $RepositoryURL --quiet 
$hrepopath = (Get-ChildItem "$path" | Select-Object FullName | ft -hidetableheaders | Out-String).trim()
$OldLocation = $hrepopath
$ConfigPath = "${hrepopath}\app.json"
$AppConfig = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$Name = $AppConfig.Name
$AppVersion = $AppConfig.version
Write-Host "To install $Name application with $AppVersion version"
            $appname = ,@("$Name","$False")
            [bool] $Check = $False
            while ($Check -eq $False)
            {
                for($j=0; $j -lt $appname.Length; $j++)
                {
                    if($appname[$j][1] -eq "$False")
                    {
                        $k = $appname[$j][0]
                        $appname[$j][1] = "$true"
                        [array]$newarray = Get-DependentApp $k $Environment
                        if($k -ne $Name)
                        {
                        $getNameVersion += Download-DependentApps $k $Environment $LocalPath
                        }
                        [array]$toiterate = $appname
                        for($i=0; $i -lt $newarray.Length; $i++)
                        {
                            for($k=0; $k -lt $toiterate.Length; $K++)
                            {
                             if ($newarray[$i] -eq $toiterate[$k][0])
                                {break}  
                                else
                                { 
                                    if ($newarray[$i] -ne $toiterate[$k][0] -and $k -eq $toiterate.Length-1)
                                    {
                                        $appname += ,@($newarray[$i],"$False")                        
                                    } 
                                }
                            }
                        }
                    }
                }
                for($z=0; $z -lt $appname.Length; $z++)
                {
                    if ($appname[$z][1] -eq "$True")
                    {
                        $Check = $true   
                    }
                    else
                    {
                        $Check = $False
                    }
                }
            }
            foreach($q in $getNameVersion ){
                    $obj2 = New-Object System.Object
                    $obj2 | Add-Member -type NoteProperty -name  "Name" -value $q.name
                    $obj2 | Add-Member -type NoteProperty -name "Version" -value $q.version
                    $finalNversion += $obj2
                }
            [array]::Reverse($finalNversion)
            if($finalNversion.count -gt 0)
            {
            Install-NAVApp -Server $Server -LocalPath $LocalPath -Installedones $Installedones -finalNversion $finalNversion 
            } 
            else {
                Write-Host "no dependent apps to install"
            } 
            Compile-NAVApp -server $Server -ServerInstance $ServerInstance -UserName $UserName -Password $Password -ALCompilerPath $ALCompilerPath -OldLocation $OldLocation -DevPort $DevPort -IsHttps $IsHttps -LocalPath $LocalPath -Installedones $Installedones
            Stop-Transcript    
        }
        }  
        Export-ModuleMember -Function 'Get-AppINFOMain'  