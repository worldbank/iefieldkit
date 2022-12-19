
	qui do "src/ado_files/iecorrect.ado"

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
	cap erase 				 "run/output/iecorrect/iecorrect-template-single-id.xlsx"
	iecorrect template using "run/output/iecorrect/iecorrect-template-single-id.xlsx", idvar(make)
	
	* Create the template with multiple id variables
	cap erase 				 "run/output/iecorrect/iecorrect-template-multiple-ids.xlsx"
	iecorrect template using "run/output/iecorrect/iecorrect-template-multiple-ids", idvar(make id)
		
	* idvar() variables are not ID vars: throw warning
	cap erase 				 "run/output/iecorrect/iecorrect-template-single-id.xlsx"
	iecorrect template using "run/output/iecorrect/iecorrect-template-single-id.xlsx", idvar(turn)
		
// Commands that should not work -----------------------------------------------

	* ID variable not present in the data
	cap iecorrect template using "run/output/iecorrect/iecorrect-template-single-id.xlsx", idvar(oi)
	assert _rc == 111
	
	* File already exists
	cap iecorrect template using "run/output/iecorrect/iecorrect-template-single-id.xlsx", idvar(id)
	assert _rc == 602
	
	* Wrong file extension
	cap iecorrect template using "run/output/iecorrect/iecorrect-template.wrong", idvar(id)
	assert _rc == 198
	
	* No file extension
	cap erase "run/output/iecorrect/iecorrect-template.xlsx"
	iecorrect template using "run/output/iecorrect/iecorrect-template", idvar(id) 		// should this return an error?
	
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
	cap iecorrect apply using "run/output/iecorrect/template-no-exist.xlsx", idvar(id)  // Now it returns a better description of the expected error 
	assert _rc == 601
	
	* No file extension
	iecorrect apply using "run/output/iecorrect/iecorrect-template", idvar(id) debug

