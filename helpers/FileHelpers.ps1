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

# Define the default regex pattern as a constant
$DefaultExclusions = 'nuget|\\bin\\|\\obj\\|\\node_modules\\|\\.git|\\.vs\\|\\References\\|\\runtimes\\|\\packages\\'

function Get-ProjectSize {
    param (
        [string]$Path = 'c:\lynx',
        [string]$Pattern = $DefaultExclusions
    )

    $totalBytes = (Get-ChildItem -Path $Path -Recurse -Force -File | 
        Where-Object { $_.FullName -notmatch $Pattern } | 
        Measure-Object -Property Length -Sum).Sum

    return $totalBytes / 1GB
}

function Get-ProjectTopFiles {
    param (
        [string]$Path = 'c:\lynx',
        [string]$Pattern = $DefaultExclusions,
        [int]$TopN = 10
    )

    Get-ChildItem -Path $Path -Recurse -Force -File |
        Where-Object { $_.FullName -notmatch $Pattern } |
        Sort-Object Length -Descending |
        Select-Object -First $TopN -Property @{N='Size (MB)'; E={"{0:N2}" -f ($_.Length / 1MB)}}, FullName |
        Format-Table -AutoSize
}

function Copy-FilesByExt {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TargetsDir,

        [Parameter(Mandatory=$true)]
        [string]$SourceDir,

        [Parameter(Mandatory=$true)]
        [string[]]$PackageFolders,

        [Parameter(Mandatory=$false)]
        [string]$Extensions = "*.targets",

        [Parameter(Mandatory=$false)]
        [switch]$WhatIf
    )

    foreach ($pkg in $PackageFolders) {
        $sourcePath = Join-Path $SourceDir $pkg
        $destPath   = Join-Path $TargetsDir $pkg
        
        if (Test-Path $sourcePath) {
            Get-ChildItem -Path $sourcePath -Filter $Extensions -Recurse | ForEach-Object {
                $relativeFile = $_.FullName.Substring($sourcePath.Length + 1)
                $targetFile = Join-Path $destPath $relativeFile
                $targetDir = Split-Path $targetFile
                
                if (!$WhatIf) {
                    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
                    Copy-Item $_.FullName $targetFile -Force
                } else {
                    Write-Host "[WhatIf] Would copy: $relativeFile" -ForegroundColor Gray
                }
            }
        }
    }
}