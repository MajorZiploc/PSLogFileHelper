function Write-DigestReport {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      $reportInfo
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $logDir
      ,
      [Parameter(Mandatory=$true)]
      [int]
      $numOfDays
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $reportOutDir
      ,
      [Parameter(Mandatory=$true)]
      [AllowNull()]
      [Nullable[datetime]]
      $lastDigestReportWrittenDate
  )

  Set-StrictMode -Version 3
  $shouldWriteReport = $false
  [datetime]$today = Get-Date
  $lDate = $today.ToString('yyyy-MM-dd')
  if ($null -eq $lastDigestReportWrittenDate){
    $shouldWriteReport = $true
  } else {
    $tspan = $today - $lastDigestReportWrittenDate
    $shouldWriteReport = $tspan.Days -ge $numOfDays
  }

  if($shouldWriteReport) {

    [array]$jsonInfo = $reportInfo.json
    $jsonInfo | ForEach-Object {
      $r = $null
      $r = Get-ReportJson -label "$($_.searchLabel)" -logDir "$logDir" -numOfDays $numOfDays
      New-Item -ItemType Directory -Force -Path "$reportOutDir/$lDate" | Out-Null
      $r | Out-File -Encoding utf8 -FilePath "$reportOutDir/$lDate/$($_.fileName).json"
    }

    [array]$txtInfo = $reportInfo.txt
    $txtInfo | ForEach-Object {
      $r = $null
      $r = Get-ReportUnstructured -label "$($_.searchLabel)" -logDir "$logDir" -numOfDays $numOfDays
      New-Item -ItemType Directory -Force -Path "$reportOutDir/$lDate" | Out-Null
      $r | Out-File -Encoding utf8 -FilePath "$reportOutDir/$lDate/$($_.fileName).txt"
    }

  }

  return @{DidWriteReport=$shouldWriteReport}
}

function Get-ReportJson {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]
      $label
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $logDir
      ,
      [Parameter(Mandatory=$true)]
      [int]
      $numOfDays
  )

  Set-StrictMode -Version 3
  return Get-Report -label "$label" -logDir "$logDir" -numOfDays $numOfDays -dataConverter Get-ReportForFileJson | ConvertTo-Json
}

function Get-ReportUnstructured {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]
      $label
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $logDir
      ,
      [Parameter(Mandatory=$true)]
      [int]
      $numOfDays
  )

  Set-StrictMode -Version 3
  return Get-Report -label "$label" -logDir "$logDir" -numOfDays $numOfDays -dataConverter Get-ReportForFileUnstructured
}

function Get-Report {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]
      $label
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $logDir
      ,
      [Parameter(Mandatory=$true)]
      [int]
      $numOfDays
      ,
      [Parameter(Mandatory=$true)]
      $dataConverter
  )

  Set-StrictMode -Version 3
  $dayDirs = @()
  [array]$dayDirs = Get-ChildItem -Path "$logDir" | Where-Object {
    # Keep folders that can be parsed to days and are in the numOfDays range
    try {
      $dateFolder = $null
      $reportStartDate = $null
      [datetime]$dateFolder = $_.Name
      [datetime]$reportStartDate = (Get-Date).AddDays(-1*$numOfDays)
      return $dateFolder -ge $reportStartDate
    } catch {
      return $false
    }
  }

  $datas = @()
  [array]$datas = $dayDirs | ForEach-Object {
    $reports = @()
    $ds = @()
    $fullDayDirName = "$($_.FullName)/$runFolderName"
    [array]$reports = Get-ChildItem -Path "$fullDayDirName"
    [array]$ds = $reports | ForEach-Object {
      (& $dataConverter -label $label -filePath "$($_.FullName)" -fName "$($_.FullName)")
    } | Where-Object { $null -ne $_ }
    $ds
  }

  return $datas
}

function Get-Json {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [array]
      $data
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $fName
  )

  Set-StrictMode -Version 3
  try {
    $json = $data | ForEach-Object {
      $j = $_ | ConvertFrom-Json
      Add-Member -InputObject $j -NotePropertyName "___Log___File___Name___" -NotePropertyValue "$fName"
      $j
    }
    # $json = "[$($data -join ',')]" | ConvertFrom-Json
    return $json
  }
  catch {
    return $null
  }
}

function Get-UnstructuredData {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [array]
      $data
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $fName
  )

  Set-StrictMode -Version 3
  return "File Name: $fName`n$($data -join '`n')"
}

function Get-ReportForFileJson {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]
      $label
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $filePath
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $fName
  )

  Set-StrictMode -Version 3
  $content = Get-Content -Path "$filePath"
  $data = @()
  [array]$data = ($content | Select-String -Pattern "$label" -Context 0,1 | ForEach-Object {
    $_.Context.PostContext
  })
  if ($null -eq $data) { return $null }
  $data = Get-Json -data $data -fName "$fName"
  return $data
}

function Get-ReportForFileUnstructured {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]
      $label
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $filePath
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $fName
  )

  Set-StrictMode -Version 3
  $content = Get-Content -Path "$filePath"
  $data = @()
  [array]$data = ($content | Select-String -Pattern "$label")
  if ($null -eq $data) { return $null }
  $data = Get-UnstructuredData -data $data -fName "$fName"
  return $data
}
