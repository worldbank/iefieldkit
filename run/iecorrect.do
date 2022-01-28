
	qui do "${iefieldkit}/src/ado_files/iecorrect.ado"

	* Dataset
	tempfile tocorrect
	
		sysuse auto, clear
		
		gen 	origin = "Local" in 5
		replace origin = "Alien" in 12
		encode 	make,	gen(id)
		
	save 	`tocorrect'
		
/*******************************************************************************
	Folder and format testing
*******************************************************************************/	
	
	* Folder does not exist
	cap iecorrect template using "folder/iecorrect-template.xlsx"          // Now it returns a better description of the expected error          
	assert _rc == 601
	
	cap iecorrect apply using "folder/iecorrect-template.xlsx", idvar(id)  // Now it returns a better description of the expected error  
	assert _rc == 601
	
	* File does not exist 
	cap iecorrect apply using "${testouput}/template-no-exist.xlsx", idvar(id)  // Now it returns a better description of the expected error 
	assert _rc == 601
	
	* Wrong file extension
	cap iecorrect template using "${testouput}/iecorrect-template.wrong"
	assert _rc == 198
	
	cap iecorrect apply using "${testouput}/iecorrect-template.wrong", idvar(id) 
	assert _rc == 198
	
	* No file extension
	cap erase "${testouput}/iecorrect-template.xlsx"
	iecorrect template using "${testouput}/iecorrect-template"
	iecorrect apply using "${testouput}/iecorrect-template", idvar(id) debug

	cap erase 				 "${testouput}/iecorrect-template-no-file-ext.xlsx" 
	iecorrect template using "${testouput}/iecorrect-template-no-file-ext"  
	
/*******************************************************************************
	Template
*******************************************************************************/	
	
	* Create the template
	cap erase 				 "${testouput}/iecorrect-template.xlsx"
	iecorrect template using "${testouput}/iecorrect-template.xlsx"

	
	* Expected error ms, template already exist 
	cap iecorrect template using "${testouput}/iecorrect-template.xlsx"         // Now it returns an error     
	assert _rc == 602

/*******************************************************************************
	Apply 
*******************************************************************************/	
	
	********************************************
	* Options 								   *
	********************************************
	
	* Simple run when template is empty
	iecorrect apply using "${testouput}/iecorrect-template.xlsx",  idvar(id)    // Now it is not returning an error :D
	
	* Simple run when template is filled
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) debug
		
	* Sheets
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(string)
	
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(numeric)
	
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(other)
	
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(drop)
	
	* Save
	use 	`tocorrect', clear
	cap erase "${testouput}/iecorrect-simple-num-id.do"
	cap iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) save("${testouput}/iecorrect-simple-num-id.do") 
	
	* Save, replace
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) save("${testouput}/iecorrect-simple-num-id.do") replace	
	
	* Noisily
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) noisily
	
	* Generate
	use 	`tocorrect', clear
	cap iecorrect apply using "${testouput}/iecorrect-gen.xlsx", idvar(id) other
	assert _rc == 111
	
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-gen.xlsx", idvar(id) other generate

	********************************************
	* Corrections using a template 			   *
	********************************************	
		
	* Dropping a row  
	use `tocorrect', clear
	assert _N == 74 
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) save("${testouput}/iecorrect-simple-num-id.do") replace noisily
	assert _N == 73
	
	
	* Correct individual data points - string sheet
	use `tocorrect', clear
	gen make_check = make
	
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id)
	assert make == "Dodge Platinum" if id == 29
	assert make == "News 98"        if make_check == "Olds 98"
	

	* Correct individual data points - numeric sheet
	use `tocorrect', clear
	gen length_check = length
	
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", ///
		idvar(id) sheet(numeric)
		
	assert length == 0 if length_check == 184
	assert price  == 1 if id == 74
	
	* Correct individual data points - other sheet
	use `tocorrect', clear
	gen origin_check = origin
	
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) sheet(other)
	assert foreign == 2   		if origin_check == "Local"
	assert foreign == 3         if origin       == "Alien"
	
	********************************************
	* Incorrect uses : error messages expected *
	********************************************

	***********************
	* Type of corrections *
	***********************	
	* Should return an error when string is used to make other types corrections 
	cap iecorrect apply using "${testouput}/iecorrect-no-num-corrections.xlsx", idvar(id)
	assert _rc == 198 
	
	********
	* Save *
	********	
	* Save, Wrong file extension
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) save("${testouput}/iecorrect-simple-num-id") replace

	//iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) save("${testouput}/iecorrect-simple-num-id.c") replace
	//assert _rc == 198
	
	* Save, folder path does not exist
	use `tocorrect', clear
	cap iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id) save("${testouput}/noexist/iecorrect-simple-num-id.do") replace
	assert _rc == 601
	
************************************************************************ The end!