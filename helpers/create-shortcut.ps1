function Create-Shortcut(
    [string] $tgt_path, 
    [string] $description, [bool] $launchAsAdmin, [string] $shortcutDir # optional parameters
) {
    if (!(Test-Path $path)) {
        Write-Error 'Path does not exit'
        exit -1
    }

    $WshShell = New-Object -comObject WScript.Shell
    $fn = [System.IO.Path]::GetFileNameWithoutExtension($tgt_path)
    if (!$shortcutDir) {        
        $shortcutDir = [Environment]::GetFolderPath("Desktop")      
    }
    if (!$description) {
        $description = $fn
    }

    $sc_fn = "$description.lnk"
    $shortcutPath = Join-Path $shortcutDir $sc_fn

    if (Test-Path $shortcutPath) {
        Remove-Item $shortcutPath -Force
        if (Test-Path $shortcutPath) {
            Write-Error 'Failed to replace shortcut'
            exit -1
        }
    }

    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $tgt_path
    $shortcut.Description = $description
    $shortcut.Save()

    if ($launchAsAdmin) {
        $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20 # set byte 21 (0x15) bit 6 (0x20) ON
        [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)
    }
}