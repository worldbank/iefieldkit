	global GitHub  "C:\Users\Inspiron\Desktop\GitHub"
	global iefieldkit "${GitHub}/iefieldkit"
	global codebook "${iefieldkit}/run/codebooks"

	do "${GitHub}/iefieldkit/src/ado_files/iecodebook.ado"

	
/*******************************************************************************
	Folder and format testing
*******************************************************************************/
	sysuse auto, clear
	* Folder does not exist
	cap iecodebook template using "folder/auto.xlsx"
	assert _rc == 601
	
	cap iecodebook apply using "folder/auto_no_exist.xlsx"
	assert _rc == 601
	
	* File does not exist
	cap iecodebook apply using "${codebook}/auto_no_exist.xlsx"
	assert _rc == 601	
	
	* Wrong file extension
	cap iecodebook template using "${codebook}/auto.xsl"
	assert _rc == 601
	
	cap iecodebook apply using "${codebook}/auto.xsl"
	assert _rc == 601
	
	* No error: No file extension
	iecodebook template using "${codebook}/auto", replace
	iecodebook apply using "${codebook}/auto"
	
	

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
	iecodebook apply using "${codebook}/auto_droplabel.xlsx"			      // Is variable foreing still labelled? No
		local f0: label foreign 1
		assert "`f0'"!= "Domestic"
	
	* Adding value labels
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_addlabel.xlsx"	
		local f0: label foreign 0
		assert "`f0'"== "Domestic car"
		local f1: label foreign 1
		assert "`f1'"== "Foreign car"	
	
	* Labelling variables
	sysuse auto, clear 	
	iecodebook apply using "${codebook}/auto_labelling.xlsx"
		local p: var label price
	    assert "`p'" == "Cost"
	
	* Renaming variables
	sysuse auto, clear 	
	iecodebook apply using "${codebook}/auto_rename.xlsx"
	
	foreach var in cost car_mpg {
		confirm variable `var'
		assert !_rc
	}

	foreach var in price mgp {
		cap confirm variable `var'
		assert _rc == 111
	}
	
	* Recoding variables
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_recode.xlsx"	
	assert displacement != 79

	* Adding missing codes
	sysuse auto, clear
	replace foreign = .d in 12
	replace foreign = .n in 13
	replace foreign = .o in 14

	iecodebook apply using "${codebook}/auto_missingvalues.xlsx", miss(.d "Don't know" .o "Other" .n "Not applicable")
	labelbook
	pause																		// missing values have been added only to yesno and origin choices :)
	
	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	
	* Non-apply options
	cap iecodebook apply using "${codebook}/auto.xlsx" keepall 
	assert _rc == 198

	
	cap iecodebook apply using "${codebook}/auto_error.xlsx"
	assert _rc == 198
	
	
	*******************
	* Invalid options *                                                        // I don´t know how to test this :c
	*******************
	
	
/*******************************************************************************
	Append data sets
*******************************************************************************/

/*------------------------------------------------------------------------------
	Template subcommand
------------------------------------------------------------------------------*/
	
	sysuse auto, clear
	tempfile auto1
	save `auto1'
	
	sysuse auto, clear
		rename price cost
		rename mpg car_mpg
		recode foreign (0=1 "Domestic")(1=0 "Foreign") , gen(domestic)
		drop foreign 
	tempfile auto2
	save `auto2'
	
	generate himpg = car_mpg > 30
	tempfile auto3
	save `auto3'
	
	* Simple run
	cap erase "${codebook}/template_apply1.xlsx"
	iecodebook template `auto1' `auto2'  using "${codebook}/template_apply1.xlsx", ///
		surveys(one two)

	* Run with replace
	iecodebook template `auto1' `auto2'  using "${codebook}/template_apply1.xlsx", ///
		surveys(one two) replace
	
	* Match
	iecodebook template `auto1' `auto2'  using "${codebook}/template_apply2.xlsx", ///
		surveys(one two) replace match
		
	* Gen
	iecodebook template `auto1' `auto2'  using "${codebook}/template_apply3.xlsx", ///
		surveys(one two) replace gen(oi)

		
	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	
	* Survey option 
	cap iecodebook template `auto1' `auto2'  ///
	using "${codebook}/template_error.xlsx", replace
	assert _rc == 198
	
	* Non-template options
	iecodebook template `auto1' `auto2' ///
	using "${codebook}/template_error.xlsx", ///
	surveys(First Second)  keepall replace // No error thrown here
			

		
