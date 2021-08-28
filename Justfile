set shell := ["pwsh", "-c"]

install:
  $modules = ("PowerShell-Beautifier", "PSScriptAnalyzer"); $modules | ForEach-Object { Install-Module -Name "$_" -Scope CurrentUser -Confirm:$False -Force; };

format:
  Import-Module -Name PowerShell-Beautifier; Get-ChildItem -Path . -Include *.ps1,*.psm1 -Recurse | Edit-DTWBeautifyScript -NewLine LF

lint:
  Import-Module -Name PSScriptAnalyzer; ("./Public", "./Private") | ForEach-Object { Invoke-ScriptAnalyzer -Path "$_" };

run:
  ./Public/Invoke-CallTakingReboot.ps1

test:
  Invoke-Pester
