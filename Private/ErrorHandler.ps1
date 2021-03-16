
function Get-ErrorDetails {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    $error
  )

  return @{
    ScriptStackTrace = $error.ScriptStackTrace
    StackTrace = $error.Exception.StackTrace
    Message = $error.Exception.Message
    FullyQualifiedErrorId = $error.FullyQualifiedErrorId
    TargetObject = $error.TargetObject
    ErrorDetails = $error.ErrorDetails
  }
}

