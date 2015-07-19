$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

# Source all Functions
"$moduleRoot\Functions\*.ps1" |
Resolve-Path |
Where-Object { -not ($_.ProviderPath.Contains(".Tests.")) } |
ForEach-Object { . $_.ProviderPath }

# create aliases for old function names
New-Alias EPS-Render New-EpsResult
New-Alias Compile-Raw Get-EpsRaw
Export-ModuleMember -Alias EPS-Render -function New-EpsResult
Export-ModuleMember -Alias Compile-Raw -function Get-EpsRaw
