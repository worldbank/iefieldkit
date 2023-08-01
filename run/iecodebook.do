
	qui do "src/ado_files/iecodebook.ado"

********************************************************************************
**# Folder and format testing
********************************************************************************

	sysuse auto, clear

	* Folder does not exist
	cap iecodebook template using "folder/auto.xlsx"
	assert _rc == 601

	cap iecodebook apply using "folder/auto.xlsx"
	assert _rc == 601

	* File does not exist
	cap iecodebook apply using "run/output/iecodebook/auto_no_exist.xlsx"
	assert _rc == 601

	* Wrong file extension
	cap iecodebook template using "run/output/iecodebook/auto.xsl"
	assert _rc == 601

	cap iecodebook apply using "run/output/iecodebook/auto.xsl"
	assert _rc == 601

	* No file extension
	iecodebook template using "run/output/iecodebook/auto", replace
	iecodebook apply using "run/output/iecodebook/auto"


    * Make sure some subcommand is specified
	cap iecodebook  using "run/output/iecodebook/auto.xlsx"
	assert _rc == 197

********************************************************************************
**#	Single data set
********************************************************************************

/*------------------------------------------------------------------------------
	Template subcommand
------------------------------------------------------------------------------*/

	sysuse auto, clear

	* Create the file template
	cap erase "run/output/iecodebook/auto.xlsx"
	iecodebook template using "run/output/iecodebook/auto.xlsx"

	* Replace option when the template already exists
	iecodebook template using "run/output/iecodebook/auto.xlsx", replace


	********************************************
	* Incorrect uses : error messages expected *
	********************************************

	* Template already exists
	cap iecodebook template using "run/output/iecodebook/auto.xlsx"
	assert _rc == 602

	* Non-template options
	cap iecodebook template using "run/output/iecodebook/auto.xlsx", replace match
	assert _rc == 198

	cap iecodebook template using "run/output/iecodebook/auto.xlsx", replace gen(foo)
	assert _rc == 198

	cap iecodebook template using "run/output/iecodebook/auto.xlsx", replace report
	assert _rc == 198

	cap iecodebook template using "run/output/iecodebook/auto.xlsx", replace keepall
	assert _rc == 198

	iecodebook template using "run/output/iecodebook/auto.xlsx", ///
	replace missing(.d "Don't know")

	iecodebook template using "run/output/iecodebook/auto.xlsx", replace drop


