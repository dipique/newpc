function Create-Association([string] $ext, [string] $exe) {
    $name = cmd /c "assoc $ext 2>NUL"
    if ($name) { # Association already exists: override it
        $name = $name.Split('=')[1]
    } else { # Name doesn't exist: create it
        $name = "$($ext.Replace('.','')) file" # ".log.1" becomes "log1file"
        cmd /c "assoc $ext=$name"
    }
    cmd /c "ftype $name=`"$exe`" `"%1`""
}