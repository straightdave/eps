Set-StrictMode -Version 2
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\..\EPS\New-EpsTemplateScript.ps1"
. "$here\..\EPS\Invoke-EpsTemplate.ps1"

Describe 'Invoke-EpsTemplate' {
	Context 'with trivial templates' {
		It '"" expands to ""' {
			Invoke-EpsTemplate -Template "" | Should Be ""
		}
		It '"   " expands to "   "' {
			Invoke-EpsTemplate -Template "   " | Should Be "   "
		}
		It '"abc" expands to "abc"' {
			Invoke-EpsTemplate -Template "abc" | Should Be "abc"
		}
		It '"`n" expands to "`n"' {
			Invoke-EpsTemplate -Template "`n" | Should Be "`n"
		}
		It '"<%%" expands to "<%"' {
			Invoke-EpsTemplate -Template "<%%" | Should Be "<%"
		}
		It '"%%>" expands to "%>"' {
			Invoke-EpsTemplate -Template "%%>" | Should Be "%>"
		}

		It '"<%% a %%>" expands to "<% a %>"' {
			Invoke-EpsTemplate -Template "<%% a %%>" | Should Be "<% a %>"
		}
		It '"<%% a %%> " expands to "<% a %> "' {
			Invoke-EpsTemplate -Template "<%% a %%> " | Should Be "<% a %> "
		}
		It '"<%% a %%>`na" expands to "<% a %>`na"' {
			Invoke-EpsTemplate -Template "<%% a %%>`na" | Should Be "<% a %>`na"
		}

		It '"a<%# b %>a" expands to "aa"' {
			Invoke-EpsTemplate -Template "a<%# b %>a" | Should Be "aa"
		}
		It '"a<%# b %>`na" expands to "a`na"' {
			Invoke-EpsTemplate -Template "a<%# b %>`na" | Should Be "a`na"
		}		
		It '"a<%# b %> a" expands to "a a"' {
			Invoke-EpsTemplate -Template "a<%# b %> a" | Should Be "a a"
		}		
	}

	Context 'with template "```"`$Test#``0``"' {
		$Template = "```"`$Test#``0``'"
		It 'escapes properly when needed' {
			Invoke-EpsTemplate -Template $Template | Should Be $Template
		}
	}

	Context 'with template "Hello <%= $A %>!" and with -Binding' {
		$Template = 'Hello <%= $A %>!'
		BeforeEach {
			$Binding  = @{}
		}
		It 'expands to Hello Titi !' {
			$binding.A = 'Titi'
			Invoke-EpsTemplate -Template $Template -Binding $Binding | Should Be "Hello Titi!"
		}
		It 'expands to Hello !' {
			$A = $Null
			Invoke-EpsTemplate -Template $Template -Binding $Binding | Should Be "Hello !"
		}
		It 'expands to Hello World!' {
			$binding.A = 'World'
			Invoke-EpsTemplate -Template $Template -Binding $Binding | Should Be "Hello World!"
		}
	}
	Context 'with binding @{ A = "Titi"; B = "Tutu" }' {
		BeforeEach {
			$Binding  = @{ A = "Titi"; B = "Tutu" }
		}
		# expression tags
		It 'expands "Hello <%=`n$A %>!" to "Hello Titi !"' {
			Invoke-EpsTemplate -Template "Hello <%=`n`$A %>!" -Binding $Binding | Should Be "Hello Titi!"
		}
		It 'expands "Hello <%= $A; $B %>!" to "Hello Titi`nTutu!"' {
			Invoke-EpsTemplate -Template "Hello <%=`$A; `$B %>!" -Binding $Binding | Should Be "Hello Titi Tutu!"
		}
		It 'expands "Hello <%= $A`n$B %>!" to "Hello Titi Tutu!"' {
			Invoke-EpsTemplate -Template "Hello <%=`$A`n`$B %>!" -Binding $Binding | Should Be "Hello Titi Tutu!"
		}
		It 'expands "<%= $a %>`n" to "Titi`n"' {
			Invoke-EpsTemplate -Template "<%= `$a %>`n" -Binding $Binding | Should Be "Titi`n"
		}

		# code tags
		It 'expands "<% (1..2) | % { %>a<% } %>" to "aa"' {
			Invoke-EpsTemplate -Template "<% (1..2) | % { %>a<% } %>" -Binding $Binding | Should Be "aa"
		}
		It 'expands "<% (1..2) | % { %><%= $_ %><% } %>" to "12"' {
			Invoke-EpsTemplate -Template "<% (1..2) | % { %><%= `$_ %><% } %>" -Binding $Binding | Should Be "12"
		}
		It 'expands "<% (1..2) | % { %><%= $_ %><% } %>" to "12"' {
			Invoke-EpsTemplate -Template "<% (1..2) | % { %><%= `$_ %><% } %>" -Binding $Binding | Should Be "12"
		}
		It 'expands "<% ''foo'' %>" to ""' {
			Invoke-EpsTemplate -Template "<% 'foo' %>" -Binding $Binding | Should Be ""
		}
		It 'expands "<% $a %>`n" to "`n"' {
			Invoke-EpsTemplate -Template "<% `$a %>`n" -Binding $Binding | Should Be "`n"
		}
		It 'expands "<% $a -%>`n" to ""' {
			Invoke-EpsTemplate -Template "<% `$a -%>`n" -Binding $Binding | Should Be ""
		}
		It 'expands "    <% $a %>" to "    "' {
			Invoke-EpsTemplate -Template "    <% `$a %>" -Binding $Binding | Should Be "    "
		}

		# trim left
		It 'expands "    <%- $a %>" to ""' {
			Invoke-EpsTemplate -Template "    <%- `$a %>" -Binding $Binding | Should Be ""
		}
		It 'expands "a`n    <%- $a %>" to "a`n"' {
			Invoke-EpsTemplate -Template "a`n    <%- `$a %>" -Binding $Binding | Should Be "a`n"
		}
		It 'expands "a`r    <%- $a %>" to "a`r"' {
			Invoke-EpsTemplate -Template "a`r    <%- `$a %>" -Binding $Binding | Should Be "a`r"
		}
		It 'expands "a`r`n    <%- $a %>" to "a`r`n"' {
			Invoke-EpsTemplate -Template "a`r`n    <%- `$a %>" -Binding $Binding | Should Be "a`r`n"
		}

		# trim eol
		It 'expands "<%= $a -%>`n" to "Titi"' {
			Invoke-EpsTemplate -Template "<%= `$a -%>`n" -Binding $Binding | Should Be "Titi"
		}
		It 'expands "<%= $a -%> `n" to "Titi `n"' {
			Invoke-EpsTemplate -Template "<%= `$a -%> `n" -Binding $Binding | Should Be "Titi `n"
		}
		It 'expands "<%= $a -%>a`n" to "Titia`n"' {
			Invoke-EpsTemplate -Template "<%= `$a -%>a`n" -Binding $Binding | Should Be "Titia`n"
		}
		It 'expands "<%= $a -%>`na" to "Titia"' {
			Invoke-EpsTemplate -Template "<%= `$a -%>`na" -Binding $Binding | Should Be "Titia"
		}
		It 'expands "<%# something -%>`na" to "a"' {
			Invoke-EpsTemplate -Template "<%# something -%>`na" -Binding $Binding | Should Be "a"
		}
	}
	Context 'with template "Hello <%= $A %>!" and with pipeline' {
		$Template = 'Hello <%= $A %>!'
		BeforeEach {
			$Binding  = @{}
		}
		It 'expands to Hello Titi !' {
			$binding.A = 'Titi'
			$Binding | Invoke-EpsTemplate -Template $Template | Should Be "Hello Titi!"
		}
		It 'expands to Hello !' {
			$binding.A = $Null
			$Binding | Invoke-EpsTemplate -Template $Template | Should Be "Hello !"
		}
		It 'expands to Hello World!' {
			$Binding.A = 'World'
			$Binding | Invoke-EpsTemplate -Template $Template | Should Be "Hello World!"
		}
	}
	Context "with @{ 'A' = @{ 'B' = 'XXX' }}" {
		BeforeEach {
			$Binding  = @{ 'A' = @{ 'B' = 'XXX' }}
		}

		It 'expands "<%= $B %>" to ""' {
			{
				$binding | Invoke-EpsTemplate -Template '<%= $B %>'
			} | Should Throw "The variable '`$B' cannot be retrieved"
		}

		It 'expands "<%= $A.B %>" to "XXX"' {
			$binding | Invoke-EpsTemplate -Template '<%= $A.B %>' | Should Be "XXX"
		}

		It 'expands "<%= $A.B`n %>" to "XXX"' {
			$binding | Invoke-EpsTemplate -Template "<%= `$A.B`n %>" | Should Be "XXX"
		}
	}
	Context 'without Template or File arguments' {
		It 'should throw an exception ' {
			{ Invoke-EpsTemplate } | Should Throw "Parameter set cannot be resolved using the specified named parameters"
		}
	}

}
	