/*------------------------------------------------------------------------------
	Apply subcommand
------------------------------------------------------------------------------*/

	******************
	*      Drop      *
	******************

	* Droping variables with blank var names using drop option
	sysuse auto, clear
	iecodebook apply using "run/output/iecodebook/auto_drop.xlsx", drop

	foreach var in make price mpg rep78 headroom trunk weight length {
		confirm variable `var'
		assert !_rc
	}

	foreach var in turn displacement gear_ratio foreign {
		cap confirm variable `var'
		assert _rc == 111
	}

	* Only by using blank var names without drop option, variables are not dropped.
	sysuse auto, clear
	iecodebook apply using "run/output/iecodebook/auto_drop.xlsx"

	foreach var in 	make price mpg rep78 headroom trunk weight length ///
					turn displacement gear_ratio foreign {
		cap confirm variable `var'
		assert !_rc
	}

	* Drop variables with a dot in the "name" column
	sysuse auto, clear
	iecodebook apply using "run/output/iecodebook/auto_dot.xlsx"

	foreach var in make price mpg rep78 headroom trunk weight length {
		cap confirm variable `var'
		assert !_rc
	}

	foreach var in turn displacement gear_ratio foreign {
		cap confirm variable `var'
		assert _rc == 111
	}

	* Drop value labels with a dot in the "choices" column
	sysuse auto, clear
	iecodebook apply using "run/output/iecodebook/auto_droplabel.xlsx"
		local f0: label foreign 1
		assert "`f0'"!= "Domestic"


	**************************
	*     missingvalues      *
	**************************
	sysuse auto, clear
	replace foreign = .d in 12
	replace foreign = .n in 13
	replace foreign = .o in 14

	iecodebook apply using "run/output/iecodebook/auto_missingvalues.xlsx", ///
	miss(.d "Don't know" .o "Other" .n "Not applicable")
	labelbook


	**************************
	*        Rename          *
	**************************

	* Rename value labels
	sysuse auto, clear
	iecodebook apply using "run/output/iecodebook/auto_addlabel.xlsx"
		local f0: label foreign 0
		assert "`f0'"== "False"
		local f1: label foreign 1
		assert "`f1'"== "True"

	* Rename variables
	sysuse auto, clear
	iecodebook apply using "run/output/iecodebook/auto_renaming.xlsx"

	foreach var in cost car_mpg rep78 {
		confirm variable `var'
		assert !_rc
	}

	foreach var in price mgp {
		cap confirm variable `var'
		assert _rc == 111
	}

	tempfile auto2
	save 	`auto2'

	**************************
	*        Label          *
	**************************

	* Label variables
	sysuse auto, clear
	iecodebook apply using "run/output/iecodebook/auto_labelling.xlsx"
		local p: var label price
	    assert "`p'" == "Cost"

	* What if labels have weird blanks spaces?
	sysuse auto, clear
	lab drop origin
	iecodebook apply using "run/output/iecodebook/auto_label_space.xlsx"

	* What if value labels are missing
	sysuse auto, clear
	lab drop origin
	cap iecodebook apply using "run/output/iecodebook/auto_label_missing.xlsx"
	assert _rc == 100

	**************************
	*        Recode          *
	**************************

	* Recode variables
	sysuse auto, clear
	iecodebook apply using "run/output/iecodebook/auto_recode.xlsx"
	assert displacement != 79


	********************************************
	* Incorrect uses : error messages expected *
	********************************************

	* Non-apply options
	cap iecodebook apply using "run/output/iecodebook/auto.xlsx", keepall
	assert _rc == 198

	cap iecodebook apply using "run/output/iecodebook/auto.xlsx", generate(new var)
	assert _rc == 198

	cap iecodebook apply using "run/output/iecodebook/auto.xlsx",  generate(new var)
	assert _rc == 198

	cap iecodebook apply using "run/output/iecodebook/auto.xlsx", report
	assert _rc == 198

	iecodebook apply using "run/output/iecodebook/auto.xlsx", replace



********************************************************************************
**# Append data sets
********************************************************************************

/*------------------------------------------------------------------------------
	Template subcommand
------------------------------------------------------------------------------*/

	sysuse auto, clear
	tempfile auto1
	save 	`auto1'

	* Simple run
	cap erase "run/output/iecodebook/template_apply1.xlsx"
	iecodebook template  `auto1' `auto2' using "run/output/iecodebook/template_apply1.xlsx", ///
		surveys(one two)

	* Run with replace
	iecodebook template `auto1' `auto2'  using "run/output/iecodebook/template_apply1.xlsx", ///
		surveys(one two) replace

	* Match
	iecodebook template `auto1' `auto2'  using "run/output/iecodebook/template_apply2.xlsx", ///
		surveys(one two) replace match

	* Gen
	iecodebook template `auto1' `auto2'  using "run/output/iecodebook/template_apply3.xlsx", ///
		surveys(one two) replace gen(oi)


	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	* Survey option
	cap iecodebook template `auto1' `auto2' using "run/output/iecodebook/template_error.xlsx", replace
	assert _rc == 198


	* Non-template options
	iecodebook template `auto1' `auto2' using "run/output/iecodebook/template_error.xlsx", ///
		surveys(First Second) ///
		keepall replace

	iecodebook template `auto1' `auto2' using "run/output/iecodebook/template_error.xlsx", ///
		surveys(First Second) ///
		report replace


/*------------------------------------------------------------------------------
	Append subcommand
------------------------------------------------------------------------------*/

	sysuse auto, clear
	tempfile auto1
	save 	`auto1'

	* Clear: required option
	cap iecodebook append `auto1' `auto2' using "run/output/iecodebook/harmonization.xlsx", ///
		surveys(First Second) generate(survey_name)
	assert _rc == 4

	* Survey: requiered option
	cap iecodebook append `auto1' `auto2' using "run/output/iecodebook/harmonization.xlsx", ///
		clear replace
	assert _rc == 198

	* Generate option
	iecodebook append `auto1' `auto2' using "run/output/iecodebook/harmonization.xlsx", ///
		clear ///
		surveys(First Second) ///
		generate(survey_name) ///
		report replace

	* Report option
	cap erase "run/output/iecodebook/harmonization_report.xlsx"
	iecodebook append `auto1' `auto2' using "run/output/iecodebook/harmonization.xlsx", ///
		clear surveys(First Second) report

	* Replace option
	cap iecodebook append `auto1' `auto2' using "run/output/iecodebook/harmonization.xlsx", ///
		clear surveys(First Second)  report
	assert _rc == 602

	iecodebook append `auto1' `auto2' using "run/output/iecodebook/harmonization.xlsx", ///
		clear surveys(First Second)  report replace


	* missingvalues option
	iecodebook append `auto1' `auto2' ///
		using "run/output/iecodebook/harmonization_missing.xlsx", ///
		clear ///
		surveys(First Second Third)  ///
		miss(.d "Don't know" .n "Not applicable")

	* keepall
	iecodebook append `auto1' `auto2' ///
		using "run/output/iecodebook/harmonization_keep.xlsx", ///
		clear surveys(First Second) ///
		keepall replace


	********************************************
	* Incorrect uses : error messages expected *
	********************************************

	* Survey option incorrect names
	cap iecodebook append `auto1' `auto2' ///
		using "run/output/iecodebook/template_survey.xlsx", ///
		clear surveys(Second name_incorrect) replace

	assert _rc == 198

	* Survey option just one of the names
	cap iecodebook append `auto1' `auto2' ///
		using "run/output/iecodebook/template_survey.xlsx", ///
		clear surveys(First) replace
	assert _rc == 111


	* Survey incorrect name order
	cap iecodebook append `auto1' `auto2' ///
		using "run/output/iecodebook/harmonization.xlsx", ///
		clear surveys(Second First) replace
	assert _rc == 198

********************************************************************************
**# Export final codebook
********************************************************************************

	sysuse auto, clear
	cap erase "run/output/iecodebook/auto_export.xlsx"
	iecodebook export using "run/output/iecodebook/auto_export.xlsx"


	**************************
	*        Replace         *
	**************************
	iecodebook export using "run/output/iecodebook/auto_export.xlsx", replace

	**************************
	*    Signature option    *
	**************************

	* Should not work if there's no file and [reset] was not specified
	cap erase  "run/output/iecodebook/auto_export-sig.txt"
	cap iecodebook export using "run/output/iecodebook/auto_export.xlsx", replace signature
	assert _rc == 601

	* Create it
	iecodebook export using "run/output/iecodebook/auto_export.xlsx", replace signature reset

	* Compare when no changes
	iecodebook export using "run/output/iecodebook/auto_export.xlsx", replace signature

	* Compare when changes
	preserve
		* Drop variables
		drop in 1
		cap iecodebook export using "run/output/iecodebook/auto_export.xlsx", replace signature
		assert _rc == 9

	restore

		* Add variables
	preserve

		gen new= make
		cap iecodebook export using "run/output/iecodebook/auto_export.xlsx", replace signature
		assert _rc == 9

	restore


	**************************
	*    Textonly option     *
	**************************

	iecodebook export using "run/output/iecodebook/auto_export.xlsx", ///
		plain(detailed) replace

	* Compact output of codebook
	iecodebook export using "run/output/iecodebook/auto_export.xlsx", ///                 // check values foreign variable
		plain(compact) 	replace

	* Detaild output of codebook
	iecodebook export using "run/output/iecodebook/auto_export.xlsx", ///
		plain(detailed) replace

    * Should not work if an incorrect argument is used
	cap iecodebook export using "run/output/iecodebook/auto_export.xlsx", ///
		plain(dalk) replace
	assert _rc == 198


	**************************
	*      noexcel           *
	**************************

	iecodebook export using "run/output/iecodebook/auto_export.xlsx", ///
		plain(compact) replace noexcel

	* Should not work if [plaintext] was not specified
	cap iecodebook export using "run/output/iecodebook/auto_export.xlsx", ///
		replace noexcel
	assert _rc == 198

	* Should not work if [noexcel] and [verify] options are combined
	cap iecodebook export using "run/output/iecodebook/auto_export.xlsx", verify noexcel  // Drop data
	assert _rc == 184


	**************************
	*        verify          *
	**************************
	sysuse auto, clear
	iecodebook export using "run/output/iecodebook/auto_export.xlsx",  replace

	* Verified existing codebook and data structure to match
	sysuse auto, clear
	iecodebook export using "run/output/iecodebook/auto_export.xlsx", verify

	* Should keep data if we use a export file that doesn't exist               // Drop data
	sysuse auto, clear
	cap iecodebook export using "run/output/iecodebook/auto_export_no_exist.xlsx", verify
	assert _rc == 601

	* Compare when changes data
	sysuse auto, clear

	preserve
		drop mpg
		cap iecodebook export using "run/output/iecodebook/auto_export.xlsx", verify
		assert _rc == 7
	restore


	preserve

		label drop origin
		cap iecodebook export using "run/output/iecodebook/auto_export.xlsx", verify replace  // verify variables?
		assert _rc == 7

	restore


	**************************
	*        Save            *
	**************************

	sysuse auto, clear
	tempfile auto
	save 	`auto'


	* The data should be saved at the same location as the codebook, with the same name as the codebook
	iecodebook export `auto' using "run/output/iecodebook/auto_export.xlsx", replace save

	* Should not work if data already exists and [replace] option was not specified
	cap erase "run/output/iecodebook/auto_export.xlsx"
	cap iecodebook export "run/output/iecodebook/auto" using "run/output/iecodebook/auto_export.xlsx", save
	assert _rc == 602

	* The data should be saved at the specified location, overwriting the codebook name.
	iecodebook export `auto' using "run/output/iecodebook/auto_export.xlsx", replace saveas("run/output/iecodebook/auto_data")

	iecodebook export `auto' using "run/output/iecodebook/auto_export.xlsx", replace saveas("run/output/iecodebook/auto_new")



	**************************
	*  Special characters    *
	**************************

	lab var make 	"É"
	lab def origin  0 "ã & @" 1 "ã" , replace
	iecodebook export using "run/output/iecodebook/auto_export.xlsx", replace

	************************
	*        Trim          *
	************************
	sysuse auto, clear
	iecodebook export using "run/output/iecodebook/auto_export_trim.xlsx", ///
							replace ///
							trim("run/output/iecodebook/iecodebook_trim1.do" ///
								 "run/output/iecodebook/iecodebook_trim2.do")

	sysuse auto, clear
	iecodebook export using "run/output/iecodebook/auto_export_trim.xlsx", ///
							replace ///
							trim("run/output/iecodebook/iecodebook_trim1.do" ///
								 "run/output/iecodebook/iecodebook_trim2.do") ///
							save

	use "run/output/iecodebook/auto_export_trim.dta", clear
	qui ds
	assert r(varlist) == "price mpg weight length gear_ratio foreign"

	sysuse auto, clear
	iecodebook export using "run/output/iecodebook/auto_export_trim.xlsx", ///
							replace ///
							trim("run/output/iecodebook/iecodebook_trim1.do") ///
							save

	use "run/output/iecodebook/auto_export_trim.dta", clear
	qui ds
	assert r(varlist) == "price mpg weight length foreign"

	* Check for dofile correct extension
	sysuse auto, clear
	cap iecodebook export using "run/output/iecodebook/auto_export_trim.xlsx", replace ///
							trim("run/output/iecodebook/iecodebook_trim1.xlm")
	assert _rc == 610

	sysuse auto, clear
	iecodebook export using "run/output/iecodebook/auto_export_trim.xlsx", ///
							replace ///
							trim("run/output/iecodebook/iecodebook_trim1.do" ///
								 "run/output/iecodebook/iecodebook_trim2.do") ///
							trimkeep(make) ///
							save

	use "run/output/iecodebook/auto_export_trim.dta", clear
	qui ds
	assert r(varlist) == "make price mpg weight length gear_ratio foreign"
	
	sysuse auto, clear
	cap iecodebook export using "run/output/iecodebook/auto_export_trim.xlsx", ///
							replace ///
							trim("run/output/iecodebook/iecodebook_trim1.do" ///
								 "run/output/iecodebook/iecodebook_trim2.do") ///
							trimkeep(foo) ///
							save
							
	assert _rc == 111

	sysuse auto, clear
	cap iecodebook export using "run/output/iecodebook/auto_export_trim.xlsx", ///
							replace ///
							trim("run/output/iecodebook/iecodebook_trim1.do" ///
								 "run/output/iecodebook/iecodebook_trim2.do") ///
							trimkeep(make turn) ///
							save
	use "run/output/iecodebook/auto_export_trim.dta", clear
	qui ds
	assert r(varlist) == "make price mpg weight length turn gear_ratio foreign"


	**************************
	*        use             *                                                  // This is not in the help files
	**************************
	clear
	iecodebook export "run/output/iecodebook/auto.dta" ///
		using "run/output/iecodebook/auto_export.xlsx", ///
		replace


	* Should not work if data doesnt exist
	clear
	cap iecodebook export "run/output/iecodebook/dat.dta" using  ///
		"run/output/iecodebook/auto_export.xslx", ///
		replace
	assert _rc == 601

********************************************************************************
**# Incomplete template (not all vars are listed)
********************************************************************************

	* Single dataset
	sysuse auto, clear
	cap iecodebook apply using "run/output/iecodebook/auto_incomplete_vars.xlsx"
	assert _rc == 198

	* Append
	cap iecodebook append `auto1' `auto2' ///
		using "run/output/iecodebook/append_incomplete_vars.xlsx", ///
		surveys(one two) keepall clear
	assert _rc == 198

	iecodebook append `auto1' `auto2' ///
		using "run/output/iecodebook/append_incomplete_vars.xlsx", ///
		surveys(one two)  clear

***************************************************************** End of do-file
