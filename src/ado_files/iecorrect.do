*! version 0 - NOT READY FOR DISTRIBUTION

cap program drop iecorrect
	program 	 iecorrect
		
	syntax [anything] using/, [GENerate idvar(varlist) NOIsily save(string) replace]
		
	gettoken subcommand anything : anything
	
	if !inlist("`subcommand'","template","apply") {
		di as err "{bf:iecorrect} requires [template] or [apply] to be specified with a target [using] file. Type {bf:help iecorrect} for details."
	}
	
/*==============================================================================
								APPLY SUBCOMMAND
==============================================================================*/
* cchec format of ID var
	if "`subcommand'" == "apply" {
	
/*******************************************************************************	
	Tests
*******************************************************************************/
		
		tempfile data
		save	 `data'
	
		* Check that folder exists
			
		* Check that file exists
		cap confirm file "`using'"
		if _rc {
			noi di as error `"{phang}File "`using'" could not be found."'
			error 601
		}
		
		foreach type in numeric string other drop {
		
			* Check that template was correctly filled
			checksheets using "`using'", type("`type'")
		
			* The result indicates if there are corrections of this type
			local `type'corr 	`r(`type'corr)'

			* If there are, it also lists the variables to be corrected or IDs to be dropped
			if ``type'corr' == 1 {
				local `type'vars	`r(`type'vars)'
			}	
		}
		
		/*test that variables exist in the original data set
		*check that the variables have the same format in the original data set
		
		 Test if variables exist
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
		*/
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
		* Write the corrections into the do file
		foreach type in numeric string other drop {

			if ``type'corr' {
				* Open the data set with the numeric corrections
				cap import excel "`using'", sheet("`type'") firstrow allstring clear

				* Open the placeholder do file and write the corrections to be made
				cap	file close 	`doname'
					file open  	`doname' using "`dofile'", text write append
				
					do`type', 	 doname("`doname'") idvar("`idvar'")
				
				* Add an extra space before the next set of corrections
					file write  `doname'		  _n _n					
					file close 	`doname'
			}
		}
		
		* If the do file will be saved for later reference, add a footer
		if "`save'" != "" {
			dofooter , doname("`doname'") dofile("`dofile'")
		}
	
/*******************************************************************************	
	Run the do file containing the corrections
*******************************************************************************/
		
		dorun , doname("`doname'") dofile("`dofile'") data("`data'")`noisily'
		
/*******************************************************************************	
	Save the do file containing the corrections if "save" was selected
*******************************************************************************/

		if "`save'" != "" {
		
			* Check that folder exists
			copy "`dofile'" `"`save'"', `replace'
			
			noi di as result `"{phang}Corrections do file was saved to: {browse "`save'":`save'} "'
		}					
	}
	
/*==============================================================================
							TEMPLATE SUBCOMMAND
==============================================================================*/

	if "`subcommand'" == "template" {
	
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
				varlist("idvalue initials notes") ///
				sheetname("drop")
			
			noi di as result `"{phang}Template spreadsheet saved to: {browse "`using'":`using'} "'
	
		}
	
	end
	
	
/*==============================================================================
================================================================================

								 SUBPROGRAMS
	
================================================================================	
==============================================================================*/

	
	
/*******************************************************************************	
	Initial checks
*******************************************************************************/
	
cap program drop checksheets
	program 	 checksheets, rclass
	
	syntax using/, type(string)
		prepdata `type' using "`using'"
		local mainvar `r(mainvar)'

		* Are any observations still left?
		count
		if `r(N)' > 0 {
				
			* Check that the sheet is filled correctly
			*checkcol`type'
			*If everything works, save the sheet in a tempfile and create a local saying to run the next command
			local	`type'corr	1 
						
			levelsof `mainvar', local(`type'vars)
			
			if inlist("`type'", "string", "numeric", "other") {
				noi di as result `"{phang}Variables for corrections of type `type': ``type'vars'{p_end}"'
			}
			else {
				noi di as result `"{phang}Observations to be dropped: ``type'vars'{p_end}"'
			}		
		}
		else if `r(N)' == 0 {
			local	`type'corr	0
			noi di as result `"{phang}No `type' variables to correct.{p_end}"'
		}
		
		return local `type'vars 	``type'vars'
		return local `type'corr 	``type'corr'	
	
	end
	
/**********************************
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
*/
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

