$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Describe 'EPS Module' {
    
    $ModuleName   = "EPS"
    $ManifestPath = "$here\..\$ModuleName\$ModuleName.psd1"

    It "loads" {
        {
            Import-Module -Force $ManifestPath
        } | Should Not Throw
    }

    AfterEach {
        Remove-Module $ModuleName
    }
}
