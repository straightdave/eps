
function Coalesce{
  param($var, $def)
  if($var -eq $null) { return $def } else { return $var }
}
Set-Alias ?? Coalesce

function Seek-Variable{
  param([string]$varname, $binding)
  $binding = ?? $(Get-Variable)
  ($binding | ?{$_.name -eq $varname}).value  
}

function EPS-Compile{
  param(
  [string]$template,
  $binding
  )
  
  
  
  
  
  
  





}

