# Check if running as Administrator and exit if not
function Require-Administrator {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script must be run as Administrator. Please run PowerShell as Administrator and try again."
        exit 1
    }
}

# Helper function to run commands in Windows PowerShell
function Invoke-WinPS {
    param([string]$Command)
    $ErrorActionPreference = "Stop"
    powershell.exe -NoProfile -NonInteractive -Command "& { $Command }"
}

function Invoke-WebWinPS {
    param([string]$Command)
    $ErrorActionPreference = "Stop"
    Invoke-WinPS -NoProfile -NonInteractive -Command "Import-Module WebAdministration; $Command"
}