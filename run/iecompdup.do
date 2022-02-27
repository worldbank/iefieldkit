
	do "${GitHub}/iefieldkit/src/ado_files/iecompdup.ado"
	
/*******************************************************************************
	Prepare data
*******************************************************************************/
	
	sysuse auto, clear
	
	encode make, gen(uuid)

	* Two duplicates
	replace uuid = 1 if (uuid <= 2)
	
	* Three duplicates 
	replace uuid = 2 if (uuid > 1 & uuid <= 5)
	
	* Four duplicates 
	replace uuid = 3 if (uuid > 2 & uuid <= 9)
	
	gen    	key 		= _n
	gen		wrong_key 	= key
	replace wrong_key 	= 2 if uuid == 2
	gen 	oi 	 		= "oi"
	
	tempfile  testdata
	save	 `testdata'

	
/*******************************************************************************
	Should return no error
*******************************************************************************/
	
*-------------------------------------------------------------------------------
* 	Two duplicates
*------------------------------------------------------------------------------- 

	iecompdup uuid, id(1)
	iecompdup uuid, id(1) didiff
	iecompdup uuid, id(1) didiff keepdiff
	
	use `testdata', clear
	iecompdup uuid, id(1) keepdiff keepother(oi)
	
*-------------------------------------------------------------------------------
* 	More than two duplicates
*------------------------------------------------------------------------------- 
	
	* With string key
	use `testdata', clear
	iecompdup uuid if inlist(make, "Audi 5000", "Audi Fox"), id(2) 
	iecompdup uuid if inlist(make, "Audi 5000", "Audi Fox"), id(2) didiff keepdiff
		
	* With numeric key
	iecompdup uuid if inlist(key, 53, 54 ), id(2) 
	iecompdup uuid if inlist(key, 53, 54 ), id(2) didiff keepdiff
	
	* With more2ok
	use `testdata', clear
	iecompdup uuid, id(2) more2ok
	iecompdup uuid, id(2) more2ok didiff keepdiff
		
	
/*******************************************************************************
	Should return error
*******************************************************************************/

	use `testdata', clear
	
*-------------------------------------------------------------------------------
* 	No duplicates
*------------------------------------------------------------------------------- 
	
	cap iecompdup uuid, id(15)
	assert _rc == 2001
	
	cap iecompdup uuid if key == 210938, id(0)
	assert _rc == 2000
	
*-------------------------------------------------------------------------------
* 	Options incorrectly specified
*------------------------------------------------------------------------------- 

	cap iecompdup uuid, id(1) keepother(oi)
	assert _rc == 197

*-------------------------------------------------------------------------------
* 	More than two duplicates
*------------------------------------------------------------------------------- 

	cap iecompdup uuid, id(2)
	assert _rc == 197
	
	cap iecompdup uuid if inlist(key, 53, 54, 3), id(2)
	assert _rc == 197
	
*-------------------------------------------------------------------------------
* 	An ID value is numeric but not an integer.
*------------------------------------------------------------------------------- 
	
	replace uuid = 1.5 if (uuid == 1)
	cap iecompdup uuid, id(1.5)
	assert _rc == 109
