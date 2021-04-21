function Get-NAVSymbols {
    param (
        [Parameter(Mandatory=$true)][String]$AppPublisher ,
        [Parameter(Mandatory=$true)][String]$AppName,
        [Parameter(Mandatory=$true)][String]$AppVersion,
        [Parameter(Mandatory=$true)][String]$Server,
        [Parameter(Mandatory=$true)][String]$ServerInstance,
        [Parameter(Mandatory=$false)][Int]$DevPort,
        [Parameter(Mandatory=$false)][bool]$IsHttps,
        [Parameter(Mandatory=$false)][String]$UserName,
        [Parameter(Mandatory=$false)][securestring]$Password,
        [Parameter(Mandatory=$false)][String]$PackageCachePath
        #[Parameter(Mandatory=$false)][String]$PackageCachePath
    )
    process {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
    $newpass = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $newpass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($newpass)
    $URL = "${Server}:${DevPort}/${ServerInstance}/dev/packages?publisher=${AppPublisher}&appName=${AppName}&versionText=${AppVersion}"
    if ($IsHttps) { 
        $URL = "https://${URL}"
    }
    else {
        $URL = "http://${URL}"
    }

    $FileName = $AppPublisher + '_' + $AppName + '_' + $AppVersion + '.app'

    Write-Host "Sending request to ${URL}"

    if ($UserName -eq '') {
        Invoke-RestMethod -Method Get -Uri $URL -OutFile "${PackageCachePath}${FileName}" -UseDefaultCredential
    }
    else {    
        $pair = "${UserName}:${newpass1}"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $basicAuthValue = "Basic $base64"
        $headers = @{ Authorization = $basicAuthValue }
        Invoke-RestMethod -Method Get -Uri $URL -Headers $headers -OutFile "${PackageCachePath}${FileName}"
    }
}
}

Export-ModuleMember -Function 'Get-NAVSymbols'