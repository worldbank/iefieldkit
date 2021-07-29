global GitHub      "..../GitHub"
global iefieldkit  "${GitHub}/iefieldkit"
global testouput   ".."	
	
	
do "${iefieldkit}/src/ado_files/iecorrect.ado"


	* Dataset
	sysuse auto, clear
		gen 	origin = "Local" in 5
		replace origin = "Alien" in 12
		encode 	make,	gen(id)
	tempfile tocorrect
	save 	`tocorrect'


	
/*******************************************************************************
	Folder and format testing
*******************************************************************************/	
	
	
	* Folder does not exist
	cap iecorrect template using "folder/iecorrect-template.xlsx"               // improve the expected ms "file folder/iecorrect-template.xlsx could not be loaded"
	assert _rc == 603
	
	cap iecorrect apply using "folder/iecorrect-template.xlsx", idvar(id)     // "folder/iecorrect-template.xlsx" could not be found. file not found
	assert _rc == 601
	
	* File does not exist
	cap iecorrect apply using "${testouput}/template-no-exist.xlsx", idvar(id)   
	assert _rc == 601
	
	* Wrong file extension
	cap iecorrect apply using "${testouput}/iecorrect-template.xsl", idvar(id)// wrong expected ms error: file not found
	assert _rc == 601
	
	* No file extension
	cap iecorrect apply using "${testouput}/iecorrect-template", idvar(id)    // wrong expected ms error: file not found
	assert _rc == 601

	iecorrect template using "${testouput}/iecorrect-template-no-file-extension"// no error    

	
/*******************************************************************************
	Template
*******************************************************************************/	
	
	* Create the template
	cap erase "${testouput}/iecorrect-template.xlsx"
	iecorrect template using "${testouput}/iecorrect-template.xlsx"

	
	* Expected error ms, template already exist 
	cap iecorrect template using "${testouput}/iecorrect-template.xlsx"
	assert _rc == 601
	

/*******************************************************************************
	Apply 
*******************************************************************************/	
	
	********************************************
	* Options *
	********************************************
	
	
	* Simple run when template is empty
	cap iecorrect apply using "${testouput}/iecorrect-template.xlsx"         /// Error when the template is empty
	assert _rc == 601
	
	
	* Simple run when template is filled
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", idvar(id)
	
	* Sheets
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx",       ///
	idvar(id) sheet(string)
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx",       ///
	idvar(id) sheet(numeric)
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx",       ///
	idvar(id) sheet(other)
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx",       ///
	idvar(id) sheet(drop)
	
	* Save
	cap erase "${testouput}/iecorrect-simple-num-id.do"
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx",       ///
	idvar(id) save("${testouput}/iecorrect-simple-num-id.do")
	
	* Save, replace
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", 		 ///
	idvar(id) save("${testouput}/iecorrect-simple-num-id.do") replace	
	
	
	* Noisily
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx",       /// first and second line are bold
	idvar(id) noisily
	
	
	* Generate
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-gen.xlsx", idvar(id) 		 /// It is not returning an error 
	
	use 	`tocorrect', clear
	iecorrect apply using "${testouput}/iecorrect-gen.xlsx", idvar(id)       ///
	generate

	
	
	
	********************************************
	* Corrections using a template *
	********************************************	
	
	
	* Dropping a row  
	use `tocorrect', clear
	assert _N == 74 
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", ///
	idvar(id) save("${testouput}/iecorrect-simple-num-id.do") replace
	assert _N == 73
	
	
	* Correct individual data points - string sheet
	use `tocorrect', clear
	gen make_check = make
	
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", ///
	idvar(id)
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
	
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", ///
	idvar(id) sheet(other)
	assert origin == 2         if origin       == "Local"
	assert origin == "Martian" if origin_check == "Local"
	assert origin == 3         if origin       == "Alien"
	

	********************************************
	* Incorrect uses : error messages expected *
	********************************************
	
	* Save, Wrong file extension
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", ///       It is not returning an error
	idvar(id) save("${testouput}/iecorrect-simple-num-id") replace
	
	iecorrect apply using "${testouput}/iecorrect-simple-num-id.xlsx", ///       It is not returning an error
	idvar(id) save("${testouput}/iecorrect-simple-num-id.c") replace
	
	

	
	

*******************************************************************************/
* End 
********************************************************************************