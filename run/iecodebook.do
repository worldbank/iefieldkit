
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
	
/*------------------------------------------------------------------------------
	Template subcommand
------------------------------------------------------------------------------*/
	
	sysuse auto, clear
		
	* No error
	cap erase "${codebook}/auto.xlsx"
	iecodebook template using "${codebook}/auto.xlsx"
	
	* No error: template already exists, use replace
	iecodebook template using "${codebook}/auto.xlsx", replace
	
	
	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	
	* Template already exists
	cap iecodebook template using "${codebook}/auto.xlsx"
	assert _rc == 602
	
	* Non-template options
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
	
	* Simple run
	
	* Run with replace
	
	* Match
		
/*------------------------------------------------------------------------------
	Append subcommand
------------------------------------------------------------------------------*/

	* Generate
	
	* Report
	
	* choices_first, choices_second,… sheets - are they reflecting changes we make?

	* keepall

/*******************************************************************************
	Export final code book
*******************************************************************************/

	sysuse auto, clear
	cap erase "${codebook}/auto_export.xlsx"
	iecodebook export using "${codebook}/auto_export.xlsx"						// Not sure how to test content
	
	* Replace option
	iecodebook export using "${codebook}/auto_export.xlsx", replace
	
	* Trim option : not working yet
	iecodebook export using "${codebook}/auto_export.xlsx", ///
							replace ///
							trim("${iefieldkit}\run\iecodebook_trim1.do" ///
								 "${iefieldkit}\run\iecodebook_trim2.do")
	
	iecodebook export using "${codebook}/auto_export_trim.xlsx", ///			// not running
							replace ///
							trim("${iefieldkit}/run/iecodebook_trim1.do")
	*/
	
* Signature option -------------------------------------------------------------

	* Should not work if there's no file and [reset] was not specified
	cap erase  "${codebook}/auto_export-sig.txt"
	cap iecodebook export using "${codebook}/auto_export.xlsx", replace signature
	assert _rc == 601
	
	* Create it 
	iecodebook export using "${codebook}/auto_export.xlsx", replace signature reset
	
	* Compare when no changes
	iecodebook export using "${codebook}/auto_export.xlsx", replace signature
	
	* Compare when changes
	preserve
		
		drop in 1
		cap iecodebook export using "${codebook}/auto_export.xlsx", replace signature
		assert _rc == 9
		
	restore
	
	* textonly option
	iecodebook export using "${codebook}/auto_export.xlsx", txt(detailed) 	replace txtonly
cap iecodebook export using "${codebook}/auto_export.xlsx", 				replace txtonly	
	assert _rc == 198
	iecodebook export using "${codebook}/auto_export.xlsx", txt(compact) 	replace
	iecodebook export using "${codebook}/auto_export.xlsx", txt(detailed) 	replace
cap iecodebook export using "${codebook}/auto_export.xlsx", txt(dalk) 		replace
	assert _rc == 198
	
	* Verify option
	iecodebook export using "${codebook}/auto_export.xlsx", replace verify
	iecodebook export using "${codebook}/auto_export.xlsx", verify
	
	preserve
	
		drop mpg
		cap iecodebook export using "${codebook}/auto_export.xlsx", verify
		assert _rc == 7
		
	restore
	
	preserve
	
		drop mpg
		cap iecodebook export using "${codebook}/auto_export.xlsx", verify replace
		assert _rc == 7
			
	restore
	
	preserve
	
		label drop origin
		cap iecodebook export using "${codebook}/auto_export.xlsx", verify replace
		assert _rc == 7
		
	restore
	
	
	* Use option
	sysuse auto, clear
	tempfile auto
	save 	`auto'
	
	clear
	iecodebook export `auto' using "${codebook}/auto_export.xlsx", replace
	
	clear
	iecodebook export "${codebook}/auto" using "${codebook}/auto_export.xlsx", replace
	
	clear
	cap iecodebook export "auto" using "${codebook}/auto_export.xlsx", replace
	assert _rc == 601
	
	* Save option
	iecodebook export "${codebook}/auto" using "${codebook}/auto_export.xlsx", replace save
	
	cap erase "${codebook}/auto_export.xlsx"
	cap iecodebook export "${codebook}/auto" using "${codebook}/auto_export.xlsx", save
	assert _rc == 602
	
	* Special characters
	lab var make 	"É"
	lab def origin  0 "ã & @", replace
	iecodebook export using "${codebook}/auto_export.xlsx", replace
	
	
