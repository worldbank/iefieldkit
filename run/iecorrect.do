
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
	cap erase 				 "${output}/iecorrect/iecorrect-template-single-id.xlsx"
	iecorrect template using "${output}/iecorrect/iecorrect-template-single-id.xlsx", idvar(make)
	
	* Create the template with multiple id variables
	cap erase 				 "${output}/iecorrect/iecorrect-template-multiple-ids.xlsx"
	iecorrect template using "${output}/iecorrect/iecorrect-template-multiple-ids", idvar(make id)
	
	* Create the template with other tab
	cap erase 				 "${output}/iecorrect/iecorrect-template-other.xlsx"
	iecorrect template using "${output}/iecorrect/iecorrect-template-other", idvar(id)
	
	* Add 'other' tab
	cap erase 				 "${output}/iecorrect/iecorrect-template-add-other.xlsx"
	iecorrect template using "${output}/iecorrect/iecorrect-template-add-other", idvar(id)
	iecorrect template using "${output}/iecorrect/iecorrect-template-add-other", idvar(id) other
	
	* idvar() variables are not ID vars: throw warning
	cap erase 				 "${output}/iecorrect/iecorrect-template-single-id.xlsx"
	iecorrect template using "${output}/iecorrect/iecorrect-template-single-id.xlsx", idvar(turn)
		
// Commands that should not work -----------------------------------------------

	* ID variable not present in the data
	cap iecorrect template using "${output}/iecorrect/iecorrect-template-single-id.xlsx", idvar(oi)
	assert _rc == 111
	
	* File already exists
	cap iecorrect template using "${output}/iecorrect/iecorrect-template-single-id.xlsx", idvar(id)
	assert _rc == 602
	
	* Wrong file extension
	cap iecorrect template using "${output}/iecorrect/iecorrect-template.wrong", idvar(id)
	assert _rc == 198
	
	* No file extension
	cap erase "${output}/iecorrect/iecorrect-template.xlsx"
	iecorrect template using "${output}/iecorrect/iecorrect-template", idvar(id) 		// should this return an error?
	
	* Folder does not exist
	cap iecorrect template using "folder/iecorrect-template", idvar(id)
	assert _rc == 601
		
/*******************************************************************************
	Folder and format testing
*******************************************************************************/	
	
	* Folder does not exist
	cap iecorrect apply using "folder/iecorrect-template.xlsx", idvar(id)  // Now it returns a better description of the expected error  
	assert _rc == 601
	
	* File does not exist 
	cap iecorrect apply using "${output}/iecorrect/template-no-exist.xlsx", idvar(id)  // Now it returns a better description of the expected error 
	assert _rc == 601
	
	* No file extension
	iecorrect apply using "${output}/iecorrect/iecorrect-template", idvar(id) debug

