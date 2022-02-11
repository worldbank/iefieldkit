*! version 0 - NOT READY FOR DISTRIBUTION

cap program drop iecorrect
	program 	 iecorrect
		
	syntax [anything] using/, ///
		idvar(varlist) 						 ///
		[ 									 ///
			GENerate 						 ///
			NOIsily 						 ///
			save(string) 					 ///
			replace 						 ///
			other 							 ///
			sheet(string) 					 ///
			debug 							 ///
		]
		
	gettoken subcommand anything : anything
	
	if !inlist("`subcommand'","template","apply") {
		di as err "{bf:iecorrect} requires [template] or [apply] to be specified with a target [using] file. Type {bf:help iecorrect} for details."
	}

	preserve
	
/*==============================================================================
								Save data
==============================================================================*/

	* Test if idvar uniquely identifies the dataset
	_testid `idvar'
		
	tempfile 	 data
	qui save	`data'

/*==============================================================================
                PROCESS OPTIONS
==============================================================================*/
	
	if "`sheet'" == "" {
		local corrSheets	numeric string drop 
		
		if "`other'" != "" {
			local corrSheets "`corrSheets' other"
		}
	}
	else {
		local corrSheets	`sheet'
	}

/*==============================================================================
                Test File
==============================================================================*/

  // Standardize file path
  local using = subinstr(`"`using'"',"\","/",.)  
  
  // Get the file extension       
    local fileext = substr(`"`using'"',strlen(`"`using'"')-strpos(strreverse(`"`using'"'),".")+1,.)

  // If no fileextension was used, then add .xslx to "`using'"
  if "`fileext'" == "" {
      
    local using  "`using'.xlsx"
  }

  // Check if the file extension is the correct  
  else if !inlist("`fileext'",".xlsx",".xls") {
        noi di as error `"{phang}The file must include the extension [.xlsx] or [.xls] The format [`fileext'] is not allowed.{p_end}"'
        error 198
    }  
        
  //   Confirm the file path is correct
  cap confirm new file `using'
  if (_rc == 603) {
    noi di as error `"{phang} The file path used [`using'] does not exist.{p_end}"'
      error 601  
  }  
  
  
/*==============================================================================
              TEMPLATE SUBCOMMAND
              
  Creates a blank excel file to be filled with the corrections.
==============================================================================*/

	if "`subcommand'" == "template" {
		
		if !missing("`debug'") noi di "Entering template subcommand"
	
		// Check if file already exists and check if the "other" tab is included
		cap confirm new file `using'
		if (_rc == 602) {
			if "`other'" != "" {
				cap import excel "`using'", sheet("other") clear
				if _rc == 601 local addother "1"
				else local errorfile "1"
				
			}
			if ("`other'" == "") | ("`errorfile'" == "1") {
				noi di as error `"{phang}File [`using'] already exists. Template was not created.{p_end}"'
			error 602 
				
			}
		}		
		
		// Create the template -----------------------------------------------------
		templateworkbook using "`using'" , idvar(`idvar') `other' addother(`addother')
			
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
			
// Crete a list of variables in the data ---------------------------------------

	qui ds, has(type double)
	local 	double_vars		`r(varlist)'
	
	qui ds, has(type float)
	local 	float_vars		`r(varlist)'
	
	qui ds
	local 	original_vars	`r(varlist)'

/* Check ID format -------------------------------------------------------------

    cap confirm string variable `idvar'
         if !_rc local  stringid 1
    else if  _rc local  stringid 0

    if !missing("`debug'") noi di as result "String ID: `stringid'"
*/
    
// Check that file exists ------------------------------------------------------

    cap confirm new file "`using'"
    if (_rc != 602) {  
      noi di as error `"{phang}The iecorrect template is not found. The template must be created before the apply subcommand can be used. {p_end}"'
      error 601 
    }
    
// Check which types of corrections need to be made ----------------------------

    foreach type of local corrSheets {
    
      * Check that template was correctly filled
      checksheets using "`using'", type("`type'") stringid(`stringid') idvar(`idvar') `debug'
      
      * The result indicates if there are corrections of this type
        local `type'corr   `r(`type'corr)'

      * If there are, it also lists the variables to be corrected or IDs to be dropped
      if ``type'corr' == 1 {
          
        * List variables to be corrected
        local `type'vars  `r(`type'vars)'
        
        if "`type'" == "other" {
          local categoricalvars `r(categoricalvars)'
        }
        
        * List IDs to be dropped and corresponding number of observations
        if "`type'" == "drop" {
          local idvals   `r(idvals)'
          local n_obs    `r(n_obs)'
        }
        
        local any_corrections 1
      }  
    }

