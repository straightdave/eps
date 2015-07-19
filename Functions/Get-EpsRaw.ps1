## Get-EpsRaw:
##
##   Used internally. To comiple templates into text
##   Input parameter '$raw' should be a [string] type.
##   So if reading from a file via 'gc/get-content' cmdlet,
##   you should join all lines together with new-line ("`n") as delimiters
##
function Get-EpsRaw{
  param(
  [string]$raw,
  [switch]$debug = $false
  )

  #========================
  # constants
  #========================
  $pre_cmd = @('$_temp = ""')
  $post_cmd = @('$_temp')
  $put_cmd = '$_temp += '
  $insert_cmd = '$_temp += '
  $p = [regex]'(?si)(?<content>.*?)(?<token><%%|%%>|<%=|<%#|<%|%>|\n)'

  #========================
  # 'global' variables
  #========================
  $content = ''
  $stag = ''  # start tag
  $line = @()
  $w = $false # whether last tag-pair is <% %>

  #========================
  # start!
  #========================
  $pre_cmd | %{ $line += $_ }
  $raw += "`n"

  $m = $p.match($raw)
  while($m.success){
    $content = $m.groups["content"].value
    $token = $m.groups["token"].value

    if($stag -eq ''){

      # escaping characters
      $content = $content -replace '"','`"'

      switch($token){
        { $_ -in '<%', '<%=', '<%#'} {
          $stag = $token
        }

        "`n" {
          if( -not $w ) {
            $content += '`n'
          }
        }

        '<%%' {
          $content += '<%'
        }

        '%%>' {
          $content += '%>'
        }

        default {
          $content += $token
        }
      }

      $w = $false
    }
    else{
      switch($token){
        '%>' {
          switch($stag){
            '<%' {
              $line += $content
              $w = $true
            }

            '<%=' {
              $line += ($insert_cmd + '"' + $content.trim() + '"')
            }

            '<%#' { }
          }

          $stag = ''
          $content = ''
        }

        "`n" {
          if($stag -eq '<%' -and $content -ne ''){
            $line += $content
          }
          $content = ''
        }

        default {
          $content += $token
        }
      }
    }

    if( $content -ne '') { $line += ($put_cmd + '"' + $content + '"') }
    $m = $m.nextMatch()
  }

  $post_cmd | %{ $line += $_ }
  $script = ($line -join ';')

  if($debug) {
    return $line
  }

  $line = $null
  $script
}