***************
* Prep data set
***************
cap program drop prepdata
	program 	 prepdata, rclass
	
	syntax anything using/
		
		cap import excel "`using'", sheet("`anything'") firstrow allstring clear

		* If the sheet does not exist, throw an error
		if _rc == 601 {
			noi di as error `"{phang}No sheet caled "`anything'" was found. Do not delete this sheet. If no `anything' corrections are needed, leave this sheet empty.{p_end}"'
			error 601
		}
		
		if "`anything'" == "numeric" 	local mainvar	numvar
		if "`anything'" == "string" 	local mainvar	strvar
		if "`anything'" == "other" 		local mainvar	strvar
		if "`anything'" == "drop" 		local mainvar 	idvalue
		

		* Drop extra lines in the excel
		drop if missing(`mainvar')
		
		return local mainvar `mainvar'
		
	end
	
***************************
* Write numeric corrections
***************************
cap program drop donumeric
	program 	 donumeric
	
	syntax , doname(string) idvar(string)
		
	file write  `doname' "** Correct entries in numeric variables " _n								// <---- Writing in do file here
			
	count
	
	* Write one line of correction for each line in the data set
		forvalues row = 1/`r(N)' {
			
		* Write one line of correction for each line in the data set					
			local var			= numvar[`row']
			local valuecurrent 	= valuecurrent[`row']
			local value		 	= value[`row']
			local idvalue		= idvalue[`row']

			* The listed variable will be corrected to new value, but a condition needs to be specified.
			* The condition can be one ID variable and/or one current value.
			local line	`"replace `var' = `value' if "'												
			
			* If it's an ID variables, write that in the do file
			if "`idvalue'" != "" {
				local line	`"`line' `idvar' == `idvalue'"'											
				
				* If it's both, add an "and"
				if "`valuecurrent'" != "" {
					local line	`"`line' & "'														
				}
			}
			
			* If there's a current value, write that in the do file.
			if "`valuecurrent'" != "" {
				noi di "enter valuecurrent"
				local line	`"`line'`var' == `valuecurrent'"'										
			}
			
			file write  `doname' `"`line'"' _n															// <---- Writing in do file here
		}	
		
	end

***************************
* Write string corrections
***************************
cap program drop dostring
	program 	 dostring
	
	syntax , doname(string) idvar(string)

	file write  `doname'		  "** Correct entries in strin variables " _n								// <---- Writing in do file here

	* Write one line of correction for each line in the data set
	count 
	forvalues row = 1/`r(N)' {
		
		local var			= strvar[`row']						
		local valuecurrent 	= valuecurrent[`row']
		local value		 	= value[`row']
		local idvalue		= idvalue[`row']

		local line		`"replace `var' = "`value'" if"'
		
		if "`idvalue'" != "" {
			*Confirm that ID var was specified
			*Confirmed that ID var is the same type as idvaue
			
			local line	`"`line' `idvar' == `idvalue'"'
			
			if "`valuecurrent'" != "" {
				local line	`"`line' &"'
			}
		}
		
		if "`valuecurrent'" != "" {
			local line	`"`line' `var' == "`valuecurrent'" "'
		}
		
		* Noew add an extra line
		file write `doname'	`"`line'"'																		// <---- Writing in do file here
	}

		
	end
	
	
/***************************
* Write string corrections
***************************

cap program drop doother
	program 	 doother
	
	 syntax , doname(string)
	
	file write  corrections		  "** Adjust categorical variables to include 'other' values " _n
	
	count
	forvalues row = 1/`r(N)' {
		
		local strvar			= strvar[`row']
		
		local strvaluecurrent 	= strvaluecurrent[`row']
		local strvaluecurrent	= `""`strvaluecurrent'""'
		
		local strvalue		 	= strvalue[`row']
		local strvalue			= `""`strvalue'""'
		
		local catvar		 	= catvar[`row']
		local catvalue		 	= catvalue[`row']

		if "`catvar'" != ""	{
			file write `doname'		`"replace `catvar' = `catvalue' if `strvar' == `strvaluecurrent'"' _n
		}
		else if !(regex(`strvalue',`strvaluecurrent') & regex(`strvalue',`strvaluecurrent'))	{
			file write `doname'		`"replace `strvar' = `strvalue' if `strvar' == `strvaluecurrent'"' _n
		}
	}
	
	end
	
*/
**********************
* Write do file footer
**********************
cap program drop dofooter
	program 	 dofooter
	
	syntax , doname(string) dofile(string)
	
		cap	file close 	`doname'
			file open  	`doname' using 	"`dofile'", text write append
			
			file write  `doname'		"*-------------- THE END --------------*"										// <---- Writing in do file here
			
			file close  `doname'	
			
	end
	
/*******************************************************************************	
	Run the do file with corrections
*******************************************************************************/

cap program drop dorun
	program		 dorun
	
	syntax , doname(string) dofile(string) data(string) [noisily]
	
		use  `data', clear
		
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
	
		save `data', replace
		
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
