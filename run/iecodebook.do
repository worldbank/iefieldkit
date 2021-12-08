	global GitHub  "C:\Users\Inspiron\Desktop\GitHub"
	global iefieldkit "${GitHub}/iefieldkit"
	global codebook "C:\Users\Inspiron\Desktop\GitHub\codebooks"

	 qui do "${GitHub}/iefieldkit/src/ado_files/iecodebook.ado"
     
	 * Just run this 
	iecodebook template using "$codebook/auto.xlsx", replace
	
	
	
/*******************************************************************************
	Folder and format testing
*******************************************************************************/

	* Folder does not exist	
	cap iecodebook template using "folder/auto.xlsx"
	assert _rc == 601
	
	cap iecodebook apply using "folder/auto.xlsx"
	assert _rc == 601
	
	* File does not exist
	cap iecodebook apply using "${codebook}/auto_no_exist.xlsx"
	assert _rc == 601	
	
	* Wrong file extension
	cap iecodebook template using "${codebook}/auto.xsl"
	assert _rc == 601
	
	cap iecodebook apply using "${codebook}/auto.xsl"
	assert _rc == 601
	
	* No file extension
	iecodebook template using "${codebook}/auto", replace
	iecodebook apply using "${codebook}/auto"


    * Make sure some subcommand is specified
	cap iecodebook  using "${codebook}/auto.xlsx"
	assert _rc == 197

/*******************************************************************************
	Single data set
*******************************************************************************/
	
/*------------------------------------------------------------------------------
	Template subcommand
------------------------------------------------------------------------------*/
	
	sysuse auto, clear
		
	* Create the file template
	cap erase "${codebook}/auto.xlsx"
	iecodebook template using "${codebook}/auto.xlsx"
	
	* Replace option when the template already exists
	iecodebook template using "${codebook}/auto.xlsx", replace
	
	
	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	
	* Template already exists
	cap iecodebook template using "${codebook}/auto.xlsx"
	assert _rc == 602
	
	* Non-template options                                                      		
	cap iecodebook template using "${codebook}/auto.xlsx", replace match
	assert _rc == 198															
	
	cap iecodebook template using "${codebook}/auto.xlsx", replace gen(foo)		
	assert _rc == 198															
	
	cap iecodebook template using "${codebook}/auto.xlsx", replace report		
	assert _rc == 198															
	
	cap iecodebook template using "${codebook}/auto.xlsx", replace keepall
	assert _rc == 198															
		
	iecodebook template using "${codebook}/auto.xlsx", ///                      
	replace missing(.d "Don't know")              
	
	iecodebook template using "${codebook}/auto.xlsx", replace drop			    
	

