*! version 3.2 31JUL2023  DIME Analytics dimeanalytics@worldbank.org

capture program drop iefieldkit
program iefieldkit, rclass

	* UPDATE THESE LOCALS FOR EACH NEW VERSION PUBLISHED
	local version "3.2"
	local versionDate "31JUL2023"

	syntax [anything]

	version 13

	/**********************
		Error messages
	**********************/

	* Make sure that no arguments were passed
	if "`anything'" != "" {
		noi di as error "This command does not take any arguments, write only {it:iefieldkit}"
		error 198
	}

	/**********************
		Output
	**********************/

	* Prepare returned locals
	return local 	versiondate "`versionDate'"
	return scalar 	version		= `version'

	* Display output
	noi di ""
	noi di _col(4) "This version of iefieldkit installed is version " _col(54)"`version'"
	noi di _col(4) "This version of iefieldkit was released on " _col(54)"`versionDate'"
	noi di ""
	noi di _col(4) "This package includes the following commands:"
	noi di _col(8) "- {help iecodebook}"
	noi di _col(8) "- {help ieduplicates}/{help iecompdup}"
	noi di _col(8) "- {help ietestform}"
end