/*******************************************************************************
	Apply 
*******************************************************************************/	

	use 	`tocorrect', clear
	
	********************************************
	* Incorrectly filling ids				   *
	********************************************
	
	cap iecorrect apply using "${output}/iecorrect/iecorrect-stringid.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 109
	
	cap iecorrect apply using "${output}/iecorrect/iecorrect-numid.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 109
	
	cap iecorrect apply using "${output}/iecorrect/iecorrect-blankid.xlsx", idvar(id make) sheet(numeric) debug 
	assert _rc == 198
	
	cap iecorrect apply using "${output}/iecorrect/iecorrect-blankid-blankcurrent.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 198
	
	cap iecorrect apply using "${output}/iecorrect/iecorrect-numvarname.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 111

	cap iecorrect apply using "${output}/iecorrect/iecorrect-wrongvalue.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 198
	
	cap iecorrect apply using "${output}/iecorrect/iecorrect-missvarname.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 198
	
	
	********************************************
	* Options 								   *
	********************************************
	
	* Check that precision is not an issue
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-precision.xlsx", idvar(id) sheet(numeric) debug save("${output}/iecorrect/iecorrect-precision") replace
	assert gear_ratio == 150 in 1
	assert gear_ratio == 60  in 2
	
	* Simple run when template is empty
	iecorrect apply using "${output}/iecorrect/iecorrect-template-single-id.xlsx", idvar(turn) save("${output}/iecorrect/iecorrect-template-single-id") replace
	
	* Simple run when template is filled
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("${output}/iecorrect/iecorrect-simple-num-id") replace
		
	* Sheets
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) sheet(string) save("${output}/iecorrect/iecorrect-simple-num-id-string") replace
	
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) sheet(numeric) save("${output}/iecorrect/iecorrect-simple-num-id-numeric") replace
	
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) sheet(other) save("${output}/iecorrect/iecorrect-simple-num-id-other") replace
	
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) sheet(drop) save("${output}/iecorrect/iecorrect-simple-num-id-drop") replace
	
	* Save
	use 	`tocorrect', clear
	cap erase "${output}/iecorrect/iecorrect-simple-num-id.do"
	cap iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("${output}/iecorrect/iecorrect-simple-num-id.do") replace
	
	* Save, replace
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("${output}/iecorrect/iecorrect-simple-num-id.do") replace	
	
	* Noisily
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) noisily
	
	* Generate
	use 	`tocorrect', clear
	cap iecorrect apply using "${output}/iecorrect/iecorrect-gen.xlsx", idvar(id) other save("${output}/iecorrect/iecorrect-gen") replace
	assert _rc == 111
	
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-gen.xlsx", idvar(id) other generate save("${output}/iecorrect/iecorrect-gen") replace

	* Count number of observations before dropping
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-nobs.xlsx", idvar(make foreign) save("${output}/iecorrect/iecorrect-nobs") replace
	
	* Use multiple ID vars
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-test-idcond.xlsx", idvar(make foreign) save("${output}/iecorrect/iecorrect-test-idcond.do") replace
	
	* All wildcards on string ID
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-wildcard-strings.xlsx", idvar(make) save("${output}/iecorrect/iecorrect-wildcard-strings") replace
	qui count if inlist(mpg, 22, 14)
	assert r(N) == 0
	
	* Don't fill ID or valuecurrent
	use 	`tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-noidnovalue.xlsx", idvar(id) save("${output}/iecorrect/iecorrect-noidnovalue") replace
	qui count if headroom != 5
	assert r(N) == 0
	
	********************************************
	* Corrections using a template 			   *
	********************************************	
		
	* Dropping a row  
	use `tocorrect', clear
	assert _N == 74 
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("${output}/iecorrect/iecorrect-simple-num-id.do") replace noisily
	assert _N == 73
	
	* Correct individual data points - string sheet
	use `tocorrect', clear
	gen make_check = make
	
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id)
	assert make == "Dodge Platinum" if id == 29
	assert make == "News 98"        if make_check == "Olds 98"
	
	use `tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-multiple-ids.xlsx", idvar(make id) save("${output}/iecorrect/iecorrect-multiple-ids") replace
	assert price == 2 in 10
	assert origin == "foo" in 12
	assert origin == "bar" in 5
	
	use `tocorrect', clear
	iecorrect apply using "${output}/iecorrect/iecorrect-missingid.xlsx", idvar(make id) save("${output}/iecorrect/iecorrect-missingid") replace
	assert price == 2 in 10
	assert origin == "foo" in 12
	assert origin == "bar" in 5
	
	* Correct individual data points - numeric sheet
	use `tocorrect', clear
	gen length_check = length
	
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", ///
		idvar(id) sheet(numeric)
		
	assert length == 0 if length_check == 184
	assert price  == 1 if id == 74
	
	* Correct individual data points - other sheet
	use `tocorrect', clear
	gen origin_check = origin
	
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) sheet(other)
	assert foreign == 2   		if origin_check == "Local"
	assert foreign == 3         if origin       == "Alien"
	
	********************************************
	* Incorrect uses : error messages expected *
	********************************************

	***********************
	* Type of corrections *
	***********************	
	* Should return an error when string is used to make other types corrections 
	*cap iecorrect apply using "${output}/iecorrect/iecorrect-no-num-corrections.xlsx", idvar(id)
	*assert _rc == 198 
	
	********
	* Save *
	********	
	* Save, Wrong file extension
	iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("${output}/iecorrect/iecorrect-simple-num-id") replace

	cap iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("${output}/iecorrect/iecorrect-simple-num-id.c") replace
	assert _rc == 198
	
	* Save, folder path does not exist
	use `tocorrect', clear
	cap iecorrect apply using "${output}/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("${output}/iecorrect/noexist/iecorrect-simple-num-id.do") replace
	assert _rc == 601
	
************************************************************************ The end!