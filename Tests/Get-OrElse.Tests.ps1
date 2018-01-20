Set-StrictMode -Version 2
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\..\EPS\Get-OrElse.ps1"

Describe 'Get-OrElse' {
    Context 'with pipelined value' {
        It 'returns default if value is null' {
            Get-OrElse $Null "default" | Should Be "default"
        }
        It 'returns default if value is empty' {
            Get-OrElse "" "default" | Should Be "default"
        }
        It 'returns value if value is neither null or empty' {
            Get-OrElse "a" "default" | Should Be "a"
            Get-OrElse 1   "default" | Should Be 1
            Get-OrElse " " "default" | Should Be " "
        }

    }
    Context 'with pipeline value' {
        It 'returns default if value is null' {
            $Null | Get-OrElse -Default "default" | Should Be "default"
        }
        It 'returns default if value is empty' {
            "" | Get-OrElse -Default "default" | Should Be "default"
        }
        It 'returns value if value is neither null or empty' {
            "a" | Get-OrElse -Default "default" | Should Be "a"
            1   | Get-OrElse -Default "default" | Should Be 1
            " " | Get-OrElse -Default "default" | Should Be " "
        }
    }
}