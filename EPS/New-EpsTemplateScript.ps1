function New-EpsTemplateScript {
    Param(
        [Parameter(Mandatory = $True)]
        [AllowEmptyString()]
        [String]$Template
    )
    $position = 0
    $Pattern = [regex]("(?sm)(?<lit><%%|%%>)|" + 
        "<%(?<ind>={1,2}|-|#)?(?<code>.*?)(?<tailch>[-=])?(?<!%)%>(?<rspace>[ \t]*\r?\n)?")
    $StringBuilder = New-Object -TypeName "System.Text.StringBuilder"

    function Add-Prolog {
        [void]$StringBuilder.`
            Append("`$sb = New-Object -TypeName 'System.Text.StringBuilder'`n").`
            Append("[void]`$(`n")
    }

    function Add-String {
        Param([String]$Value) 

        if ($Value) {
            $Value = $Value -replace '([`"$])', '`$1'
            [void]$StringBuilder.Append(";`$sb.Append(`"").Append($Value).Append("`");")
        }
    }

    function Add-LiteralString {
        Param([String[]]$Values) 

        foreach ($Value in $Values) {
            [void]$StringBuilder.Append($Value)    
        }
    }

    function Add-Expression {
        Param([String]$Value)

        [void]$StringBuilder.`
            Append("`$sb.Append(`"`$(").`
            Append($Value.Replace('""', '`"`"')).`
            Append(")`");") 
    }

    function Add-Code {
        Param([String]$Value)

        [void]$StringBuilder.Append($Value)
    }

    function Add-Epilog {
        [void]$StringBuilder.Append("`n)`n`$sb.ToString()")
    }

    Add-Prolog
    $Pattern.Matches($Template) | ForEach-Object {
        $match         = $_
        $contentLength = $match.Index - $position
        $content       = $Template.Substring($position, $contentLength)
        $position      = $match.Index + $match.Length
        $lit           = $match.Groups["lit"]

        if ($lit.Success) {
            if ($contentLength -ne 0) {
                Add-String $content
            }
            switch ($lit.Value) {
                "<%%" {
                    Add-String "<%"
                }
                "%%>" {
                    Add-String "%>"
                }
            }
        } else {
            $ind           = $match.Groups["ind"].Value
            $code          = $match.Groups["code"].Value
            $tail          = $match.Groups["tailch"].Value
            $rspace        = $match.Groups["rspace"].Value

            if (($ind -ne '-') -and ($contentLength -ne 0)) {
                Add-String $content
            } else {
                Add-Code ";"
            }
            switch ($ind) {
                '=' {
                    Add-Expression $code.Trim()
                }
                '-' {
                    Add-String ($content -replace '(?smi)([\n\r]+|\A)[ \t]+\z', '$1')
                    Add-Code $code.Trim()
                }
                '' {
                    Add-Code $code.Trim()
                }
                '#' { # Do nothing
                }
            }
            if (($ind -ne '%') -and (($tail -ne '-') -or ($rspace -match '^[^\r\n]'))) {
                Add-String $rspace
            } else {
                Add-Code ";"
            }
        }
    }
    if ($position -eq 0) {
        Add-String $Template
    } elseif ($position -lt $Template.Length) {
        Add-String $Template.Substring($position, $Template.Length - $position)
    }
    Add-Epilog

    [ScriptBlock]::Create($StringBuilder.ToString())
}
