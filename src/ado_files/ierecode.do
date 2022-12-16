			else if "`type'" == "other" {
				replace  strvaluecurrent = ".v" if strvaluecurrent == "*"
				destring catvalue, replace
			}

***********************************
* Check variables in other sheet
***********************************

cap program drop _checkcolother
  program   	 _checkcolother, rclass
  
 	syntax, ///
		idvar(string) originalvars(string) ///
		[stringvars(string) floatvars(string) doublevars(string) ///
		data(string) debug generate]

	if !missing("`debug'") noi di as result "Entering checkcolother subcommand"
  
	  
		* Keep only relevant variables -- the user may have added notes that are not relevant for the command
		keep strvar strvaluecurrent catvar catvalue
		
		* Check that strvar and catvar contain strings
		foreach var in strvar catvar strvaluecurrent {
			_fillvartype, type(other) vartype(string) var(`var') `debug'
			if "`r(errortype)'" == "1" local errortype 1
		}
		
		_fillvartype, type(other) vartype(numeric) var(catvalue) `debug'
		if "`r(errortype)'" == "1" local errortype 1
		
		* Check that variables listed in column strvar are string variables
		qui levelsof strvar, local(stringvars)
		foreach var of local stringvars {
			_vargen,  type(categorical) vartype(string) column(strvar) var(`var') originalvars(`originalvars') `debug'
			if "`r(errorgen)'" == "1" local errorgen 1
			
			_vartype, type(categorical) vartype(string) column(strvar) var(`var') stringvars(`stringvars')  `debug'
			if "`r(errortype)'" == "1" local errortype 1
		}
		
		* Check that variables listed in column catvar are numeric variables
		qui levelsof catvar, local(catvars)
		foreach var of local catvars {
			_vargen,  type(categorical) vartype(numeric) column(catvar) var(`var') originalvars(`originalvars') `debug' `generate'
			if "`r(errorgen)'" == "1" 	 local errorgen 1
			if !missing("`r(genvars)'")  local genvars 	"`genvars' `r(genvars)'"
			
			_vartype, type(categorical) vartype(numeric) column(catvar) var(`var') stringvars(`stringvars')  `debug'
			if "`r(errortype)'" == "1" local errortype 1
		}

		* All columns in this sheet must be specified
		_fillrequired, type(other) varlist(strvar strvaluecurrent catvar) vartype(string) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		_fillrequired, type(other) varlist(catvalue) vartype(numeric) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		* Check if the string columns have extra whitespaces and special characters
		foreach var in strvar strvaluecurrent {
		  _valstrings `var', location(Column)         
		}
    
    return local errorfill	`errorfill'
	return local errorgen 	`errorgen'
	return local errortype 	`errortype'
	return local genvars 	`genvars'
    
end  

else if   "`type'" == "other"				local columns	strvar strvaluecurrent catvar catvalue
	
		if "`type'" == "other" local message " Check the variable name or use option {bf:generate} to create the variable."
		
		else if !regex(" `originalvars' ", " `var' ") & !missing("`generate'") {
			local genvars	`var'
		}
	return local genvars	`genvars'
	
	
***************************
* Write 'other' corrections
***************************

cap program drop 	_doother
	program    		_doother
  
	syntax , ///
		doname(string) idvar(string) ///
		[originalvars(string) floatvars(string) doublevars(string) stringvars(string) ///
		debug generate] 

	if !missing("`debug'") noi di as result "Entering doother subcommand"
  
		file write  `doname'      "** Adjust categorical variables to include 'other' values " _n

		qui count
		forvalues row = 1/`r(N)' {

			local strvar      		= strvar[`row']
			local strvaluecurrent 	= strvaluecurrent[`row']
			local strvaluecurrent 	= `""`strvaluecurrent'""'
			local catvar       		= catvar[`row']
			local catvalue       	= catvalue[`row']
		
			file write `doname'    `"replace `catvar' = `catvalue'"'

			if `"`strvaluecurrent'"' != ".v"  {
			  file write `doname'    `" if `strvar' == `strvaluecurrent'"' _n
			}
		}

end

* Other variables
		if "`other'" != "" {
			templatesheet using "`using'", ///
				varlist("strvar strvaluecurrent catvar catvalue initials notes") ///
				sheetname("other") ///
				current("strvalue")
		}
		
		if !missing("`genvars'") & !missing("`generate'") {
		foreach var in `genvars' {
			cap  file close   `doname'
			qui  file open    `doname' using "`dofile'", text write append
				 file write   `doname' `"gen `var' = .  "' _n     										 // <---- Writing in do file here
				 file close   `doname'	
		}
	}

				_vargen,  type(numeric) vartype(numeric) column(varname) var(`var') originalvars(`originalvars') `debug'
			if "`r(errorgen)'" == "1" local errorgen 1

*************************
* Check if variable exits
*************************

cap program drop _vargen
	program    	 _vargen, rclass
	
	syntax, type(string) vartype(string) column(string) var(string) originalvars(string) [debug]

	if !missing("`debug'")	noi di as result "Entering vargen subcommand"

		if !regex(" `originalvars' ", " `var' ") {
			noi di as error `"{phang} The variable {bf:`var'} listed in column {bf:`column'} of sheet {bf:`type'} does not exist in the dataset.`message'{p_end}"'
			local errorgen	1
		}

	return local errorgen	`errorgen'

end