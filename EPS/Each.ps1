function Each {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$True)]
        [Object[]]$InputObject,

        [Parameter(Mandatory=$True, Position=0)]
        [ScriptBlock]$Process,

        [ScriptBlock]$Begin,

        [ScriptBlock]$End,

        [String]$Join
    )
    Begin {
        $StringBuilderVar = New-Object -TypeName 'System.Management.Automation.PSVariable' 'sb'
        $ItemVar          = New-Object -TypeName 'System.Management.Automation.PSVariable' '_'
        $IndexVar         = New-Object -TypeName 'System.Management.Automation.PSVariable' @('index', 0)
        $Vars             = @($ItemVar, $StringBuilderVar, $IndexVar)

        function Invoke-InnerBlock {
            Param(
                [ScriptBlock]$ScriptBlock,
                $Item = $Null
            )
            if ($ScriptBlock) {
                $fsb = New-Object -TypeName 'System.Text.StringBuilder'
                $StringBuilderVar.Value = $fsb
                $ItemVar.Value = $Item 

                [void]$ScriptBlock.InvokeWithContext(@{}, $Vars)
                $fsb.ToString()
            }
        }
        if ($Join) {
            $Accumulator = New-Object -TypeName 'System.Collections.ArrayList'
            [void]$Accumulator.Add((Invoke-InnerBlock -ScriptBlock $Begin))
        } else {
            [void]$sb.Append((Invoke-InnerBlock -ScriptBlock $Begin))
        }
    }
    Process {
        if ($Join) {
            foreach($item in $InputObject) {
                [void]$Accumulator.Add((Invoke-InnerBlock -ScriptBlock $Process -Item $item))
                $IndexVar.Value += 1                
            }
        } else {
            foreach($item in $InputObject) {
                [void]$sb.Append((Invoke-InnerBlock -ScriptBlock $Process -Item $item))
                $IndexVar.Value += 1                
            }
        }
    }
    End {
        if ($Join) {
            [void]$Accumulator.Add((Invoke-InnerBlock -ScriptBlock $End))
            [void]$sb.Append($Accumulator.Where({ $_ -ne $Null}) -Join $Join)
        } else {
            [void]$sb.Append((Invoke-InnerBlock -ScriptBlock $End))
        }
    }
}