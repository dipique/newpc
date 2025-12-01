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

function Is-RunningAsAdmin() {
    # Get current user context
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    
    # Check user is running the script is member of Administrator Group
    $CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# if not running as admin, re-launch the script with admin rights
function Check-RunAsAdministrator() {
    if(Is-RunningAsAdmin) {
         Write-host "Script is running with admin privileges"
    } else {
        Escalate
    }
}

# Escalate the script to run as Administrator
function Escalate() {
    if ($PSversionTable.PSVersion.Major -eq 5) {
        EscalateLegacy
    } else {
        EscalateStandard
    }
}

# Escalate the script to run as Administrator (PowerShell 7+)
function EscalateStandard() {
    Start-Process pwsh –Verb RunAs –ArgumentList '-c', $script:MyInvocation.MyCommand.Path
    Exit
}

# Escalate the script to run as Administrator (PowerShell 5)
function EscalateLegacy() {
    # Create a new elevated process powershell process
    $adminProc = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
    $adminProc.Verb = 'runas'

    # specify the current script path and name as a parameter
    $adminProc.Arguments = "& '$($script:MyInvocation.MyCommand.Path)'"

    # start new elevated process and exit from the current one
    [System.Diagnostics.Process]::Start($adminProc)
    Exit
}

function Run-RemoteScript {
    param(        
        [Parameter(Mandatory = $false)]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Script,

        [Parameter(Mandatory = $false)]
        [string]$ArgumentList = @()
    )
    
    if ($ComputerName -eq $env:COMPUTERNAME) {
        & $Script -ArgumentList $ArgumentList
    } else {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $Script -ArgumentList $ArgumentList
    }
}