*! version 0 - NOT READY FOR DISTRIBUTION

cap program drop iecorrect
	program 	 iecorrect
		
	syntax [anything] using/, [GENerate idvar(varlist) NOIsily save(string) replace sheet(string) debug]
		
	gettoken subcommand anything : anything
	
	if !inlist("`subcommand'","template","apply") {
		di as err "{bf:iecorrect} requires [template] or [apply] to be specified with a target [using] file. Type {bf:help iecorrect} for details."
	}

	preserve
	
	noi di _n
	
/*==============================================================================
								PROCESS OPTIONS
==============================================================================*/
	
	if "`sheet'" == "" {
		local corrSheets	numeric string other drop 
	}
	else {
		local corrSheets	`sheet'
	}
	
/*==============================================================================
							TEMPLATE SUBCOMMAND
							
	Creates a blank excel file to be filled with the corrections.
==============================================================================*/

	if "`subcommand'" == "template" {
		
		if !missing("`debug'") noi di "Entering template subcommand"
		
		* Check that folder exists
			
			
		// Check that file doesn't already exist -----------------------------------
		
		cap confirm file "`using'"
		if !_rc {
			noi di as error `"{phang}File "`using'" already exists. Template was not created.{p_end}"'
			error 601
		}
		
		// Create the template -----------------------------------------------------
		templateworkbook using "`using'"
			
		if !missing("`debug'") noi di "Exiting template subcommand"
	}																			// End of template subcommand
	
