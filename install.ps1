param(
    [string]$LogDir,
    [string]$CacheDir
)

if (-not $LogDir) {
    $LogDir = "$PSScriptRoot\logs"
}
$global:LOG_DIR = $LogDir
if (-not $CacheDir) {
    $CacheDir = "$PSScriptRoot\cache"
}
$global:TEMP_DIR = 'c:\tmp'

. $PSScriptRoot\scripts\Debloat.ps1
. $PSScriptRoot\scripts\install-chocolatey.ps1
. $PSScriptRoot\scripts\Install-WingetApps.ps1 -JsonPath "$PSScriptRoot\cfg\winget-apps.json"
. $PSScriptRoot\scripts\Install-vscode.ps1
. $PSScriptRoot\scripts\install-o365.ps1
. $PSScriptRoot\helpers\FileHelpers.ps1
ShowHiddenFiles
ShowFileExtensions