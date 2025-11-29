function ShowHiddenFiles {
    Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    $changed = $false
    $hidden = Get-ItemPropertyValue -Name Hidden
    if ($hidden -eq '1') {
        Write-Host 'Setting explorer to show hidden files'
        Set-ItemProperty . Hidden '0'
        $changed = $true
    } else {
        Write-Host 'Explorer already shows hidden files'
    }

    $superHidden = Get-ItemPropertyValue -Name ShowSuperHidden
    if ($superHidden -eq '1') {
        Write-Host 'Setting explorer to show super hidden files'
        Set-ItemProperty . ShowSuperHidden '0'
        $changed = $true
    } else {
        Write-Host 'Explorer already shows super hidden files'
    }

    if ($changed) {
        Write-Host 'Restarting explorer to enact changes'
        Stop-Process -processName: Explorer -force # This will restart the Explorer service to make this work.
    }
    
    Pop-Location    
}

function ShowFileExtensions {
    # http://superuser.com/questions/666891/script-to-set-hide-file-extensions
    Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    $current = Get-ItemPropertyValue -Name HideFileExt
    if ($current -eq '1') {
        Write-Host 'File extensions are hidden; setting to show'
        Set-ItemProperty . HideFileExt '0'
        Stop-Process -processName: Explorer -force # This will restart the Explorer service to make this work.
    } else {
        Write-Host 'File extensions are already shown'
    }
    
    Pop-Location    
}

# Delete a folder along with all its contents
function DeleteFolder {
    param (
        [string]$dir
    )
    $folder = Split-Path $dir -Leaf
    $removeText = "removing '$folder' folder"
    try {
        # make sure it exists before trying to remove it
        if (Test-Path $dir) {
            Remove-Item -Recurse -Force $dir -ErrorAction Stop
        }

        if (Test-Path $dir) {
            Write-Host "removal failed (folder still exists)"
        }
        
        Write-Host "`t$removeText...Done"
    }
    catch {
        if ($_.Exception -is [System.IO.DirectoryNotFoundException]) {
            # Folder doesn't exist, so just ignore
        }
        else {
            Write-Host "`t$removeText...Failed - $($_.Exception.Message)"
        }
    }
}

# Delete a subfolder of a directory along with all its contents
function DeleteSubfolder {
    param (
        [string]$root,
        [string]$folder
    )
    $dir = Join-Path $root $folder
    DeleteFolder $dir
}

function Grant-UserAccess { # requires admitminsitrative privileges
    param(
        [Parameter(Mandatory = $true)]
        [string]$User, # domain\username or username

        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    # todo: validate account

    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $acl = Get-ACL $Path
    $acl.AddAccessRule($accessRule)
    Set-ACL -Path $Path -ACLObject $acl
}