// Check drop number corrections -----------------------------------------------

    qui use `data', clear

    local n : word count `idvals'

    forvalues i = 1/`n' {
        
      * Get ID and number of corresponding observations
      local id  : word `i' of `idvals'
      local obs : word `i' of `n_obs'

      * Test that the number of observations that will be dropped is correct
      qui count if `idvar' == `id'
      
      cap assert `obs' != r(N)
      if !_rc {
        noi di as error `"{phang} The number of observations with ID value [`id'] in the data does not match the number of observations listed in the column [n_obs] of the template sheet [drop].{p_end}"'
        error 111    
      }

      else if _rc {
        noi di as result `"{phang}`obs' observations with ID value [`id'] will be removed from the data.{p_end}"'
      }
    }

// Check dataset variables to be corrected -------------------------------------

    qui use `data', clear
 
    foreach type in string other numeric {

		if inlist("`type'","string", "other" ) &  "``type'corr'"== "1" {
			cap confirm string var ``type'vars'
			if _rc local errortype 1
		}
		
		if "`type'" == "numeric" &  "``type'corr'"== "1"{
			qui cap confirm string var `type'vars
			if !_rc local errortype 1
		}

		* Check if the string variables to be corrected don't have extra white spaces and special characters
		foreach var of local `type'vars { 
			qui destring `var', replace
			qui cap confirm string var `var' 
			if !_rc {
				valstrings `var', location(Variable)
			}	
		}
		
		if "`errortype'" == "1" {
			
			if inlist("`type'", "string", "numeric") {
				noi di as error `"{phang} At least one variable for column varname in `type' sheet is not `type'. This column should contain `type' variables to be corrected.{p_end}"'
				error 109	
			}
			if "`type'" == "other" {
				noi di as error `"{phang} At least one variable for column varname in `type' sheet is not string. This column should contain string variables to be corrected.{p_end}"'
				error 109				
				
			}
		}				
	}
	   
/*******************************************************************************  
  Create a do file containing the corrections
*******************************************************************************/    

// Define tempfile -------------------------------------------------------------
    
    tempname  doname
    tempfile  dofile

// If the do file will be saved for later reference, add a header --------------
    if "`save'" != "" {
      qui doheader , doname("`doname'") dofile("`dofile'")
    }
    
