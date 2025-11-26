if ((Get-Module -Name PSWindowsUpdate).Count -ne 0) {
    Write-Host 'PSWindowsUpdate is already installed.'
    exit 0
}

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord

Install-Module -Name PSWindowsUpdate -Force