function Compile-NAVApp {
    param(
        [Parameter(Mandatory=$true)][String]$Server,
        [Parameter(Mandatory=$true)][String]$ServerInstance,
        #[Parameter(Mandatory=$false)][String]$authentication = "Windows",
        [Parameter(Mandatory=$true)][String]$UserName,
        [Parameter(Mandatory=$true)][securestring]$Password,
        [Parameter(Mandatory=$true)][String]$ALCompilerPath,
        [Parameter(Mandatory=$false)][String]$DestinationPath,
        [Parameter(Mandatory=$false)][String]$PackageCachePath,
        [Parameter(Mandatory=$false)][String]$Path = './',
        [Parameter(Mandatory=$false)][String]$OldLocation,
        [Parameter(Mandatory=$False)][String]$DevPort,
        [Parameter(Mandatory=$False)][bool]$IsHttps,
        [Parameter(Mandatory=$False)][String]$LocalPath,
        [Parameter(Mandatory=$False)][array]$Installedones
    )  
    process {
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
$finalNversion2 = @()
$AppPath = $OldLocation + '\'
if ( $DestinationPath -eq '' ) {
    $DestinationPath = $AppPath
}
if ( $PackageCachePath -eq '' ) {
    $PackageCachePath = $AppPath + '.alpackages/'
}
New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
New-Item -ItemType Directory -Force -Path $PackageCachePath | Out-Null
$ConfigPath = "${AppPath}\app.json"
$DestinationPath2 = $DestinationPath+'.alpackages'+'\'
$DestinationPath2
    $AppConfig = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
    $DestinationFile = Join-Path $DestinationPath -Child ($AppConfig.publisher + '_' + $AppConfig.Name + '_' + $AppConfig.version + '.app')
    Get-NAVSymbols -AppPublisher Microsoft -AppName 'Application' -AppVersion $AppConfig.platform -Server $Server -ServerInstance $ServerInstance  -UserName $UserName -Password $Password -PackageCachePath $DestinationPath2 -DevPort $DevPort -IsHttps $IsHttps
    Get-NAVSymbols -AppPublisher Microsoft -AppName 'System' -AppVersion $AppConfig.application -Server $Server -ServerInstance $ServerInstance  -UserName $UserName -Password $Password -PackageCachePath $DestinationPath2 -DevPort $DevPort -IsHttps $IsHttps
    foreach ($Dependency in $AppConfig.dependencies) {
        Get-NAVSymbols -AppPublisher $Dependency.publisher -AppName $Dependency.name -AppVersion $Dependency.version -Server $Server -ServerInstance $ServerInstance  -UserName $username -Password $password -PackageCachePath $DestinationPath2 -DevPort $DevPort -IsHttps $IsHttps
    }
    $appnameforfinal = $AppConfig.Name
    $appversforfinal = $AppConfig.version
    Write-Host 'All reference symbols have been downloaded.'
    Set-Location -Path $ALCompilerPath
    $b = .\alc.exe "/project:${AppPath}" "/packagecachepath:${PackageCachePath}" "/out:${DestinationFile}"
    $b
    Set-Location -Path $OldLocation 
    if ($b -match 'error') {
        write-host -ForegroundColor Red 'alc.exe Compiler Error'
        write-host -ForegroundColor Blue $b
        throw
    }
    Write-Host 'App Compiled successfully'
    foreach($q in $AppConfig ){
        $obj2 = New-Object System.Object
        $obj2 | Add-Member -type NoteProperty -name  "Name" -value $q.name
        $obj2 | Add-Member -type NoteProperty -name "Version" -value $q.version
        $finalNversion2 += $obj2
    }
    $dirname = $finalNversion2.name
    $AppVersion = $finalNversion2.version
    mkdir -Path $LocalPath -Name $dirname -WarningAction SilentlyContinue | out-null
    $LocalPath2 = $LocalPath+'\'+$dirname+'\'
    mkdir -Path $LocalPath2 -Name $AppVersion -WarningAction SilentlyContinue | out-null
    $DestinationPath2 = $LocalPath+'\'+$dirname+'\'+$AppVersion+'\'
    Copy-item -Path $DestinationFile -Destination $DestinationPath2 -Recurse -Force
    Install-NAVApp -Server $Server -LocalPath $LocalPath -finalNversion $finalNversion2 -Installedones $Installedones
    Write-Host "$dirname App with $AppVersion version is successfully Installed"
 }
}
Export-ModuleMember -Function 'Compile-NAVApp'