// Write new variables to be created -------------------------------------------
  
  foreach var in `stringvars' {
  
    cap assert regex(" `original_vars' ", " `var' ")
    if _rc &  "`generate'" != "" {
      qui {
        cap  file close   `doname'
          file open    `doname' using   "`dofile'", text write append
          file write  `doname'    `"gen `var' = "" "' _n      // <---- Writing in do file here
          file close  `doname'  
      }  
    }
  }

  foreach var in `numericvars' `categoricalvars' {

    cap assert regex(" `original_vars' ", " `var' ")  
    if _rc &  "`generate'" != "" {
      qui {
        cap  file close   `doname'
          file open    `doname' using   "`dofile'", text write append
          file write  `doname'    "gen `var' = . " _n      // <---- Writing in do file here
          file close  `doname'
      }
    }
    
    if _rc &  "`generate'" == "" {
      noi di as error `"{phang} The variable {bf:`var'} does not exist in the dataset. Check the variable name or use [generate] option to create a categorical variable to represent your corrections.{p_end}"'
      error 111
    }
  }

// Read correction sheet -------------------------------------------------------

	local numericopts "floatvars(`float_vars') doublevars(`double_vars')"
	
    foreach type of local corrSheets {

      if ``type'corr' {
        
		* Open the data set with the numeric corrections
        cap import excel "`using'", sheet("`type'") firstrow allstring clear
        
        * Drop observations with all missing variables
        tempvar      allmiss
        egen        `allmiss' = rownonmiss(*), strok
        qui keep if `allmiss' > 0
        drop        `allmiss'

        * Open the placeholder do file and write the corrections to be made
        cap  file close   `doname'
        qui  file open    `doname' using "`dofile'", text write append
              
        do`type',    doname("`doname'") idvar("`idvar'") stringid(`stringid') `debug' ``type'opts'

        * Add an extra space before the next set of corrections
        file write   `doname'      _n _n          
        file close   `doname'

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
			* Standardize do file path
			local save= subinstr(`"`save'"',"\","/",.)
         
      * Get the file extension       
      local save_fileext = substr(`"`save'"',strlen(`"`save'"')-strpos(strreverse(`"`save'"'),".")+1,.)
      
      * If no file extension was used, then add .do to "`save'"
      if "`save_fileext'" == "" {
        local save  "`save'.do"
      }    
            
      else if !(`"`save_fileext'"' == ".do" ){
        noi di as error `"{phang}The file extension used in the option save is not valid. The do-file must include the file extension [.do].{p_end}"'
        error 198
      }      
      
      * Check that folder exists and save the do file
      cap qui copy "`dofile'" `"`save'"', `replace'
      if _rc == 603 {
        noi di as error `"{phang}The folder path used in the option save [`save'] does not exist.{p_end}"'
        error 601    
      }
      
      else if _rc == 602 {
        noi di as error `"{phang}The file used in the option save [`save'] already exists. Use [replace] option if yo want to overwrite it. {p_end}"'
        error 602          
      }
      
      noi di as result `"{phang}Corrections do file was saved to: {browse "`save'":`save'} {p_end}"'
    }  
    
/*******************************************************************************  
  Run the do file containing the corrections
*******************************************************************************/
  
    restore
    
    * Don't run if there are no corrections to be made
    if !missing("`any_corrections'") {
      dorun , doname("`doname'") dofile("`dofile'") data("`data'") `debug' `noisily' 
    }     
  
    if !missing("`debug'") noi di as result "Exiting template subcommand"
  
  }                                        // End of apply subcommand 
  
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
	
	syntax varlist
	
	cap isid `varlist'
		
	if _rc == 459 {
			noi di as error `"{phang}The ID variables listed in option [idvar] do not uniquely and fully identify the data. This may cause unintended changes to the data when applying corrections.{p_end}"'
			noi di 			""
	}
	
	
end

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
			local mainvar	varname
		}
		if "`anything'" == "string" 	local mainvar	varname
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
	program    	 checksheets, rclass
  
  syntax using/, type(string) stringid(numlist) idvar(varlist)  [debug]
  
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
      
	  checkcol`type', idvar(`idvar') 
      if "`r(errorfill)'" == "1" {
        error 198
      }
      
	  if !missing("`debug'") noi di as result "Exiting checkcol`type' subcommand"
      
      *If everything works, save the sheet in a tempfile and create a local saying to run the next command
      local  `type'corr  1 
            
      * List the variables that will need corrections of this type
      qui levelsof `mainvar', local(`type'vars) clean
      
      * List categorical variables used in 'other' corrections
      if "`type'" == "other" {
        qui levelsof catvar, local(categoricalvars) clean
      }
      
      * List idvals and number of observations to be dropped
      if "`type'" == "drop" {
        qui levelsof idvalue,   local(idvals)
        qui levelsof n_obs,   local(n_obs)
      }
      
      if inlist("`type'", "string", "numeric", "other") {
        noi di as text `"{phang}Variables for corrections of type `type': ``type'vars'{p_end}"'
      }
      else {
        noi di as text `"{phang}IDs of observations to be dropped: ``type'vars'{p_end}"'
      }    
    }
    
    * If there are no corrections to be made, save that information and move forward
    else if `r(N)' == 0 {
      local  `type'corr  0
      if inlist("`type'", "string", "numeric", "other") {
        noi di as text `"{phang}No corrections of type `type'.{p_end}"'
      }
      else {
        noi di as text `"{phang}No observations to be dropped.{p_end}"'
      }
    }
    
    ** Save the information
    * Whether there are any corrections to be made
    return local `type'corr   ``type'corr'  
    
    * What are the names of the variables to be corrected
    return local `type'vars   ``type'vars'
    
    if "`type'" == "other" {
      return local categoricalvars `categoricalvars'
    }
    
    if "`type'" == "drop" {
      return local idvals `idvals'
      return local n_obs  `n_obs'
    }
    
    if !missing("`debug'") noi di as result "Exiting checksheets subcommand"
    
  end
  
***********************************
* Check variables in numeric sheet
***********************************

cap program drop checkcolnumeric
	program 	 checkcolnumeric, rclass
	
	syntax, idvar(varlist)
	
		* Are all the necessary variables there?
		foreach var in `idvar' varname valuecurrent value {
			cap confirm var `var'
			if _rc {
				noi di as error `"{phang}Column `var' not found in sheet [numeric]. This variable must not be erased from the template. If you do not wish to use it, leave it blank.{p_end}"'
				local errorfill 1
			}
		}
		
		* Keep only those variables in the data set -- the user may have added notes
		* that are not relevant for the command
		keep varname `idvar' valuecurrent value 
		
* Checks -----------------------------------------------------------------------

		* Check id variables
		_fillid, type(numeric)
		
		** Check that variables have the correct format
		cap confirm string var varname
		if _rc {
			noi di as error `"{phang}Column varname in sheet [numeric] is not a string. This column should contain the name of the `type' variables to be corrected.{p_end}"'
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
	
	syntax, idvar(varlist)
	
		* Are all the necessary variables there?
		foreach var in `idvar' varname valuecurrent value {
			cap confirm var `var'
			if _rc {
				noi di as error `"{phang}Column `var' not found in sheet [string]. This variable must not be erased from the template. If you do not wish to use it, leave it blank.{p_end}"'
			}
		}
		
		* Keep only those variables in the data set -- the user may have added notes
		* that are not relevant for the command
		keep varname `idvar' valuecurrent value 
		
		** Check that variables have the correct format
		cap confirm string var varname
		if _rc {
			noi di as error `"{phang}Column varname in sheet [string] is not a string. This column should contain the name of the `type' variables to be corrected.{p_end}"'
			local errorfill 1
		}
		
		cap assert !missing(value)
		if _rc {
			noi di as error `"{phang}At least one entry for column value in sheet [string] is blank. If there are no corrections specified in a row, remove it from the corrections form.{p_end}"'
			local errorfill 1
		}
					
		** Either idvalue or valuecurrent need to be specified
		qui count if missing(idvalue) & missing(valuecurrent)
		if r(N) > 0 {
			noi di as error `"{phang}There are `r(N)' lines in sheet [string] where neither the idvalue or the valuecurrent columns are specified. At least one of these columns should be filled for numeric corrections to be made correctly.{p_end}"'
			local errorfill 1
		}
		
		return local errorfill `errorfill'
		
end		
	
***********************************
* Check variables in other sheet
***********************************

cap program drop checkcolother
  program    checkcolother, rclass
  
  syntax [anything]
  
    * Are all the necessary variables there?
    foreach var in strvar strvaluecurrent catvar catvalue {
      cap confirm var `var'
      if _rc {
        noi di as error `"{phang}Column `var' not found in sheet [other]. This column must not be erased from the template. If you do not wish to use it, leave it blank.{p_end}"'
        local errorfill 1
      }
    }
    
    * Keep only those variables in the data set -- the user may have added notes
    * that are not relevant for the command
    keep strvar strvaluecurrent catvar catvalue
    
    ** Check that variables have the correct format
    foreach var in strvar catvar {
      qui destring `var', replace
      cap confirm string var `var'
      if _rc {
        noi di as error `"{phang}Column `var' in sheet [other] is not a string. This column needs to be filled for corrections of categorical variable to be made.{p_end}"'
        local errorfill 1
      }
    }
    
    cap assert !missing(catvalue)
    if _rc {
      noi di as error `"{phang}At least one entry for column catvalue in sheet [other] is blank. If there are no corrections specified in a row, remove it from the corrections form.{p_end}"'
      local errorfill 1
    }
    
    ** Either strvaluecurrent need to be specified
    qui count if missing(strvaluecurrent)    
    if r(N) > 0 {
      noi di as error `"{phang}There are `r(N)' lines in sheet [other] sheet where strvaluecurrent column is not filled. This column should be filled for categorical corrections to be made correctly.{p_end}"'
      local errorfill 1
    }

    ** Check if the string columns have extra whitespaces and special characters
    foreach var in strvar strvaluecurrent catvar {
      valstrings `var', location(Column)         
    }
    
    return local errorfill `errorfill'
    
end  

********************************
* Check variables in drop sheet
********************************
  
cap program drop checkcoldrop
  program    checkcoldrop, rclass
  
  syntax, idvar(varlist)
  
    * Are all the necessary variables there?
    foreach var in `idvar' n_obs {
      cap confirm var `var'
      if _rc {
        noi di as error `"{phang}Column `var' not found in sheet [drop]. This column must not be erased from the template.{p_end}"'
        local errorfill 1
      }
    }
  
