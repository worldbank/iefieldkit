*! version 0 - NOT READY FOR DISTRIBUTION

cap program drop iecorrect
	program 	 iecorrect
		
	syntax using/, [GENerate idvar(varlist) NOIsily save(string) replace]
		
	preserve
	
/*******************************************************************************	
	Open file and check which types of corrections need to be made
*******************************************************************************/
		
		* Check that folder exists
		
		* Check that file exists
		cap confirm file "`using'"
		noi di _rc
		if _rc {
			noi di as error "file does not exist"
			error 601
		}
		
		*Numeric variables
		noi di "import 'string' sheet"
			* Check that there are numeric corrections
			* Check that corrections are correctly specified
		
		*String variables
			* Check that there are numeric corrections
			* Check that corrections are correctly specified
			
		*"Other" variables
			* Check that there are numeric corrections
			* Check that corrections are correctly specified
		
		
/*******************************************************************************	
	Create a do file containing the corrections
*******************************************************************************/		
		
		* Define tempfile
		tempname	doname
		tempfile	dofile
		
		* If the do file will be saved for later reference, add a header
		if "`save'" != "" {
			doheader , doname("`doname'") dofile("`dofile'")
		}
					
		* If there are corrections to be made to numeric variables, then make them		
		if `numeric' {
			corrnum using `datanum', doname("`doname'") dofile("`dofile'")
		}
		
		*String variables
		*"Other" variables
		
		* If the do file will be saved for later reference, add a footer
		if "`save'" != "" {
			dofooter , doname("`doname'") dofile("`dofile'")
		}

/*******************************************************************************	
	Run the do file containing the corrections
*******************************************************************************/

		dorun , doname("`doname'") dofile("`dofile'") `noisily'
		
/*******************************************************************************	
	Save the do file containing the corrections if "save" was selected
*******************************************************************************/

		if "`save'" != "" {
		
			* Check that folder exists
			copy "`dofile'" `"`save'"', `replace'
			
			noi di as result `"{phang}Corrections do file was saved to: {browse "`save'":`save'} "'
		}

	restore
	
	end
	
		
			* String variables corrections
			
		if !_rc {
		
			drop if missing(strvar)

			
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
		
		
		
		
	}
	end

/*******************************************************************************	
	Initial checks
*******************************************************************************/
	
cap program drop checksheets
	program 	 checksheets
	
	cap import excel "`using'", sheet("numeric") firstrow allstring clear
	
	* If the sheet does not exist, then say no corrections of this type
	if _rc == {
		
	}
	* If the sheet exist, check that it is correctly specified
	else {
		
		* Drop extra lines in the excel
		drop if missing(numvar)
	
		* Are any observations still left?
		count
		if `r(N)' > 0 {
				
		*Are all the necessary variables there?
			* If numeric corrections, either idvalue or valuecurrent need to be specified
		
			*Are they the right format?
			foreach var of varlist numvar {
				levelsof `var', local(numlist)		
			}
		}
		
		tempfile datanum
		save	 `datanum'
		
		*Do the variables referred to in the file exist?
		*Are they the right format?
		*If everything works, save the sheet in a tempfile and create a local saying to run the next command
	}
	
	
	end
	
/*******************************************************************************	
	Write the do file with corrections
*******************************************************************************/

**********************
* Write do file header
**********************
cap program drop doheader
	program 	 doheader
	
	syntax , doname(string) dofile(string)
	
		cap	file close 	`doname'
			file open  	`doname' using 	"`dofile'", text write replace
			
			file write  `doname'		"* Write header here" _n _n														// <---- Writing in do file here
			
			file close  `doname'	
			
	end

***************************
* Write numeric corrections
***************************
cap program drop donum
	program 	 donum
	
	syntax using/ , doname(string) dofile(string)

		preserve
			
			* Open the data set with the numeric corrections
			use "`using'", clear
		
			* Open the placeholder do file and write the corrections to be made
			cap	file close 	`doname'	
				file open  	`doname' using "`dofile'", text write append
				
				file write  `doname'		  "** Correct entries in numeric variables " _n								// <---- Writing in do file here
				
				* Write one line of correction for each line in the data set
				forvalues row = 1/`r(N)' {
					
					local var			= numvar[`row']
					local valuecurrent 	= valuecurrent[`row']
					local value		 	= value[`row']
					local idvalue		= idvalue[`row']

					* The listed variable will be corrected to new value, but a condition needs to be specified.
					* The condition can be one ID variable and/or one current value.
					file write `doname'		`"replace `var' = `value' if "'												// <---- Writing in do file here
					
					* If it's an ID variables, write that in the do file
					if "`idvar'" != "" {
						file write `doname'	`"`idvar' == `idvalue' "'													// <---- Writing in do file here
						
						* If it's both, add an "and"
						if "`valuecurrent'" != "" {
							file write `doname'	`"& "'																	// <---- Writing in do file here
						}
					}
					
					* If there's a current value, write that in the do file.
					if "`valuecurrent'" != "" {
						noi di "enter valuecurrent"
						file write `doname'	 `"`var' == `valuecurrent'"'												// <---- Writing in do file here
					}
					
					* Noew add an extra line
					file write `doname'	_n																				// <---- Writing in do file here
				}
					
				* Add an extra space before the next set of corrections
				file write  `doname'		  _n _n																		// <---- Writing in do file here
				
				* And close the do file
				noi di "exit write loop"
			file close `doname'
		
		restore
		
	end
	
	
**********************
* Write do file footer
**********************
cap program drop dofooter
	program 	 dofooter
	
	syntax , doname(string) dofile(string)
	
		cap	file close 	`doname'
			file open  	`doname' using 	"`dofile'", text write replace
			
			file write  `doname'		"*-------------- THE END --------------*"										// <---- Writing in do file here
			
			file close  `doname'	
			
	end
	
/*******************************************************************************	
	Run the do file with corrections
*******************************************************************************/

cap program drop dorun
	program		 dorun
	
	syntax , doname(string) dofile(string) [noisily]
	
		noi di "Read corretions"
		file open `doname' using "`dofile'", read
		file read `doname' line
		
		noi di "Run each line"
		while r(eof)==0 {
			display `"`line'"'
			`noisily' `line'
			file read `doname' line
		}

		noi di "Close corrections"
		file close `doname'
	
	end
	
	