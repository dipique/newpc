param (
    [string]$JsonPath
)

Write-Host 'Installing winget apps...' -ForegroundColor Blue
$apps = Get-Content $JsonPath -Raw | ConvertFrom-Json
foreach ($app in $apps) {
    $name = $app.q
    if ($null -eq $app.q) {
        $name = $null -eq $app.name ? $app.id : $app.name
    }
    Write-Host "App: $name" -ForegroundColor Blue
    # assemble the params for calling winget list
    $listArgParts = @(
        'list'
      , ($null -ne $app.q ) ? $app.q  : $null
      , ($null -ne $app.id) ? "-e"    : $null
      , ($null -ne $app.id) ? "--id"  : $null
      , ($null -ne $app.id) ? $app.id : $null
      , ($null -ne $app.s ) ? '-s'    : $null
      , ($null -ne $app.s ) ? $app.s  : $null
      , '--accept-source-agreements'
    ).where({$null -ne $_})
    
    # $cmd = "winget $($listArgParts -join ' ')"
    # Write-Host "Running: $cmd"
    $result = & winget $listArgParts
    $installed = !$result.contains('No installed package found matching input criteria.')

    if ($installed) {
        Write-Host "$name is already installed; skipping installation"
    } else {
        Write-Host "Installing $name..."

        # assemble the params for calling winget install
        if ($null -ne $app.version) {
          $listArgParts += '-v'
          $listArgParts += $app.version
        }

        $listArgParts += '--accept-package-agreements'
        $listArgParts[0] = 'install'

        # $listArgParts
        & winget $listArgParts

        if ($LASTEXITCODE -ne 0) {
          if (!$app.required) {
            if ($app.s -eq 'msstore') {
              Write-Host 'Since this is an Microsoft Store package, this installation failure was probably due to not being signed in. If you really want this app, then abort the script, open the windows store, log in (a personal Microsoft account works fine), and then try again.' -ForegroundColor yellow
            }
            Write-Host ''
            $result = $host.ui.PromptForChoice(        
                'Installation failed',
                'The installation of this app failed; would you like to continue?',
                [string[]]('&Continue without this app', '&Abort and resolve issue'),
                0 # default choice index
            )
            if ($result -eq 0) {
              Write-Host "Continuing without $name"
              $LASTEXITCODE = 0
            } else {
              Write-Host 'Aborting'
              exit 1
            }
          } else {
            Write-Host 'Installation failed :('
            exit 1
          }
        }
    }
}

exit 0