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

function CreateDesktopShortcut { # returns the path to the created shortcut
    param (
        [Parameter(Mandatory=$False, Position=0)]
        [string]$AppPath,

        [Parameter(Mandatory=$False, Position=1)]
        [string]$AppName,

        [Parameter(Mandatory=$False, Position=1)]
        [switch]$Overwrite
    )

    if (!($AppName)) {
        $AppName = [System.IO.Path]::GetFileNameWithoutExtension($AppPath)
    }

    # Define the path for the desktop shortcut
    $desktopPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), "$AppName.lnk")

    if (Test-Path -Path $desktopPath) {
        if ($Overwrite) {
            Remove-Item -Path $desktopPath -Force
            Write-Host "Existing shortcut removed: $desktopPath"
        } else {
            Write-Host "Shortcut already exists: $desktopPath"
            return $desktopPath
        }
    }

    # Create a WScript.Shell object to create the shortcut
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($desktopPath)
    $shortcut.TargetPath = $AppPath
    $shortcut.Save()
    Write-Host "Desktop shortcut created at: $desktopPath"
    return $desktopPath
}

function PinAppToTaskbar {
    param (
        [string]$AppPath,
        [string]$AppName,
        [switch]$Force
    )

    # todo: we really need the desktop shortcut to check if it's pointing to the same application, and some with overwriting on the taskbar; we actually need to
    # "search" for the shortcut instead of just looking at filenames
    # and of course we need to check the deskbar before we create a desktop shortcut

    # Copy the temporary shortcut to the taskbar pinned items directory
    $desktopShortcutPath = CreateDesktopShortcut -AppPath $AppPath -AppName $AppName -Overwrite:$Force
    $shortcutFilename = [System.IO.Path]::GetFileName($desktopShortcutPath)
    $taskbarPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('ApplicationData'), 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar')
    $shortcutPath = [System.IO.Path]::Combine($taskbarPath, $shortcutFilename)

    if (Test-Path $shortcutPath) {
        if ($Force) {
            Remove-Item -Path $shortcutPath -Force
            Write-Host "Existing taskbar shortcut removed: $shortcutPath"
        } else {
            Write-Host "Taskbar shortcut already exists: $shortcutPath"
            Remove-Item -Path $desktopShortcutPath -Force # Remove the temporary shortcut from the desktop
            Write-Host "Temporary desktop shortcut removed: $desktopShortcutPath"
            return $shortcutPath
        }
    }
    
    Copy-Item -Path $desktopShortcutPath -Destination $taskbarPath -Force
    Write-Host "App pinned with shortcut: $shortcutPath"
    Remove-Item -Path $desktopShortcutPath -Force # Remove the temporary shortcut from the desktop
    Write-Host "Temporary desktop shortcut removed: $desktopShortcutPath"
    return $shortcutPath
}

# todo: need to add this to setup cfg for new apps -- maybe even to winget? can winget retrieve the exe? Otherwise we need logic to find the exe from the installed app

# PinAppToTaskbar "C:\Program Files\Google\Chrome\Application\chrome.exe" -AppName "Chrome"
# PinAppToTaskbar "C:\Program Files\Google\Chrome Beta\Application\chrome.exe" -AppName "Chrome Beta"
# PinAppToTaskbar "C:\Program Files\Everything\Everything.exe"
# PinAppToTaskbar "C:\Users\dipiq\AppData\Local\Programs\Microsoft VS Code\Code.exe"
# PinAppToTaskbar "C:\Users\dipiq\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
# PinAppToTaskbar "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.23.12811.0_x64__8wekyb3d8bbwe\WindowsTerminal.exe" -AppName Terminal

# obsidian

# setup:
#  postman
#  ssms
#  slack
#  teams
#  outlook
#  vs (already there, but should make part of cfg)


# C:\Users\dipiq\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar

# not sure this is working; another option is:
#  Import-StartLayout -LayoutPath "C:\Temp\TaskbarLayout.xml" -MountPath C:\