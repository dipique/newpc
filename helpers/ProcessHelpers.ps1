# Check if a process is currently running
function ProcessRunning {
    param (
        [string]$processName
    )
    $processCheck = Get-Process -Name $processName -ErrorAction SilentlyContinue
    return $null -ne $processCheck
}