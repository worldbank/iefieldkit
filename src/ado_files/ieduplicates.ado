*! version 3.2 31JUL2023  DIME Analytics dimeanalytics@worldbank.org

	capture program drop ieduplicates
	program ieduplicates , rclass


	qui {

		syntax  varname [using/] , UNIQUEvars(varlist) ///
            [force ///
            FOLder(string) ///
            KEEPvars(varlist) ///
            tostringok ///
            droprest ///
            nodaily ///
            SUFfix(string) ///
            duplistid(string) datelisted(string) datefixed(string) correct(string) drop(string) newid(string) initials(string) notes(string) listofdiffs(string)]

		version 11.0

		*Add version of Stata fix
		//Make sure that keepvars are still saved if saved if the duplicates file
		*	is generated on a subset of the data. For example, duplicates from
		*	version 1, 2 . If the command is run on only version 1. Then values
		*	for keeepvars in version 2 and 3 are dropped and not reloaded as those
		*	obs are not in current memory

		**Test that observations have not been deleted from the report before readind
		* it. Deleted in a way that the report does not make sense. Provide an error
		* message to this that is more informative.

		preserve

			/***********************************************************************
			************************************************************************
				Section 1 - Set up locals needed in data
				Saving a version of the data to be used before merging corrections
				back to the original data set and before correcting duplicates
			************************************************************************
			***********************************************************************/

			*Tempfiles to be used
			tempfile originalData preppedReport datawithreportmerged dataToReturn

			** Save a version of original data that can be brought
			*  back withing the preserve/restore section
			save 	`originalData'

			* Create a local with todays date to date the reports
			local  date = subinstr(c(current_date)," ","",.)

			*Put idvar in a local with a more descriptive name
			local idvar `varlist'

			* Test that values are missing in idvar
			cap assert(!missing(`idvar'))
			if _rc {
				noi di as error "{phang}There are missing values in the ID variable [`idvar']. Those values must be removed or solved before this command can be used. Click the link - {stata browse if missing(`idvar')} - to browse the observations for which the ID variable is missing so that they can be addressed.{p_end}"
				noi di ""
				error 198
				exit
			}

			* Test that the idvar does not contain the character `
			cap confirm string variable `idvar'
			if !_rc {
				cap assert !strpos(`idvar', "`")
				if _rc {
					noi di as error "{phang}The data set contains one or more observations that has the character `=char(96)' in the ID variable [`idvar']. This is the only character {inp:ieduplicates} cannot handle that is otherwise allowed in a variable in your version of Stata.{p_end}"
					noi di ""
					error 198
					exit
				}
			}


			** Making one macro with all variables that will be
			*  imported and exported from the Excel file
			local argumentVars `idvar' `uniquevars' `keepvars'

			* Create a list of the variables created by this command to put in the report

			********************
			* Test that each manually entered Excel varaible name is valid, or assigned the default name

			*For optioin to change var names. Setting a default name of columns (in case user did not specify the variable name)
			local deafultvars duplistid datelisted datefixed correct drop newid initials notes listofdiffs
			foreach deafultvar of local deafultvars  {

				*trim user input. If no input string is empty, which returns an empty string
				local `deafultvar' = trim("``deafultvar''") //trim() is older syntax, compare to strtrim() in Stata 15 and newer

				*Test that the customized names only include lower case. This was a compromise
				* needed to allow backward compatibility when all excel variable names are
				* imported in lower case. This follows from the Excel variable names in first
				* version had upper case letters, but Stata options cannot use upper case, and
				* we want the two to be the same
				if "``deafultvar''" != lower("``deafultvar''") {
					noi di as error "{phang}For the puprpose of backward version compatibility, the names in option `deafultvar'(``deafultvar'') must not include any upper case letters.{p_end}"
					noi di ""
					error 198
					exit
				}

				*If no user input for this var, assign default name
				if "``deafultvar''" == "" local `deafultvar' = "`deafultvar'"

				*Check for space in varname (only possible when user assign names manually)
				if strpos("``deafultvar''", " ") != 0 {

					noi di as error "{phang}The Excel report variable name [``deafultvar''] should not contain any space. Please change the variable name.{p_end}"
					noi di ""
					error 198
					exit
				}
			}

			********************
			* Excel variables values are ok on their own, test in relation to each other and varaiblaes already in the data

			* Test that no variable with the name needed for the excel report already exist in the data set
			local excelVars `duplistid' `datelisted' `datefixed' `correct' `drop' `newid' `initials' `notes' `listofdiffs'

			* Check for duplicate variable names in the excelVars
			local duplicated_names : list dups excelVars
			if "`duplicated_names'" != "" {

				local duplicates : list uniq duplicatenames
				noi display as error "{phang}The excel report variable name [`duplicates'] already exist within either the default variable name or modified name. Variable names in Excel report must be distinct. Please change the variable name.{p_end}"
				noi di ""
				error 198
				exit
			}


			* Check for duplicate variable names in the existing dataset
			foreach excelvar of local excelVars {
				cap confirm variable `excelvar'
				if _rc == 0 {
					*Variable exist, output error
					noi di as error "{phang}The Excel report variable [``excelvar''] cannot be created as that variable already exist in the data set. Use the option called ``excelvar''() to change the name of the variable to be created in the report.{p_end}"
					noi di ""
					error 198
					exit
				}
			}

			*********************
			* Prepare locals for report file path
			if "`folder'" != ""		local foldertotest 		folder(`folder')
			if "`suffix'" != ""		local suffixtotest 		suffix(`suffix')
			if "`using'"  != ""		local usingtotest		`"using "`using'""'

			noi testpath `usingtotest' , today(`date') `suffixtotest' `foldertotest'

			local name		= r(name)
			local folder	= r(folder)
			local ext		= r(ext)

			local using		"`folder'`name'`ext'"

			/***********************************************************************
			************************************************************************
				Section 2 - Test unique vars
				Test the unique vars so that they are identifying the data set and
				are not in a time format that might get corrupted by exporting to
				and importing from Excel. This is needed as the uniquevars are needed
				to merge the correct correction to the correct duplicat
			************************************************************************
			***********************************************************************/

			*Test that the unique vars fully and uniquely identifies the data set
			cap isid `uniquevars'
			if _rc {

				noi display as error "{phang}The variable(s) listed in uniquevars() does not uniquely and fully identifies all observations in the data set.{p_end}"
				isid `uniquevars'
				error 198
				exit
			}

			** Test that no unique vars are time format. Time values might be corrupted
			*  and changed a tiny bit when importing and exporting to Excel, which make merge not possible
			foreach uniquevar of local uniquevars {

				*Test if format is time format
				local format : format `uniquevar'
				if substr("`format'",1,2) == "%t" {

					noi display as error `"{phang}The variable {inp:`uniquevar'} listed in {inp:uniquevars()} is using time format which is not allowed. Stata and Excel stores and displays time slightly differently which can lead to small changes in the value when the value is imported and exported between Stata and Excel, and then the variable can no longer be used to merge the report back to the original data. Use another variable or create a string variable out of your time variable using this code: {inp: generate `uniquevar'_str = string(`uniquevar',"%tc")}.{p_end}"'
					noi di ""
					error 198
					exit
				}
			}


			/***********************************************************************
			************************************************************************
				Section 3 - Test input from Excel file
				If Excel report exists, import it and test for invalid corrections
				made in the excel report.
			************************************************************************
			***********************************************************************/

			/******************
				Section 3.1
				Check if report exists from before.
			******************/

			*Check if file exist. Suffix option can be used to create multiple reports in the same folder
			cap confirm file "`using'"

			if !_rc {
				local fileExists 1
			}
			else {
				local fileExists 0
			}


			/******************
				Section 3.2
				If report exists, load file and check input, otherwise skip to section 4
			******************/

			if `fileExists' {

				*Load excel file. Load all vars as string and use metadata from Section 1
				import excel "`using'"	, clear firstrow

				ds
				local existingExcelVarsRaw  `r(varlist)' // before fixing case

				*Test that the ID variable is in the imported report
				if `:list idvar in existingExcelVarsRaw' == 0 {

					noi display as error "{phang}The ID variable `idvar' does not exist in the previously exported Excle file. If you renamed the ID variable you need to rename it manually in the Excel report or start a new Excel report by renaming or moving the original report, then run the command again and create a new file and manually copy any corrections from the old file to the new. If you changed the ID variable you need to start with a new report.{p_end}"
					noi di ""
					error 111
					exit

				}

				local existingExcelVarsRaw : list existingExcelVarsRaw - idvar

				*For backward comapitbility after allowing user to change names on
				* vars, only use lower case, but do not change name of idvar

				foreach var of local existingExcelVarsRaw {
					local lowcase = lower("`var'")
					if ("`var'"!="`lowcase'") rename `var' `lowcase'  // Will throw error if name is the same
				}

				*Drop empty rows that otherwise create error in merge that requires unique key
				tempvar count_nonmissing_values
				egen `count_nonmissing_values' = rownonmiss(_all), strok
				drop if `count_nonmissing_values' == 0

				* Check if the variable name in the excel spreadsheet remain unchanged from the original report outputted.
				foreach excelvar of local excelVars {
					cap confirm variable `excelvar'

					*The listofdiffs var was not a part of the original vars so old report might not have it. So create it if it does not exits.
					if _rc !=0 & "`excelvar'" == "listofdiffs" {
						gen `excelvar' = ""
					}

					*Required variable does not exist in Excel file, output error
					else if _rc !=0 {

						noi display as error "{phang}The spreadsheet variable {inp:`excelvar'} does not exist. Either you changed the name of the variables in the spreadsheet, or you are using options to ieduplicates that are changing the variable names expected in the spreadsheet. Change the names in the spreadsheet, or use the command options to change the name of variable {inp:`excelvar'}.{p_end}"
						error 198
						exit
					}

				** All excelVars but duplistid and newid should be string. duplistid
				*  should be numeric and the type of newid should be based on the user input
					if !inlist("`excelvar'", "`duplistid'", "`newid'") {

						* Make original ID var string
						tostring `excelvar' , replace
						replace  `excelvar' = "" if `excelvar' == "."
					}
				}

				/******************
					Section 3.2.1
					Make sure that the ID variable and the uniquevars are
					not changed since last report.
				******************/

				*Copy a list of all variables in the imported report to the local existingExcelVars
				ds
				local existingExcelVars  `r(varlist)'

				*Test that the unique variables are in the imported report
				if `:list uniquevars in existingExcelVars' == 0 {

					noi display as error "{phang}One or more unique variables in [`uniquevars'] do not exist in the previously exported Excel file. If you renamed or changed any variable used in uniquevars(), you need to start over with a new file. Rename or move the already existing file. Create a new file and carefully copy any corrections from the old file to the new.{p_end}"
					noi di ""
					error 111
					exit
				}

				/******************
					Section 3.3
					Make sure input is correct
				******************/

				*Temporary variables needed for checking input
				tempvar multiInp inputNotYes maxMultiInp notDrop yesCorrect groupNumCorrect toDrop anyCorrection groupAnyCorrection

				*Locals indicating in which ways input is incorrect (if any)
				local local_multiInp 		0
				local local_multiCorr		0
				local local_inputNotYes	0
				local local_notDrop			0


				/******************
					Section 3.3.1
					Make sure input is "correct" or "drop" for the correct and drop columns
					"Yes" and "y" are allowed for backward compatibility
				******************/

				* 1. Trim the string of leading and trailing spaces, 2. make it lower case
				* and 3. (change "y" to "yes" : backward compatibility)
				replace `correct' = lower(trim(`correct'))
				replace `drop' 	  = lower(trim(`drop'))
				replace `correct' = "yes" if `correct' == "y" //Backward compatibility
				replace `drop' 	  = "yes" if `drop'    == "y" //Backward compatibility

				*Check that variables are either empty or correct/drop. (Or "yes" : backward compatibility)
				gen `inputNotYes' = !( ///
					(`correct' == "correct" | `correct' == "" | `correct' == "yes") & ///
					(`drop'    == "drop"    | `drop'    == "" | `drop'    == "yes")   ///
				)

				*Set local to 1 if error should be outputted
				cap assert `inputNotYes' == 0
				if _rc local local_inputNotYes 	1

				/******************
					Section 3.3.2
					Make sure there are not too many corrections for a single observation
				******************/

				* Count the number of corrections (correct drop newid) per
				* observation. Only one correction per observation is allowed.
				egen `multiInp' = rownonmiss(`correct' `drop' `newid'), strok

				*Check that all rows have at most one correction
				cap assert `multiInp' == 0 | `multiInp' == 1

				*Error will be outputted below
				if _rc local local_multiInp 	1

				/******************
					Section 3.3.3
					Test that maximum one duplicate per duplicate group is indicated as correct
				******************/

				*Generate dummy if correct column is set to "correct" (or "yes" : backward compatibility)
				gen `yesCorrect' = (`correct' == "correct" | `correct' == "yes") //("yes" : backward compatibility)

				*Count number of duplicates within duplicates where that dummy is 1
				bys `idvar' : egen `groupNumCorrect' =  total(`yesCorrect')

				*Test if more than 1 duplicate in that duplicate group is correct
				count if `groupNumCorrect' > 1

				*Output error is more than one duplicate in a duplicate group is yes
				if `r(N)' != 0 local local_multiCorr 1


				/******************
					Section 3.3.4
					Make sure that either option droprest is specified, or that
					drop was correctly indicated for all observations. i.e.; if
					correct or newid was indicated for at least one duplicate in
					a duplicate group, then all other observations should be
					indicated as drop (unless droprest is specified)
				******************/

				*Generate dummy if there is any correction for this observation
				gen `anyCorrection' = !missing(`correct') | !missing(`newid')

				*Count number of observations with any correction in suplicates group
				bys `idvar' : egen `groupAnyCorrection' =  total(`anyCorrection')

				*Create dummy that indicates each place this error happens
				gen `notDrop' = (missing(`drop') & `groupAnyCorrection' > 0 & `anyCorrection' == 0)

				* Check if option droprest is specified
				if "`droprest'" == "" {

					** If option droprest is not used, then all observations in a duplicate
					*  group where at least one observation has a correction must have a
					*  correction or have drop set to "drop" (or "yes" : backward compatibility)
					cap assert `notDrop' == 0

					*Error will be outputted below
					if _rc local local_notDrop 	1

				}
				else {

					** Option -droprest- specified. Drop will be changed to drop
					*  for any observations without drop or any other correction
					*  explicitly specified if the observation is in a duplicate
					*  group with at least one observation has a correction
					replace `drop' 	= "drop" if `notDrop' == 1

				}

				/******************
					Section 3.4
					Throw errors if any of the tests were not passed
				******************/

				*Output errors if errors in the report were detected
				if `local_multiInp' == 1 | `local_inputNotYes' == 1 | `local_notDrop' == 1 | `local_multiCorr' == 1  {
					noi {
						di ""
						di ""
						di as error "{phang}{ul:The corrections made in the Excel report has the following errors:}{p_end}"
						di ""

						*Error multiple input
						if `local_multiInp' == 1 {
							display as error "{phang}The following observations have more than one correction. Only one correction (correct, drop or newid) per row is allowed{p_end}"
							list `idvar' `duplistid' `correct' `drop' `newid' `uniquevars' if `multiInp' > 1
							di ""
						}

						*Error multiple correct
						if `local_multiCorr' == 1 {
							display as error "{phang}The following observations are in a duplicate group where more than one observation is listed as correct. Only one observation per duplicate group can be correct{p_end}"
							list `idvar' `duplistid' `correct' `drop' `newid' `uniquevars' if `groupNumCorrect' > 1
							di ""
						}

						*Error in incorrect string
						if `local_inputNotYes' == 1 {
							display as error `"{phang}The following observations have an answer in either correct or drop that is not valid. The only valid value in correct is "correct", and in drop is "drop". ("yes" is also allowed for backward compatibility.){p_end}"'
							list `idvar' `duplistid' `correct' `drop' `uniquevars' if `inputNotYes' == 1
							di ""
						}

						*Error is not specfied as drop
						if `local_notDrop' == 1 {
							display as error "{phang}The following observations are not explicitly indicated as drop while other duplicates in the same duplicate group are corrected. Either manually indicate as drop or see option droprest{p_end}"
							list `idvar' `duplistid' `correct' `drop' `newid' `uniquevars' if `notDrop' == 1
							di ""
						}

						*Same error for any incorrect input

						di as error "{phang}Since there was at least one error in the Excel report no corrections have been made to the duplicates in the data set. Please address the errors above and then run the command again.{p_end}"
						error 198
						exit
					}
				}


				/******************
					Section 3.5
					Save the prepared report to be used later
				******************/

				*Keep only the variables needed for matching and variables used for input in the Excel file
				keep 	`idvar' `uniquevars' `excelVars' `groupAnyCorrection'

				*Save imported data set with all corrections
				save	`preppedReport'
			}


			/***********************************************************************
			************************************************************************
				Section 4 - Merge report to original data
				Merge corrections with original data, test that there are no
				obs in report that are not in main data, and save this data
				in temp file
			************************************************************************
			***********************************************************************/

			*Re-load original data
			use `originalData', clear

			* Merge original data with imported Excel file (if Excel file exists)
			if `fileExists'  {

				*Create a tempvar for merging results
				tempvar iedup_merge

				*Merge the corrections with the data set
				merge 1:1 `uniquevars' using `preppedReport', generate(`iedup_merge')

				*Make sure that obsrevations listed in the duplicate report is still in the data set
				cap assert `iedup_merge' != 2

				*Display error message if assertion is not true and some duplicates in the Excel file are no longer in the data set
				if _rc {

					display as error "{phang}One or several observations in the Excel report are no longer found in the data set. Always run ieduplicates on the raw data set that include all the duplicates, both new duplicates and those you have already identified. After removing duplicates, save the data set using a different name. You might also receive this error if you are using an old ieduplicates Excel report on a new data set.{p_end}"
					error 9
					exit
				}

				*Explicitly drop temporary variable. Temporary variables might
				*be exported to excel so delete explicitly before that. Only
				*using tempvar here to create a name with no conflicts
				drop `iedup_merge'

			}

			*save the data set to be used when correcting the data
			save `datawithreportmerged'

			/***********************************************************************
			************************************************************************
				Section 5 - Generate the Excel report
				Test if there are duplicates in ID var. If any duplicates exist,
				then update the Excel file with new and unaddressed cases
			************************************************************************
			***********************************************************************/

			/******************
				Section 5.1
				Test if there are any duplicates in ID var
			******************/

			* Generate variable that is not 0
			* if observation is a duplicate
			tempvar dup
			duplicates tag `idvar', gen(`dup')

			*Test if there are any duplicates
			cap assert `dup'==0
			if _rc {

				/******************
					Section 5.2
					Keep only duplicates for the report
				******************/

				*Keep if observation is part of duplicate group
				keep if `dup' != 0

				/******************
					Generate the report variables if they do not exist
				******************/

				*Generate the excel variables used for indicating correction
				foreach excelvar of local excelVars {

					*Test if variable exist. Only does not exist if no report yet or an olde report
					cap confirm variable `excelvar'
					if _rc {
						*Create all variables apart from duplistid as string vars
						if inlist("`excelvar'", "`duplistid'", "`newid'") {
							gen `excelvar' = .
						}
						else {
							gen `excelvar' = ""
						}
					}
				}

				*Add list of variables that are different between the two duplicated id value in excel report in 'listofdiffs' variable
				levelsof `idvar', local(list_dup_ids)
				foreach id of local list_dup_ids {

					*reset list of differing vars between each loop
					local difflist ""

					*Count differently if string or numeric var
					cap confirm numeric variable `idvar'
					if !_rc count if `idvar' == `id'
					else count if `idvar' == "`id'"

					*Check if duplicated id has more than 2 duplicates, as iecompdup must be run manually to check difference when there is more than 2 observations with same ID
					if `r(N)' > 2 {
						local difflist	"Cannot list differences for duplicates for which 3 or more observations has the same ID, use command iecompdup instead."
					}
					else {
						*Get the list of variables that are different between the two duplicated id value
						qui iecompdup `idvar', id(`id')
						local diffvars "`r(diffvars)'"

						* Only checking variables in the original data set and not variables in Excel report.
						local diffvars: list diffvars - excelVars

						*Truncate list when longer than 250 to look better in report
						if strlen("`diffvars'") > 250 local difflist  = substr("`r(diffvars)'" ,1 ,200) + " ||| List truncated, use iecompdup for full list"
						else local difflist "`diffvars'" //List of diff is short enough to show in its entirety
					}

					*Count differently if string or numeric var
					cap confirm numeric variable `idvar'
					if !_rc replace `listofdiffs' = "`difflist'" if `idvar' == `id'
					else replace `listofdiffs' = "`difflist'" if `idvar' == "`id'"
				}

				* Delete all variables that is not supposed to be exported
				keep 	`argumentVars' `excelVars'

				/******************
					Section 5.3
					Update the excel vars that are not updated manually
				******************/

				* Generate a local that is 1 if there are new duplicates
				local unaddressedNewExcel 0
				count if missing(`datefixed')
				if `r(N)' > 0 local unaddressedNewExcel 1

				/******************
					Section 5.3.1 Date variables
				******************/

				* Add date first time duplicate was identified
				replace `datelisted' 	= "`date'" if missing(`datelisted')

				** Add today's date to variable datefixed if datefixed
				*  is empty and at least one correction is added
				replace `datefixed' 	= "`date'" if missing(`datefixed') & (!missing(`correct') | !missing(`drop') | !missing(`newid'))

				/******************
					Section 5.3.2 Duplicate report list ID
				******************/

				** Sort after duplistid and after ID var for
				*  duplicates currently without duplistid
				sort `duplistid' `idvar'

				** Assign duplistid 1 to the top row if no duplicate
				*  list IDs have been generated so far.
				replace `duplistid' = 1 if _n == 1 & missing(`duplistid')

				** Generate new IDs based on the row above instead of directly
				*  from the row number. That prevents duplicates in the list in
				*  case an observation is deleted. The first observation with
				*  missing value will have an ID that is one digit higher than
				*  the highest ID already in the list
				replace `duplistid' = `duplistid'[_n - 1] + 1 if missing(`duplistid')

				/******************
					Section 5.4
					Keep and order the variables and output the Excel files
				******************/

				* If cases unaddressed then update the Excel file
				if `unaddressedNewExcel'  {

					keep 	`argumentVars' `excelVars'
					order	`idvar' `excelVars' `uniquevars' `keepvars'

					* Save daily folder
					if "`daily'" == "" {

						savedaily , folder(`folder') name(`name') ext(`ext') today(`date')

						*Prepare local for output
						local daily_output " and a daily copy have been saved to the Daily folder"
					}

					*Making listofdiffs come last
					order `listofdiffs', last

					*Export main report
					export excel using "`using'" , firstrow(variables) replace  nolabel

					*Produce output
					noi di `"{phang}Excel file created at: {browse "`using'":`using'}`daily_output'.{p_end}"'
					noi di ""
				}
			}

		/***********************************************************************
		************************************************************************
			Section 6
			Update the data set and with the new corrections.
		************************************************************************
		***********************************************************************/

		* Load the original data set merged with correction. Duplicates
		* in all variables are already dropped in this data set
		use 	`datawithreportmerged', clear

		* If excel file exists, apply any corrections indicated (if any)
		if `fileExists' {

			/******************
				Section 6.1
				Drop duplicates listed for drop
			******************/

			drop if (`drop' == "drop" | `drop' == "yes")

			/******************
				Section 6.2
				Update new ID. ID var can be either numeric or
				string. All numbers can be made strings but not
				all strings can be numeric. Therefore this
				section is complicated.
			******************/

			*Test if there are any corrections by new ID
			cap assert missing(`newid')
			if _rc {

				local idtype 	: type `idvar'
				local idtypeNew : type `newid'

				/******************
					Section 6.2.1
					ID var in original file is string. Either
					newid was imported as string or the variable
					is made string. Easy.
				******************/

				if substr("`idtype'",1,3) == "str" & substr("`idtypeNew'",1,3) != "str" {

					tostring `newid' , replace
					replace  `newid' = "" if `newid' == "."
				}

				/******************
					Section 6.2.2
					If ID var is numeric but the newid is loaded as string, this
					could be an import error or a user input error
				******************/

				else if substr("`idtype'",1,3) != "str" & substr("`idtypeNew'",1,3) == "str" {

					* Check if [tostringok] is specificed. In this case, the old ID will be turned to string
					if "`tostringok'" != "" {

						* Make original ID var string
						tostring `idvar' , replace
						replace  `idvar' = "" if `idvar' == "."

					}
					* If it was just an import error, it will be possible to turn the new ID into a number
					else {

						* Try to destring the variable
						destring `newid', replace

						* Test if it worked
						cap confirm numeric variable `newid'

						* Throw an error if it didn't
						if _rc {
							* Create a local with all non-numeric values
							levelsof `newid' if missing(real(`newid')), local(NaN_values) clean

							* Output error message
							di as error "{phang}The ID variable `idvar' is numeric but newid has these non-numeric values: `NaN_values'. Update newid to only contain numeric values or see option tostringok.{p_end}"
							error 109
							exit
						}
					}
				}

				/******************
					Section 6.2.3
					After making sure that type is ok, update the IDs
				******************/
				replace `idvar' = `newid' if !missing(`newid')


				/******************
					Section 6.3
					Test that values in newid
					were neither used twice
					nor already existed
				******************/


				*Test if there are any duplicates after corrections (excluding observations in duplicate groups not yet corrected)
				tempvar newDup
				duplicates tag `idvar' if `groupAnyCorrection' != 0, generate(`newDup')

				*Consider missing values as no new duplicates, make conditions below easier
				replace `newDup' = 0 if missing(`newDup')

				cap assert `newDup' == 0
				if _rc {

					levelsof `idvar' if `newDup' != 0  , local(newDuplist)
					di as error "{phang}No corrections from the report are applied as it would lead to new duplicates in the following value(s): `newDuplist'.{p_end}"
					error 198
					exit
				}
			}

			/******************
				Section 6.4
				Drop Excel vars
			******************/

			drop `excelVars'
		}

		/***********************************************************************
		************************************************************************
			Section 7
			Return the data set without duplicates and
			output information regarding unresolved duplicates.
		************************************************************************
		***********************************************************************/

		* Generate a variable that is 1 if the observation is a duplicate in varlist
		tempvar dropDup
		duplicates tag `idvar',  gen(`dropDup')
		* Generate a list of the IDs that are still duplicates
		levelsof `idvar' 			if `dropDup' != 0 , local(dup_ids) clean
		* Drop the duplicates (they are exported in Excel)
		drop 						if `dropDup' != 0

		* Test if varlist is now uniquely and fully identifying the data set
		cap isid `idvar'
		if _rc {

			di as error "{phang}The data set is not returned with `idvar' uniquely and fully identifying the data set. Please report this bug to dimeanalytics@worldbank.org{p_end}"
			error 119
			exit

		}

		*Count number of duplicate groups still in the data
		local numDup	= `:list sizeof dup_ids'

		if `numDup' == 0 {
			noi di	"{phang}There are no unresolved duplicates in this data set. The data set is returned with `idvar' uniquely and fully identifying the data set.{p_end}"
		}
		else if "`force'" == "" {
			noi di as error	"{phang}There are `numDup' duplicated IDs still unresolved. IDs still containing duplicates: `dup_ids'. The unresolved duplicate observations were exported in the Excel file. Variable `idvar' does not uniquely identify the current data set. The {it:force} option is required to return the data set without those duplicates.{p_end}"
			error 198
			restore
			exit
		}
		else if "`force'" != "" {
			noi di	"{phang}There are `numDup' duplicated IDs still unresolved. IDs still containing duplicates: `dup_ids'. The unresolved duplicate observations were exported in the Excel file. The data set is returned without those duplicates and with `idvar' uniquely and fully identifying the data set.{p_end}"
		}

		return scalar numDup	= `numDup'

		/***********************************************************************
		************************************************************************
			Section 8
			Save data set to be returned outside preserve/restore.
			Preserve/restore is used so that original data is returned
			in case an error is thrown.
		************************************************************************
		***********************************************************************/

		save 	`dataToReturn'

		restore

		** Using restore above to return the data to
		*  the orignal data set in case of error.
		use `dataToReturn', clear

	}
end


/*******************************************************************************
	Function to find the last occurrence of a character in a string
*******************************************************************************/

cap program drop strlast
	program		 strlast , rclass

qui {

	syntax , expression(string) character(string)

	local firstpos = strpos("`expression'", "`character'")
	local lastpos	`firstpos'

	if `firstpos' != 0 {
		while `firstpos' > 0 {
			local expression 	= substr("`expression'", `firstpos' + 1, .)
			local firstpos 		= strpos("`expression'", "`character'")
			local lastpos 		= `lastpos' + `firstpos'
		}
	}
	return local lastpos `lastpos'

}

end

/*******************************************************************************
	Test file path to save the report and prepare the file name
*******************************************************************************/

cap program drop testpath
	program		 testpath , rclass

	syntax [using/] , today(string) [folder(string) suffix(string)]

/*******************************************************************************
	Check that options were correctly specified
*******************************************************************************/

	* Check that either using or folder options were specified
	if "`using'" == "" & "`folder'" == "" {
		noi di as error "{phang}using required.{p_end}"
		noi di ""
		error 100
		exit
	}

	* Test that user is not using both the old syntax (with folder and suffix)
	* and the new one (with using) at the same time
	else if "`using'" != "" & ("`folder'" != "" | "`suffix'" != "") {
		noi di as error "{phang}Options {inp:using} cannot be used together with options {inp:folder} and {inp:suffix}. {inp:folder} and {inp:suffix} are part of a deprecated syntax, and although supported for backward compatibility purpose, they are no longer documented. We recommend specifying only the {inp:using} option.{p_end}"
		noi di ""
		error 198
		exit
	}

