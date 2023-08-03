*! version 3.2 31JUL2023  DIME Analytics dimeanalytics@worldbank.org

	capture program drop iecompdup
	program iecompdup , rclass

	qui {

		syntax varname [if],  id(string) [DIDIfference KEEPDIFFerence KEEPOTHer(varlist) more2ok]

		version 11.0

		preserve

/*******************************************************************************
	Test syntax
*******************************************************************************/

			* More2ok and if are meant to solve the same problem, so they cannot be used together
			if "`more2ok'" != "" & `"`if'"' != "" {

				noi di as error "{phang}Option {inp:more2ok} cannot be used together with {inp:if}.{p_end}"
				noi di ""
				error 197
				exit
			}

			* Option keep other can only be used with option keepdifference
			if "`keepdifference'" == "" & "`keepother'" != "" {

				noi di as error "{phang}Not allowed to specify option {inp:keepother()} without specifying {inp:keepdifference}.{p_end}"
				noi di ""
				error 197
				exit
			}

/*******************************************************************************
	Prepare data
*******************************************************************************/

			* Turn ID var to string so that the rest of the command works similarly
			stringid `varlist'

			* Only keep duplicates with the ID specified
			keep if  `varlist' == "`id'"

			* Test number of duplicates
			testnumobs `varlist', id("`id'")

			* If there are more than 2 observations, either the user must
			* explicitly select the observations to compare, or aknowledge that
			* only the first two will be compared, or the command will not run
			if `r(more2)' == 1 & "`more2ok'" == "" & `"`if'"' == "" {
				errormore2 `varlist', id("`id'")
			}
			else if `r(more2)' == 1 & "`more2ok'" != "" {

				keep if _n <= 2
				noi di "{phang}There are more than two observations with (`varlist' == `id'). The first two observations with (`varlist' == `id') according to the sort order in the data set will be compared.{p_end}"

			}
			else if `r(more2)' == 1 & `"`if'"' != "" {

				* Remove observations excluded by if
				marksample touse,  novarlist
				keep if `touse'

				* Test that now we have the right number of observations
				testnumobs `varlist', id("`id'")

				if `r(more2)' == 1 {
					errormore2 `varlist', id("`id'") ifused
				}
			}

/*******************************************************************************
	Compare all variables
*******************************************************************************/

			*Initiate the locals
			local match
			local difference

			* Go over all variables and see if they are non missing for at least one of the variables
			foreach var of varlist _all {

				cap assert missing(`var')

				** If not missing for at lease one of the observations, test
				*  if they are identical across the duplicates or not, and
				*  store variable name in appropriate local
				if _rc {

					* Are the variables identical
					if `var'[1] == `var'[2] {
						local match `match' `var'
					}
					else {
						local difference `difference' `var'
					}
				}
				* If missing for all duplicates, then drop that variable
				else {
					drop `var'
				}
			}

			* Remove the ID var from the match list, it is match by definition and therefore add no information
			local match : list match - varlist

/*******************************************************************************
	Output the results
*******************************************************************************/

			noi di ""
			** Display all variables that differ. This comes first in case
			*  the number of variables are a lot, cause then it would push
			*  any other output to far up
			if "`didifference'" != "" {

				noi di "{phang}The following variables have different values across the duplicates:{p_end}"
				noi di "{pstd}`difference'{p_end}"
				noi di ""
			}

			*Display number output
			local numNonMissing = `:list sizeof match' + `:list sizeof difference'

			noi di "{phang}The duplicate observations with ID = `id' have non-missing values in `numNonMissing' variables. Out of those variables:{p_end}"
			noi di ""
			noi di "{phang2}`:list sizeof match' variable(s) are identical across the duplicates{p_end}"
			noi di "{phang2}`:list sizeof difference' variable(s) have different values across the duplicates{p_end}"



			return local matchvars 	`"`match'"'
			return local diffvars 	`"`difference'"'

			return scalar nummatch	= `:list sizeof match'
			return scalar numdiff 	= `:list sizeof difference'
			return scalar numnomiss	= `numNonMissing'

		restore

/*******************************************************************************
	If keep difference is applied, return only different or selected variables
*******************************************************************************/

		if "`keepdifference'" != "" & "`difference'" != "" {

			order `varlist' `difference' `keepother'
			keep `varlist' `difference' `keepother'

			* Drop differently depending on numeric or string
			cap confirm numeric variable `varlist'
			if !_rc {
				keep if  `varlist' == `id'
			}
			else {
				keep if  `varlist' == "`id'"
			}
		}
	}

	end

