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
      $runDirName
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $rfolderName
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $lDate
  )

  $shouldWriteReport = $false
  if ($null -eq $lastState.lastDigestReportWritten){
    $shouldWriteReport = $true
  } else {
    [datetime]$lastDigestReportWrittenDate = $lastState.lastDigestReportWritten
    [datetime]$today = Get-Date
    $tspan = $today - $lastDigestReportWrittenDate
    $shouldWriteReport = $tspan.Days -ge $numOfDays
  }

  if($shouldWriteReport) {
    $lastState.lastDigestReportWritten = $lDate

    $jsonInfo = $reportInfo.json
    $jsonInfo | ForEach-Object {
      $r = $null
      $r = Get-ReportJson -label "$($_.searchLabel)" -logDir "$logDir" -numOfDays $numOfDays -runDirName "$runDirName"
      New-Item -ItemType Directory -Force -Path "$logDir/$rFolderName/$lDate" | Out-Null
      $r | Out-File -Encoding utf8 -FilePath "$logDir/$rFolderName/$lDate/$($_.fileName).json"
    }

    $txtInfo = $reportInfo.txt
    $txtInfo | ForEach-Object {
      $r = $null
      $r = Get-ReportUnstructured -label "$($_.searchLabel)" -logDir "$logDir" -numOfDays $numOfDays -runDirName "$runDirName"
      New-Item -ItemType Directory -Force -Path "$logDir/$rFolderName/$lDate" | Out-Null
      $r | Out-File -Encoding utf8 -FilePath "$logDir/$rFolderName/$lDate/$($_.fileName).txt"
    }

  }
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
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $runDirName
  )

  return Get-Report -label "$label" -logDir "$logDir" -numOfDays $numOfDays -runDirName $runDirName -dataConverter Get-ReportForFileJson | ConvertTo-Json
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
      ,
      [Parameter(Mandatory=$true)]
      [string]
      $runDirName
  )

  return Get-Report -label "$label" -logDir "$logDir" -numOfDays $numOfDays -runDirName $runDirName -dataConverter Get-ReportForFileUnstructured
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
      [string]
      $runDirName
      ,
      [Parameter(Mandatory=$true)]
      $dataConverter
  )

  $dayDirs = $null
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

  $datas = $null
  [array]$datas = $dayDirs | ForEach-Object {
    $reports = $null
    $ds = $null
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

  $content = Get-Content -Path "$filePath"
  $data = $null
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

  $content = Get-Content -Path "$filePath"
  $data = $null
  [array]$data = ($content | Select-String -Pattern "$label")
  if ($null -eq $data) { return $null }
  $data = Get-UnstructuredData -data $data -fName "$fName"
  return $data

}