/*******************************************************************************
	Prepare file name if option using was specified
*******************************************************************************/

	* Parse using option to get (1) the folder path (2) the name of the report and
	* (3) the format selected
	else if "`using'" != "" {

		* Replace any backslashes with forward slashes so it's compatible with
		* different OS and so we know what to look for as separators when parsing
		local using = subinstr("`using'", "\", "/", .)

		* Separate the folder name from the file name
		strlast, expression("`using'") character("/")

		* If a folder was specified, get the folder path
		if `r(lastpos)' > 0 {
			local folder	 = substr("`using'", 1, `r(lastpos)')
		}
		else {
			noi di as error	"{phang}You have not specified a folder path to the duplicates report. An absolute folder path is required.{p_end}"
			noi di as error `"{phang}This command will not work if you are trying to use {inp:cd} to set the directory and open or save files. To know more about why this practice is not allowed, {browse "https://dimewiki.worldbank.org/wiki/Stata_Coding_Practices#File_paths":see this article in the DIME Wiki}.{p_end}"'
			noi di as error	""
			error 198
			exit
		}

		* Everything that comas after the folder path is the file name and format
		local file	 	 = substr("`using'", `r(lastpos)' + 1, .)

		* If a filename was specified, separate the file name from the file format
		if "`file'" != "" {

			* Get index of separation between file name and file format
			strlast, expression("`file'") character(".")

			* If a format was specified, separate name and format
			if `r(lastpos)' > 0 {
				local ext 		= substr("`file'", `r(lastpos)', .)				// File format starts at the last period and ends at the end of the string
				local name		= substr("`file'", 1, `r(lastpos)' - 1)				// File name starts at the beginning and ends at the last period
			}
			* If a format was not specified, the name is everything that follows the
			* folder path
			else {
				local name 	`file'
			}
		}
		* Check that a folder name was specified and through an error if it wasn't
		if ("`file'" == "" | ( "`file'" != "" & "`name'" == "")) {
			noi di as error "{phang}`using' not a valid filename.{p_end}"
			noi di ""
			error 198
			exit
		}

		* The default format is xlsx. Other possible formats are xls
		if "`ext'" == "" {
			local	ext	.xlsx
		}
		else if !inlist("`ext'", ".xls", ".xlsx") {
			noi di ""
			noi di as error `"{phang}`ext' is not currently supported as a format for the duplicates report. Supported formats are: xls, xslx. If you have a suggestion of a different format to support, please e-mail dimeanalytics@worldbank.org or {browse "https://github.com/worldbank/iefieldkit/issues":create an issue on the iefieldkit GitHub repository.}{p_end}"'
			noi di ""
			error 198 //TODO: check error code
			exit
		}
	}

	* Create file name if using was not specified
	else if "`using'" == "" {

								local folder	`folder'/
								local name		iedupreport
		if "`suffix'" != "" 	local name		`name'_`suffix'
								local ext		.xlsx
	}

	* Test that the folder indicated existes
	mata : st_numscalar("r(dirExist)", direxists("`folder'"))

	** If the folder does not exist, throw an error
	if `r(dirExist)' == 0  {

		*Variable exist, output error
		noi di as error "{phang}The folder specified does not exist :`folder'.{p_end}"
		noi di ""
		error 198 // TODO: check error code
		exit
	}

	return local name 	`name'
	return local ext	`ext'
	return local folder	`folder'

end

/*******************************************************************************
	Save daily report
*******************************************************************************/

cap program drop savedaily
	program		 savedaily , rclass

noi {

	syntax , folder(string) name(string) ext(string) today(string)

	*--------------------------------*
	* Calculate name of daily file	 *
	*--------------------------------*
	local using_daily "`folder'Daily/`name'_`today'`ext'"

	*--------------------------------*
	* Check that daily folder exists *
	*--------------------------------*

	* Returns 0 if folder does not exist, 1 if it does
	mata : st_numscalar("r(dirExist)", direxists("`folder'Daily"))

	* If the daily folder is not created, just create it
	if `r(dirExist)' == 0  {

		*Create the folder since it does not exist
		mkdir "`folder'Daily"
	}

	*--------------------------------------------*
	* Check that the daily report does not exist *
	*--------------------------------------------*
	cap confirm file "`using_daily'"

	* If it does exist, check that it's the same as the current one
	if !_rc {

		tempfile daily
		save	 `daily'

		import excel using "`using_daily'", clear firstrow

		cap cf _all using `daily'

		* If it's not the same, save with a timestamp
		if "`r(Nsum)'" != "0" {

			local time			= c(current_time)

			foreach colon in h m {
				noi di `" local time 		= substr("`time'", ":", "`colon'", 1)"'
				local time 		= subinstr("`time'", ":", "`colon'", 1)
			}

			local using_daily "`folder'Daily/`name'_`today'_`time's`ext'"
		}

		use `daily', clear
	}

	*-----------------------*
	* Export the daily file *
	*-----------------------*
	cap export excel using "`using_daily'"	, firstrow(variables) replace nolabel

	*Print error if daily report cannot be saved
	if _rc {

		display as error "{phang}The Daily copy could not be saved to the `folder'Daily folder. Make sure to close any old daily copy or see the option nodaily.{p_end}"
		error 603
		exit
	}

}

end
