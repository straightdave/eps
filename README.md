[![Build status](https://ci.appveyor.com/api/projects/status/dkkgi7fg8fsubqph?svg=true)](https://ci.appveyor.com/project/dbroeglin/eps)

# EPS

EPS ( *Embedded PowerShell* ), inspired by [ERB][erb], is a templating tool that embeds
PowerShell code into a text document. It is conceptually and syntactically similar to ERB
for Ruby or [Twig][twig] for PHP.

EPS can be used to generate any kind of text. The example below illustrates generating
plain text, but it could be used to generate HTML as in [DS][ds] or PowerShell code as
in the [Forge Module generator][forge_module].

EPS is available in the [PowerShell Gallary](https://www.powershellgallery.com/packages/EPS).
You can install the module with the following command:

```powershell
Install-Module -Name EPS
```

## Syntax

EPS allows PowerShell code to be embedded within a pair of `<% ... %>`,
`<%= ... %>`, or `<%# ... %>` as well:

- Code in `<% CODE %>` blocks are executed but no value is inserted.
  - If started with `<%-` : the preceding indentation is trimmed.
  - If terminated with `-%>` : the following line break is trimmed.
- Code in `<%= EXPRESSION %>` blocks insert the value of `EXPRESSION`.
  - If terminated with `-%>` : the following line break is trimmed.
- Text in `<%# ... %>` blocks are treated as comments and are removed from the output.
  - If terminated with `-%>` : the following line break is trimmed.
- `<%%` and `%%>` : are replaced respectively by `<%` and `%>` in the output.

All blocks accept multi-line content as long as it is valid PowerShell.

## Command Line Usage

```PowerShell
Invoke-EpsTemplate [-Template <string>] [-Binding <hashtable>] [-Safe]  [<CommonParameters>]

Invoke-EpsTemplate [-Path <string>] [-Binding <hashtable>] [-Safe]  [<CommonParameters>]
```

- use `-Template` to render the template in the corresponding string.
than a file
- use `-Path` to render the template in the corresponding file.
- `-Safe` renders the template in **isolated** mode (in another thread/powershell
instance) to avoid variable pollution (variable that are already in the current
scope).
- if `-Safe` is provided, you must bind your values using `-Binding` option
with a `Hashtable` containing key/value pairs.

## Example

A very simple example of EPS would be :

```powershell
$name = "Dave"

Invoke-EpsTemplate -Template 'Hello <%= $name %>!'
```

This script produces the following result:

```
Hello Dave!
```

In a template file `Test.eps`:

```
Hi <%= $name %>

<%# this is a comment -%>
Please buy me the following items:
<% 1..5 | %{ -%>
  - <%= $_ %> pigs ...
<% } -%>

Dave is a <% if($True) { %>boy<% } else { %>girl<% } %>.

Thanks,
Dave
<%= (Get-Date -f yyyy-MM-dd) %>
```

Then render it in on the command line:
```powershell
Import-Module EPS

$name = "ABC"
Invoke-EpsTemplate -Path Test.eps
```

Here it is in non-safe mode (render template with values in current run space)
To use safe mode (render the template in an isolated scope) execute: `Invoke-EpsTemplate -Path Test.eps -Safe` with binding values

It will produce:

```
Hi dave

Please buy me the following items:
  - 1 pigs ...
  - 2 pigs ...
  - 3 pigs ...
  - 4 pigs ...
  - 5 pigs ...

Dave is a boy.

Thanks,
Dave
2016-12-07
```

Or you can use safe mode with data bindings:
```powershell
Invoke-EpsTemplate -Path Test.eps -Safe -binding @{ name = "dave" }
```

which will generate the same output.

## More examples

### Multi-line code or expression blocks

You can use multi-line statements in blocks:

```powershell
$name = "Dave"

Invoke-EpsTemplate -Template @'
Hello <%= $name %>!
Today is <%= Get-Date -UFormat %x %>.
'@
```

will produce:

```
Hello Dave!
Today is 11/12/17.
```

### Iterating and joining the results

Sometimes we would like to iterate over a collection, generate some text for each
element and finally join the generated blocks together with a separator.

#### Inside expression blocks

In an expression block we can use the following idiomatic PowerShell snippet:

```powershell
Invoke-EpsTemplate -Template @'
<%= ("Id", "Name", "Description" | ForEach-Object { "[String]`$$_" }) -Join ",`n" -%>
'@
```
which would generate the following result:

```powershell
[String]$Id,
[String]$Name,
[String]$Description
```
#### With EPS templating elements

However, due to EPS internal workings, the following code would not work:

```powershell
Invoke-EpsTemplate -Template @'
<% ("Id", "Name", "Description" | ForEach-Object { -%>
[String]$<%= $_ -%>
<% }) -join ",`n" -%>
'@
```

The `-join` operator is ignored by EPS:

```
[String]$Id[String]$Name[String]$Description
```

This is expected behavior because `-join` is applied to the result of 
`ForEach-Object` which is defined inside a _CODE_ block and should not produce
any output.

EPS provides an internal `Each` function whose behavior is similar to 
`ForEach-Object` but achieves the desired result inside a template :

```PowerShell
Each [-Process] <scriptblock> [-InputObject <Object[]>] [-Begin <scriptblock>] [-End <scriptblock>] [-Join <string>]
```

`Each` can only be used in PS v3 or above.

This snippet of EPS would generate the desired result (notice that `-Join` is a parameter of `Each`
and is not applied to its result value as would be the case with the `-join` operator):

```powershell
Invoke-EpsTemplate -Template @'
<% "Id", "Name", "Description" | Each { -%>
[String]$<%= $_ -%>
<% } -Join ",`n" -%>
'@
```

and generate:

```powershell
[String]$Id,
[String]$Name,
[String]$Description
```

In some cases it can be useful to also generate a prefix and suffix to the iterated part:

```powershell
Invoke-EpsTemplate -Template @'
<% "Id", "Name", "Description" | Each { -%>
[String]$<%= $_ -%>
<% } -Begin { %>[NSSession]$Session<% } -End { %>[String]$LogLevel<% } -Join ",`n" -%>
'@
```

will generate:

```powershell
[NSSession]$Session,
[String]$Id,
[String]$Name,
[String]$Description,
[String]$LogLevel
```

Notice that when using `-Begin` and/or `-End` with `-Join` all blocks are joined together.

If you want to prefix and suffix, _without_ joining the prefix and suffix, use the following
pattern:

```powershell
Invoke-EpsTemplate -Template @'
Param(
<% "Id", "Name", "Description" | Each { -%>
    [String]$<%= $_ -%>
<% } -Join ",`n" %>
)
'@
```

Which will generate:

```powershell
Param(
    [String]$Id,
    [String]$Name,
    [String]$Description
)
```

### Iterating with an index

In some cases it is useful to iterate over a collection while maintaining an _index_ of the
current item. The `Each` function exposes a `$index` variable to the script blocks it executes.
The `$index` variable starts at 0 for the first element.

```powershell
Invoke-EpsTemplate -Template @'
<% "Dave", "Bob", "Alice" | Each { -%>
<%= $Index + 1 %>. <%= $_ %>
<% } -%>
'@
```

would generate the following listing:

```
1. Dave
2. Bob
3. Alice
```

### Handling default values

Using default values if the provided variable is `$Null` or empty (as returned by the `[string]::IsNullOrEmpty` function) is a very common pattern which can be done easily with a template like:

```powershell
$config = [PSCustomObject]@{
  Host = "localhost"
  #Port = "8080" # this would be an optional configuration value
}
Invoke-EpsTemplate -Template @'
<%= $config.Host 
%>:<%= 
  if ([string]::IsNullOrEmpty($config.Port)) { "80" } else { $config.Port }
%>
'@
```

EPS provides a `Get-OrElse` function that allows for a shorter version:

```powershell
$config = [PSCustomObject]@{
  Host = "localhost"
  #Port = "8080" # this would be an optional configuration value
}
Invoke-EpsTemplate -Template @'
<%= $config.Host %>:<%= Get-OrElse $config.Port "80" %>
<%= $config.Host %>:<%=  $config.Port | Get-OrElse -Default "80" %>
'@
```

## Contribution

* Original version was written by [Dave Wu](https://github.com/straightdave).
* Maintained now and extended by [Dominique Broeglin (@dbroeglin)](https://github.com/dbroeglin), thank you pal 谢谢！

Help find more bugs! Or find more usage of this tool...
Author's email: eyaswoo@163.com

[erb]: https://en.wikipedia.org/wiki/ERuby
[twig]: http://twig.sensiolabs.org/
[ds]: https://github.com/straightdave/ds
[forge_module]: https://github.com/dbroeglin/Forge.Module
