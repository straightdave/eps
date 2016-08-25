$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$here\..\EPS" -Force

Describe 'Expand-EPS' {
	Context 'with template "``#"" and with -Binding' {
		$Template = "```"`$Test#``0``"
		It 'escapes properly when needed' {
			Expand-Template -Template $Template | Should Be "```"`$Test#``0```n"
		}
	}
	Context 'with template "Hello <%= $A %>!" and with -Binding' {
		$Template = 'Hello <%= $A %>!'
		BeforeEach {
			$Binding  = @{}	
		}
		It 'expands to Hello Titi !' {
			$binding.A = 'Titi'
			Expand-Template -Template $Template -Binding $Binding| Should Be "Hello Titi!`n"
		}
		It 'expands to Hello !' {
			$A = $Null
			Expand-Template -Template $Template -Binding $Binding | Should Be "Hello !`n"
		}	
		It 'expands to Hello World!' {
			$binding.A = 'World'
			Expand-Template -Template $Template -Binding $Binding | Should Be "Hello World!`n"
		}
	}
	Context 'with template "Hello <%= $A %>!" and with pipeline' {
		$Template = 'Hello <%= $A %>!'
		BeforeEach {
			$Binding  = @{}		
		}			
		It 'expands to Hello Titi !' {
			$binding.A = 'Titi'
			$binding | Expand-Template -Template $Template | Should Be "Hello Titi!`n"
		}
		It 'expands to Hello !' {
			$binding | Expand-Template -Template $Template | Should Be "Hello !`n"
		}	
		It 'expands to Hello World!' {
			$binding.A = 'World'
			$binding | Expand-Template -Template $Template | Should Be "Hello World!`n"
		}
	}
	Context "with @{ 'A' = @{ 'B' = 'XXX' }}" {
		BeforeEach {
			$Binding  = @{ 'A' = @{ 'B' = 'XXX' }}		
		}
		It 'expands "<%= $B %>" to ""' {
			$binding | Expand-Template -Template '<%= $B %>' | Should Be "`n"
		}			
		It 'expands "<%= $A.B %>" to "XXX"' {
			$binding | Expand-Template -Template '<%= $A.B %>' | Should Be "XXX`n"
		}			
		It 'expands "<%= $A.C %>" to ""' {
			$binding | Expand-Template -Template '<%= $A.C %>' | Should Be "`n"
		}			
	}	
	Context 'without Template or File arguments' {
		It 'should throw an exception ' {
			{ Expand-Template } | Should Throw "Either Template or File must be provided"
		}
	}
}
	
