# PSLogFileReporter

## Compatible with powershell core and powershell 5.1 (the default windows powershell on most systems)

## Install

> Install-Module -Name powershell_scaffolder -Scope CurrentUser -Force

## Development Tools
- VSCode
- Powershell extension for vscode

## Publishing to PSGallery
REQUIRES PSCORE

```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Import-Module -Name PSLogFileReporter

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force # DOESNT WORK FOR NONADMIN

Publish-Module -name PSLogFileReporter -NuGetApiKey 'api_key'

