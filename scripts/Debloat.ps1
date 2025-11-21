# to get existing apps (for updating the config)
#   ipmo Appx -UseWindowsPowershell
#   Get-AppxPackage | Format-Table -Property @{n='Name';e={$_.Name}}, @{n='Version';e={$_.Version}}


# Load bloat apps from JSON configuration
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configPath = Join-Path (Split-Path -Parent $scriptPath) "cfg\debloat.json"

if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    $bloat_apps = $config.apps
} else {
    Write-Warning "Configuration file not found: $configPath"
    exit 1
}

ipmo Appx -UseWindowsPowershell
$bloat_apps | % { Write-Host "Removing $_..."; Get-AppxPackage -name $_ } | ? { $_ } | Remove-AppxPackage

# foreach ($bloat_app in $bloat_apps) {
#     if ($bloat_app) {
#         Write-Host "Removing $bloat_app..."
#         $pkg = Get-AppxPackage -name $bloat_app
#         if ($pkg) {
#             $pkg | Remove-AppxPackage
#         }
#     }
# }

exit 0

