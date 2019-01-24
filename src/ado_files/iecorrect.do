cap program drop iecorrect
	program 	 iecorrect
		
	syntax using/, [GENerate idvar(varlist) save(string) replace]
		
		
		cap confirm file "`using'"
		noi di _rc
		if _rc {
			noi di as error "file does not exist"
			error 601
		}
		else {
		
			tempname	corrections
			tempfile	correctionsfile

		cap	file close 	corrections
			file open  	corrections using "`correctionsfile'", text write replace
			file write  corrections		  "* Write header here" _n _n
			file close  corrections		  
			
		preserve
		
			* Numeric variables corrections
			noi di "import 'numeric' sheet"
		cap import excel "`using'", sheet("numeric") firstrow allstring clear
		if !_rc {
			
			drop if missing(numvar)
			foreach var of varlist numvar {
				levelsof `var', local(`var'List)
			}
			
			count
			if `r(N)' > 0 {						
			noi di "enter write loop"
		cap	file close 	corrections	
			file open  	corrections using "`correctionsfile'", text write append
			file write  corrections		  "** Correct entries in numeric variables " _n
				forvalues row = 1/`r(N)' {
					
					local var			= numvar[`row']
					local valuecurrent 	= valuecurrent[`row']
					local value		 	= value[`row']
					local idvalue		= idvalue[`row']

					file write corrections		`"replace `var' = `value' if "'
					
					if "`idvar'" != "" {
						file write corrections	`"`idvar' == `idvalue' "'
						
						if "`valuecurrent'" != "" {
							file write corrections	`"& "'
						}
					}
					
					if "`valuecurrent'" != "" {
						noi di "enter valuecurrent"
						file write corrections	 `"`var' == `valuecurrent'"'
					}
					
					file write corrections	_n
				}
			file write  corrections		  _n _n
			
			noi di "exit write loop"
			file close corrections
			}		
	}		
			* String variables corrections
			noi di "import 'string' sheet"
		cap	import excel "`using'", sheet("string") firstrow allstring clear
		if !_rc {
		
			drop if missing(strvar)
			foreach var of varlist strvar {
				levelsof `var', local(`var'List)
			}
			
			count
			if `r(N)' > 0 {
		cap	file close 	corrections
			file open  	corrections using "`correctionsfile'", text write append
						
			noi di "enter write loop"
			file write  corrections		  "** Correct entries in string variables " _n
				forvalues row = 1/`r(N)' {
					
					local var			= strvar[`row']
					
					local valuecurrent 	= valuecurrent[`row']
					local valuecurrent	= `""`valuecurrent'""'
					
					local value		 	= value[`row']
					local value			= `""`value'""'
					
					local idvalue		= idvalue[`row']

					file write corrections		`"replace `var' = `value' if "'
					
					if "`idvar'" != "" {
						file write corrections	`"`idvar' == `idvalue' "'
						
						if "`valuecurrent'" != "" {
							file write corrections	`"& "'
						}
					}
					
					if "`valuecurrent'" != "" {
						noi di "enter valuecurrent"
						file write corrections	 `"`var' == `valuecurrent'"'
					}
					
					file write corrections	_n
				}
			file write  corrections		  _n _n
			
			noi di "exit write loop"
			file close corrections
			}		
		}	
			* 'Other' variables
			noi di "import 'other' sheet"
		cap	import excel "`using'", sheet("other") firstrow allstring clear
		if !_rc {
			
			drop if missing(strvar)
			foreach var of varlist strvar catvar {
				levelsof `var', local(`var'List)
			}
			
			count
			if `r(N)' > 0 {
		cap	file close 	corrections
			file open  	corrections using "`correctionsfile'", text write append
						
			noi di "enter write loop"
			
			file write  corrections		  "** Adjust categorical variables to include 'other' values " _n
				forvalues row = 1/`r(N)' {
					
					local strvar			= strvar[`row']
					
					local strvaluecurrent 	= strvaluecurrent[`row']
					local strvaluecurrent	= `""`strvaluecurrent'""'
					
					local strvalue		 	= strvalue[`row']
					local strvalue			= `""`strvalue'""'
					
					local catvar		 	= catvar[`row']
					local catvalue		 	= catvalue[`row']

					if "`catvar'" != ""	{
						noi di "enter first if"
						file write corrections		`"replace `catvar' = `catvalue' if `strvar' == `strvaluecurrent'"' _n
					}
					if !(regex(`strvalue',`strvaluecurrent') & regex(`strvalue',`strvaluecurrent'))	{
						noi di "enter second if"
						file write corrections		`"replace `strvar' = `strvalue' if `strvar' == `strvaluecurrent'"' _n
					}
				}
			file write  corrections		  _n _n
			
			noi di "exit write loop"
			file close corrections
			}			
		}	
		restore
		
		noi di "Back to original file"
		
		* Test if variables exist
		foreach varType in strvar catvar numvar idvar {
			foreach var of local `varType'List {
				cap confirm variable `var'
				if _rc {
					if "`generate'" != "" {
						gen `var' = .
					}
					else {
						noi di as error "There is no variable called `var'. To create this variable, use the generate option."
						exit
					}
				}
			}
		}
		
		* Test if numeric variable is numeric
		
		
		noi di "Read corretions"
		file open corrections using "`correctionsfile'", read
		file read corrections line
		
		noi di "Run each line"
		while r(eof)==0 {
			display `"`line'"'
			`line'
			file read corrections line
		}

		noi di "Close corrections"
		file close corrections
		
		if "`save'" != "" {
			copy "`correctionsfile'" `"`save'"', `replace'
		}
	}
	end
