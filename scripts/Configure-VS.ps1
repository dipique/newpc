. $PSScriptRoot\..\helpers\WinCfgHelpers.ps1

$appName = 'Microsoft.VisualStudio.2026.Community' # winget name
$productId = 'Microsoft.VisualStudio.Product.Community'
$channelId = 'VisualStudio.18.Release'

# make sure VS is already installed
$listApp = winget list --exact -q $appName
if (![String]::Join('', $listApp).Contains($appName)) {
    Write-Host "Application $appName is not installed; skipping configuration step"
    exit 1
}

$vscfg = "$PSScriptRoot\install.vsconfig"
if (!(Test-Path $vscfg)) {
    Write-Host "Could not find VS configuration file '$vscfg'; please make sure it exists"
    exit 1
} else {
    Write-Host 'Found VS configuration file'
}
$vscfg = (Resolve-Path $vscfg).Path

Push-Location
Set-Location 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\'
if (!(Test-Path ./setup.exe)) {
    Write-Host "Could not find VS installer; skipping configuration step"
    exit 1
}
Write-Host 'Found Visual Studio, configuring...'
$logPath = Join-Path $LOG_DIR "visual_studio_install.log"
Write-Host "Logging to $logPath"
./setup.exe modify --installWhileDownloading --includeRecommended --productId $productId --channelId $channelId --config $vscfg --passive > $logPath | Out-Null # --passive means no interaction, --quiet means no ui displayed but it also seems like quiet makes it just not work
Pop-Location

# Add admin shortcut to desktop
$path = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -Property ProductPath
if (!$path) {
    Write-Host "Could not find Visual Studio installation; skipping shortcut step"
    exit 1
} {
    Write-Host "Found Visual Studio at: $path"
}
Create-Shortcut -tgt_path $path -description 'Visual Studio 2022 (Admin)' -launchAsAdmin $true