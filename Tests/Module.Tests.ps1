Describe 'EPS Module' {
    
    $ModuleName   = "EPS"
    $ManifestPath = "$PSScriptRoot\..\$ModuleName\$ModuleName.psd1"

    It "loads" {
        {
            Import-Module -Force $ManifestPath
        } | Should Not Throw
    }

    AfterEach {
        Remove-Module $ModuleName
    }
}
