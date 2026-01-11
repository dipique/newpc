# apps
chrome remote desktop
set chrome security features?
lynx
  c:\lynx\src, setup
  nodep-setup.ps1 -localdb rmt-lt-dkasche3
vn (optional?)
onedrive
  set up
  vault
  disable desktop backup
vs code
 - user settings json add: {
  "security.allowedUNCHosts": [
    "dorcas"
  ],
  "files.hotExit": "onExitAndWindowClose"
  "powershell.scriptAnalysis.settingsPath": "C:\\dev\\homelab\\ps\\PSScriptAnalyzerSettings.psd1",
 }
install poshgit (it's done in setup, dont think I'm doing it yet)
validate paths; if we make sure es (everything cli search) works, we can use it to find executables more easily, if winget doesn't already have a thing for that
create json powershell modules to install (I guess no need to import)
licensed software -- installer + license
  - should these be optional? maybe selectable at the beginning and build a cfg so it survives restarts?
  4K downloader -- file + license
  Eagle -- file + settings (should these be optional?)
  allsync
brother printer driver

# windows

# configuration
move existing configs into a separate script
set machine name
windows update
features
enable rdp
create dev drive
sleep/power profile
terminal profile
remove persistent learn about picture icon
Accounts -> Sign-in-options -> Automatically save my restartable apps and restart when I sign back in
https://www.ninjaone.com/blog/remove-learn-about-this-picture-desktop-icon/
autostart passwords.ahk
windows start -> Personalization -> Start -- all sorts of settings like showing recomendations
put repo configuration into a cfg file

### dev drive

https://learn.microsoft.com/en-us/windows/dev-drive/
https://stackoverflow.com/a/78329177/2524708 <-- actual example of vhd drive

vhd - portable, slower, space can be expanded more easily
partition - faster

Format-Volume -DriveLetter D -DevDrive -FileSystem ReFS -Configm:$false -Force

optimizations
fsutil devdrv trust <drive-letter>:
fsutil devdrv enable /disallowAv

# create folder, then add access path
md c:\lynx
(Get-Partition -DriveLetter L) | Add-PartitionAccessPath -AccessPath "c:\lynx"
md c:\dev
(Get-Partition -DriveLetter D) | Add-PartitionAccessPath -AccessPath "c:\dev"

## start menu
  disable switcher
  left -aligned tasks
  add shortcuts -- should be an option for an app, maybe experiment in setup first
    everything
    vs code
    chrome

# data
homelab repo
work repo (homework)

# infrastructure
* need to use a loop like setup to detect failures and resume
* way to have optional scripts

# probably needs to happen in setup
set up ais shortcut (setup)
