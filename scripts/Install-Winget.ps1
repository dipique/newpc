$installed = $false
try {
    $installed = (winget --version).startsWith('v')
} catch { } # prevent error message if not installed

if (!$installed) {
    $MyLink = "https://github.com/microsoft/winget-cli/releases/download/v1.3.431/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

    Write-Host "Winget is being downloaded"
    $file = Join-Path $TEMP_DIR winget-installer.msixbundle
    Invoke-WebRequest -Uri $MyLink -OutFile $file
    Write-Host "Winget installer downloaded, launching installer."
    & $file
    winget --version
} else {
    Write-Host 'Winget detected; skipping installation'
}