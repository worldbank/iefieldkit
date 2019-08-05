
	cscript ieduplicates_test adofile ieduplicates
	which   ieduplicates

/*******************************************************************************
	Set up
*******************************************************************************/

	* Add the path to your local clone of the iefieldkit repo
	global iefieldkit ""
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
	*ieduplicates uuid using "${iefieldkit}", uniquevars(make)

	* Without 'clear' option
	use `duplicates', clear
	*ieduplicates uuid using "${iefieldkit}\foo", uniquevars(make)

	* Invalid format
	use `duplicates', clear
	*ieduplicates uuid using "${iefieldkit}\foo.csv", uniquevars(make)

	use `duplicates', clear
	*ieduplicates uuid using "${iefieldkit}\foo.", uniquevars(make) force

	* Invalid name
	use `duplicates', clear
	*ieduplicates uuid using "${iefieldkit}\.xlsx", uniquevars(make)

	*Check that cd is not working
	cd "${iefieldkit}"
	use `duplicates', clear
	ieduplicates uuid using "foo", uniquevars(make) force


