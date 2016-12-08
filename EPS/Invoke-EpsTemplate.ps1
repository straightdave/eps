Set-StrictMode -Version 2
$ErrorActionPreference = "Stop"
function Invoke-EpsTemplate {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
    Param(
        [Parameter(ParameterSetName='String template')]
        [String]$Template,

        [Parameter(ParameterSetName='File template')]
        [String]$Path,

        [Parameter(ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$True)]
        [Hashtable]$Binding = @{},

        [switch]$Safe
    )   
    
    if ($Null -eq $Path) {
        $Template = [IO.File]::ReadAllText($Path)
    }

    $templateScriptBlock = New-EpsTemplateScript -Template $Template
    Write-Verbose "Executing script @'`n$templateScriptBlock`n'@."

    if($Safe) {
        $block = {
            Param([String]$Script, [Hashtable]$Binding)

            $Binding.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value }
            $templateScriptBlock.Invoke()    
        }

        try {
            $powershell = [powershell]::Create()
            $powershell.`
                AddScript($block).`
                AddParameter("Binding", $Binding).`
                AddParameter("Script", $script).`
                Invoke()[0]
        } finally {
            if ($powershell) {
                $powershell.Dispose()
            }
        }
    } else {
        if ($templateScriptBlock.psobject.Methods['InvokeWithContext']) {
            # InvokeWithContext was introduced in PowerShell version 3.0
            $variablesToDefine = $Binding.GetEnumerator() | 
                ForEach-Object { New-Object System.Management.Automation.PSVariable @($_.Key, $_.Value) }
            $templateScriptBlock.InvokeWithContext(@{}, $variablesToDefine)
        } else {
            $Binding.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value }
            $templateScriptBlock.Invoke()
        }
    }
}