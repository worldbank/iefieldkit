
/*******************************************************************************
	Set up
*******************************************************************************/

	* Add the path to your local clone of the iefieldkit repo
	do 	"${iefieldkit}/src/ado_files/ieduplicates.ado"


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
	ieduplicates uuid using "${iefieldkit}\foo.xlsx", uniquevars(make) force

	use `duplicates', clear
	ieduplicates uuid using "${iefieldkit}\foo.xls", uniquevars(make) force

	* Test folder and suffix syntax
	use `duplicates', clear
	ieduplicates uuid, uniquevars(make) folder("${iefieldkit}") force

	use `duplicates', clear
	ieduplicates uuid, uniquevars(make) folder("${iefieldkit}") suffix(bar) force


/*******************************************************************************
	Yes error
*******************************************************************************/

	* Observations were removed
	cap ieduplicates uuid using "${iefieldkit}", uniquevars(make)
	assert _rc == 9
	
	* Without 'clear' option
	use `duplicates', clear
	cap ieduplicates uuid using "${iefieldkit}\foo", uniquevars(make)
	assert _rc == 198

	* Invalid format
	use `duplicates', clear
	cap ieduplicates uuid using "${iefieldkit}\foo.csv", uniquevars(make)
	assert _rc == 198

	use `duplicates', clear
	cap ieduplicates uuid using "${iefieldkit}\foo.", uniquevars(make) force
	assert _rc == 198

	* Invalid name
	use `duplicates', clear
	cap ieduplicates uuid using "${iefieldkit}\.xlsx", uniquevars(make)
	assert _rc == 198

	*Check that cd is not working
	cd "${iefieldkit}"
	use `duplicates', clear
	cap ieduplicates uuid using "foo", uniquevars(make) force
	assert _rc == 198


