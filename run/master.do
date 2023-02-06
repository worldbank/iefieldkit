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

	*Kbjarkefur
	if lower(c(username)) == "wb462869" {
		global GitHub		"C:\Users\wb462869\github"
		global AnalyticsDB	"C:\Users\wb462869\Dropbox\DIME Analytics"
	}

	* Luiza work PC
	if lower(c(username)) == "luizaandrade" {
		global GitHub		"C:\Users\luizaandrade\Documents\GitHub"
		global AnalyticsDB	"C:\Users\luizaandrade\Dropbox\WB\Analytics\DIME Analytics"
	}

	if lower(c(username)) == "luiza" {
		global GitHub		"/home/luiza/github"
		global AnalyticsDB	"/home/luiza/Dropbox/WB/Analytics/DIME Analytics"
	}

	if lower(c(username)) == "bbdaniels" {
		global GitHub		"/users/bbdaniels/github"
		global AnalyticsDB	"/Users/bbdaniels/Library/CloudStorage/Dropbox/Work/DIME/DIME Analytics"
	}

	* Set up folder globals
	global iefieldkit	"${GitHub}/iefieldkit"
	global run 			"${iefieldkit}/run"
	global output		"${run}/output"
	global form			"${AnalyticsDB}/Data Coordinator/iefieldkit/ietestform"
	global codebook		"${output}/iecodebook"

	* Select commands to test
	local iecorrect		1
	local ietestform	1
	local iecodebook	1
	local iefieldkit	1
	local ieduplicates	1
	local iecompdup		1


/*******************************************************************************
	Part II: Test inputs
*******************************************************************************/

	if "${GitHub}" == "" {
		noi di as error "Add the folder path to your GitHub folder to the Master run file."
		exit
	}
	if !inlist(1, `ieduplicates', `iecompdup', `ietestform', `iecodebook', `iefieldkit', `iecorrect') {
		noi di as error "No commands to test"
		exit
	}

}

/*******************************************************************************
	Part III: Test commands
*******************************************************************************/

	* Test ietestform
	if `ietestform' 	do "${run}/ietestform.do"

	* Test iecodebook
	if `iecodebook' 	do "${run}/iecodebook.do"

	* Test iecorrect
	if `iecorrect' 		do "${run}/iecorrect.do"

	* Test iecompdup
	if `iecompdup' 		do "${run}/iecompdup.do"

	* Test ieduplicates
	if `ieduplicates' 	do "${run}/ieduplicates.do"




*************************** End of Master Do-File ******************************
