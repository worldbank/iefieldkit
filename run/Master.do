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

	* Set folder paths
	global GitHub		""
	global AnalyticsDB	""

	* Calculate globals
	global iefieldkit	"${GitHub}/iefieldkit"
	global form			"${AnalyticsDB}/Data Coordinator/iefieldkit/ietestform"
	
	* Select commands to test
	local ieduplicates	1
	local iecompdup		1
	local ietestform	1
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
	
*************************** End of Master Do-File ******************************
