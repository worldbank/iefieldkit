
	cscript ieduplicates_test adofile ieduplicates
	which   ieduplicates 

/*******************************************************************************
	Set up
*******************************************************************************/
	
	global iefieldkit "C:\Users\wb501238\Documents\GitHub\iefieldkit"
	do 	"${iefieldkit}\src\ado_files\ieduplicates.ado"


	sysuse auto, clear
	encode make, gen(uuid)
	replace uuid = 7 in 16
	replace uuid = 1 in 2
	
	tempfile duplicates
	save	 `duplicates'

/*******************************************************************************
	No error
*******************************************************************************/	

	* No duplicates
	ieduplicates make using "${iefieldkit}\foo", uniquevars(make)
	
	* Test file format	
	use `duplicates', clear
	ieduplicates uuid using "${iefieldkit}\foo.xlsx", uniquevars(make) clear
	
	use `duplicates', clear
	ieduplicates uuid using "${iefieldkit}\foo.xls", uniquevars(make) clear
	
	* Test folder and suffix syntax
	use `duplicates', clear
	ieduplicates uuid, uniquevars(make) folder("${iefieldkit}") clear
	
	use `duplicates', clear
	ieduplicates uuid, uniquevars(make) folder("${iefieldkit}") suffix(bar) clear
	
	
/*******************************************************************************
	Yes error
*******************************************************************************/		
	
	* Observations were removed
	*ieduplicates uuid using "${iefieldkit}", uniquevars(make) 
	
	* Without 'clear' option
	use `duplicates', clear
	*ieduplicates uuid using "${iefieldkit}\foo", uniquevars(make)
	
	* Invalid format
	use `duplicates', clear
	*ieduplicates uuid using "${iefieldkit}\foo.csv", uniquevars(make)
	
	use `duplicates', clear
	*ieduplicates uuid using "${iefieldkit}\foo.", uniquevars(make) clear
	
	* Invalid name
	use `duplicates', clear
	*ieduplicates uuid using "${iefieldkit}\.xlsx", uniquevars(make)

/*******************************************************************************
	Check that cd is working
*******************************************************************************/

	cd "${iefieldkit}"
	
	use `duplicates', clear
	ieduplicates uuid using "foo", uniquevars(make) clear
	
	use `duplicates', clear
	ieduplicates uuid using "foo bar", uniquevars(make) clear
	
	use `duplicates', clear
	ieduplicates uuid using "foo bar.xls", uniquevars(make) clear
		
