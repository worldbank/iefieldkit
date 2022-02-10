/*******************************************************************************
	
							MASTER RUN FILE
							
	This file is meant to be used to test the commands before a new release.
	It should not be merged to the Master branch, just kept on develop so it
	can be used before making a new PR.

*******************************************************************************/


qui {
/*******************************************************************************
	Part I: Set up
*******************************************************************************/

	* Set root paths
	if inlist(c(username), "WB501238", "wb50123") {
		global GitHub		"C:\Users\wb501238\Documents\GitHub"
		global AnalyticsDB	"C:\Users\wb501238\Dropbox\WB\Analytics\DIME Analytics"
	}
	
	* Set up folder globals
	global iefieldkit	"${GitHub}/iefieldkit"
	global form			"${AnalyticsDB}/Data Coordinator/iefieldkit/ietestform"
	global codebook		"${iefieldkit}/run/output/iecodebook"
	
	** Test if output folder exists, if not create it
	mata : st_numscalar("r(dirExist)", direxists("${testouput}"))
	if `r(dirExist)' == 0  mkdir "${testouput}"
	
	* Select commands to test
	local ieduplicates	0
	local iecompdup		0
	local ietestform	0
	local iecodebook	0
	local iefieldkit	0
	
/*******************************************************************************
	Part II: Test inputs
*******************************************************************************/

	if "${GitHub}" == "" {
		noi di as error "Add the folder path to your GitHub folder to the Master run file."
		exit
	}
	if !inlist(1, `ieduplicates', `iecompdup', `ietestform', `iecodebook', `iefieldkit') {
		noi di as error "No commands to test"
		exit
	}
	
	** Test if output folder exists, if not create it
	mata : st_numscalar("r(dirExist)", direxists("${testouput}"))
	if `r(dirExist)' == 0  mkdir "${testouput}"
}	

/*******************************************************************************
	Part III: Test commands
*******************************************************************************/
	
	* Test ieduplicates
	if `ieduplicates' do "${iefieldkit}/run/ieduplicates.do"
	
	* Test iecompdup
	if `iecompdup' do "${iefieldkit}/run/ieduplicates.do"	
	
	* Test ietestform
	if `ietestform' do "${iefieldkit}/run/ietestform.do"	
	
	* Test ietestform
	if `iecodebook' do "${iefieldkit}/run/iecodebook.do"	
	
*************************** End of Master Do-File ******************************
