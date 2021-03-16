
function Clean-Logs {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(0, [int]::MaxValue)]
    [int]
    $keepLogFilesForNDays
    ,
    [Parameter(Mandatory = $false)]
    [string]
    $logDir=$logFolder
    ,
    [Parameter(Mandatory = $false)]
    [array]
    $excludeList=@()
  )

  [array]$logDates = Get-ChildItem -Path "$logDir" -Exclude $excludeList
  if ($null -eq $logDates -or $logDates.Length -eq 0) { return }
  $logDates | ForEach-Object {
    [datetime]$lDate = $_.Name
    $now = Get-Date
    $timespan = $now - $lDate
    $daysOld = $timespan.Days
    if ($daysOld -gt $keepLogFilesForNDays) {
      # delete the log date folder
      Remove-Item -Path $_.FullName -Recurse -Force
    }
  }
}


function Write-Log {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]
      $msg
      ,
      [Parameter(Mandatory=$false)]
      [string]
      $logPath=$logFile
      ,
      [Parameter(Mandatory=$false)]
      [string]
      $summaryPath=$summaryFile
      ,
      [Parameter(Mandatory=$false)]
      [string]
      $whereToLog="11"
  )

  $base = 2
  $lAsInt = [convert]::ToInt32("10", $base) # log file
  $sAsInt = [convert]::ToInt32("01", $base) # summary file

  if (($whereToLog -band $lAsInt) -eq $lAsInt) {
    $msg | Out-File -FilePath "$logFile" -Encoding utf8 -Append
  }
  if (($whereToLog -band $sAsInt) -eq $sAsInt) {
    $msg | Out-File -FilePath "$summaryFile" -Encoding utf8 -Append
  }
}

function Write-Json {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$false)]
      [string]
      $label=""
      ,
      [Parameter(Mandatory=$true)]
      $data
      ,
      [Parameter(Mandatory=$false)]
      [string]
      $logPath=$logFile
      ,
      [Parameter(Mandatory=$false)]
      [string]
      $summaryPath=$summaryFile
  )

  $label = if ([string]::IsNullOrWhiteSpace($label)) { "" } else { "$label`n" }

  $jsonc = $data | Select-Object -Property * | ConvertTo-Json -Compress
  $json =  $data | Select-Object -Property * | ConvertTo-Json 
  Write-Log -msg "$label$jsonc" -logPath "$summaryFile" -whereToLog "10"
  Write-Log -msg "$label$json" -logPath "$summaryFile" -whereToLog "01"
}

