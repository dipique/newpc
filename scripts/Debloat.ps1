# to get existing apps (for updating the config)
#   ipmo Appx -UseWindowsPowershell
#   Get-AppxPackage | Format-Table -Property @{n='Name';e={$_.Name}}, @{n='Version';e={$_.Version}}, @{n='Publisher';e={$_.Publisher}}

# to find winget stuff containing 'web': winget list | ? { $_ -match 'web' }

# Load bloat apps from JSON configuration
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configPath = Join-Path (Split-Path -Parent $scriptPath) "cfg\debloat.json"

if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    $bloat_apps = 
} else {
    Write-Warning "Configuration file not found: $configPath"
    exit 1
}

# can't use pipeline because it causes concurrrent pipeline issues with Remove-AppxPackage
ipmo Appx -UseWindowsPowershell
foreach ($appName in $config.apps) {
    $pkg = Get-AppxPackage -Name $appName -ErrorAction SilentlyContinue
    Write-Host "Removing $appName..."
    if ($pkg) {        
        $pkg | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
}

exit 0