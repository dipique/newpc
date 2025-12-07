function Get-WinRebootState {
    Install-Module -Name PendingReboot
    Test-PendingReboot -Detailed
}