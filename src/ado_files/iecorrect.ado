*! version 3.2 31JUL2023  DIME Analytics dimeanalytics@worldbank.org

cap program drop iecorrect
	program 	 iecorrect
		
	syntax [anything] using/, ///
		idvar(varlist) 						 ///
		[ 									 ///
			NOIsily 						 ///
			save(string) 					 ///
			replace 						 ///
			SHEETs(string) 					 ///
			debug 							 ///
			break							 ///
		]
		
	preserve
	
	gettoken subcommand anything : anything
	
	if !inlist("`subcommand'","template","apply") {
		di as err "{bf:iecorrect} requires {bf:template} or {bf:apply} to be specified with a target {bf:using} file. Type {bf:help iecorrect} for details."
	}
	
/*==============================================================================
								Save data
==============================================================================*/

	* Test if idvar uniquely identifies the dataset
	_testid `idvar', `break'
		
	tempfile 	 data
	qui save	`data'

/*==============================================================================
                PROCESS OPTIONS
==============================================================================*/
	
	if !missing("`sheets'") local corrSheets	`sheets'
	else					local corrSheets	numeric string drop
	
	_testsheets, sheets("`corrSheets'") debug

/*==============================================================================
                Test File
==============================================================================*/

  // Standardize file path
  local using = subinstr(`"`using'"', "\", "/", .)  
  
  // Get the file extension       
    local fileext = substr(`"`using'"', strlen(`"`using'"') - strpos(strreverse(`"`using'"'), ".") + 1, .)

  // If no fileextension was used, then add .xslx to "`using'"
  if "`fileext'" == "" {     
    local using  "`using'.xlsx"
  }

  // Check if the file extension is the correct  
  else if !inlist("`fileext'",".xlsx",".xls") {
        noi di as error `"{phang}The file must include the extension {bf:.xlsx} or {bf:.xls} The format {bf:`fileext'} is not allowed.{p_end}"'
        error 198
    }  
        
  //   Confirm the file path is correct
  cap confirm new file `using'
  if (_rc == 603) {
		noi di as error `"{phang} The file path used {bf:`using'} does not exist.{p_end}"'
		error 601  
  }  
  
/*==============================================================================
              TEMPLATE SUBCOMMAND
              
  Creates a blank excel file to be filled with the corrections.
==============================================================================*/

	if "`subcommand'" == "template" {
		
		// Check if file already exists and check if the "other" tab is included
		cap confirm new file `using'
		
		if (_rc == 602) {
			noi di as error `"{phang}File {bf:`using'} already exists. Template was not created.{p_end}"'
			error 602 
		}

		// Create the template -----------------------------------------------------
		templateworkbook using "`using'" , idvar(`idvar') `debug'
	}

/*==============================================================================
                APPLY SUBCOMMAND
==============================================================================*/

