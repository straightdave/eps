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

```Powershell
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

In a template file 'Test.eps':   

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
To use safe mode: using `Invoke-EpsTemplate -Path Test.eps -Safe` with binding values
   
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

You can use multi-line statements in blocks:   

```powershell
$template = @'
<%=
  $name = "dave"
  
  1..5 | %{
    "haha"
  }
%>

Hello, I'm <%= $name %>.
'@

Invoke-EpsTemplate -Template $template
```

will produce:

```
haha haha haha haha haha

Hello, I'm dave.
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
