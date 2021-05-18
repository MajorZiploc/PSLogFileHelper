$PSVersion = $PSVersionTable.PSVersion.Major
# import the file with the functions you are testing
# . $PSScriptRoot"/../../Public/Get-Num.ps1"
Describe "<name_of_function1> PS$PSVersion Integrations tests" { 
  Context "Strict mode" { 
    Set-StrictMode -Version latest
    It "should get valid data" {
      # Simple Mock example
      # Mock Get-PrivateNum {
      #   return 8
      # }
      # Simple assertion
      # $actual = Get-Num -n -10
      # $actual | Should Not Be $null Because "it is always defined."
      # $expected = -2
      # $actual | Should Be $expected Because "the value is 2"
    }
  }
}
# Describe "<name_of_function2> PS$PSVersion Integrations tests" { 
#   Context "Strict mode" { 
#     Set-StrictMode -Version latest
#     It "should get valid data" {
#     }
#   }
# }
