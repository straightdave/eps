#######################################################
##
##  EPS - Embedded PowerShell
##  Dave Wu, June 2014
##
##  Templating tool for PowerShell
##  For detailed usage please refer to:
##  http://straightdave.github.io/eps
##
#######################################################

# Load functions
$functions = Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.ps1 |
    Sort-Object |
    ForEach-Object { . $_.FullName }
