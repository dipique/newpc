function Create-RemoteBackgroundService {
  param {
    [string]$serviceName,
    [string]$appDirectory = "C:\LynxServices\$serviceName",
    [string]$destServer,
    [string]$svcUnme,
    [string]$svcPd
  }

  # Create Background Service scheduled task
  Write-Host "Creating Background Service scheduled task for $serviceName..."
  try {
    Invoke-Command -ComputerName $destServer -ScriptBlock {
      $taskName = "$using:serviceName Start on Boot"
      Write-Host "Creating scheduled task: $taskName"
      
      # Check for and delete existing task
      $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
      if ($existingTask) {
        Write-Warning "Task '$taskName' already exists. Deleting and recreating."
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
      }
      
      # Find the executable
      $exeName = "$using:serviceName.exe"
      $executable = Get-ChildItem -Path $using:appDirectory -Filter $exeName -Recurse | Select-Object -First 1
      if (-not $executable) {
        throw "Could not find executable '$exeName' in '$appDirectory'"
      }
      
      $exeFullPath = $executable.FullName
      Write-Host "Found executable at: $exeFullPath"
      
      # Create task components
      $taskAction = New-ScheduledTaskAction -Execute $exeFullPath
      $taskTrigger = New-ScheduledTaskTrigger -AtStartup
      $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Days 365)
      $taskSettings.AllowDemandStart = $true
      $taskSettings.Enabled = $true
      $taskSettings.Hidden = $false
      $taskSettings.MultipleInstances = 'IgnoreNew'
      
      # Register the task
      Register-ScheduledTask -TaskName $taskName `
        -Action $taskAction `
        -Trigger $taskTrigger `
        -Settings $taskSettings `
        -RunLevel Highest `
        -Description "Starts the $using:serviceName application on system boot. (Managed by deployment script)" `
        -User $using:svcUnme `
        -Password $using:svcPd
      
      Write-Host "Scheduled task '$taskName' created successfully."
      
    }
    
  } catch {
    Write-Error "Failed to create Background Service task: $($_.Exception.Message)"
    exit 1
  }
}

function Start-RemoteBackgroundService {
  param {
    [string]$serviceName,
    [string]$destServer
  }
  
  # Start the Background Service task
  Write-Host "Starting Background Service task for $serviceName..."
  try {
    Invoke-Command -ComputerName $destServer -ScriptBlock {
      $taskName = "$using:serviceName Start on Boot"
      Start-ScheduledTask -TaskName $taskName
      Write-Host "Background Service task started."
    }
  } catch {
    Write-Error "Failed to start Background Service task: $($_.Exception.Message)"
    exit 1
  }
}