* Checks -----------------------------------------------------------------------

		* Check id variables
		_fillid, type(numeric)

    cap assert !missing(idvalue)
    if _rc {
      noi di as error `"{phang}At least one entry for column idvalue in sheet [drop] is blank. If there are no corrections specified in a row, remove it from the corrections form.{p_end}"'
      local errorfill 1
    }
    
    cap assert !missing(n_obs)
    if _rc {
      noi di as error `"{phang}At least one entry for column n_obs in sheet [drop] is blank. Dropping observations without confirming the number of rows to be deleted is a risky practice that is not allowed by iecorrect. If there are no corrections specified in a row, remove it from the corrections form.{p_end}"'
      local errorfill 1
    }
        
    qui destring n_obs, replace
    cap confirm string var n_obs
    if !_rc {
      noi di as error `"{phang}Column n_obs in sheet [drop] is not numeric. This column should contain the number of observations to be dropped.{p_end}"'
      local errorfill 1
    }
    
    return local errorfill `errorfill'
      
end  

*************************************************************
* Check that ID vars were filled correctly
*************************************************************

cap program drop _fillid
	program    	 _fillid, rclass
	
	syntax varlist, type(string)
	
* Check that all IDs were filled -----------------------------------------------

	local n_vars = wordcount("`varlist'")
	
	* Three options: all filled, none filled, some filled
	tempvar   blank_ids
	qui egen `blank_ids' = rowmiss(`varlist')

	qui count if (`blank_ids' > 0) & (`blank_ids' != `n_vars')
	if r(N) > 0 {
		noi di as error `"{phang}There are `r(N)' lines in sheet [`type'] where the  ID variable columns were not filled correctly: the value for at least one of the ID variables was left blank. If you wish to apply corrections to obsevartions regardless of the value they take for one of the ID variables, fill the column that corresponds to this variable with the wildcard sign (*).{p_end}"'
      local errorfill 1
	}
  
  * Return an error if something was filled incorrectly ------------------------
  
	return local errorfill `errorfill'
	
 end

*************************************************************
* Check if there are extra whitespaces and special characters
*************************************************************
cap program drop valstrings
  program    valstrings, rclass
  
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
      strerror, var(`varlist') type(whitespace) location(`location')  
    }
  
    ********************
    * Special Characters
    ********************
    forvalues i = 0/255 {
      if !inrange(`i', 48, 57) /// numbers
        & !inrange(`i', 65, 90) /// uppers case letters
        & !inrange(`i', 97, 122) ///  case letters
        & !inlist(`i', 32, 33, 35, 37, 38, 40, 41, 42, 43, 44, 45, 46, 58, 59, 60, 61, 62, 63, 64, 91, 93, 95){ 
        capture assert index(`validation', char(`i')) == 0 
		if _rc local errorspecialcharac 1	
      }
    }
	
	if "`errorspecialcharac'" == "1" {
			strerror, var(`varlist') type(specialchar) location(`location')
	}
	
end  

cap program drop strerror
  program    strerror
  
  syntax , var(string) type(string) location(string)
  
  if "`type'" == "specialchar" {
    local issue   special characters
    local details   ""
  }
  else if "`type'" == "whitespace" {
    local issue   extra whitespaces
    local details   (leading, trailing or consecutive spaces, tabs or new lines)
  }
  
  noi di as error `"{phang}`location' {bf:`var'} contains `issue' `details'. [iecorrect] will run, but this may cause mismatches between the template spreadsheet and the content of the data, in which case the corrections will not be applied. It is recommended to remove `issue' from the data and the template spreadsheet before running [iecorrect].{p_end}"'
    
end
  
/*******************************************************************************  
  Write the do file with corrections

*******************************************************************************/

**********************
* Write do file header
**********************
cap program drop doheader
  program    doheader
  
  syntax , doname(string) dofile(string)
    
    cap  file close   `doname'
      file open    `doname' using   "`dofile'", text write replace
      file write  `doname'    "* Write header here" _n _n          // <---- Writing in do file here
      file close  `doname'  
      
  end
  
***************************
* Write numeric corrections
***************************
cap program drop donumeric
	program 	 donumeric
	
	syntax , doname(string) idvar(string) stringid(numlist) [floatvars(string) doublevars(string) debug] 
				
	if !missing("`debug'") noi di as result "Entering donumeric subcommand"
	
	file write  `doname' "** Correct entries in numeric variables " _n								// <---- Writing in do file here
	
	* Count the number of lines in the current data set: each line will be one
	* line in the do-file
	qui count
	
	* Write one line of correction for each line in the data set
	forvalues row = 1/`r(N)' {

		* Calculate the user-specified inputs for this line
		local var			= varname[`row']
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
		    if 		regex(" `floatvars' ", " `var' ")  local line	`"`line'`var' == float(`valuecurrent')"'
			else if regex(" `doublevars' ", " `var' ") local line	`"`line'`var' == double(`valuecurrent')"'
			else 									   local line	`"`line'`var' == `valuecurrent'"'
													
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
		local var			= varname[`row']						
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
  program    dodrop
  
  syntax , doname(string) idvar(string) stringid(numlist) [debug]

  if !missing("`debug'") noi di as result "Entering dodrop subcommand"
  
  file write  `doname'      "** Drop observations " _n                // <---- Writing in do file here

  * Write one line of correction for each line in the data set
  qui count 
  forvalues row = 1/`r(N)' {
    
    local idvalue    = idvalue[`row']

    if `"`idvalue'"' != "" {
      *Confirm that ID var was specified
      *Confirmed that ID var is the same type as idvaue

      ** Write the line to the do file
      if `stringid'  local idvalue = `""`idvalue'""'
      
      file write `doname'  `"drop if `idvar' == `idvalue' "' _n              // <---- Writing in do file here
      
    }
  }

  if !missing("`debug'") noi di as result "Exiting dodrop subcommand"
  
end
  
***************************
* Write 'other' corrections
***************************

cap program drop doother
  program    doother
  
  syntax , doname(string) idvar(string) stringid(numlist) [debug]
  
  if !missing("`debug'") noi di as result "Entering doother subcommand"
  
  file write  `doname'      "** Adjust categorical variables to include 'other' values " _n
  
  qui count
  forvalues row = 1/`r(N)' {
    
    local strvar      = strvar[`row']
    
    local strvaluecurrent   = strvaluecurrent[`row']
    local strvaluecurrent  = `""`strvaluecurrent'""'
    
    local catvar       = catvar[`row']
    local catvalue       = catvalue[`row']

    if "`catvar'" != ""  {
      file write `doname'    `"replace `catvar' = `catvalue' if `strvar' == `strvaluecurrent'"' _n
    }
  }

  if !missing("`debug'") noi di as result "Exiting doother subcommand"
end
  

**********************
* Write do file footer
**********************

cap program drop dofooter
  program    dofooter
  
  syntax , doname(string) dofile(string) 
  
    cap  file close   `doname'
      file open    `doname' using   "`dofile'", text write append
      file write  `doname'    "***************************************************************** End of do-file"  // <---- Writing in do file here
      file close  `doname'  
      
  end
  
/*******************************************************************************  
  Run the do file with corrections
*******************************************************************************/

cap program drop dorun
  program     dorun
  
  syntax , doname(string) dofile(string) data(string) [NOIsily debug]
  
  if !missing("`debug'")     noi di as result "Entering dorun subcommand"
  
                local display qui
  if !missing("`noisily'")  local display noi
  
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
	
	syntax using/ , idvar(string) [other addother(string)]
	
	preserve
	    if "`addother'" == "" { 
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
			varlist("`idvar' initials notes") ///
			sheetname("drop")
		}	

		* Other variables
		if "`other'" != "" {
			templatesheet using "`using'", ///
				varlist("strvar strvaluecurrent catvar catvalue initials notes") ///
				sheetname("other") ///
				current("strvalue")
		}
			

		noi di as result `"{phang}Template spreadsheet saved to: {browse "`using'":`using'}{p_end}"'
			
	restore
	
end

cap program drop templatesheet
  program     templatesheet
  
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
