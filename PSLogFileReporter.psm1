#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

Export-ModuleMember -Function "Write-DigestReport"
Export-ModuleMember -Function "Get-ReportJsonDateRange"
Export-ModuleMember -Function "Get-ReportTxtDateRange"
Export-ModuleMember -Function "Get-ReportDateRange"
Export-ModuleMember -Function "Get-ReportForDay"
Export-ModuleMember -Function "Get-JsonDataConverter"
Export-ModuleMember -Function "Get-TxtDataConverter"
Export-ModuleMember -Function "Get-ReportJsonFile"
Export-ModuleMember -Function "Get-ReportTxtFile"

