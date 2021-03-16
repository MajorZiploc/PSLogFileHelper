# Only edit this file if you intend to write a powershell module or need to use secrets or change the environment
# If you intend to use this as a powershell project, then edit the program file in the private directory

function Invoke-PSLogFileReporter {
  [CmdletBinding()]
  param ()

  # Makes powershell stricter by default to make code safer and more reliable
  Set-StrictMode -Version 3

  # Import statements (follows the bash style dot sourcing notation)
  . $PSScriptRoot"/../Private/Program.ps1"
  . $PSScriptRoot"/../Private/ErrorHandler.ps1"
  . $PSScriptRoot"/../Private/LogHelper.ps1"

  # The environment to use. Determines the app config and state objects to use
  New-Variable -Name environ -Value $("test") -Option ReadOnly,AllScope -Force
  New-Variable -Name settingsFolder -Value $("$PSScriptRoot\..\settings") -Option ReadOnly,AllScope -Force
  New-Variable -Name appConfig -Value $(Get-Content -Path "$settingsFolder\$environ\appsettings.json" -Raw | ConvertFrom-Json) -Option ReadOnly,AllScope -Force
  # Secrets object. Things that you do not want to put in git go inside this. Add to the secrets json in the private folder
  # Need to uncomment this line if you want to use secrets. You will likely need to create the file aswell.
  # New-Variable -Name secrets -Value $($PSScriptRoot"\..\Private\secrets.json") -Option ReadOnly,AllScope -Force

  New-Variable -Name lastStateFilePath -Value $("$settingsFolder\$environ\lastState.json") -Option ReadOnly,AllScope -Force
  New-Variable -Name lastState -Value $(Get-Content -Path $lastStateFilePath -Raw | ConvertFrom-Json) -Option ReadOnly,AllScope -Force

  New-Variable -Name thisScriptName -Value $($MyInvocation.MyCommand.Name -replace ".ps1", "") -Option ReadOnly,AllScope -Force
  New-Variable -Name logFolder -Value $("$PSScriptRoot/../logs/$thisScriptName") -Option ReadOnly,AllScope -Force
  New-Variable -Name startTime -Value $(Get-Date) -Option ReadOnly,AllScope -Force
New-Variable -Name logDate -Value $($startTime.ToString("yyyy-MM-dd")) -Option ReadOnly,AllScope -Force
New-Variable -Name logTime -Value $($startTime.ToString("HH-mm-ss")) -Option ReadOnly,AllScope -Force
  # Create log directory if it does not exist, does not destroy the folder if it exists already
  New-Item -ItemType Directory -Force -Path "$logFolder/$logDate/$($appConfig.runFolderName)" | Out-Null
  New-Item -ItemType Directory -Force -Path "$logFolder/$logDate/$($appConfig.summaryFolderName)" | Out-Null

  New-Variable -Name logFile -Value $("$logFolder/$logDate/$($appConfig.runFolderName)/$($appConfig.logFileName)_$($logTime)_log.txt") -Option ReadOnly,AllScope -Force
  New-Variable -Name summaryFile -Value $("$logFolder/$logDate/$($appConfig.summaryFolderName)/$($appConfig.logFileName)_log.txt") -Option ReadOnly,AllScope -Force
  New-Variable -Name keepLogsForNDays -Value $($appConfig.keepLogsForNDays) -Option ReadOnly,AllScope -Force

  $msg = "Starting process. $(Get-Date)`n"
  $msg += "environment: $environ`n"
  Write-Log -msg $msg
  Write-Json -label "appConfig:" -data $appConfig

  try {
    # Program is where you should write your normal powershell script code
    Program -ErrorAction Stop
  }

  catch {
    $errorDetails = Get-ErrorDetails -error $_
    Write-Json -label "Top level issue: " -data $errorDetails
    throw $_
  }

  finally {
    $msg = "Finished process. $(Get-Date)`n"
    Write-Log -msg $msg
    # Delete old logs
    Clean-Logs -keepLogFilesForNDays $keepLogsForNDays
    # update last state json
    $lastState | ConvertTo-Json > $lastStateFilePath
  }
}
