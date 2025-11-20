. $PSScriptRoot\..\helpers\CreateAssociation.ps1

# install latest version of vs code and extensions
$vcpath = "$($env:LOCALAPPDATA)\Programs\Microsoft VS Code\Code.exe"
$vcexists = Test-Path $vcpath
$installvc = $true
if ($vcexists) {
    Write-Host ''
    $result = $host.ui.PromptForChoice(        
        'VS Code is already installed',
        'Do you want to run the VS Code installer to ensure that the extensions are installed as well (recommended)?',
        [string[]]('&Yes', '&No'),
        0 # default choice index
    )
    if ($result -eq 1) {
        Write-Host 'Continuing without installing VS Code'
        $installvc = $false
    }
}

if ($installvc) {
    $exts = Get-Content $PSScriptRoot\..\cfg\vscode-extensions.json -Raw | ConvertFrom-Json
    Unblock-File $PSScriptRoot\..\external\Install-VSCode.ps1
    & $PSScriptRoot\..\external\Install-VSCode.ps1 -BuildEdition Stable-User -Architecture 64-bit -EnableContextMenus -AdditionalExtensions $exts
}

# associate with .config files

Create-Association -ext '.config' -exe $vcpath