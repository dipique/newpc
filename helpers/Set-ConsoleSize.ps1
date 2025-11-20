<#
.Synopsis
Set the size of the current console window

.Description
Set-ConsoleSize sets or resets the size of the current console window. By default, it
sets the window to a height of 40 lines, with a 2000 line buffer, and sets the 
the width and width buffer to 120 characters. 

.Example
Restore the console window to 40h x 120w:
Set-ConsoleSize

.Example
Change the current console to a height = 30 lines and a width = 180 chars:
Set-ConsoleSize -Height 30 -Width 180

.Parameter Height
The number of lines to which to set the current console. Default = 40 lines. 

.Parameter Width
The number of characters to which to set the current console. Default = 120 chars.

.Inputs
[int]
[int]

.Notes
    Author: ss64.com/ps/syntax-consolesize.html
 Last edit: 2019-08-29
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=0)]
    [int]$Height = 40,
    [Parameter(Mandatory=$False,Position=1)]
    [int]$Width = 120
)
$console = $host.ui.rawui
$ConBuffer  = $console.BufferSize
$ConSize = $console.WindowSize

$currWidth = $ConSize.Width
$currHeight = $ConSize.Height

# if height is too large, set to max allowed size
if ($Height -gt $host.UI.RawUI.MaxPhysicalWindowSize.Height) {
    $Height = $host.UI.RawUI.MaxPhysicalWindowSize.Height
}

# if width is too large, set to max allowed size
if ($Width -gt $host.UI.RawUI.MaxPhysicalWindowSize.Width) {
    $Width = $host.UI.RawUI.MaxPhysicalWindowSize.Width
}

# If the Buffer is wider than the new console setting, first reduce the width
If ($ConBuffer.Width -gt $Width ) {
   $currWidth = $Width
}
# If the Buffer is higher than the new console setting, first reduce the height
If ($ConBuffer.Height -gt $Height ) {
    $currHeight = $Height
}
# initial resizing if needed
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size($currWidth,$currHeight)

# Set the Buffer
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size($Width,2000)

# Now set the WindowSize
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size($Width,$Height)

# Display the new sizes (Optional/for debugging)
# "Height: " + $host.ui.rawui.WindowSize.Height
# "Width:  " + $host.ui.rawui.WindowSize.width
# Examples
# PS C:\> Set-ConsoleSize -Height 30 -Width 180