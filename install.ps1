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

# remove winget web experience package (weather, news, etc.)
Install-Module -Name Microsoft.WinGet.Client
ipmo -Name Microsoft.WinGet.Client
Get-WinGetPackage | ? { $_.Id -match 'webexperience' } | Uninstall-WinGetPackage

# remove search bar
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force

# unpin certain apps from taskbar
$appNames = "Microsoft Store", "Outlook", "Microsoft Edge"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ? { $appNames -contains $_.Name }).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}