# NOTE ON LOGGING: THESE HELPER LOGGING FUNCTIONS ARE REQUIRED TO BE USED.
# Write(append) to the log files like so:
#   For non structured data:
#      Write-Log -msg $msg
#   For structured data (hash maps or powershell custom objects): 
#      Write-Json -data $data
#   note: when using the $msg variable to store your message. Make sure to clear out the variable like so:
#        $msg = ""
# Why do I have to use these for logging?
# These helper functions use the utf-8 writing format which is required to parse the logs
# Default writing format is utf-16 for powershell 5.1 and lower.
#   This is the binary format, and not consumed as text by other programs
# These helper functions also write to multiple files in different formats depending on the file

# See the black listed variables file to see what variables to not reassign:
# By default, if you try and reassign a black listed variable, it will throw an error.
#   It is possible to override the value with force, but it is highly recommended not to!
#  LogFileReporter/BlackListedVariables.txt

function Program {
  #[CmdletBinding()]
  #param (
    # [Parameter(Mandatory = $false)]
    # [ValidateRange([int]::MinValue, 0)]
    # [int]
    # $n = 0
  #)

  # Imports files from same directory as this file
  . $PSScriptRoot"/LogHelper.ps1"
  . $PSScriptRoot"/ErrorHandler.ps1"

  return 0
}
