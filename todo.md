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

# windows

# configuration
move existing configs into a separate script
set machine name
windows update
features
enable rdp
need to do that thing for remote desktop
  runas /u:MicrosoftAccount\dipique@gmail.com winver
create dev drive
sleep/power profile
terminal profile
remove persistent learn about picture icon
Accounts -> Sign-in-options -> Automatically save my restartable apps and restart when I sign back in
https://www.ninjaone.com/blog/remove-learn-about-this-picture-desktop-icon/

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

# infrastructure 
* need to use a loop like setup to detect failures and resume
* way to have optional scripts

# probably needs to happen in setup
set up ais shortcut (setup)
