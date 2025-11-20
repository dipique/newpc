function Is-RunningAsAdmin() {
    # Get current user context
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    
    # Check user is running the script is member of Administrator Group
    $CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Check-RunAsAdministrator() {
    if(Is-RunningAsAdmin) {
         Write-host "Script is running with admin privileges"
    } else {
        Escalate
    }
}

function Escalate() {
    if ($PSversionTable.PSVersion.Major -eq 5) {
        EscalateLegacy
    } else {
        EscalateStandard
    }
}

function EscalateStandard() {
    Start-Process pwsh –Verb RunAs –ArgumentList '-c', $script:MyInvocation.MyCommand.Path
    Exit
}

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