/*==============================================================================
								APPLY SUBCOMMAND
==============================================================================*/

	else if "`subcommand'" == "apply" {
	
		if !missing("`debug'") noi di "Entering apply subcommand"
		
/*******************************************************************************	
	Tests
*******************************************************************************/
		
		tempfile 	 data
		qui save	`data'
	
// Crete a list of variables in the data ---------------------------------------

	
	qui ds
	local original_vars `" `r(varlist)' "'

// Check ID format -------------------------------------------------------------

		cap confirm string variable `idvar'
			 if !_rc local 	stringid 1
		else if  _rc local	stringid 0

		if !missing("`debug'") noi di as result "String ID: `stringid'"

		
// Check that file exists ------------------------------------------------------

		cap confirm file "`using'"
		if _rc {
			noi di as error `"{phang}File "`using'" could not be found.{p_end}"'
			error 601
		}
		

// Check which types of corrections need to be made ----------------------------

		foreach type of local corrSheets {
		
			* Check that template was correctly filled
			checksheets using "`using'", type("`type'") stringid(`stringid') `debug'
			
			* The result indicates if there are corrections of this type
				local `type'corr 	`r(`type'corr)'

			* If there are, it also lists the variables to be corrected or IDs to be dropped
			if ``type'corr' == 1 {
				local `type'vars	`r(`type'vars)'
				if "`type'" == "other" {
					local categoricalvars `r(categoricalvars)'
				}
			}	
		}
		
/*******************************************************************************	
	Create a do file containing the corrections
*******************************************************************************/		

// Define tempfile -------------------------------------------------------------
		
		tempname	doname
		tempfile	dofile

// If the do file will be saved for later reference, add a header --------------
		if "`save'" != "" {
			qui doheader , doname("`doname'") dofile("`dofile'")
		}
		
// Write new variables to be created -------------------------------------------
	
	foreach var in `stringvars' {
	
		cap assert regex("`original_vars'", "`var'")
		if _rc {
			qui {
				cap	file close 	`doname'
					file open  	`doname' using 	"`dofile'", text write append
					file write  `doname'		`"gen `var' = "" "' _n			// <---- Writing in do file here
					file close  `doname'	
			}	
		}
	}

	foreach var in `numericvars' `categoricalvars' {

		cap assert regex("`original_vars'", "`var'")	
		if _rc {
			qui {
				cap	file close 	`doname'
					file open  	`doname' using 	"`dofile'", text write append
					file write  `doname'		"gen `var' = . " _n			// <---- Writing in do file here
					file close  `doname'
			}
		}
	}

// Read correction sheet -------------------------------------------------------

		foreach type of local corrSheets {

			if ``type'corr' {
				* Open the data set with the numeric corrections
				cap import excel "`using'", sheet("`type'") firstrow allstring clear
				
				* Drop observations with all missing variables
				tempvar 	 allmiss
				egen 		`allmiss' = rownonmiss(*), strok
				qui keep if `allmiss' > 0
				drop 		`allmiss'

				* Open the placeholder do file and write the corrections to be made
				cap	file close 	`doname'
				qui	file open  	`doname' using "`dofile'", text write append
							
					do`type', 	 doname("`doname'") idvar("`idvar'") stringid(`stringid') `debug'

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
	Save the do file containing the corrections if "save" was selected
*******************************************************************************/
		if "`save'" != "" {
			
			* Check that folder exists
			qui copy "`dofile'" `"`save'"', `replace'
			noi di as result `"{phang}Corrections do file was saved to: {browse "`save'":`save'} {p_end}"'
		}			
				
/*******************************************************************************	
	Run the do file containing the corrections
*******************************************************************************/
	
		restore
		noi di _n 
		
		dorun , doname("`doname'") dofile("`dofile'") data("`data'") `debug' `noisily' 
		
	
		if !missing("`debug'") noi di as result "Exiting template subcommand"
	
	}																				// End of apply subcommand 
	
end
	
/*==============================================================================
================================================================================

								 SUBPROGRAMS
	
================================================================================	
==============================================================================*/

/*******************************************************************************	
	Import data set
*******************************************************************************/

**********************************************************************
* Load data set for each check and keep only the lines filled by user
**********************************************************************

cap program drop prepdata
	program 	 prepdata, rclass
	
	syntax anything using/, stringid(numlist) [debug]

		if !missing("`debug'") noi di as result "Entering prepdata subcommand"
	
		** Load the sheet that was filled
		cap import excel "`using'", sheet("`anything'") firstrow allstring clear

		* If the sheet does not exist, throw an error
		if _rc == 601 {
			noi di as error `"{phang}No sheet called "`anything'" was found. Do not delete this sheet. If no `anything' corrections are needed, leave this sheet empty.{p_end}"'
			error 601
		}
		
		** Specify the main column for each type of correction -- this column
		** indicates the name of the variable to be corrected
		if !`stringid' & "`anything'" != "other" {
			qui destring idvalue, replace
			qui count if !missing(idvalue)
			if r(N) > 0 {
				cap confirm string var idvalue
				if !_rc {
					noi di as error `"{phang}Column idvalue in sheet [`anything'] is not numeric. This column should contain the unique identifier of the observations to be corrected.{p_end}"'
					local errorfill 1
				}
			}
		}
		
		if "`anything'" == "numeric" 	{
			qui destring valuecurrent value, replace
			local mainvar	numvar
		}
		if "`anything'" == "string" 	local mainvar	strvar
		if "`anything'" == "other" 		{
			qui destring catvalue, replace
			local mainvar	strvar
		}
		if "`anything'" == "drop" 		local mainvar 	idvalue

		* Drop blank lines that were imported by mistake
		qui drop if missing(`mainvar')
		
		** Return the name of the main variable to be used in the next steps
		return local mainvar `mainvar'
		
		if !missing("`debug'") noi di as result "Exiting prepdata subcommand"
		
	end
	
/*******************************************************************************	
	Initial checks
*******************************************************************************/
	
****************************************
* Check that sheet is filled correctly
****************************************
	
cap program drop checksheets
	program 	 checksheets, rclass
	
	syntax using/, type(string) stringid(numlist) [debug]
	
		if !missing("`debug'") noi di as result "Entering checksheets subcommand"
		
		** Import the data set and clean blank observations (commmand defined below)
		prepdata `type' using "`using'", stringid(`stringid') `debug'
		
		* Identify the type of correction being made
		local mainvar `r(mainvar)'

		** Check that there are corrections of this type to be made
		qui count
		
		* If there are
		if `r(N)' > 0 {
				
			* Check that the sheet is filled correctly
			if !missing("`debug'") noi di as result "Entering checkcol`type' subcommand"
			checkcol`type'
			if "`r(errorfill)'" == "1" {
				error 198
			}
			if !missing("`debug'") noi di as result "Exiting checkcol`type' subcommand"
			
			*If everything works, save the sheet in a tempfile and create a local saying to run the next command
			local	`type'corr	1 
						
			* List the variables that will need corrections of this type
			qui levelsof `mainvar', local(`type'vars) clean
			
			* List categorical variables used in 'other' corrections
			if "`type'" == "other" {
				qui levelsof catvar, local(categoricalvars) clean
			}
			
			if inlist("`type'", "string", "numeric", "other") {
				noi di as result `"{phang}Variables for corrections of type `type': ``type'vars'{p_end}"'
			}
			else {
				noi di as result `"{phang}IDs of observations to be dropped: ``type'vars'{p_end}"'
			}		
		}

		* If there are no corrections to be made, save that information and move forward
		else if `r(N)' == 0 {
			local	`type'corr	0
			if inlist("`type'", "string", "numeric", "other") {
				noi di as result `"{phang}No corrections of type `type'.{p_end}"'
			}
			else {
				noi di as result `"{phang}No observations to be dropped.{p_end}"'
			}
		}
		
		** Save the information
		* Whether there are any corrections to be made
		return local `type'corr 	``type'corr'	
		
		* What are the names of the variables to be corrected
		return local `type'vars 	``type'vars'
		
		if "`type'" == "other" {
		return local categoricalvars `categoricalvars'
		}
		
		if !missing("`debug'") noi di as result "Exiting checksheets subcommand"
		
	end
	
***********************************
* Check variables in numeric sheet
***********************************

cap program drop checkcolnumeric
	program 	 checkcolnumeric, rclass
	
	syntax [anything]
	
		* Are all the necessary variables there?
		foreach var in numvar idvalue valuecurrent value {
			cap confirm var `var'
			if _rc {
				noi di as error `"{phang}Column `var' not found in sheet [numeric]. This variable must not be erased from the template. If you do not wish to use it, leave it blank.{p_end}"'
				local errorfill 1
			}
		}
		
		* Keep only those variables in the data set -- the user may have added notes
		* that are not relevant for the command
		keep numvar idvalue valuecurrent value 
		
		** Check that variables have the correct format
		cap confirm string var numvar
		if _rc {
			noi di as error `"{phang}Column numvar in sheet [numeric] is not a string. This column should contain the name of the `type' variables to be corrected.{p_end}"'
			local errorfill 1
		}
				
		* valuecurrent col may not have been filled, so only check if it was
		qui count if !missing(valuecurrent)
		if r(N) > 0 {
			cap confirm string var valuecurrent
			if !_rc {
				noi di as error `"{phang}Column valuecurrent in sheet [numeric] is not numeric. This column should contain the values of the `type' variables to be corrected.{p_end}"'
				local errorfill 1
			}
		}
		
		cap confirm string var value
		if !_rc {
			noi di as error `"{phang}Column value in sheet [numeric] is not numeric. This column should contain the correct values of the `type' variables to be corrected.{p_end}"'
			local errorfill 1
		}
		
		cap assert !missing(value)
		if _rc {
			noi di as error `"{phang}At least one entry for column value in sheet [numeric] is blank. If there are no corrections specified in a row, remove it from the corrections form.{p_end}"'
			local errorfill 1
		}
		
		** Either idvalue or valuecurrent need to be specified
		qui count if missing(idvalue) & missing(valuecurrent)
		
		if r(N) > 0 {
			noi di as error `"{phang}There are `r(N)' lines in sheet [numeric] where neither the idvalue or the valuecurrent columns are specified. At least one of these columns should be filled for numeric corrections to be made correctly.{p_end}"'
			local errorfill 1
		}
		
		return local errorfill `errorfill'
			
	end		

***********************************
* Check variables in string sheet
***********************************

cap program drop checkcolstring
	program 	 checkcolstring, rclass
	
	syntax [anything]
	
		* Are all the necessary variables there?
		foreach var in strvar idvalue valuecurrent value {
			cap confirm var `var'
			if _rc {
				noi di as error `"{phang}Column `var' not found in `type' sheet. This variable must not be erased from the template. If you do not wish to use it, leave it blank.{p_end}"'
			}
		}
		
		* Keep only those variables in the data set -- the user may have added notes
		* that are not relevant for the command
		keep strvar idvalue valuecurrent value 
		
		** Check that variables have the correct format
		cap confirm string var strvar
		if _rc {
			noi di as error `"{phang}Column numvar in `type' sheet is not a string. This column should contain the name of the `type' variables to be corrected.{p_end}"'
			local errorfill 1
		}
		
		cap assert !missing(value)
		if _rc {
			noi di as error `"{phang}At least one entry for column value in `type' sheet is blank. If there are no corrections specified in a row, remove it from the corrections form.{p_end}"'
			local errorfill 1
		}
					
		** Either idvalue or valuecurrent need to be specified
		qui count if missing(idvalue) & missing(valuecurrent)
		if r(N) > 0 {
			noi di as error `"{phang}There are `r(N)' lines in the `type' sheet where neither the idvalue or the valuecurrent columns are specified. At least one of these columns should be filled for numeric corrections to be made correctly.{p_end}"'
			local errorfill 1
		}
		
		return local errorfill `errorfill'
		
end		
	
***********************************
* Check variables in other sheet
***********************************

cap program drop checkcolother
	program 	 checkcolother, rclass
	
	syntax [anything]
	
		* Are all the necessary variables there?
		foreach var in strvar strvaluecurrent strvalue catvar catvalue {
			cap confirm var `var'
			if _rc {
				noi di as error `"{phang}Column `var' not found in `type' sheet. This variable must not be erased from the template. If you do not wish to use it, leave it blank.{p_end}"'
				local errorfill 1
			}
		}
		
		* Keep only those variables in the data set -- the user may have added notes
		* that are not relevant for the command
		keep strvar strvaluecurrent strvalue catvar catvalue
		
		** Check that variables have the correct format
		foreach var in strvar catvar {
			cap confirm string var `var'
			if _rc {
				noi di as error `"{phang}Column `var' in [other] sheet is not a string. This column needs to be filled for corrections of categorical variable to be made.{p_end}"'
				local errorfill 1
			}
		}
		
		cap assert !missing(catvalue)
		if _rc {
			noi di as error `"{phang}At least one entry for column value in sheet [other] is blank. If there are no corrections specified in a row, remove it from the corrections form.{p_end}"'
			local errorfill 1
		}
		
		** Either strvaluecurrent need to be specified
		qui count if missing(strvaluecurrent)		
		if r(N) > 0 {
			noi di as error `"{phang}There are `r(N)' lines in sheet [other] where strvaluecurrent column is not filled. This column should be filled for categorical corrections to be made correctly.{p_end}"'
			local errorfill 1
		}
		
		return local errorfill `errorfill'
		
end	

********************************
* Check variables in drop sheet
********************************
	
cap program drop checkcoldrop
	program 	 checkcoldrop, rclass
	
	syntax [anything]
	
		* Are all the necessary variables there?
		foreach var in idvalue {
			cap confirm var `var'
			if _rc {
				noi di as error `"{phang}Column `var' not found in sheet [drop]. This column must not be erased from the template. If you do not wish to use it, leave it blank.{p_end}"'
				local errorfill 1
			}
		}
		
		
		cap assert !missing(idvalue)
		if _rc {
			noi di as error `"{phang}At least one entry for column idvalue in sheet [drop] is blank. If there are no corrections specified in a row, remove it from the corrections form.{p_end}"'
			local errorfill 1
		}
		
		return local errorfill `errorfill'
			
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
			file write  `doname'		"* Write header here" _n _n					// <---- Writing in do file here
			file close  `doname'	
			
	end
	
***************************
* Write numeric corrections
***************************
cap program drop donumeric
	program 	 donumeric
	
	syntax , doname(string) idvar(string) stringid(numlist) [debug]
		
	if !missing("`debug'") noi di as result "Entering donumeric subcommand"
	
	file write  `doname' "** Correct entries in numeric variables " _n								// <---- Writing in do file here
	
	* Count the number of lines in the current data set: each line will be one
	* line in the do-file
	qui count
	
	* Write one line of correction for each line in the data set
	forvalues row = 1/`r(N)' {

		* Calculate the user-specified inputs for this line
		local var			= numvar[`row']
		local valuecurrent 	= valuecurrent[`row']
		local value		 	= value[`row']
		local idvalue		= idvalue[`row']

		** Prepare a local with the line to be written in the do-file

		* The main variable will be corrected to new value, but a condition needs to be specified.
		* The condition can be one ID variable and/or one current value.
		local line	`"replace `var' = `value' if "'												

		* If it's an ID variables, write that in the line
		if `"`idvalue'"' != "" {
			if `stringid'	local idvalue = `" "`idvalue'" "'
			local line	`" `line' `idvar' == `idvalue' "'											

			* If it's both, add an "and"
			if "`valuecurrent'" != "" {
				local line	`"`line' & "'														
			}
		}

		* If there's a current value, write that in the line
		if "`valuecurrent'" != "" {
			local line	`"`line'`var' == `valuecurrent'"'										
		}

		** Write the line to the do file
		file write  `doname' `"`line'"' _n															// <---- Writing in do file here
	}	

	if !missing("`debug'") noi di as result "Exiting donumeric subcommand"

end

***************************
* Write string corrections
***************************
cap program drop dostring
	program 	 dostring
	
	syntax , doname(string) idvar(string) stringid(numlist) [debug]
	
	if !missing("`debug'") noi di as result "Entering dostring subcommand"
	
	file write  `doname'		  "** Correct entries in string variables " _n								// <---- Writing in do file here

	* Count the number of lines in the current data set: each line will be one
	* line in the do-file
	qui count 
	
	* Write one line of correction for each line in the data set
	forvalues row = 1/`r(N)' {
		
		* Identify the user-specified input in that line
		local var			= strvar[`row']						
		local valuecurrent 	= valuecurrent[`row']
		local value		 	= value[`row']
		local idvalue		= idvalue[`row']

		local line		`"replace `var' = "`value'" if"'
		
		if `"`idvalue'"' != "" {
			
			if `stringid' 	local line `"`line' `idvar' == "`idvalue'""'
			else			local line `"`line' `idvar' == `idvalue'"'
			
			if "`valuecurrent'" != "" {
				local line	`"`line' &"'
			}
		}
		
		if "`valuecurrent'" != "" {
			local line	`"`line' `var' == "`valuecurrent'" "'
		}
		
		** Write the line to the do file
		file write `doname'	`"`line'"' _n																		// <---- Writing in do file here
	}
	
	if !missing("`debug'") noi di as result "Exiting dostring subcommand"
	
end

***********************
* Dropping observations
***********************
cap program drop dodrop
	program 	 dodrop
	
	syntax , doname(string) idvar(string) stringid(numlist) [debug]

	if !missing("`debug'") noi di as result "Entering dodrop subcommand"
	
	file write  `doname'		  "** Drop observations " _n								// <---- Writing in do file here

	* Write one line of correction for each line in the data set
	qui count 
	forvalues row = 1/`r(N)' {
		
		local idvalue		= idvalue[`row']

		if `"`idvalue'"' != "" {
			*Confirm that ID var was specified
			*Confirmed that ID var is the same type as idvaue

			** Write the line to the do file
			if `stringid'	local idvalue = `""`idvalue'""'
			
			file write `doname'	`"drop if `idvar' == `idvalue' "' _n							// <---- Writing in do file here
			
		}
	}

	if !missing("`debug'") noi di as result "Exiting dodrop subcommand"
	
end
	
***************************
* Write 'other' corrections
***************************

cap program drop doother
	program 	 doother
	
	syntax , doname(string) idvar(string) stringid(numlist) [debug]
	
	if !missing("`debug'") noi di as result "Entering doother subcommand"
	
	file write  `doname'		  "** Adjust categorical variables to include 'other' values " _n
	
	qui count
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
		if !(`"`strvalue'"' == `"`strvaluecurrent'"') | (`"`strvalue'"' == "")	{
			file write `doname'		`"replace `strvar' = `strvalue' if `strvar' == `strvaluecurrent'"' _n
		}
	}

	if !missing("`debug'") noi di as result "Exiting doother subcommand"
end
	

**********************
* Write do file footer
**********************

cap program drop dofooter
	program 	 dofooter
	
	syntax , doname(string) dofile(string) 
	
		cap	file close 	`doname'
			file open  	`doname' using 	"`dofile'", text write append
			file write  `doname'		"***************************************************************** End of do-file"	// <---- Writing in do file here
			file close  `doname'	
			
	end
	
/*******************************************************************************	
	Run the do file with corrections
*******************************************************************************/

cap program drop dorun
	program		 dorun
	
	syntax , doname(string) dofile(string) data(string) [NOIsily debug]
	
	if !missing("`debug'") 		noi di as result "Entering dorun subcommand"
	
								local display qui
	if !missing("`noisily'")	local display noi
	
	file open `doname' using "`dofile'", read
	file read `doname' line
	
	while r(eof)==0 {
		if !missing("`noisily'") display `"`line'"'
		`display' `line'
		file read `doname' line
	}

	file close `doname'

	qui save `data', replace

	if !missing("`debug'") noi di as result "Exiting dorun subcommand"
	
end

/*******************************************************************************	
	Create template sheet
*******************************************************************************/

cap program drop templateworkbook
	program		 templateworkbook
	
	syntax using/
	
	preserve
	
		* String variables
		templatesheet using "`using'", ///
			varlist("strvar idvalue valuecurrent value initials notes") ///
			sheetname("string") ///
			current("value")
					
		* Numeric variables
		templatesheet using "`using'", ///
			varlist("numvar idvalue valuecurrent value initials notes") ///
			sheetname("numeric") ///
			current("value")

		* Other variables
		templatesheet using "`using'", ///
			varlist("strvar strvaluecurrent strvalue catvar catvalue initials notes") ///
			sheetname("other") ///
			current("strvalue")

		* Drop observations
		templatesheet using "`using'", ///
			varlist("idvalue initials notes") ///
			sheetname("drop")

		noi di as result `"{phang}Template spreadsheet saved to: {browse "`using'":`using'}{p_end}"'
			
	restore
	
end

cap program drop templatesheet
	program		 templatesheet
	
	syntax using/, varlist(string) sheetname(string) [current(string)]
	
	qui {
			clear
			set obs 1
			
			foreach var of local varlist {
				gen `var' = .
			}
			
			if "`curent'" != "" {
				lab var `current'current "`current':current"
			}
						
			export excel using "`using'", sheet("`sheetname'") firstrow(varlabels)
		}		
	end

*********************************** THE END ************************************