/*------------------------------------------------------------------------------
	Append subcommand
------------------------------------------------------------------------------*/

	* Generate
	iecodebook append `auto1' `auto2' /// 
	using "${codebook}/harmonization.xlsx", ///
	clear surveys(First Second) generate(survey_name)	
	
	* Report
	iecodebook append `auto1' `auto2' /// 
	using "${codebook}/harmonization.xlsx", ///
	clear surveys(First Second) replace report 
	
	* choices_first, choices_second,… sheets - are they reflecting changes we make?
	iecodebook append `auto1' `auto2' ///
	"${codebook}/data3.dta" using "${codebook}/harmonization_merge.xlsx", /// 
	clear surveys(First Second Third)

	* keepall
	iecodebook append `auto1' `auto2' `auto3' ///
	using "${codebook}/harmonization_keep.xlsx", /// 
	clear surveys(First Second Third) keepall replace 
	
	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	
	* Clear
	cap iecodebook append `auto1' `auto2' ///
	using "${codebook}/harmonization.xlsx", ///
	surveys(First Second) generate(survey_name)
	assert _rc == 4
			
	* Survey option
	cap	iecodebook append `auto1' `auto2' ///
	using "${codebook}/harmonization.xlsx", /// 
	clear surveys(Second name_incorrect) replace 
	assert _rc == 111
	
	cap iecodebook append `auto1' `auto2' ///
	using "${codebook}/harmonization.xlsx", /// 
	clear surveys(First) replace 
	assert _rc == 111
	
	cap iecodebook append `auto1' `auto2' /// 
	using "${codebook}/harmonization.xlsx", /// 
	clear surveys(Second First) replace  // different order
	assert _rc == 111
	
	* Non-append options
	iecodebook append `auto1' `auto2' ///
	using "${codebook}/harmonization.xlsx", ///
	clear surveys(First Second) match replace                                   // No error thrown here!


/*******************************************************************************
	Export final codebook
*******************************************************************************/

	sysuse auto, clear
	cap erase "${codebook}/auto_export.xlsx"
	iecodebook export using "${codebook}/auto_export.xlsx"						// Not sure how to test content
	
* Replace option ---------------------------------------------------------------

	iecodebook export using "${codebook}/auto_export.xlsx", replace
	
* Trim option ------------------------------------------------------------------
	sysuse auto, clear
	iecodebook export using "${codebook}\auto_export_trim.xlsx", ///
							replace ///
							trim("${iefieldkit}\run\iecodebook_trim1.do" ///
								 "${iefieldkit}\run\iecodebook_trim2.do")
	sysuse auto, clear
	iecodebook export using "${codebook}/auto_export_trim.xlsx", ///			//  It is working now! 
							replace ///
							trim("${iefieldkit}/run/iecodebook_trim1.do")

	
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
	
* Textonly option --------------------------------------------------------------

	iecodebook export using "${codebook}/auto_export.xlsx", plain(detailed) replace noexcel

	iecodebook export using "${codebook}/auto_export.xlsx", plain(compact) 	replace
	iecodebook export using "${codebook}/auto_export.xlsx", plain(detailed) replace
	*Expected error
cap iecodebook export using "${codebook}/auto_export.xlsx", 				replace noexcel	
	assert _rc == 198	
cap iecodebook export using "${codebook}/auto_export.xlsx", plain(dalk) 	replace
	assert _rc == 198
	
* Verify option ----------------------------------------------------------------

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
	
* Use option -------------------------------------------------------------------

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
	
* Save option ------------------------------------------------------------------

	sysuse auto, clear
	tempfile auto
	save 	`auto'
	
	iecodebook export `auto' using "${codebook}/auto_export.xlsx", replace save
	iecodebook export `auto' using "${codebook}/auto_export.xlsx", replace saveas("auto")
	iecodebook export `auto' using "${codebook}/auto_export.xlsx", replace saveas("${codebook}/auto")
		
	cap erase "${codebook}/auto_export.xlsx"
	cap iecodebook export "${codebook}/auto" using "${codebook}/auto_export.xlsx", save
	assert _rc == 602
	
* Special characters -----------------------------------------------------------

	lab var make 	"É"
	lab def origin  0 "ã & @", replace
	iecodebook export using "${codebook}/auto_export.xlsx", replace             // Should origin 1 be kept with the same label?
	
***************************************************************** End of do-file
