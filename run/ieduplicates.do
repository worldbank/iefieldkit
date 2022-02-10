
/*******************************************************************************
	Set up
*******************************************************************************/

	* Add the path to your local clone of the iefieldkit repo
	do 	"${iefieldkit}/src/ado_files/ieduplicates.ado"

	local iedup_output "${testouput}/ieduplicates_output"

	** Test if output folder exists, if not create it
	mata : st_numscalar("r(dirExist)", direxists("`iedup_output'"))
	if `r(dirExist)' == 0  mkdir "`iedup_output'"

	sysuse auto, clear
	encode make, gen(uuid)
	replace uuid = 7 in 16
	replace uuid = 1 in 2
	
	*Issue https://github.com/worldbank/iefieldkit/issues/172 - long id with space
	gen 	make_dup = make + " abcdefghijklmnopqrstuvwxyz1234567890"
	replace make_dup = make_dup[_n-1] if floor(_n/2)*2 == _n

	tempfile duplicates
	save	 `duplicates'

/*******************************************************************************
	No error
*******************************************************************************/

	* No duplicates
	ieduplicates make using "`iedup_output'/foo", uniquevars(make)

	* Test file format
	use `duplicates', clear
	ieduplicates uuid using "`iedup_output'/foo.xlsx", uniquevars(make) force

	use `duplicates', clear
	ieduplicates uuid using "`iedup_output'/foo.xls", uniquevars(make) force

	* Test folder and suffix syntax
	use `duplicates', clear
	ieduplicates uuid, uniquevars(make) folder("`iedup_output'") force

	use `duplicates', clear
	ieduplicates uuid, uniquevars(make) folder("`iedup_output'") suffix(bar) force
	
	*Duplicates and a long id with spaces (for example a name in listing) 
	*From issue #172
	use `duplicates', clear
	ieduplicates make_dup using "`iedup_output'/longdup.xls", uniquevars(make) force
	
/*******************************************************************************
	Yes error
*******************************************************************************/

	* Observations were removed
	cap ieduplicates uuid using "`iedup_output'\iedupreport.xlsx", uniquevars(make)
	di _rc
	assert _rc == 9

	* Without 'force' option
	use `duplicates', clear
	cap ieduplicates uuid using "`iedup_output'\foo", uniquevars(make)
	di _rc
	assert _rc == 198

	* Invalid format
	use `duplicates', clear
	cap ieduplicates uuid using "`iedup_output'\foo.csv", uniquevars(make)
	assert _rc == 198

	use `duplicates', clear
	cap ieduplicates uuid using "`iedup_output'\foo.", uniquevars(make) force
	di _rc
	assert _rc == 198

	* Invalid name
	use `duplicates', clear
	cap ieduplicates uuid using "`iedup_output'\.xlsx", uniquevars(make)
	di _rc
	assert _rc == 198

	*Check that cd is not working
	cd "`iedup_output'"
	use `duplicates', clear
	cap ieduplicates uuid using "foo", uniquevars(make) force
	di _rc
	assert _rc == 198
