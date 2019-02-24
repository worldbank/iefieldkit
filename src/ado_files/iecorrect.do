*! version 0 - NOT READY FOR DISTRIBUTION

cap program drop iecorrect
	program 	 iecorrect
		
	syntax [anything] using/, [GENerate idvar(varlist) NOIsily save(string) replace]
		
	gettoken subcommand anything : anything
	
	if "`subcommand'" == "apply" {
	
/*******************************************************************************	
	Tests
*******************************************************************************/
	
	preserve
	
		* Check that folder exists
		
		* Check that file exists
		cap confirm file "`using'"
		noi di _rc
		if _rc {
			noi di as error "file does not exist"
			error 601
		}
		
		checksheets using "`using'", type(numeric) typeshort(num)
		local numcorr 	r(numcorr)
		local datanum  	r(datanum)
		local numvars	r(numvars)
		
		noi di as result `"{phang}Numeric variables to be corrected: `numvars'"'
		
		checksheets using "`using'", type(string) typeshort(str)
		checksheets using "`using'", type(other) typeshort(str)
		
	restore
	
	*test that variables exist in the original data set
	*check that the variables have the same format in the original data set
	
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
					
		* Write the corrections
		foreach type in numeric string other {
			
			local typeshort = substr("`type'", 1, 3)
			
			preserve
				
				* Open the data set with the numeric corrections
				use "`type'", clear
				
						
			
				* Open the placeholder do file and write the corrections to be made
				cap	file close 	doname	
					file open  	doname using "`dofile'", text write append
					
					file write  doname		  "** Correct entries in numeric variables " _n								// <---- Writing in do file here
					
					forvalues row = 1/`r(N)' {
	
						file write	doname	  `"r(doline)"' _N
					
					}
					
				* Add an extra space before the next set of corrections
				file write  doname		  _n _n																		// <---- Writing in do file here
				
				* And close the do file
				noi di "exit write loop"
			file close doname
		
		restore
		}
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
		
		*/
	}
	else if "`subcommand'" == "template" {
	
		* Check that folder exists
		* Check that file doesn't already exist
		* Create the template
	
		preserve
		
			* String variables
			template using "`using'", ///
				varlist("strvar idvalue valuecurrent value initials notes") ///
				sheetname("string") ///
				current("value")
						
			* Numeric variables
			template using "`using'", ///
				varlist("numvar idvalue valuecurrent value initials notes") ///
				sheetname("numeric") ///
				current("value")
			
			* Other variables
			template using "`using'", ///
				varlist("strvar strvaluecurrent strvalue catvar catvalue initials notes") ///
				sheetname("other") ///
				current("strvalue")
			
			* Drop observations
			template using "`using'", ///
				varlist("idvar initials notes") ///
				sheetname("drop_obs")
			
			noi di as result `"{phang}Template spreadsheet saved to: {browse "`using'":`using'} "'
	
		}
		else if !inlist("`subcommand'","template","apply") {
			di as err "{bf:iecorrect} requires [template] or [apply] to be specified with a target [using] file. Type {bf:help iecorrect} for details."
		}
	
	end
	
/*******************************************************************************	
	Initial checks
*******************************************************************************/
	
