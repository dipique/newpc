winget settings --enable InstallerHashOverride
winget install --id=Microsoft.Office -e --ignore-security-hash

# this might need to be run manually; the former needs admin and maybe the second admin isn't allowed?