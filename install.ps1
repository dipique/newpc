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

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Write-Host -f Yellow "Dark theme enabled.`n" # https://gist.github.com/bobby-tablez/4b5f1ee02c68a93dc8312c4ff858c0a7

# create 
git clone https://AISHealthcare@dev.azure.com/AISHealthcare/Lynx/_git/lynx