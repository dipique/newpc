try {
    choco > $null
    Write-Host 'Chocolatey already installed'
    exit 0
} catch {
    Write-Host 'Installing Chocolatey'
    $chocoPath = Resolve-Path $PSScriptRoot\..\external\install-chocolatey.ps1
    $logPath = Join-Path $LOG_DIR 'chocolatey_install.log'
    $LASTEXITCODE = (Start-Process -FilePath 'pwsh' -ArgumentList "-command `"& { $chocoPath > $logPath }`"" -PassThru -Wait).ExitCode
}