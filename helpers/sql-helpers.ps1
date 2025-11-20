function EnsureSmo {
    $installed = (Get-Module -Name SqlServer).count -gt 0 2> $null
    if ($installed) {
        Import-Module -Name SqlServer
    } else {
        Install-Module -Name SqlServer -Force
    }
}

function LinkedServerExists([string] $lsName) {
    EnsureSmo
    $smo = New-Object Microsoft.SqlServer.Management.Smo.Server $env:ComputerName 2> $null
    $exists = $smo.linkedservers.where({$_.State -eq 'Existing'}).where({$_.Name -eq $lsName}).count -gt 0 2> $null
    $exists
}

function UserExists([string] $userName) {
    EnsureSmo
    $smo = New-Object Microsoft.SqlServer.Management.Smo.Server $env:ComputerName 2> $null
    $userExists = $smo.logins.where({$_.name -eq $userName}).count -gt 0 2> $null
    $userExists
}

function GetSqlDir {
    $sqlRootDir = 'C:\Program Files\Microsoft SQL Server\'
    $sqlSuffixDir = '\MSSQL\DATA\'
    [array]$sqlDirCands = Get-ChildItem $sqlRootDir -filter 'MSSQL1?.MSSQLSERVER' -Directory | Sort-Object -Property Name -Descending
    foreach ($sqlDirCand in $sqlDirCands) {
        $fullName = Join-Path $sqlRootDir $sqlDirCand.Name $sqlSuffixDir
        if (Test-Path $fullName) {
            return $fullName
        }
    }
    
    return '' # never found a valid directory
}

$useTrustServerCertParam = $false
function TrySql($params) {
    $LASTEXITCODE = 0
    $params | Add-Member -NotePropertyName 'OutputSqlErrors' -NotePropertyValue $true
    if (!$useTrustServerCertParam) {
        $errOutput = $($result = Invoke-Sqlcmd $params) 2>&1
        if ($errOutput.count -gt 0) {
            $msg = $errOutput[0]
            if ($msg -like '*certificate*') {
                Write-Host 'Enabling certificate trust for remote server' -ForegroundColor Yellow
                $useTrustServerCertParam = $true
            } else {
                Write-Host $msg -ForegroundColor Red
                return $false
            }
        } else {
            return $result
        }
    }

    $result = Invoke-Sqlcmd -TrustServerCertificate @params
    if ($LASTEXITCODE -gt 0) {
        Write-Host $result -ForegroundColor Red
        return $false
    } else {
        if (!$result) {
            return $true
        }
        return $result
    }
}