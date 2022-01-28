
	qui do "${iefieldkit}/src/ado_files/iecorrect.ado"

	* Dataset
	tempfile tocorrect
	
		sysuse auto, clear
		
		gen 	origin = "Local" in 5
		replace origin = "Alien" in 12
		encode 	make,	gen(id)
		
	save 	`tocorrect'
		
/*******************************************************************************
	Template
*******************************************************************************/	
	
// Commands that should work --------------------------------------------------

	* Create the template with a single id variable
	cap erase 				 "${run_correct}/iecorrect-template-single-id.xlsx"
	iecorrect template using "${run_correct}/iecorrect-template-single-id.xlsx"
	
	* Create the template with multiple id variables
	cap erase 				 "${run_correct}/iecorrect-template-multiple-ids.xlsx"
	iecorrect template using "${run_correct}/iecorrect-template-multiple-ids"
	
	* Create the template with other tab
	cap erase 				 "${run_correct}/iecorrect-template-other.xlsx"
	iecorrect template using "${run_correct}/iecorrect-template-other"
	
	* Add 'other' tab
	cap erase 				 "${run_correct}/iecorrect-template-add-other.xlsx"
	iecorrect template using "${run_correct}/iecorrect-template-add-other"
	iecorrect template using "${run_correct}/iecorrect-template-add-other", other
		
// Commands that should not work -----------------------------------------------

	* File already exists
	cap iecorrect template using "${run_correct}/iecorrect-template-single-id.xlsx"
	assert _rc == 602
	
	* Wrong file extension
	cap iecorrect template using "${run_correct}/iecorrect-template.wrong"
	assert _rc == 198
	
	* No file extension
	//iecorrect template using "${run_correct}/iecorrect-template", id(id) 		// should this return an error?
	
	* Folder does not exist
	cap iecorrect template using "folder/iecorrect-template"
	assert _rc == 601
		
/*******************************************************************************
	Folder and format testing
*******************************************************************************/	
	
	* Folder does not exist
	cap iecorrect apply using "folder/iecorrect-template.xlsx", idvar(id)  // Now it returns a better description of the expected error  
	assert _rc == 601
	
	* File does not exist 
	cap iecorrect apply using "${run_correct}/template-no-exist.xlsx", idvar(id)  // Now it returns a better description of the expected error 
	assert _rc == 601
	
	* No file extension
	cap erase "${run_correct}/iecorrect-template.xlsx"
//	iecorrect apply using "${run_correct}/iecorrect-template", idvar(id) debug

/*******************************************************************************
	Apply 
*******************************************************************************/	
	
	********************************************
	* Options 								   *
	********************************************
	
	* Check that precision is not an issue
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-precision.xlsx", idvar(id) sheet(numeric)
	assert gear_ratio == 150 in 1
	assert gear_ratio == 60  in 2
	
	* Simple run when template is empty
	iecorrect apply using "${run_correct}/iecorrect-template-single-id.xlsx", idvar(id)
	
	* Simple run when template is filled
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id)
		
	* Sheets
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(string)
	
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(numeric)
	
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(other)
	
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(drop)
	
	* Save
	use 	`tocorrect', clear
	cap erase "${run_correct}/iecorrect-simple-num-id.do"
	cap iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) save("${run_correct}/iecorrect-simple-num-id.do") 
	
	* Save, replace
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) save("${run_correct}/iecorrect-simple-num-id.do") replace	
	
	* Noisily
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) noisily
	
	* Generate
	use 	`tocorrect', clear
	cap iecorrect apply using "${run_correct}/iecorrect-gen.xlsx", idvar(id) other
	assert _rc == 111
	
	use 	`tocorrect', clear
	iecorrect apply using "${run_correct}/iecorrect-gen.xlsx", idvar(id) other generate

	********************************************
	* Corrections using a template 			   *
	********************************************	
		
	* Dropping a row  
	use `tocorrect', clear
	assert _N == 74 
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) save("${run_correct}/iecorrect-simple-num-id.do") replace noisily
	assert _N == 73
	
	
	* Correct individual data points - string sheet
	use `tocorrect', clear
	gen make_check = make
	
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id)
	assert make == "Dodge Platinum" if id == 29
	assert make == "News 98"        if make_check == "Olds 98"
	

	* Correct individual data points - numeric sheet
	use `tocorrect', clear
	gen length_check = length
	
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", ///
		idvar(id) sheet(numeric)
		
	assert length == 0 if length_check == 184
	assert price  == 1 if id == 74
	
	* Correct individual data points - other sheet
	use `tocorrect', clear
	gen origin_check = origin
	
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(other)
	assert foreign == 2   		if origin_check == "Local"
	assert foreign == 3         if origin       == "Alien"
	
	********************************************
	* Incorrect uses : error messages expected *
	********************************************

	***********************
	* Type of corrections *
	***********************	
	* Should return an error when string is used to make other types corrections 
	cap iecorrect apply using "${run_correct}/iecorrect-no-num-corrections.xlsx", idvar(id)
	assert _rc == 198 
	
	********
	* Save *
	********	
	* Save, Wrong file extension
	iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) save("${run_correct}/iecorrect-simple-num-id") replace

	//iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) save("${run_correct}/iecorrect-simple-num-id.c") replace
	//assert _rc == 198
	
	* Save, folder path does not exist
	use `tocorrect', clear
	cap iecorrect apply using "${run_correct}/iecorrect-simple-num-id.xlsx", idvar(id) save("${run_correct}/noexist/iecorrect-simple-num-id.do") replace
	assert _rc == 601
	
************************************************************************ The end!