/*******************************************************************************
	Apply 
*******************************************************************************/	

	use 	`tocorrect', clear
	
	********************************************
	* Incorrectly filling ids				   *
	********************************************
	
	cap iecorrect apply using "run/output/iecorrect/iecorrect-stringid.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 109
	
	cap iecorrect apply using "run/output/iecorrect/iecorrect-numid.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 109
	
	cap iecorrect apply using "run/output/iecorrect/iecorrect-blankid.xlsx", idvar(id make) sheet(numeric) debug 
	assert _rc == 198
	
	cap iecorrect apply using "run/output/iecorrect/iecorrect-blankid-blankcurrent.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 198
	
	cap iecorrect apply using "run/output/iecorrect/iecorrect-numvarname.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 198

	cap iecorrect apply using "run/output/iecorrect/iecorrect-wrongvalue.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 198
	
	cap iecorrect apply using "run/output/iecorrect/iecorrect-missvarname.xlsx", idvar(id make) sheet(numeric) debug
	assert _rc == 198
	
	
	********************************************
	* Options 								   *
	********************************************
	
	* Check that precision is not an issue
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-precision.xlsx", idvar(id) sheet(numeric) debug save("run/output/iecorrect/iecorrect-precision") replace
	assert gear_ratio == 150 in 1
	assert gear_ratio == 60  in 2
	
	* Simple run when template is empty
	    iecorrect apply using "run/output/iecorrect/iecorrect-template-single-id.xlsx", idvar(turn) save("run/output/iecorrect/iecorrect-template-single-id") replace
	cap iecorrect apply using "run/output/iecorrect/iecorrect-template-single-id.xlsx", idvar(turn) save("run/output/iecorrect/iecorrect-template-single-id") replace break
	assert _rc == 111
	
	* Simple run when template is filled
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("run/output/iecorrect/iecorrect-simple-num-id") replace
		
	* Sheets
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) sheet(string) save("run/output/iecorrect/iecorrect-simple-num-id-string") replace
	
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) sheet(numeric) save("run/output/iecorrect/iecorrect-simple-num-id-numeric") replace
	
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) sheet(drop) save("run/output/iecorrect/iecorrect-simple-num-id-drop") replace
	
	* Save
	use 	`tocorrect', clear
	cap erase "run/output/iecorrect/iecorrect-simple-num-id.do"
	cap iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("run/output/iecorrect/iecorrect-simple-num-id.do") replace
	
	* Save, replace
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("run/output/iecorrect/iecorrect-simple-num-id.do") replace	
	
	* Noisily
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) noisily

	* Count number of observations before dropping
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-nobs.xlsx", idvar(make foreign) save("run/output/iecorrect/iecorrect-nobs") replace
	
	* Use multiple ID vars
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-test-idcond.xlsx", idvar(make foreign) save("run/output/iecorrect/iecorrect-test-idcond.do") replace
	
	* All wildcards on string ID
	use 	`tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-wildcard-strings.xlsx", idvar(make) save("run/output/iecorrect/iecorrect-wildcard-strings") replace
	qui count if inlist(mpg, 22, 14)
	assert r(N) == 0
	
	* Don't fill ID or valuecurrent
	use 	`tocorrect', clear
	cap iecorrect apply using "run/output/iecorrect/iecorrect-noidnovalue.xlsx", idvar(id) save("run/output/iecorrect/iecorrect-noidnovalue") replace
	assert _rc == 198
	
	********************************************
	* Corrections using a template 			   *
	********************************************	
		
	* Dropping a row  
	use `tocorrect', clear
	assert _N == 74 
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("run/output/iecorrect/iecorrect-simple-num-id.do") replace noisily
	assert _N == 73
	
	* Correct individual data points - string sheet
	use `tocorrect', clear
	gen make_check = make
	
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id)
	assert make == "Dodge Platinum" if id == 29
	assert make == "News 98"        if make_check == "Olds 98"
	
	use `tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-multiple-ids.xlsx", idvar(make id) save("run/output/iecorrect/iecorrect-multiple-ids") replace
	assert price == 2 in 10
	assert origin == "foo" in 12
	assert origin == "bar" in 5
	
	use `tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-missingid.xlsx", idvar(make id) save("run/output/iecorrect/iecorrect-missingid") replace
	assert price == 2 in 10
	assert origin == "foo" in 12
	assert origin == "bar" in 5
	
	* Correct individual data points - numeric sheet
	use `tocorrect', clear
	gen length_check = length
	
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", ///
		idvar(id) sheet(numeric)
		
	assert length == 0 if length_check == 184
	assert price  == 1 if id == 74
	
	* Fix issue with ids containing hyphens
	sysuse auto, clear
	replace make = subinstr(make, "Datsun ", "datsun-",  .)
	iecorrect apply using "run/output/iecorrect/hyphen-id.xlsx" , idvar(make) save("run/output/iecorrect/hyphen-id.do") debug replace
		
	********************************************
	* Incorrect uses : error messages expected *
	********************************************

	***********************
	* Type of corrections *
	***********************	
	* Should return an error when string is used to make other types corrections 
	use `tocorrect', clear
	cap iecorrect apply using "run/output/iecorrect/iecorrect-wrong-type.xlsx", idvar(id)
	assert _rc == 109
	
	****************************
	* No corrections specified *
	****************************
	* Warning message only
	use `tocorrect', clear
	iecorrect apply using "run/output/iecorrect/iecorrect-no-corrections.xlsx", idvar(id) debug
	qui count if mpg < 0
	assert r(N) == 1 

	* Break the code
	cap iecorrect apply using "run/output/iecorrect/iecorrect-no-corrections.xlsx", idvar(id) debug break
	assert _rc == 111
	
	use `tocorrect', clear
	cap iecorrect apply using "run/output/iecorrect/iecorrect-wrong-type.xlsx", idvar(id)
	assert _rc == 109	
	
	********************************************************
	* Did not specify number of observations to be dropped *
	********************************************************
	cap iecorrect apply using "run/output/iecorrect/iecorrect-nonobs.xlsx", idvar(id) replace debug
	assert _rc == 198

	********
	* Save *
	********
	use `tocorrect', clear
	* Save, Wrong file extension
	iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("run/output/iecorrect/iecorrect-simple-num-id") replace

	use `tocorrect', clear
	cap iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("run/output/iecorrect/iecorrect-simple-num-id.c") replace
	assert _rc == 198
	
	* Save, folder path does not exist
	use `tocorrect', clear
	cap iecorrect apply using "run/output/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("run/output/iecorrect/noexist/iecorrect-simple-num-id.do") replace
	assert _rc == 601
	
************************************************************************ The end!