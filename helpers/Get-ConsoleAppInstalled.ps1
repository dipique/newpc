function Get-ConsoleAppInstalled($cmd) {
    try {
        $cmd > $null
        return $true
        exit 0
    } catch {
        $LASTEXITCODE = 0
        return $false
    }
}