/*------------------------------------------------------------------------------
	Apply subcommand
------------------------------------------------------------------------------*/

	******************
	*      Drop      *
	******************
	
	* Droping variables with blank var names using drop option
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
	
	* Only by using blank var names without drop option, variables are not dropped.
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_drop.xlsx"
	
	foreach var in 	make price mpg rep78 headroom trunk weight length ///
					turn displacement gear_ratio foreign {
		cap confirm variable `var'
		assert !_rc
	}
		
	* Drop variables with a dot in the "name" column
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_dot.xlsx"

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
	iecodebook apply using "${codebook}/auto_droplabel.xlsx"			        
		local f0: label foreign 1
		assert "`f0'"!= "Domestic"	
	
	
	**************************
	*     missingvalues      *
	**************************		
	sysuse auto, clear
	replace foreign = .d in 12
	replace foreign = .n in 13
	replace foreign = .o in 14

	iecodebook apply using "${codebook}/auto_missingvalues.xlsx", ///
	miss(.d "Don't know" .o "Other" .n "Not applicable")
	labelbook
																	

	**************************
	*        Rename          *
	**************************		
	
	* Rename value labels
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_addlabel.xlsx"	
		local f0: label foreign 0
		assert "`f0'"== "Domestic car"
		local f1: label foreign 1
		assert "`f1'"== "Foreign car"

	* Rename variables
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
			
		
	**************************
	*        Label          *
	**************************			
	
	* Label variables
	sysuse auto, clear 	
	iecodebook apply using "${codebook}/auto_labelling.xlsx"
		local p: var label price
	    assert "`p'" == "Cost"

		
	**************************
	*        Recode          *
	**************************				

	* Recode variables
	sysuse auto, clear
	iecodebook apply using "${codebook}/auto_recode.xlsx"	
	assert displacement != 79


	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	
	* Non-apply options 
	cap iecodebook apply using "${codebook}/auto.xlsx", keepall 
	assert _rc == 198
	
	cap iecodebook apply using "${codebook}/auto.xlsx", generate(new var)
	assert _rc == 198
	
	cap iecodebook apply using "${codebook}/auto.xlsx",  generate(new var)
	assert _rc == 198
	
	cap iecodebook apply using "${codebook}/auto.xlsx", report
	assert _rc == 198
	
	iecodebook apply using "${codebook}/auto.xlsx", replace                     
 

	
/*******************************************************************************
	Append data sets
*******************************************************************************/

/*------------------------------------------------------------------------------
	Template subcommand
------------------------------------------------------------------------------*/
	
	* Simple run
	cap erase "${codebook}/template_apply1.xlsx"
	iecodebook template  `auto1' `auto2' using "${codebook}/template_apply1.xlsx", ///
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
	surveys(First Second)  keepall replace                                      
	
	iecodebook template `auto1' `auto2' ///
	using "${codebook}/template_error.xlsx", ///
	surveys(First Second)  report replace                                       
			
	
/*------------------------------------------------------------------------------
	Append subcommand
------------------------------------------------------------------------------*/
    
	* Clear: requiered option
	cap iecodebook append `auto1' `auto2' ///
	using "${codebook}/harmonization.xlsx", ///
	surveys(First Second) generate(survey_name)
	assert _rc == 4

	* Survey: requiered option
	cap iecodebook append `auto1' `auto2' ///
	using "${codebook}/harmonization.xlsx", /// 
	clear replace 
	assert _rc == 198	
		
	
	* Generate option
	iecodebook append `auto1' `auto2' /// 
	using "${codebook}/harmonization.xlsx", ///
	clear surveys(First Second) generate(survey_name) report replace
		
   		
	* Report option 
	cap erase "${codebook}/harmonization_report.xlsx"
	iecodebook append `auto1' `auto2' /// 
	using "${codebook}/harmonization.xlsx", ///
	clear surveys(First Second) report 
	
	* Replace option 
	cap iecodebook append `auto1' `auto2' /// 
	using "${codebook}/harmonization.xlsx", ///
	clear surveys(First Second)  report 
	assert _rc == 602

	iecodebook append `auto1' `auto2' /// 
	using "${codebook}/harmonization.xlsx", ///
	clear surveys(First Second)  report replace 
	
	
	* missingvalues option
	iecodebook append `auto1' `auto2' ///
	"${codebook}/data3.dta" using "${codebook}/harmonization_missing.xlsx", /// 
	clear surveys(First Second Third)  miss(.d "Don't know" .n "Not applicable")
	
	* keepall
	iecodebook append `auto1' `auto2' `auto3' ///
	using "${codebook}/harmonization_keep.xlsx", /// 
	clear surveys(First Second Third) keepall replace 
	
		
	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	
	* Survey option incorrect names                                                                                    
	cap iecodebook append `auto1' `auto2' ///
	using "${codebook}/template_survey.xlsx", /// 
	clear surveys(Second name_incorrect) replace 
	assert _rc == 111
	
	* Survey option just one of the names                                          
	cap iecodebook append `auto1' `auto2' ///
	using "${codebook}/template_survey.xlsx", /// 
	clear surveys(one) replace 
	assert _rc == 111
	
	
	* Survey incorrect name order	                                            
	cap iecodebook append `auto1' `auto2' ///
	using "${codebook}/harmonization.xlsx", /// 
	clear surveys(two one) replace 
	assert _rc == 111
	
/*******************************************************************************
	Export final codebook
*******************************************************************************/

	sysuse auto, clear
	cap erase "${codebook}/auto_export.xlsx"
	iecodebook export using "${codebook}/auto_export.xlsx"						

	
	**************************
	*        Replace         *
	**************************		
	iecodebook export using "${codebook}/auto_export.xlsx", replace
	
	
	**************************
	*        Trim          *
	**************************		
	sysuse auto, clear
	iecodebook export using "${codebook}\auto_export_trim.xlsx", ///
							replace ///
							trim("${iefieldkit}\run\iecodebook_trim1.do" ///
								 "${iefieldkit}\run\iecodebook_trim2.do")
	sysuse auto, clear
	iecodebook export using "${codebook}/auto_export_trim.xlsx", ///			
							replace ///
							trim("${iefieldkit}/run/iecodebook_trim1.do")
							
	* Check for dofile correct extension
	sysuse auto, clear
	cap iecodebook export using "${codebook}/auto_export_trim.xlsx", replace ///
							trim("${iefieldkit}/run/iecodebook_trim1.xlm")
	assert _rc == 610

	
	**************************
	*    Signature option    *
	**************************			

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
		* Drop variables
		drop in 1
		cap iecodebook export using "${codebook}/auto_export.xlsx", replace signature 
		assert _rc == 9
		
	restore
	
		* Add variables
	preserve
		
		gen new= make
		cap iecodebook export using "${codebook}/auto_export.xlsx", replace signature 
		assert _rc == 9
		
	restore
	
	
	**************************
	*    Textonly option     *
	**************************		
	
	iecodebook export using "${codebook}/auto_export.xlsx", ///
	plain(detailed) replace 
		
	* Compact output of codebook
	iecodebook export using "${codebook}/auto_export.xlsx", ///                 // check values foreign variable
	plain(compact) 	replace 
	
	* Detaild output of codebook
	iecodebook export using "${codebook}/auto_export.xlsx", ///
	plain(detailed) replace
	
    * Should not work if an incorrect argument is used	
	cap iecodebook export using "${codebook}/auto_export.xlsx", ///
	plain(dalk) replace
	assert _rc == 198

	
	**************************
	*      noexcel           *
	**************************	
	
	iecodebook export using "${codebook}/auto_export.xlsx", /// 
	plain(compact) replace noexcel			
	
	* Should not work if [plaintext] was not specified
	cap iecodebook export using "${codebook}/auto_export.xlsx", ///
	replace noexcel
	assert _rc == 198

	* Should not work if [noexcel] and [verify] options are combined
	cap iecodebook export using "${codebook}/auto_export.xlsx", verify noexcel  // Drop data
	assert _rc == 184
	

	**************************
	*        verify          *
	**************************	
	sysuse auto, clear
	iecodebook export using "${codebook}/auto_export.xlsx",  replace
	
	* Verified existing codebook and data structure to match
	sysuse auto, clear
	iecodebook export using "${codebook}/auto_export.xlsx", verify

	* Should keep data if we use a export file that doesn't exist               // Drop data
	sysuse auto, clear
	cap iecodebook export using "${codebook}/auto_export_no_exist.xlsx", verify
	assert _rc == 601
	
	* Compare when changes data
	sysuse auto, clear
	
	preserve
		drop mpg
		cap iecodebook export using "${codebook}/auto_export.xlsx", verify      
		assert _rc == 7	
	restore

	
	preserve
	
		label drop origin
		cap iecodebook export using "${codebook}/auto_export.xlsx", verify replace  // verify variables?
		assert _rc == 7
		
	restore

	
	**************************
	*        use             *                                                  // This is not in the help files 
	**************************		
	sysuse auto, clear
	clear
	iecodebook export "${codebook}/auto1.dta" using "${codebook}/auto_export.xlsx", replace
	
	
	* Should not work if data doesnt exist
	clear
	cap iecodebook export "${codebook}/dat.dta" using  /// 
	"${codebook}/auto_export.xslx", replace
	assert _rc == 601

	
	
	**************************
	*        Save            *                                                  
	**************************		
	
	sysuse auto, clear
	tempfile auto
	save 	`auto'
	
	
	* The data should be saved at the same location as the codebook, with the same name as the codebook
	iecodebook export `auto' using "${codebook}/auto_export.xlsx", replace save 
	
	
	* The data should be saved at the specified location, overwriting the codebook name.
	iecodebook export `auto' using "${codebook}/auto_export.xlsx", replace saveas("auto_data")
	
	iecodebook export `auto' using "${codebook}/auto_export.xlsx", replace saveas("${codebook}/auto_new")
	
	
	* Should not work if data already exists and [replace] option was not specified
	cap erase "${codebook}/auto_export.xlsx"
	cap iecodebook export "${codebook}/data3" using "${codebook}/auto_export.xlsx", save
	assert _rc == 602

	
	**************************
	*  Special characters    *                                                  
	**************************		

	lab var make 	"É"
	lab def origin  0 "ã & @" 1 "ã" , replace
	iecodebook export using "${codebook}/auto_export.xlsx", replace          
	
	
***************************************************************** End of do-file


