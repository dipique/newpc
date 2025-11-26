Write-Host 'Registering nuget'
. $PSScriptRoot\CheckRunAsAdministrator.ps1
$LOG_DIR = "c:\tmp\logs"
md $LOG_DIR -ErrorAction SilentlyContinue | Out-Null
$LASTEXITCODE = 0
Check-RunAsAdministrator
if ($LASTEXITCODE -gt 0) {
    write-host 'Failed to escalate privileges' -ForegroundColor Red
    exit $LASTEXITCODE
}
$logPath = Join-Path $LOG_DIR "register_nuget.log"
& $PSScriptRoot/RegisterNuget.ps1 > $logPath
& $PSScriptRoot/PSUpdateSetup.ps1

$MIN_WINDOWS10_RELEASE = 1809
$osVer = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentMajorVersionNumber
if ($osVer -eq 10) {
    $osRelease = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId
    if ($osRelease -lt $MIN_WINDOWS10_RELEASE) {
        Write-Host 'This script requires at least Windows 10 Release 1809 (October 2018)' -ForegroundColor Red
        Write-Host 'Please install the latest release of Windows 10' -ForegroundColor Red
        Write-Host 'https://www.microsoft.com/en-us/software-download/windows10' -ForegroundColor Red
        exit 1
    }
    Write-Host 'Windows 11 or compatible version of Windows 10 detected' -ForegroundColor Green
} else {
    Write-Host 'OS version seems fine, continuing' -ForegroundColor Red
}

Write-Host 'Checking for Windows updates...'

if ((Get-Module -ListAvailable PSWindowsUpdate).length -lt 1) {
    Install-Module -Name PSWindowsUpdate
}
$wuerr = Import-Module -Name PSWindowsUpdate 2>&1
if ($wuerr) {
    Write-Host 'Error installing windows update checker:'
    Write-Host $wuerr
    $wuCont = Read-Host 'Continue without updating Windows? Y/N'
    if (!$wuCont -or $wuCont.ToLower() -ne 'y') {
        Write-Host 'Aborting script' -ForegroundColor Red
        exit 1
    }
}
$updates = Get-WUList -NotTitle "Feature Update"
$updates # display formatted table
$pending_count = $updates.Count
if ($pending_count -gt 0) {
    Write-Host ''
    $result = $host.ui.PromptForChoice(        
        'There are ' + $pending_count + ' updates pending',
        'Do you want to install these updates (recommended)?',
        [string[]]('&Yes', '&No'),
        0 # default choice
    )
    if ($result -eq 1) {
        Write-Host 'Continuing without installing updates'
        exit 0
    }
} else {
    Write-Host 'No updates pending'
    exit 0
}

Write-Host 'Installing updates...'
$logPath = Join-Path $LOG_DIR "windows_updates.log"
Install-WindowsUpdate -NotTitle "Feature Update" -AcceptAll -AutoReboot > $logPath # install all pending updates (except feature updates)
Write-Host 'Updates installed'