/*******************************************************************************

	Subprograms to test inputs and prepare data

*******************************************************************************/

*------------------------------------------------------------------------------*
*	Turn ID var to string so that the rest of the command works similarly
*------------------------------------------------------------------------------*

capture program drop stringid
		program 	 stringid

qui {

	syntax varname

	* Test if ID variable fully identifies the data (otherwise, the next test will not work)
	qui count if missing(`varlist')
	if r(N) != 0 {
		di as error "{phang}The ID variable contains missing values. The data set is not fully identified.{p_end}"
		error 459
		exit
	}

	* Test if ID variable is numeric or string
	cap confirm numeric variable `varlist'
	if !_rc {

		* If numeric, test if all values in ID variable is integer
		cap assert mod(`varlist',1) == 0

		* This command does not allow numeric ID variables that are not integers
		if _rc {
			di as error "{phang}The ID variable is only allowed to be either string or only consist of integers. Integer in this context is not the same as the variable type int. Integer in this context means numeric values without decimals. Please consider using integers as your ID or convert your ID variable to a string.{p_end}"
			error 109
			exit
		}
		else {

			** Find the longest (for integers that is the same as largest)
			*  number and get its legth.l
			sum `varlist'
			local length 	= strlen("`r(max)'")

			** Use that length when explicitly setting the format in
			*  order to prevent information lost
			tostring `varlist', replace format(%`length'.0f) force
		}
	}

		* Testing that the ID variable is a string before continuing the command
		cap confirm string variable `varlist'
		if _rc {
			di as error "{phang}This error message is not due to incorrect specification from you. This message follows a failed check that the command is working properly. If you get this error, please send an email to kbjarkefur@worldbank.org including the follwoing message 'ID var was not succesfully turned in to a string without information loss in iecompdup.' and include whatever other data you do not mind sharing.{p_end}"
		}
}

end

*------------------------------------------------------------------------------*
*	Test the number of duplicates
*------------------------------------------------------------------------------*

capture program drop testnumobs
		program		 testnumobs , rclass

qui {

	syntax varname, id(string)

	* Count number of observations
	count

		 if `r(N)' == 2		local more2 0
	else if `r(N)' == 0 {

		noi di as error "{phang}ID incorrectly specified. No observations with (`varlist' == `id'){p_end}"
		noi di ""
		error 2000
		exit
	}
	else if `r(N)' == 1 {

		noi di as error "{phang}ID incorrectly specified. No duplicates with that ID. Only one observation where (`varlist' == `id').{p_end}"
		noi di ""
		error 2001
		exit
	}
	else if `r(N)' > 2 {

		local more2	1
	}

	return local more2	`more2'
}

end

*------------------------------------------------------------------------------*
*	Error message when more than two obs to compare
*------------------------------------------------------------------------------*

capture program drop errormore2
		program		 errormore2

	syntax varname, id(string) [ifused]

	if "`ifused'" != "" {
		local if_message " that also satisfy the {inp:if} condition"
	}

	noi di as error "{phang}There are more than 2 observations with (`varlist' == `id')`if_message'. The current version of iecompdup is not able to compare more than 2 duplicates at the time. (How to output the results for groups larger than 2 is non-obvious and suggestions on how to do that are appreciated.){p_end}{break}"
	noi di as error "{phang}Either use {inp:if} to explicitly select the observations to be compared or specify option {inp:more2ok}, in which case the comparison will be done between the first and the second occurrences of the value `id' in `varlist'.{p_end}"
	noi di ""
	error 197
	exit

end
