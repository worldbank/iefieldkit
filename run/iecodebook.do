
	do "${GitHub}/iefieldkit/src/ado_files/iecodebook.ado"

	
/*******************************************************************************
	Folder and format testing
*******************************************************************************/
	
	* Folder does not exist
	* No file extension
	* Wrong file extension
	

/*******************************************************************************
	Single data set
*******************************************************************************/
	
	sysuse auto, clear
	
/*------------------------------------------------------------------------------
	Template subcommand
------------------------------------------------------------------------------*/
	
	* No error
	cap erase "${codebook}/auto.xlsx"
	iecodebook template using "${codebook}/auto.xlsx"
	
	* Yes error: template already exists
	cap iecodebook template using "${codebook}/auto.xlsx"
	assert _rc == 602
	
	* No error: template already exists, use replace
	iecodebook template using "${codebook}/auto.xlsx", replace
	
	* Yes error: non-template options
	cap iecodebook template using "${codebook}/auto.xlsx", replace match
	assert _rc == 198															// Maybe add to the error message that 'match' cannot be used with 'template'?
	
	cap iecodebook template using "${codebook}/auto.xlsx", replace gen(foo)		
	assert _rc == 198															// Maybe add to the error message that 'match' cannot be used with 'template'?
	
	cap iecodebook template using "${codebook}/auto.xlsx", replace report		
	assert _rc == 198															// Maybe add to the error message that 'report' cannot be used with 'template'?
	
	cap iecodebook template using "${codebook}/auto.xlsx", replace keepall
	assert _rc == 198															// Maybe add to the error message that 'keepall' cannot be used with 'template'?
	
	iecodebook template using "${codebook}/auto.xlsx", replace missing(.d "Don't know")				// No error thrown here
	iecodebook template using "${codebook}/auto.xlsx", replace drop									// No error thrown here

/*------------------------------------------------------------------------------
	Apply subcommand
------------------------------------------------------------------------------*/

	* Blank var names, no drop
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_drop.xlsx"
	
	foreach var in 	make price mpg rep78 headroom trunk weight length ///
					turn displacement gear_ratio foreign {
		cap confirm variable `var'
		assert !_rc
	}
	
	* Drop option
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_drop.xlsx", drop
	
	foreach var in make price mpg rep78 headroom trunk weight length {
		confirm variable `var'
		assert !_rc
	}

	foreach var in turn displacement gear_ratio foreign {
		cap confirm variable `var'
		assert _rc == 111
	}
	
	* Dropping variables with dot
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_dot.xlsx", drop

	foreach var in make price mpg rep78 headroom trunk weight length {
		cap confirm variable `var'
		assert !_rc
	}

	foreach var in turn displacement gear_ratio foreign {
		cap confirm variable `var'
		assert _rc == 111
	}
	
	* Dropping value labels
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_droplabel.xlsx"			
	* Is variable foreing still labelled?										// I don't know how to test this
	
	* Adding value labels
	
	* Labelling variables
	
	* Renaming variables
	
	* Recoding variables
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_recode.xlsx"	
	assert displacement != 79

	* Adding missing codes
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_missingvalues.xlsx", miss(.d "Don't know" .o "Other" .n "Not applicable")
	labelbook
	pause																		// missing values have been added only to yesno
	
	*******************
	* Invalid options *
	*******************
	
	
/*******************************************************************************
	Append data sets
*******************************************************************************/

/*------------------------------------------------------------------------------
	Template subcommand
------------------------------------------------------------------------------*/
	
/*------------------------------------------------------------------------------
	Apply subcommand
------------------------------------------------------------------------------*/

/*******************************************************************************
	Export final code book
*******************************************************************************/

	sysuse auto, clear
	cap erase "${codebook}/auto_export.xlsx"
	iecodebook export using "${codebook}/auto_export.xlsx"						// Not sure how to test content
	
	* Replace option
	iecodebook export using "${codebook}/auto_export.xlsx", replace
	
	* Trim option
	iecodebook export using "${codebook}/auto_export.xlsx", ///
							replace ///
							trim("${iefieldkit}/run/iecodebook_trim1" ///		// file C:\Users\wb501238\Documents\GitHub/iefieldkit/run/iecodebook_trim1.csv not found
								 "${iefieldkit}/run/iecodebook_trim2")
	
	iecodebook export using "${codebook}/auto_export_trim.xlsx", ///			// not running
							replace ///
							trim("${iefieldkit}/run/iecodebook_trim1.do")
	
	
	* IN 
	iecodebook export in 1  using "${codebook}/auto_export.xlsx", replace					// "in range not allowed"
	
	* IF 
	iecodebook export if domestic == 1  using "${codebook}/auto_export.xlsx", replace		// "if not allowed"