else if "`subcommand'" == "apply" {

    if !missing("`debug'") noi di "Entering apply subcommand"
    
	* Test that the file exists
	_findtemplate using "`using'", `debug' 

// Create a list of variables in the data ---------------------------------------

	qui ds, has(type double)
	local 	double_vars		`r(varlist)'
	
	qui ds, has(type float)
	local 	float_vars		`r(varlist)'
	
	qui ds, has(type string)
	local 	string_vars		`r(varlist)'
	
	qui ds
	local 	original_vars	`r(varlist)'

// Check inputs ----------------------------------------------------------------

    foreach type of local corrSheets {
    		
		* Check that template was correctly filled
		_checksheets using "`using'", type("`type'") ///
			originalvars(`original_vars') stringvars(`string_vars') ///
			floatvars(`float_vars') doublevars(`double_vars') ///
			idvar(`idvar') `debug' data(`data')
		
		* Prepare inputs if there are corrections
		if "`r(correct)'" == "1" {
			
			* Save corrections as a tempfile
			tempfile  `type'
			qui save ``type''
			
			* Add this to the list of corrections to be made
			local corrections		"`corrections' `type'"
			local any_corrections 	1
			
			* Print a list of the variables that will be corrected
			_printaction,  present(yes) type(`type') `debug'
		}
		* If there are not, just say there aren't
		else if "`r(correct)'" == "0" {
		    _printaction,  present(no)  type(`type') `debug'
		}
		
    }

// Create a do file containing the corrections ---------------------------------

	* Define tempfile
    tempname  doname
    tempfile  dofile

	* If the do file will be saved for later reference, add a header
    if ("`save'" != "") qui _doheader , doname("`doname'") dofile("`dofile'")
 
	* Write correction do-file
    foreach type of local corrections {
        
		* Open the data set with the numeric corrections
        use ``type'', clear

		cap  file close   `doname'
		qui  file open    `doname' using "`dofile'", text write append
			 file write   `doname'      _n _n   
				 
        _do`type',  ///
			doname("`doname'") ///
			idvar("`idvar'") ///
			stringvars(`string_vars') floatvars(`float_vars') doublevars(`double_vars')  ///
			originalvars(`original_vars') ///
			`debug'
		
		* Add an extra space before the next set of corrections
		file close   `doname'	
	}
		
    if ("`save'" != "") 	_dofooter, doname("`doname'") dofile("`dofile'")
	if ("`save'" != "")   	_dosave,   doname("`doname'") dofile("`dofile'") save("`save'") `replace'
    
//  Run the do file containing the corrections ---------------------------------

	restore
    qui use `data', clear
    
    * Don't run if there are no corrections to be made
    if !missing("`any_corrections'") {
		_dorun using "`using'", ///
			doname("`doname'") dofile("`dofile'") ///
			data("`data'") sheets("`corrections'") ///
			idvar(`idvar') `debug' `noisily'  `break'
    }
	
	* Return the corrected dataset
	qui use `data', clear
  
  }

 end


/*==============================================================================
================================================================================

                 SUBPROGRAMS
  
================================================================================  
==============================================================================*/

/*******************************************************************************  
  Import data set
*******************************************************************************/

cap program drop _testid
	program 	 _testid
	
	syntax varlist, [break]
	
	cap isid `varlist'
		
	if _rc == 459 {
			noi di as error `"{phang}The ID variables listed in option {bf:idvar} do not uniquely and fully identify the data. This may cause unintended changes to the data when applying corrections.{p_end}"'
			if !missing("`break'") {
				error 111
				exit
			}
			
			noi di 			""
	}
	
	
end

/*******************************************************************************  
  Test selected sheets
*******************************************************************************/

cap program drop _testsheets
	program 	 _testsheets
	
	syntax , sheets(string) [debug]
	
	if !missing("`debug'") noi di as result "Entering testsheets subcommand"
	
	local n_sheets = wordcount("`sheets'")
	
	forvalues sheet = 1/`n_sheets' {
		
		local sheetname : word `sheet' of `sheets'
		
		if !inlist("`sheetname'", "string", "numeric", "drop") {
			noi di as error `"{phang}`sheetname' is not a valid sheet name to be selected in option {bf:sheets}. This option only accepts a combination of the words "string", "numeric", and "drop", separated by space.{p_end}"'
			error 198
		}
	}
	
	if !missing("`debug'") noi di as result "Exiting testsheets subcommand"
end

**********************************************************************
* Load data set for each check and keep only the lines filled by user
**********************************************************************

cap program drop _loadsheet
	program 	 _loadsheet
	
	syntax using/, type(string) [debug]

		if !missing("`debug'") noi di as result "Entering loadsheet subcommand"
	
		** Load the sheet that was filled
		cap import excel "`using'", sheet("`type'") firstrow allstring clear

		* If the sheet does not exist, throw an error
		if _rc == 601 {
			noi di as error `"{phang}No sheet called {bf:`type'} was found. Do not delete this sheet. If no `anything' corrections are needed, leave this sheet empty.{p_end}"'
			error 601
		}
		
end

cap program drop _parsesheet
	program 	 _parsesheet
	
	syntax , idvar(string) type(string) [stringvars(string) debug]

	if !missing("`debug'") noi di as result "Entering parsesheet subcommand"
	
 * Drop lines with no information ----------------------------------------------
	qui {
		
		tempvar  allmiss
		egen    `allmiss' = rownonmiss(*), strok
		keep if `allmiss' > 0
		drop    `allmiss'
		
		if _N > 0 {
		
			* Check that all relevant variables are in the sheet ---------------
			_fillmissingcol, idvar(`idvar') type(`type') `debug'
				
			* Prepare ID values ------------------------------------------------			
			foreach var of varlist `idvar' {
				replace  `var'  = ".v" if `var' == "*"
				count if `var' != ".v"
				if ((r(N) > 0) | !regex(" `stringvars' ", " `var' ")) destring `var', replace					
			}
						
			* Destring numeric columns -----------------------------------------
			if 	inlist("`type'", "numeric") 			replace  valuecurrent = ".v" if valuecurrent == "*"
			if 	inlist("`type'", "numeric", "string")   cap destring value valuecurrent, replace
			if 	inlist("`type'", "string") 				replace  valuecurrent = ".v" if valuecurrent == "*"
			
			else if "`type'" == "drop" {
				replace  n_obs = ".v" if n_obs == "*"
				destring n_obs, replace
			}
		}
	}
					
end
	
/*******************************************************************************	
	Initial checks
*******************************************************************************/

****************************************
* Check that sheet is filled correctly
****************************************
  
cap program drop _checksheets
	program    	 _checksheets, rclass
  
	syntax using/, ///
		type(string) idvar(string) ///
		originalvars(string) data(string) ///
		[debug ///
		stringvars(string) floatvars(string) doublevars(string)]
  
    if !missing("`debug'") noi di as result "Entering checksheets subcommand"
    
* Load sheet and parse data  ---------------------------------------------------

    _loadsheet using "`using'",  type(`type') `debug' 								// import correction sheet
	_parsesheet , idvar(`idvar') type(`type') stringvars(`stringvars') `debug'		// remove blanks lines, destring numeric variables
	      
* If there are corrections, check individual sheets ----------------------------

    qui count

    if `r(N)' > 0 {	    
		_checkcol`type', ///
			idvar(`idvar') ///
			originalvars(`originalvars') stringvars(`stringvars') ///
			floatvars(`floatvars') doublevars(`doublevars') ///
			`debug' data(`data') 
		
			 if !missing("`r(errorfill)'")	error 198
		else if !missing("`r(errortype)'")  error 109

		return local correct  	1
    }
	else if `r(N)' == 0 {    
		return local correct  	0
    }

end
  
***********************************
* Check variables in numeric sheet
***********************************

cap program drop _checkcolnumeric
	program 	 _checkcolnumeric, rclass
	
	syntax, ///
		idvar(string) originalvars(string) ///
		[stringvars(string) floatvars(string) doublevars(string) ///
		data(string) debug]
	
	if !missing("`debug'") noi di as result "Entering checkcolnumeric subcommand"
	
		* Keep only those variables in the data set -- the user may have added notes
		* that are not relevant for the command
		keep varname `idvar' valuecurrent value 
		
		* Check if id variables are filled correctly (either all or none are filled)
		_fillid, type(numeric) idvar(`idvar') `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		* Check that IDs were filled with the correct information (number/text)
		_fillidtype, type(numeric) idvar(`idvar') stringvars(`stringvars') `debug'				
		if "`r(errortype)'" == "1" local errortype 1
		
		* If none id values were filled, valuecurrent must be filled
		_fillidorvalue, type(numeric) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		* Check that all columns were filled		
		_fillrequired, type(numeric) varlist(varname) vartype(string) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		_fillrequired, type(numeric) varlist(value valuecurrent) vartype(numeric) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		* Check that varname column is numeric
		foreach var in value valuecurrent {
			_fillvartype, type(numeric) vartype(numeric) var(`var') `debug'
			if "`r(errortype)'" == "1" local errortype 1
		}
		
		_fillvartype, type(numeric) vartype(string) var(varname) `debug'
		if "`r(errortype)'" == "1" local errortype 1
			
		* Check that variables to be corrected exist
		qui levelsof varname, local(numericvars)
		foreach var of local numericvars {
				
			_vartype, type(numeric) vartype(numeric) column(varname) var(`var') stringvars(`stringvars')  `debug'
			if "`r(errortype)'" == "1" local errortype 1
		}
		
		* Check that value current was correctly filled
		_fillcurrent, type(numeric) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
	return local errorfill	`errorfill'
	return local errortype 	`errortype'

end		

***********************************
* Check variables in string sheet
***********************************

cap program drop _checkcolstring
	program 	 _checkcolstring, rclass
	
	syntax, ///
		idvar(string) originalvars(string) ///
		[stringvars(string) floatvars(string) doublevars(string) ///
		data(string) debug]

	if !missing("`debug'") noi di as result "Entering checkcolstring subcommand"
	
		* Keep only relevant variables -- the user may have added notes that are not relevant for the command
		keep varname `idvar' valuecurrent value 

		* Check if id variables are filled correctly (either all or none are filled)
		_fillid, type(string) idvar(`idvar') `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		* Check that IDs were filled with the correct information (number/text)
		_fillidtype, type(string) idvar(`idvar') stringvars(`stringvars') `debug'				
		if "`r(errortype)'" == "1" local errortype 1
		
		* If none id values were filled, valuecurrent must be filled
		_fillidorvalue, type(string) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		_fillrequired, type(string) varlist(varname value valuecurrent) vartype(string) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		* Check that information in columns has the right type
		foreach var in varname value valuecurrent {
			_fillvartype, type(string) vartype(string) var(`var') `debug'
			if "`r(errortype)'" == "1" local errortype 1
		}
			
		* Check that variables to be corrected exist
		qui levelsof varname, local(stringvars)
		foreach var of local stringvars {
			_vartype, type(string) vartype(string) column(varname) var(`var') stringvars(`stringvars')  `debug'
			if "`r(errortype)'" == "1" local errortype 1
		}
		
		* Check if the string variables to be corrected don't have extra white spaces and special characters
		foreach var in value valuecurrent { 
			if !_rc {
				_valstrings `var', location(Variable)
			}	
		}
		
		* Check that value current was correctly filled
		_fillcurrent, type(string) `debug'
		if "`r(errorfill)'" == "1" local errorfill 1
		
		return local errorfill	`errorfill'
		return local errortype 	`errortype'
		
end		
	
********************************
* Check variables in drop sheet
********************************
  
cap program drop 	_checkcoldrop
	program    		_checkcoldrop, rclass
  
	syntax, ///
		idvar(string) originalvars(string) ///
		[stringvars(string) floatvars(string) doublevars(string) ///
		data(string) debug]
 
	* Keep only relevant variables -- the user may have added notes that are not relevant for the command
	keep `idvar' n_obs
		
	* Check if id variables are filled correctly (either all or none are filled)
	_fillid, type(drop) idvar(`idvar') `debug'
	if "`r(errorfill)'" == "1" local errorfill 1
	
	* Check that IDs were filled with the correct information (number/text)
	_fillidtype, type(drop) idvar(`idvar') stringvars(`stringvars') `debug'				
	if "`r(errortype)'" == "1" local errortype 1
		
	cap confirm string var n_obs
    if !_rc {
		noi di as error `"{phang}Column {bf:n_obs} in sheet {bf:drop} is not numeric. This column should contain the number of observations to be dropped.{p_end}"'
		local errorfill 1
    }
	
	* The number of observations to be dropped must be checked
	_fillrequired, type(drop) varlist(n_obs) vartype(numeric) `debug'
	if "`r(errorfill)'" == "1" local errorfill 1
	
   qui count if missing(n_obs)
   if r(N) > 0 {
		noi di as error `"{phang}Column {bf:n_obs} in sheet {bf:drop} was not filled. This column should contain the number of observations to be dropped, and it does not accept wildcards.{p_end}"'
		local errorfill 1
   }
	
	_filldropobs, ///
		idvar(`idvar') ///
		originalvars(`originalvars') floatvars(`floatvars') doublevars(`doublevars') stringvars(`stringvars') ///
		`debug' data(`data')
	if "`r(errorfill)'" == "1" local errorfill 1
	
	return local errorfill	`errorfill'
	return local errortype 	`errortype'
      
end  

/*******************************************************************************
 							Sheet filling checks
*******************************************************************************/
{
***********************************************
* Check that all IDs were filled (or non was)
***********************************************
cap program drop _fillid
	program    	 _fillid, rclass
	
	syntax, type(string) idvar(string) [debug]
	
	if !missing("`debug'")	noi di as result "Entering fillid subcommand"
	
		* Three options: all filled, none filled, some filled
		qui gen __blank_ids   = 0
		qui gen __missing_ids = 0
		
		foreach var of varlist `idvar' {
			cap confirm numeric var `var'
			if !_rc	{
				qui replace __blank_ids   = __blank_ids   + 1 if `var' == .v
				qui replace __missing_ids = __missing_ids + 1 if `var' == .
			}	
			else {
				qui replace __blank_ids   = __blank_ids   + 1 if `var' == ".v"
				qui replace __missing_ids = __missing_ids + 1 if `var' == ""
				
			}		
		}

		* Error if columns was left blanks instead of using wildcard 
		qui count if (__missing_ids > 0)
		if r(N) > 0 {
			noi di as error `"{phang}There are `r(N)' lines in sheet {bf:`type'} where the  ID variable columns were not filled correctly: the value for at least one of the ID variables was left blank. If you wish to apply corrections to observations regardless of the value they take for one of the ID variables, fill the column that corresponds to this variable with the wildcard sign ("*").{p_end}"'
		  local errorfill 1
		}
		
		* Mark all observations where the IDs where not filled (valuecurrent must be filled in these cases)		
		local n_vars = wordcount("`idvar'")
		qui replace __blank_ids = (__blank_ids == `n_vars')
		
		qui drop 	__missing_ids
		
	* Return an error if something was filled incorrectly
	return local errorfill `errorfill'
	
 end
 
****************************************
* Check that IDs have the correct format
****************************************
cap program drop _fillidtype
	program		 _fillidtype, rclass
	
	syntax , stringvars(string) idvar(string) type(string) [debug]
	
	if !missing("`debug'") noi di as result "Entering fillidtype subcommand"
	
	* Test type for each ID variable if variable contains any non-missing values
	foreach var of varlist `idvar' {

		* Check if there are non-missing values
		qui count if !missing(`var')
		if r(N) > 0 {
			
			* Is the variable a string?
			cap confirm string var `var'

			* Is not a string, but should be
			if _rc & regex(" `stringvars' ", " `var' ") {
				noi di as error `"{phang} ID variable {bf:`var'} is a string variable in the original dataset, but was filled with all numeric values in sheet {bf:`type'}.{p_end}"'
				local errortype 1
			}
			* Is a string, but should not be
			else if !_rc & !regex(" `stringvars' ", " `var' ") {
				noi di as error `"{phang}ID variable {bf:`var'} is a numeric variable in the original dataset, but was filled with text in sheet {bf:`type'}.{p_end}"'
				local errortype 1
			}
		}
	}
	
	return local errortype `errortype'
	
end
 
 
****************************************************
* Check that valuecurrent is filled when IDs are not
****************************************************
cap program drop _fillidorvalue
	program    	 _fillidorvalue, rclass

	syntax, type(string) [debug]	

	if !missing("`debug'")	noi di as result "Entering fillidorvalue subcommand"

	if "`type'" == "string" {
		qui count if __blank_ids & valuecurrent == ".v"
		if r(N) > 0 {
			noi di as error `"{phang}There are `r(N)' lines in sheet {bf:`type'} where neither the ID variable values or the {bf:valuecurrent} column were specified. At least one of these columns should be filled with valid information (other than a wildcard) for corrections to be made correctly.{p_end}"'
			local errorfill 1
		}
	}
	else {
		qui count if __blank_ids & missing(valuecurrent)		
		if r(N) > 0 {
			noi di as error `"{phang}There are `r(N)' lines in sheet {bf:`type'} where neither the ID variable values or the {bf:valuecurrent} column were specified. At least one of these columns should be filled with valid information (other than a wildcard) for corrections to be made correctly.{p_end}"'
			local errorfill 1
		}
	}
	
	qui drop __blank_ids

	return local errorfill `errorfill'

 end
 
***********************************************
* Check that varname column is filled with text
***********************************************

cap program drop _fillvartype
	program    	 _fillvartype, rclass
	
	syntax, type(string) vartype(string) var(string) [debug]
	
	if !missing("`debug'")	noi di as result "Entering fillvartype subcommand: testing column `var'"

		qui count if !missing(`var')
		if r(N) != 0 {
			cap confirm `vartype' var `var'
			if _rc {
				noi di as error `"{phang}Column {bf:`var'} in sheet {bf:`type'} is not of type `vartype'.{p_end}"'
				local errortype 1
			}
		}
		
	return local errortype `errortype'
	
 end
 
************************************************
* Check that no column was deleted from template
************************************************

cap program drop _fillmissingcol
	program    	 _fillmissingcol, rclass
	
	syntax, idvar(string) type(string) [debug]
	
	if !missing("`debug'")	noi di as result "Entering fillmissingcol subcommand"

	if inlist("`type'", "string", "numeric") 	local columns	`idvar' varname value valuecurrent
	else if   "`type'" == "drop"				local columns	`idvar' n_obs
	
		foreach col in `columns' {
			
		  cap confirm var `col'
		  if _rc {
			noi di as error `"{phang}Column {bf:`col'} not found in sheet {bf:`type'}. This column must not be erased from the template. If you do not wish to use it, leave it blank.{p_end}"'
			error 198
		  }
		}

 end
 
******************************************************
* Check that column value current was correctly filled
******************************************************

cap program drop _fillcurrent
	program    	 _fillcurrent, rclass
	
	syntax, type(string) [debug]
	
	if !missing("`debug'")	noi di as result "Entering fillcurrent subcommand"

	qui count if !missing(valuecurrent)											// does not apply if column was not filled
	if r(N) > 0 {
	    cap confirm `type' var valuecurrent
		if _rc {
			noi di as error `"{phang}Column valuecurrent in sheet {bf:`type'} is not of type `type'. This column should contain the values of the `type' variables to be corrected.{p_end}"'
			local errorfill 1
		}
	}

	return local errorfill `errorfill'
	
 end
 
****************************************
* Check that required columns are filled
****************************************

cap program drop _fillrequired
	program    	 _fillrequired, rclass
	
	syntax, type(string) varlist(string) vartype(string) [debug]
	
	if !missing("`debug'")	noi di as result "Entering fillrequired subcommand"

			 if	"`vartype'" == "string"		local condition	`"== """'
		else if	"`vartype'" == "numeric"	local condition `"== ."'	

		* Check that required variables are filled and print error message otherwise
		foreach var of local varlist {
			if regex("`var'", "current") local message `" If you wish to apply corrections to observations regardless of their current value, fill this column with the wildcard sign ("*")."'

			cap count if `var' `condition'    // captured so type mismatches errors are not returned at this point
			if (!_rc) & (r(N) > 0) {
			  noi di as error `"{phang}There are `r(N)' lines in sheet {bf:`type'} sheet where column  {bf:`var'} is not filled. This column is required for corrections to be made correctly. If there are no corrections specified in a row, remove the row from the corrections form.`message'{p_end}"'
			  local errorfill 1
			}
		}

	return local errorfill `errorfill'
	
 end
 
********************************************
* Check that new value was entered correctly
********************************************
 
**************************
* Check if template exists
**************************

cap program drop _findtemplate 
	program		 _findtemplate 
	
	syntax using/, [debug]
	
	if !missing("`debug'")	noi di as result "Entering findtetemplate subcommand"

		cap confirm new file "`using'"
		if (_rc != 602) {  
		  noi di as error `"{phang}The iecorrect template is not found. The template must be created before the apply subcommand can be used. {p_end}"'
		  error 601 
		}
		
end
 
*************************************************************
* Check if there are extra whitespaces and special characters
*************************************************************
cap program drop _valstrings
	program    	 _valstrings, rclass
  
  syntax varname, location(string)

    *******************
    * Extra whitespaces
    *******************
    tempname validation
    qui gen `validation' = `varlist'
    
    *Test if there are any leading or trailing spaces
    qui replace `validation' = strtrim(`validation')

    * Test if there are consecutive spaces
    qui replace `validation' = stritrim(`validation')
  
    * Test if there are any Unicode whitespace (line, Tab..)
    qui replace `validation' = ustrtrim(`validation')
  
    cap assert `varlist' == `validation'
    if _rc {
		qui drop `validation'
		_strerror, var(`varlist') type(whitespace) location(`location')  
    }
  
    ********************
    * Special characters
    ********************
    forvalues i = 0/255 {
		
		* Lis accepted characters
		if 	  !inrange(`i', 48, 57) /// numbers
			& !inrange(`i', 65, 90) /// uppers case letters
			& !inrange(`i', 97, 122) ///  case letters
			& !inlist(`i', 32, 33, 35, 37, 38, 40, 41, 42, 43, 44, 45, 46, 58, 59, 60, 61, 62, 63, 64, 91, 93, 95) { 
        
		capture assert index(`validation', char(`i')) == 0 
		if _rc {
			qui drop `validation'
			_strerror, var(`varlist') type(specialchar) location(`location')
		}
      }
    }
		
	qui drop `validation'
	
end  

**************************************
* Error message for special characters
**************************************

cap program drop _strerror
	program      _strerror
  
  syntax , var(string) type(string) location(string)
  
	  if "`type'" == "specialchar" {
		local issue   special characters
		local details   ""
	  }
	  else if "`type'" == "whitespace" {
		local issue   extra whitespaces
		local details   (leading, trailing or consecutive spaces, tabs or new lines)
	  }
  
	  noi di as error `"{phang}`location' {bf:`var'} contains `issue' `details'. {bf:iecorrect} will run, but this may cause mismatches between the template spreadsheet and the content of the data, in which case the corrections will not be applied. It is recommended to remove `issue' from the data and the template spreadsheet before running {bf:iecorrect}.{p_end}"'
    
end

***********************
* Dropping observations
***********************
cap program drop 	_filldropobs
	program    		_filldropobs, rclass

	syntax , ///
		idvar(string) data(string) ///
		[originalvars(string) floatvars(string) doublevars(string) stringvars(string) debug] 
		
	if !missing("`debug'") noi di as result "Entering filldropobs subcommand"

	* Write one line of correction for each line in the data set
	qui count 
	forvalues row = 1/`r(N)' {
		
		local nobs = n_obs[`row']
	
		_idcond, ///
			idvar(`idvar') row(`row') `debug' ///
			stringvars(`stringvars') floatvars(`floatvars') doublevars(`doublevars') 
		
		local condition "`r(idcond)'"
		local condition = substr(`"`condition'"', 1, length(`"`condition'"') - 3)

		preserve
	
		  qui use `data', clear
		  qui count if `condition'
		  local count = r(N)
		  cap assert `nobs' != `count'
		  if !_rc {
			noi di as error `"{phang} The number of observations satisfying the condition {bf:`condition'} in the data (`count') does not match the number of observations listed in the column {bf:n_obs} of the template sheet {bf:drop} (`nobs').{p_end}"'
			local errorfill 1
		  }
	
		restore
	}
	
	return local errorfill `errorfill'

end
  
  
*********************
* Check variable type
*********************

cap program drop _vartype
	program    	 _vartype, rclass
	
	syntax, type(string) vartype(string) column(string) var(string) [stringvars(string) debug]
	
	if !missing("`debug'")	noi di as result "Entering vartype subcommand"

		if ("`vartype'" == "string") & !regex(" `stringvars' ", " `var' ") {
			local errortype 1
		}
		else if ("`vartype'" == "numeric") & regex(" `stringvars' ", " `var' ") {
			local errortype 1
		}
		
		if "`errortype'" == "1" {
			noi di as error `"{phang} Variable {bf:`var'} listed in column {bf:`column'} in sheet {bf:`type'} is not of type `vartype'.{p_end}"'
		}
		
	return local errortype `errortype'
	
end
  
}
/*******************************************************************************  
  Write the do file with corrections
*******************************************************************************/
{
**********************
* Write do file header
**********************
cap program drop _doheader
	program      _doheader
  
  syntax , doname(string) dofile(string)
  
	if !missing("`debug'")	noi di as result "Entering doheader subcommand"

	cap file close  `doname'
		file open  	`doname' using   "`dofile'", text write replace
		file write  `doname' "/*=============================================================================="  _n     // <---- Writing in do file here
		file write  `doname' "This do-file was created using iecorrect" _n 												// <---- Writing in do file here
		file write  `doname' "Last updated by `c(username)' on `c(current_date)' at `c(current_time)'" _n 				// <---- Writing in do file here
		file write  `doname' "==============================================================================*/" _n _n   // <---- Writing in do file here
		file close  `doname'  
      
  end
  
***************************
* Write numeric corrections
***************************
cap program drop _donumeric
	program 	 _donumeric
	
	syntax , ///
		doname(string) idvar(string) ///
		[originalvars(string) floatvars(string) doublevars(string) stringvars(string) ///
		debug generate] 
				
	if !missing("`debug'") noi di as result "Entering donumeric subcommand"

		file write  `doname' "** Correct entries in numeric variables " _n								// <---- Writing in do file here

		* Count the number of lines in the current data set: each line will be one
		* line in the do-file
		qui count
		
		* Write one line of correction for each line in the data set
		forvalues row = 1/`r(N)' {

			* Calculate replacement to be made
			local var	= varname[`row']
			local value	= value[`row']

			local line	`"replace `var' = `value' if "'												

			* Calculate condition for replacement based on current value
			local valuecurrent 	= valuecurrent[`row']
			if  "`valuecurrent'" != ".v" {
				if 		regex(" `floatvars' ", " `var' ")  local line	`"`line'(`var' == float(`valuecurrent')) & "'
				else if regex(" `doublevars' ", " `var' ") local line	`"`line'(`var' == double(`valuecurrent')) & "'
				else 									   local line	`"`line'(`var' == `valuecurrent') & "'
			}

			_idcond, ///
				idvar(`idvar') row(`row') `debug' ///
				stringvars(`stringvars') floatvars(`floatvars') doublevars(`doublevars') 
				
			if !missing(`"`r(idcond)'"') 	local line `"`line'`r(idcond)'"'	
			local line = substr(`"`line'"', 1, length(`"`line'"') - 3)
			
			** Write the line to the do file
			file write  `doname' `"`line'"' _n															// <---- Writing in do file here
		}	

	if !missing("`debug'") noi di as result "Exiting donumeric subcommand"
end

***************************
* Write string corrections
***************************
cap program drop _dostring
	program 	 _dostring
	
	syntax , ///
		doname(string) idvar(string) ///
		[originalvars(string) floatvars(string) doublevars(string) stringvars(string) ///
		debug generate] 
	
	if !missing("`debug'") noi di as result "Entering dostring subcommand"
	
		file write  `doname'		  "** Correct entries in string variables " _n						// <---- Writing in do file here

		* Count the number of lines in the current data set: each line will be one
		* line in the do-file
		qui count 
		
		* Write one line of correction for each line in the data set
		forvalues row = 1/`r(N)' {
		
			* Calculate replacement to be made
			local var	= varname[`row']
			local value	= value[`row']

			local line	`"replace `var' = "`value'" if "'												

			* Calculate condition for replacement based on current value
			local valuecurrent 	= valuecurrent[`row']
			if ("`valuecurrent'" != ".v") 	local line	`"`line'(`var' == "`valuecurrent'") & "'
			
			_idcond, ///
				idvar(`idvar') row(`row') `debug' ///
				stringvars(`stringvars') floatvars(`floatvars') doublevars(`doublevars') 
				
			if !missing("`r(idcond)'") 	local line `"`line'`r(idcond)'"'
			local line = substr(`"`line'"', 1, length(`"`line'"') - 3)
		
			** Write the line to the do file
			file write `doname'	`"`line'"' _n															// <---- Writing in do file here
		}
		
end

***********************
* Dropping observations
***********************
cap program drop 	_dodrop
	program    		_dodrop
  
  	syntax , ///
		doname(string) idvar(string) ///
		[originalvars(string) floatvars(string) doublevars(string) stringvars(string) ///
		debug generate] 

  if !missing("`debug'") noi di as result "Entering dodrop subcommand"
  
	  file write  `doname'      "** Drop observations " _n               								// <---- Writing in do file here
	  
	  * Write one line of correction for each line in the data set
	  qui count 
	  forvalues row = 1/`r(N)' {
		
			_idcond, ///
				idvar(`idvar') row(`row') `debug' ///
				stringvars(`stringvars') floatvars(`floatvars') doublevars(`doublevars') 
				
			local line `"drop if `r(idcond)'"'
			local line = substr(`"`line'"', 1, length(`"`line'"') - 3)
		
			** Write the line to the do file
			file write `doname'	`"`line'"' _n															// <---- Writing in do file here
		}
		
end

************************************
* Write code to create new variables
************************************

cap program drop _idcond
	program    	 _idcond, rclass
	
	syntax, idvar(string) row(numlist) [floatvars(string) doublevars(string) stringvars(string) debug] 
	
	if !missing("`debug'") noi di as result "Entering idcond subcommand"

		local n_ids = wordcount("`idvar'")

		forvalues i = 1/`n_ids' {
			
			local idvarname : word `i' of `idvar' 
			local idval 	= `idvarname'[`row']

			if !missing("`idval'") & ("`idval'" != ".v") {
					 if regex(" `stringvars' ", " `idvarname' ") local idcond	`"`idcond'(`idvarname' == "`idval'") & "'
				else if regex(" `floatvars' " , " `idvarname' ") local idcond	`"`idcond'(`idvarname' == float(`idval')) & "'
				else if regex(" `doublevars' ", " `idvarname' ") local idcond	`"`idcond'(`idvarname' == double(`idval')) & "'
				else 									   		 local idcond	`"`idcond'(`idvarname' == `idval') & "'
			}
		}

	if !missing("`debug'") noi di as result "Exiting idcond subcommand"
	 
	return local idcond `"`idcond'"'

end

**********************
* Write do file footer
**********************

cap program drop 	_dofooter
	program    		_dofooter
  
	syntax , doname(string) dofile(string) 
  
	cap file close  `doname'
		file open   `doname' using   "`dofile'", text write append
		file write  `doname'      _n _n  
		file write  `doname'    "***************************************************************** End of do-file"  // <---- Writing in do file here
		file close  `doname'  
      
  end
}
/*******************************************************************************  
  Run the do file with corrections
*******************************************************************************/
{
cap program drop _dorun
	program      _dorun
  
	syntax using/, doname(string) dofile(string) data(string) sheets(string) idvar(string) [NOIsily debug break]

	if !missing("`debug'")    noi di as result "Entering dorun subcommand"
	if !missing("`noisily'")  noi di ""
	
	if !missing("`noisily'")  local display noi
	else					  local display qui
	
	
	* Read do-file line by line
	tempname file
	file open `doname' using "`dofile'", read
	file read `doname' line
	
	while r(eof)==0 {
		
		* If the line is starting a new type of correction, 
		* start a new matrix to store the number of changes caused by this
		* type of corrections
		if (substr(`"`line'"', 1, 3) == "** ") {
			
			if regex(`"`line'"', "numeric") local matrix numeric
			if regex(`"`line'"', "string") 	local matrix string
			if regex(`"`line'"', "Drop") 	local matrix drop
			
			local row 1
			
		}
		* If the line is actually making a correction, make that correction and
		* count the number of changes
		else if ((substr(`"`line'"', 1, 7) == "replace") | (substr(`"`line'"', 1, 4) == "drop")) {
			
			local ++row
			
			* Count number of changes and store in a local
			local  		if_start 	= strpos(`"`line'"'," if (")
			local  		condition 	= substr(`"`line'"', `if_start', .)
			qui count  `condition'
			local obs = r(N)
			
			* Throw a warning if there are no changes
			if (`obs' == 0) {
				local nochange 1
			}
			
			* Run line with changes
			`display' di `"`line'"'
			`display' `line'
			
			* Write number of changes in matrix with this type of changes
			if (`row' == 2) {
				mat `matrix' = `obs'
			}
			else {
				mat `matrix' = `matrix' , `obs'
			}
		}
		
		* Read next line
		file read `doname' line
	}

	file close `doname'
	
	if ("`nochange'" == "1") {
		noi di as  error `"{phang}At least one of the lines in the spreadsheet did not create any modifications in the data. Refer to column [n_changes] in the spreadsheet for details on which lines caused this error.{p_end}"'
		if !missing("`break'") {
			noi di as  error `"{phang}No corrections were applied to the data.{p_end}"'
			error 111 
			exit
		}
	}
	
	* Save changes to the data
	qui save `data', replace

	* Update information on the workbook to include last date when changes were made
	foreach sheet of local sheets {
		
		qui import excel "`using'", sheet("`sheet'") firstrow allstring clear
		
		* Update records from last time the file was run
		qui ds
		if regex(r(varlist),  "date_last_changed")  local changes_applied 1
		else										local changes_applied 0
		
									local keep `idvar' initials notes
		if ("`sheet'" != "drop")	local keep `keep' varname  valuecurrent value 
		else						local keep `keep' n_obs
		if (`changes_applied' == 1)	local keep `keep' date_last_changed
										  keep `keep'
		
		* Add new column to template with number of changes for corrections other than "drop" type
		* (drop type already has a check for number of observations dropped)
		if ("`sheet'"  != "drop") {
			
			matrix `sheet' = `sheet''
			svmat  `sheet' , names("n_changes")
			
			rename n_changes1  n_changes
			local  keep `keep' n_changes
		}
		
		* Add a column with the date when changes were last applied
		if (`changes_applied' == 1)	replace date_last_changed = "`c(current_date)'"
		else 						gen		date_last_changed = "`c(current_date)'"

		* Export Excel
		qui export excel "`using'", sheet("`sheet'", replace) firstrow(variables)

	}
  
end
}
/*******************************************************************************  
  Create template sheet
*******************************************************************************/
{
cap program drop templateworkbook
	program		 templateworkbook
	
	syntax using/ , idvar(string) [debug]
	
	if !missing("`debug'")     noi di as result "Entering templateworkbook subcommand"
	
	preserve
		
		* String variables
		templatesheet using "`using'", ///
			varlist("`idvar' varname value valuecurrent initials notes") ///
			sheetname("string") ///
			current("value")

		* Numeric variables
		templatesheet using "`using'", ///
			varlist("`idvar' varname value valuecurrent initials notes") ///
			sheetname("numeric") ///
			current("value")

		* Drop observations
		templatesheet using "`using'", ///
			varlist("`idvar' n_obs initials notes") ///
			sheetname("drop")

		noi di as result `"{phang}Template spreadsheet saved to: {browse "`using'":`using'}{p_end}"'
			
	restore
	
end

cap program drop 	templatesheet
	program     	templatesheet
  
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
}

/*******************************************************************************  
  Save the do file with corrections
*******************************************************************************/

cap program drop 	_dosave
	program    		_dosave
  
	syntax , doname(string) dofile(string) save(string) [debug replace]
     
	 	if !missing("`debug'")	noi di as result "Entering dosave subcommand"
		
		* Standardize do file path
		local doname = subinstr(`"`save'"',"\","/",.)

		* Get the file extension       
		local save_fileext = substr(`"`save'"', strlen(`"`save'"') - strpos(strreverse(`"`save'"'),".") + 1, .)

		* If no file extension was used, then add .do to "`save'"
		if ("`save_fileext'" == "") {
			local save  "`save'.do"
		}	
		else if (`"`save_fileext'"' != ".do") {
			noi di as error `"{phang}The file extension used in the option {bf:save} is not valid. The do-file must include the file extension {bf:.do}.{p_end}"'
			error 198
		}      

		* Check that folder exists and save the do file
		cap qui copy "`dofile'" `"`save'"', `replace'
		if _rc == 603 {
			noi di as error `"{phang}The folder path used in the option {bf:save (`save')} does not exist.{p_end}"'
			error 601    
		}
		else if _rc == 602 {
			noi di as error `"{phang}The file used in the option {bf:save (`save')} already exists. Use option {bf:replace} if yo want to overwrite it. {p_end}"'
			error 602          
		}

		noi di as result `"{phang}Corrections do-file was saved to: {browse "`save'":`save'} {p_end}"'

end
 
	
/*******************************************************************************  
  Run the do file with corrections
*******************************************************************************/

cap program drop 	_printaction
	program    		_printaction
  
	syntax , type(string) present(string) [debug]
     
	 	if !missing("`debug'")	noi di as result "Entering printaction subcommand"

		if ("`present'" == "yes") {
			if inlist("`type'", "string", "numeric") {
				local mainvar	varname
				
				qui levelsof `mainvar', clean local(vars)
				noi di as text `"{phang}Variables for corrections of type `type': `vars'{p_end}"'
			}
			else if ("`type'" == "drop") {
				qui collapse (sum) n_obs
				qui sum n_obs
				noi di as text `"{phang}Number of observations to be dropped: `r(mean)'{p_end}"'
			}
		}
		else if ("`present'" == "no") {
		    if inlist("`type'", "string", "numeric") {
				noi di as text `"{phang}No corrections of type `type'.{p_end}"'
			}
			else if ("`type'" == "drop") {
				noi di as text `"{phang}No observations to be dropped.{p_end}"'
			}
		}
		
		if !missing("`debug'")	noi di as result "Exiting printaction subcommand"

end         
 
    

*********************************** THE END ************************************
