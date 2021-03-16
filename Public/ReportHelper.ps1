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
      [string]
      $reportOutDir
      ,
      [Parameter(Mandatory=$true)]
      [datetime]
      $startReportDate
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $endReportDate
  )

  Set-StrictMode -Version 3
  try {
    [array]$jsonInfo = $reportInfo.json
    $jsonInfo | ForEach-Object {
      $r = $null
      $r = Get-ReportJsonDateRange -label "$($_.searchLabel)" -logDir "$logDir" -startReportDate $startReportDate -endReportDate $endReportDate
      New-Item -ItemType Directory -Force -Path "$reportOutDir" | Out-Null
      $r | Out-File -Encoding utf8 -FilePath "$reportOutDir/$($_.fileName).json"
    }

    [array]$txtInfo = $reportInfo.txt
    $txtInfo | ForEach-Object {
      $r = $null
      $r = Get-ReportTxtDateRange -label "$($_.searchLabel)" -logDir "$logDir" -startReportDate $startReportDate -endReportDate $endReportDate
      New-Item -ItemType Directory -Force -Path "$reportOutDir" | Out-Null
      $r | Out-File -Encoding utf8 -FilePath "$reportOutDir/$($_.fileName).txt"
    }

    return @{success=$true, $error=$null}
  } catch {
    return @{success=$false, $error=$_}
  }
}

function Get-ReportJsonDateRange {
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
      [datetime]
      $startReportDate
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $endReportDate
  )

  Set-StrictMode -Version 3
  return Get-Report -label "$label" -logDir "$logDir" -startReportDate $startReportDate -endReportDate $endReportDate -dataConverter Get-ReportForFileJson | ConvertTo-Json
}

function Get-ReportTxtDateRange {
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
      [datetime]
      $startReportDate
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $endReportDate
  )

  Set-StrictMode -Version 3
  return Get-Report -label "$label" -logDir "$logDir" -startReportDate $startReportDate -endReportDate $endReportDate -dataConverter Get-ReportForFileUnstructured
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
      $dataConverter
      ,
      [Parameter(Mandatory=$true)]
      [datetime]
      $startReportDate
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $endReportDate
  )

  Set-StrictMode -Version 3
  $dayDirs = @()
  [array]$dayDirs = Get-ChildItem -Path "$logDir" | Where-Object {
    # Keep folders that can be parsed to days and are in the date range
    try {
      $dateFolder = $null
      [datetime]$dateFolder = $_.Name
      return $dateFolder -ge $startReportDate -and $dateFolder -le $endReportDate
    } catch {
      return $false
    }
  }

  $datas = @()
  [array]$datas = $dayDirs | ForEach-Object {
    Get-ReportForDay -dayDir "$($_.FullName)/$runFolderName" -label "$label" -dataConverter $dataConverter
  }

  return $datas
}

function Get-ReportForDay {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]
      $dayDir
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $label
      ,
      [Parameter(Mandatory=$true)]
      $dataConverter
  )
  $reports = @()
  $ds = @()
  [array]$reports = Get-ChildItem -Path "$dayDir"
  [array]$ds = $reports | ForEach-Object {
    (& $dataConverter -label "$label" -filePath "$($_.FullName)")
  } | Where-Object { $null -ne $_ }
  return $ds
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
      $filePath
  )

  Set-StrictMode -Version 3
  try {
    $json = $data | ForEach-Object {
      $j = $_ | ConvertFrom-Json
      Add-Member -InputObject $j -NotePropertyName "___Log___File___Name___" -NotePropertyValue "$filePath"
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
      $filePath
  )

  Set-StrictMode -Version 3
  return "File Name: $filePath`n$($data -join '`n')"
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
  )

  Set-StrictMode -Version 3
  $content = Get-Content -Path "$filePath"
  $data = @()
  [array]$data = ($content | Select-String -Pattern "$label" -Context 0,1 | ForEach-Object {
    $_.Context.PostContext
  })
  if ($null -eq $data) { return $null }
  $data = Get-Json -data $data -filePath "$filePath"
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
  )

  Set-StrictMode -Version 3
  $content = Get-Content -Path "$filePath"
  $data = @()
  [array]$data = ($content | Select-String -Pattern "$label")
  if ($null -eq $data) { return $null }
  $data = Get-UnstructuredData -data $data -filePath "$filePath"
  return $data
}