cap program drop checksheets
	program 	 checksheets
	
	syntax using/, type(string) typeshort(string) rclass
	
		
	cap import excel "`using'", sheet("`type'") firstrow allstring clear
	* If the sheet does not exist, then say no corrections of this type
	if _rc == {
		
	}
	* If the sheet exist, check that it is correctly specified
	else {
		
		* Drop extra lines in the excel
		drop if missing(`typeshort'var)
	
		* Are any observations still left?
		count
		if `r(N)' > 0 {
				
			* Check that the sheet is filled correctly
			checkcol`typeshort'
			
			*If everything works, save the sheet in a tempfile and create a local saying to run the next command
			local	`typeshort'corr	1 
			
			tempfile data`typeshort'
			save	 `data`typeshort''
		
		}
		else if `r(N)' == 0 {
			local	`typeshort'corr	0
			noi di as result `"{phang}No `type' variables to correct."'
		}
		
		return local `typeshort'corr 	`typeshort'corr'
		return local data`typeshort' 	"`data`typeshort''"
	}
	
	
	end
	
**********************************
* Check variables in numeric sheet
**********************************
cap program drop checkcolnum
	program 	 checkcolnum
	
	syntax [anything]
	
		*Are all the necessary variables there?
		foreach var in numvar idvalue valuecurrent value {
			cap confirm var `var'
			if _rc {
				noi di as error `"{phang}Column `var' not found in `type' sheet. This variable must not be erased from the template. If you do not wish to use it, leave it blank."'
			}
		}
		
		* Keep only those variables in the data set
		keep numvar idvalue valuecurrent value 
		
		* Check that variables have the correct format
		cap confirm string var numvar
		if _rc {
			noi di as error `"{phang}Column numvar in `type' sheet is not a string. This column should contain the name of the `type' variables to be corrected."'
		}
				
		cap confirm 	   var valuecurrent
		if !rc {
			cap confirm string var valuecurrent
			if !_rc {
				noi di as error `"{phang}Column valuecurrent in `type' sheet is not numeric. This column should contain the values of the `type' variables to be corrected."'
			}
		}
		
		cap confirm string var value
		if !_rc {
			noi di as error `"{phang}Column value in `type' sheet is not numeric. This column should contain the correct values of the `type' variables to be corrected."'
		}
		
		* Either idvalue or valuecurrent need to be specified
		
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

				
				* Write one line of correction for each line in the data set					
					local var			= numvar[`row']
					local valuecurrent 	= valuecurrent[`row']
					local value		 	= value[`row']
					local idvalue		= idvalue[`row']

					* The listed variable will be corrected to new value, but a condition needs to be specified.
					* The condition can be one ID variable and/or one current value.
					local line	`"replace `var' = `value' if "'												// <---- Writing in do file here
					
					* If it's an ID variables, write that in the do file
					if "`idvar'" != "" {
						local line	`"`line' `idvar' == `idvalue'"'													// <---- Writing in do file here
						
						* If it's both, add an "and"
						if "`valuecurrent'" != "" {
							local line	`"`line' & "'																	// <---- Writing in do file here
						}
					}
					
					* If there's a current value, write that in the do file.
					if "`valuecurrent'" != "" {
						noi di "enter valuecurrent"
						local line	`"`line'`var' == `valuecurrent'"'												// <---- Writing in do file here
					}
					
					
		
	end
	
***************************
* Write string corrections
***************************
cap program drop dostr
	program 	 dostr
	
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
					
					local var			= strvar[`row']						
					
					local valuecurrent 	= valuecurrent[`row']
					local valuecurrent	= `""`valuecurrent'""'
					
					local value		 	= value[`row']
					local value			= `""`value'""'
					
					local idvalue		= idvalue[`row']

					file write corrections		`"replace `var' = `value' if "'										// <---- Writing in do file here
					
					if "`idvar'" != "" {
						file write corrections	`"`idvar' == `idvalue' "'											// <---- Writing in do file here
						
						if "`valuecurrent'" != "" {
							file write corrections	`"& "'															// <---- Writing in do file here
						}
					}
					
					if "`valuecurrent'" != "" {
						noi di "enter valuecurrent"
						file write corrections	 `"`var' == `valuecurrent'"'										// <---- Writing in do file here
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
	
	
***************************
* Write string corrections
***************************

cap program drop dooth
	program 	 dooth
	
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
	
/*******************************************************************************	
	Create template
*******************************************************************************/

cap program drop template
	program		 template
	
	syntax using/, varlist(string) sheetname(string) [current(string)]
	
	clear
			
	set obs 1
	
	foreach var of local varlist {
		gen `var' = .
	}
	
	if "`curent'" != "" {
		lab var `current'current "`current':current"
	}
				
	export excel using "`using'", sheet("`sheetname'") firstrow(varlabels)
			
	end

*********************************** THE END ************************************
