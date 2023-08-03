*! version 3.2 31JUL2023  DIME Analytics dimeanalytics@worldbank.org

capture program drop ietestform
		program ietestform , rclass

qui {

	version 13

	preserve

	syntax [using/] ,  Reportsave(string) [Surveyform(string) STATAlanguage(string) date replace]

	/***********************************************
		Test input
	***********************************************/

	/*********
		Test survey file input
	*********/

	*Test and finally combine the using and surveyform for backward compatibility
	if `"`using'"' != "" & `"`surveyform'"'  != "" {
		noi di as error `"{phang}Option surveyform() [`surveyform'] cannot be used together with [using `using']. surveyform() is an undocumneted option allowed for backward compatibility reasons only.{p_end}"'
		error 198
	}
	else if `"`using'`surveyform'"' == "" {
		noi di as error `"{phang}You must specifiy your survey form with [using].{p_end}"'
		error 198
	}
	local surveyform `"`using'`surveyform'"'


	* Test for form file is xls or xlsx
	local surveyformtype = substr(`"`surveyform'"',strlen(`"`surveyform'"')-strpos(strreverse(`"`surveyform'"'),".")+1,.)
	if !(`"`surveyformtype'"' == ".xls" | `"`surveyformtype'"' == ".xlsx") {
		noi di as error `"{phang}The survey form file [`surveyform'] must have file extension .xls or .xlsx specified in the option.{p_end}"'
		error 601
	}

	*Test that the form file exists
	cap confirm file "`surveyform'"
	if _rc {

		noi di as error `"{phang}The SCTO questionnaire form file in surveyform(`surveyform') was not found.{p_end}"'
		error _rc
	}

	/*********
		Test report file input
	*********/

	*********
	*Get the folder for the report file

	**Start by finding the position of the last forward slash. If no forward
	* slash exist, it is zero, then replace to to string len so it is never
	* the min() below.
	local r_f_slash = strpos(strreverse(`"`reportsave'"'),"\")
	if   `r_f_slash' == 0 local r_f_slash = strlen(`"`reportsave'"')

	**Start by finding the position of the last backward slash. If no backward
	* slash exist, it is zero, then replace to to string len so it is never
	* the min() below.
	local r_b_slash = strpos(strreverse(`"`reportsave'"'),"/")
	if   `r_b_slash' == 0 local r_b_slash = strlen(`"`reportsave'"')

	*Get the last slash in the report file path regardless of back or forward
	local r_lastslash = strlen(`"`reportsave'"')-min(`r_f_slash',`r_b_slash')

	*Get the folder
	local r_folder = substr(`"`reportsave'"',1,`r_lastslash')

    *Test that the folder for the report file exists
	mata : st_numscalar("r(dirExist)", direxists("`r_folder'"))
	if `r(dirExist)' == 0  {
		noi di as error `"{phang}The folder used in [`reportsave'] does not exist.{p_end}"'
		error 601
	}

	*Get the filename and the file extension type from the report file
	local r_filename = substr(`"`reportsave'"',`r_lastslash'+1, .)
	local r_filenametype = substr(`"`r_filename'"',strlen(`"`r_filename'"')-strpos(strreverse(`"`r_filename'"'),".")+1,.)
	*Test what the file extension type is
	if (`"`r_filenametype'"' == "") {
		*No file type specified, add .csv
		local reportsave `"`reportsave'.csv"'
	}
	else if (`"`r_filenametype'"' != ".csv") {
		*Incorrect file type added. Throw error
		noi di as error `"{phang}The report  file [`reportsave'] may only have the file extension .csv.{p_end}"'
		error 601
	}
	else {
		* All is correct, do nothing
	}

	*Tempfile that will be used to write the report
	tempfile report_tempfile

	/***********************************************
		Get form meta data and set up report file
	***********************************************/

	*Get meta data on the form from the form setting sheet
	noi importsettingsheet, form("`surveyform'") report_tempfile("`report_tempfile'")



	/***********************************************
		Test the choice sheet independently
	***********************************************/

	noi importchoicesheet, form("`surveyform'") statalanguage(`statalanguage') report_tempfile("`report_tempfile'")

	*Get all choice lists actaually used
	local all_list_names 	`r(all_list_names)'
	* Convert to lower case
	local l_all_list_names = lower("`all_list_names'")
	*Names used in choice sheet, used if outputting unused choice lists
	local choice_listnamevar		`r(listnamevar)'
	local choice_valuevar			`r(valuevar)'
	local choice_labelvars			`r(labelvars)'

	*Create a temp data set that can be reloaded when displaying unused choice lists.
	tempfile choicesheet
	save `choicesheet'

	/***********************************************
		Test the survey sheet independently
	***********************************************/

	noi importsurveysheet, form("`surveyform'") statalanguage(`statalanguage') report_tempfile("`report_tempfile'")

	*Get all choice lists actaually used
	local all_lists_used `r(all_lists_used)'
	* Convert to lowercase
	local l_all_lists_used=lower("`all_lists_used'")
	/***********************************************
		Tests based on info from multiple sheets
	***********************************************/

	/***********************************************
		TEST - No unused lists
		Test that all lists in the choice sheet were
		actually used in the survey sheet
	***********************************************/
	local unused_lists : list l_all_list_names - l_all_lists_used
	if "`unused_lists'" != "" {

		*Reload the data to be able to show the unsused lists
		use `choicesheet', clear

		*Indicate which lists were unused
		gen unused_list = strpos(" " + "`unused_lists'" + " ", " " + list_name + " ") > 0

		*Write error message and list of unused lists to the report
		local error_msg "There are lists in the choice sheet that are not used by any field in the survey sheet. While that is allowed in ODK syntax it is an indication of a typo that might casue errors later. Make sure that the following list items are indeed not supposed to be used:"
		noi report_file add , report_tempfile("`report_tempfile'") testname("UNUSED CHOICE LISTS") message("`error_msg'") wikifragment("Unused_Choice_Lists") table("list row `choice_listnamevar' `choice_valuevar' `choice_labelvars' if unused_list == 1")

	}

	/***********************************************
		Finsish the report and write it to disk
	***********************************************/

	*Option date is used, add today's date to file name
	if "`date'" != ""{
		local date = subinstr(c(current_date)," ","",.)
		local reportsave = subinstr("`reportsave'",".csv","_`date'.csv",.)
	}

	*Write the file to disk
	noi report_file write, report_tempfile("`report_tempfile'") filepath("`reportsave'") `replace'

	restore

}
end

** This program imports the settings sheet and get meta information to be used in report header
capture program drop importsettingsheet
		program 	 importsettingsheet , rclass

qui {

		syntax , form(string) report_tempfile(string)


	*Import the settings sheet - This is the first time the file is imported so add one layer of custom test
	cap import excel "`form'", sheet("settings") clear first
	if _rc == 603 {
		noi di as error  "{phang}The file [`form'] cannot be opened. This error can occur for two reasons: either you have this file open, or it is saved in a version of Excel that is more recent than the version of Stata. If the file is not opened, try saving your file in an earlier version of Excel.{p_end}"
		error 603
	}
	else if _rc != 0 {
		*Run the command without cap and display error message for any other error
		import excel "`form'", sheet("settings") clear first
	}

	*test that the column version exist
	cap confirm variable form_title form_id version
	if _rc != 0 {
		noi di as error  "{phang}The three variables [form_title form_id version] were not found in the settings sheet of the form. Make sure that your form was already tested at SurveyCTO's server. If you are using non-SurveyCTO ODK then the variable [version] is not requried. To make this command work in that case, simply create a new column in the settings sheet, give it the name {it:version} on first row, and the value 1 on the second row.{p_end}"
		confirm variable form_title form_id version
	}



	/***********************************************
		Write header for report
	***********************************************/

	*Get meta data from settings sheet
	local form_title = form_title[1]
	local form_id 	= form_id[1]
	local version 	= version[1]


	*Setup the report tempfile where all results from all tests will be written
	  report_file setup , ///
				report_tempfile("`report_tempfile'") ///
				metav("`version'") ///
				metaid("`form_id'") ///
				metatitle("`form_title'") ///
				metafile("`form'")




	/***********************************************
		TEST - Encryption key not included/errors
	***********************************************/

	*Testing if a variable pulbic_key at all exists
	cap confirm variable public_key
	if _rc {
		local public_key = ""
	}
	*If varialbe exists, convert whatever value (or missing) to string
	else {
		tostring public_key, replace
		local public_key = public_key[1]
	}


	cap assert !missing("`public_key'")

	if _rc {
	    local error_msg "The survey form is not encrypted. It is best practice to encrypt your survey form as it adds a layer of security."

		noi report_file add , ///
			report_tempfile("`report_tempfile'") ///
			testname("ENCRYPTION KEY MISSING") ///
			message("`error_msg'") ///
			wikifragment("Encryption")

	}


}
end


** This program imports the choice sheet and run tests on the information there
capture program drop importchoicesheet
		program 	 importchoicesheet , rclass

qui {

	syntax , form(string) [statalanguage(string) report_tempfile(string)]


	/***********************************************
		Load choices sheet from form
	***********************************************/

	*Import the choices sheet
	cap import excel "`form'", sheet("choices") clear first

	*Test that the choices sheet exists

	if _rc == 601 {
		noi di as error  "{phang}The file [`form'] cannot be opened. This error occurs when your form is missing either the survey or the choices sheet. If the file {p_end}"
		error 601
	}
	else if _rc == 603 {
		noi di as error  "{phang}The file [`form'] cannot be opened. This error can occur for two reasons: either you have this file open, or it is saved in a version of Excel that is more recent than the version of Stata. If the file is not opened, try saving your file in an earlier version of Excel.{p_end}"
		error 603
	}
	else if _rc != 0 {
		*Run the command without cap and display error message for any other error
		import excel "`form'", sheet("choices") clear first
	}


	/***********************************************
		Get info from columns/variables and
		make tests on them
	***********************************************/

	*Create a list of all variables in the choice sheet
	ds
	local choicesheetvars `r(varlist)'

	*Test that either value or name is used for value/name column in the choice sheet, and return the one that is used
	test_colname , var("choice_valuevar") sheetvars(`choicesheetvars') sheetname("choices")
	local  valuevar = "`r(checked_varname)'"

	*Test that either list_name or listname is used for the list name column in the choice sheet, and return the one that is used
	test_colname , var("choice_list_name") sheetvars(`choicesheetvars') sheetname("choices")
	local  listnamevar = "`r(checked_varname)'"

	/***********************************************
		Get info from rows/labels and
		make tests on them
	***********************************************/

	*Drop rows with all values missing
	egen 	countmissing = rownonmiss(_all), strok

	** Generate a variable with row number. This must be done after the egen code
	*  above as the variable row will have value for all rows, and it must be done
	*  before the drop code below as otherwise the row number will not correspond
	*  to the row in the excel file.
	gen row = _n + 1 //Plus 1 as column name is the first row in the Excel file
	order row

	*After the row number has been created to be identical to form file, then drop empty rows
	drop if countmissing == 0

	*Get a list with all the list names
	levelsof `listnamevar', clean local("all_list_names")

	*Create a list of the variables with labels (multiple in case of multiple languages)
	foreach var of local choicesheetvars {
		if substr("`var'", 1, 5) == "label" local labelvars "`labelvars' `var'"
	}
	local num_label_vars : word count `labelvars'

	**Make sure all label vars are strings. Only non-string if all values are
	* digits or all values missing. In both cases these should be changed to
	* string, and if "." change to missing
	foreach labelvar of local labelvars {

		cap confirm string variable `labelvar'
		if _rc {
			tostring `labelvar', replace
			replace `labelvar' = "" if `labelvar' == "."
		}
	}

	*Create dummies for missing status in the label vars
	egen 	label_count_miss	 = rowmiss(`labelvars')
	egen 	label_count_non_miss = rownonmiss(`labelvars'), strok

	gen label_all_miss 		= (label_count_non_miss == 0)
	gen label_some_miss 	= (label_count_miss > 0)
	gen label_all_non_miss 	= (label_count_miss == 0)
	gen label_some_non_miss = (label_count_non_miss > 0)

	/***********************************************
		TEST - List names with leading or trailing
		spaces in columns where that can lead to errors
	***********************************************/

	*Values in these columns can cause errors if they include leading or trailing spaces
	local nospacevars `listnamevar' `labelvars'

	*Keep track if any cases are found
	local cases_found 0

	foreach nospacevar of local nospacevars {
		*Test that the list name does not have leading or trailing spaces
		gen trim_`nospacevar' = (`nospacevar' != trim(`nospacevar'))

		*Add item to report for any row with missing label in the label vars
		count if trim_`nospacevar' == 1
		if `r(N)' > 0 {

			*Write header if this is the first case found
			if `cases_found' == 0 noi report_title , report_tempfile("`report_tempfile'") testname("SPACES BEFORE OR AFTER STRING (choice sheet)")

			*Prepare message and write it
			local error_msg "The string values in [`nospacevar'] column in the choice sheet are imported as strings and has leading or trailing spaces in the Excel file in the following cases:"
			noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'") table("list row `nospacevar' if trim_`nospacevar' == 1")

			*Indicate that a case have been found
			local cases_found 1
		}

		*Remove leading or trailing spaces so they do not cause errors in later tests
		replace `nospacevar' = trim(`nospacevar')
	}

	*If any cases were found, then write link to close this section
	if `cases_found' == 1 noi report_wikilink , report_tempfile("`report_tempfile'") wikifragment("Leading_and_Trailing_Spaces")

	/***********************************************
		TEST - Numeric name
		Test that all variables in the name
		variable are numeric
	***********************************************/

	*Test if variable is numeric
	cap destring `valuevar', replace //destring if import from Excel incorrectly made string
	cap confirm numeric variable `valuevar'

	*Test if error code is 7, other codes should return other error message
	if _rc == 7 {

		*Creates a dummy for all obs where value/name var is not numeric
		gen non_numeric = missing(real(`valuevar'))

		local error_msg "There are non numeric values in the [`valuevar'] column of the choice sheet"

		noi report_file add , report_tempfile("`report_tempfile'") testname("NON NUMERIC NAME VALUES") message("`error_msg'") wikifragment("Value.2FName_Numeric") table("list row `listnamevar' `valuevar' `labelvars' if non_numeric != 0")

	}
	else if _rc != 0 {
		noi di as error "{phang}ERROR IN CODE LOGIC [cap confirm numeric variable `valuevar']{p_end}"
		noi di ""
		error 198
	}


	/***********************************************
		TEST - No duplicates combinations
		Test that all combinations of
		list_name and name is unique
	***********************************************/

	*Test for duplicates and return error if not all combinations are unique
	duplicates tag `listnamevar' `valuevar', gen(list_item_dup)

	*Don't treat missing as duplicates, it will be tested for later.
	replace list_item_dup = 0 if missing(`valuevar')

	*Add item to report if any duplicates were found
	count if list_item_dup != 0
	if `r(N)' > 0 {

		local error_msg "There are duplicates in the following list names in varaible `listnamevar's:"

		noi report_file add , report_tempfile("`report_tempfile'") testname("DUPLICATED LIST CODES") message("`error_msg'") wikifragment("Duplicated_List_Code") table("list row `listnamevar' `valuevar' `labelvars' if list_item_dup != 0")
	}

	/***********************************************
		TEST - Value labels with no values
		Test that all non-missing values in the label
		column have a name/value.
	***********************************************/

	*Test that all rows with a label in any language as a value in the value var
	gen lable_with_missvalue = (missing(`valuevar') & label_some_non_miss == 1)

	*Add item to report for any row with missing value in the value/name var
	count if lable_with_missvalue != 0
	if `r(N)' > 0 {

		local error_msg "There is no value in the [`valuevar'] column for some choice list items that have non-missing values in the [`labelvars'] column(s):"

		noi report_file add , report_tempfile("`report_tempfile'") testname("MISSING LIST VALUE") message("`error_msg'") wikifragment("Missing_Labels_or_Value.2FName_in_Choice_Lists") table("list row `listnamevar' `valuevar' `labelvars' if lable_with_missvalue != 0")
	}

	/***********************************************
		TEST - Unlabelled values
		Test that all values/names have a label
	***********************************************/

	*Test that rows with non-missing value/name values have label in all label languages
	gen unlabelled = (!missing(`valuevar') & label_some_miss == 1)

	*Add item to report for any row with missing label in the label vars
	count if unlabelled != 0
	if `r(N)' > 0 {

		local error_msg "There non-missing values in the [`valuevar'] column of the choice sheet without a label in the [label] colum:"

		noi report_file add , report_tempfile("`report_tempfile'") testname("MISSING LIST LABELS") message("`error_msg'") wikifragment("Missing_Labels_or_Value.2FName_in_Choice_Lists") table("list row `listnamevar' `valuevar' `labelvars' if unlabelled != 0")
	}

	/***********************************************
		TEST - No duplicates labels in list
		Test that there are no duplicate
		labels within a list
	***********************************************/

	*Initialize the dummy that indicate if there are duplicates to 0. This is used to store errors on
	gen label_all_cols_dup = 0

	*Keep track if any cases are found
	local cases_found 0

	** Loop over each label language column
	foreach labelvar of local labelvars {

		*Reset vars and locals used in each label column
		replace label_all_cols_dup = 0
		local lists_with_dups ""

		*Loop over each list name
		foreach list of local all_list_names {

			**Test for duplicates in the label var and display
			* errors if any observation do not have a unique,
			* i.e. label_dup != 0, label
			duplicates tag `labelvar' if `listnamevar' == "`list'", gen(label_dup)

			*Was any duplicates found in this list
			count if label_dup == 1
			if `r(N)' > 0 {
				*Copy duplicate values to main
				replace label_all_cols_dup = 1 if label_dup == 1

				local lists_with_dups =trim("`lists_with_dups' `list'")
			}

			*Drop the tempvar so that it can be generated again by duplicates
			drop label_dup
		}

		**If there are any duplicates in label within a list for this
		* label column, display error and list those cases
		count if label_all_cols_dup == 1
		if `r(N)' > 0 {

			*Write header if this is the first case found
			if `cases_found' == 0 noi report_title , report_tempfile("`report_tempfile'") testname("DUPLICATED LABEL WITHIN LIST")

			*Prepare message and write it
			local error_msg "There are duplicated entries in the [`labelvar'] column of the choice sheet within the [`lists_with_dups'] list(s) for the following labels:"
			noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'") table("list row `listnamevar' `valuevar' `labelvar' if label_all_cols_dup == 1")

			*Indicate that a case have been found
			local cases_found 1
		}
	}

	*If any cases were found, then write link to close this section
	if `cases_found' == 1 noi report_wikilink , report_tempfile("`report_tempfile'") wikifragment("Duplicated_List_Labels")

	/***********************************************
		TEST - Stata language for value labels
		Test that there is one column with labels formatted for stata
	***********************************************/

	*User specified stata label name that is not simply stata
	if "`statalanguage'" != "" {
		local labelstata "label`statalanguage'"
	}
	*Otherwise use the default name
	else {
		local labelstata "labelstata"
	}

	*Test if the Stata language
	if `:list labelstata in choicesheetvars' == 0 {

		*The user specified stata label language name does not exist. Throw error
		if "`statalanguage'" != "" {
			noi di as error "{phang}The label language specified in {inp:statalanguage(`statalanguage')} does not exist in the choice sheet. A column in the choice sheet must have a name that is [label:`statalanguage'].{p_end}"
			noi di ""
			error 198
		}
		*The default stata label language name does not exist. Throw warning (error for now)
		else {

			local error_msg "There is no column in the choice sheet with the name [label:stata]. This is best practice as it allows you to automatically import choice list labels optimized for Stata's value labels, making the data set easier to read."

			noi report_file add , report_tempfile("`report_tempfile'") testname("NO STATA LIST LABEL") message("`error_msg'") wikifragment("Stata_Labels_Columns")

		}
	}

	/***********************************************
		Return values
	***********************************************/

	return local all_list_names				"`all_list_names'"

	return local listnamevar				"`listnamevar'"
	return local valuevar					"`valuevar'"
	return local labelvars					"`labelvars'"

}
end

capture program drop importsurveysheet
		program 	 importsurveysheet , rclass
qui {
	syntax , form(string) [statalanguage(string) report_tempfile(string)]

	*Gen the tempvars needed
	tempvar countmissing

	/***********************************************
		Load survey sheet from file and
		delete empty row
	***********************************************/

	*Import the choices sheet
	cap import excel "`form'", sheet("survey") clear first

	*Test that the survey sheet exists

	if _rc == 601 {
		noi di as error  "{phang}The file [`form'] cannot be opened. This error occurs when your form is missing either the survey or the choices sheet. If the file {p_end}"
		error 601
	}
	else if _rc == 603 {
		noi di as error  "{phang}The file [`form'] cannot be opened. This error can occur for two reasons: either you have this file open, or it is saved in a version of Excel that is more recent than the version of Stata. If the file is not opened, try saving your file in an earlier version of Excel.{p_end}"
		error 603
	}

	*Gen row number that corresponds to the row number in the excel file
	gen row = _n + 1 //Plus 1 as column name is the first row in the Excel file
	order row

	*Drop rows with all values missing
	egen `countmissing' = rownonmiss(_all), strok
	drop if `countmissing' == 0


	/***********************************************
		Get list of variables, do tests on them,
		and creates locals to be used below
	***********************************************/

	*Create a list of all variables in the choice sheet
	ds
	local surveysheetvars `r(varlist)'

	*Create a list of the variables with labels (multiple in case of multiple languages)
	foreach var of local surveysheetvars {
		if substr("`var'", 1, 5) == "label" local labelvars "`labelvars' `var'"
	}

	*Variables that must be included every time
	local name_vars 		"name"
	local cmd_vars  		"type required appearance" // Include as needed eventually. "readonly"
	local msg_vars  		"`labelvars'"
	local code_vars 		" constraint  relevance  calculation repeat_count choice_filter"

	local surveysheetvars_required "`name_vars' `cmd_vars' `msg_vars' `code_vars'"

	*Test that all required vars are actually in the survey sheets
	if `: list surveysheetvars_required in surveysheetvars' == 0 {

		*Generate a list of the vars missing and display error
		local missing_vars : list surveysheetvars_required - surveysheetvars
		noi di as error "{phang}One or several variables required to run all the tests in this command are missing in this form. The following variable(s) are missing [`missing_vars'].{p_end}"
		noi di ""
		error 688
	}

	*Variables that are not required to be included but we recommend considering to do so
	local surveysheetvars_recommended "hint constraintmessage requiredmessage"

	*Test that all recommended vars are in the list and add to report if not
	if `: list surveysheetvars_recommended in surveysheetvars' == 0 {

		*Generate a list of the vars missing and output to repiort
		local missing_vars : list surveysheetvars_recommended - surveysheetvars
		local error_msg "The following column(s) [`missing_vars'] are not required but are often good to include to write a high quality questionnaire. Look them up in SurveyCTO's documentation and consider including them."
		noi report_file add , report_tempfile("`report_tempfile'") testname("MISSING RECOMMENDED COLUMNS") message("`error_msg'") wikifragment("NOT_YET_CREATED")

		*Remove the missing non-required variables fomr the list used when keeping below
		local surveysheetvars_recommended : list surveysheetvars_recommended - missing_vars
	}

	keep `surveysheetvars_required' `surveysheetvars_recommended' row

	*********
	*make command vars that sometimes are not used and then loaded as numeric
	foreach var of local cmd_vars  {

		tostring `var', replace
		replace `var' = lower(itrim(trim(`var')))
		replace `var' = "" if `var' == "."
	}

	*make code vars strings that sometimes are not used and then loaded as numeric
	foreach var of local code_vars  {

		tostring `var', replace
		replace `var' = lower(itrim(trim(`var')))
		replace `var' = "" if `var' == "."
	}


	/***********************************************
		Test that variables that mustn't contain special
		charcters, like UTF-8 chars, do not contain them
	***********************************************/

	local only_simple_char_vars name

	foreach only_simple_char_var of local only_simple_char_vars {

		*Testing that all values in these vars are only a-z, A-Z, 0-9 and _
		noi test_illegal_chars `only_simple_char_var', sheet("survey")
	}



	/***********************************************
		TEST - List names with leading or trailing
		spaces in columns where that can lead to errors
	***********************************************/

	*The type and name variables should not be written with leading or trailing spaces
	local nospacevars type name required

	*Keep track if any cases are found
	local cases_found 0

	foreach nospacevar of local nospacevars {
		*Test that the list name does not have leading or trailing spaces
		gen trim_`nospacevar' = (`nospacevar' != trim(`nospacevar'))

		*Add item to report for any row with missing label in the label vars
		count if trim_`nospacevar' == 1
		if `r(N)' > 0 {

			*Write header if this is the first case found
			if `cases_found' == 0 noi report_title , report_tempfile("`report_tempfile'") testname("SPACES BEFORE OR AFTER STRING (survey sheet)")

			*Prepare message and write it
			local error_msg "The string values in [`nospacevar'] column in the survey sheet are imported as strings and has leading or trailing spaces in the Excel file"
			noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'") table("list row `nospacevar' if trim_`nospacevar' == 1")

			*Indicate that a case have been found
			local cases_found 1
		}

		*Remove leading or trailing spaces so they do not cause errors in later tests
		replace `nospacevar' = trim(`nospacevar')
	}

	*If any cases were found, then write link to close this section
	if `cases_found' == 1 noi report_wikilink , report_tempfile("`report_tempfile'") wikifragment("Leading_and_Trailing_Spaces")



	/***********************************************
		TEST - List names with outdated syntax
	***********************************************/
	*The type and name variables should not be using outdated syntax
	local outdatedsyntaxvars relevance constraint calculation repeat_count choice_filter

	*Keep track if any cases are found
	local cases_found 0

	foreach od_var of local outdatedsyntaxvars {
		*Test that the list name does not have outdated syntax
		gen out_`od_var' = 1 if regexm(`od_var', "position\(|jr:choice-name\(")
		replace out_`od_var' = 0 if missing(out_`od_var')
		*Add item to report for any row with missing label in the label vars
		count if out_`od_var' != 0
		if `r(N)' > 0 {

			*Write header if this is the first case found
			if `cases_found' == 0 noi report_title , report_tempfile("`report_tempfile'") testname("OUTDATED SYNTAX")

			*Prepare message and write it
			local error_msg "The values in [`od_var'] column is using outdated syntax. It is recommended to update the syntax to the new syntax. See wiki page linked to below. These fields were found to have outdated syntax:"
			noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'") table("list row `od_var' if out_`od_var' == 1")

			*Indicate that a case have been found
			local cases_found 1
		}

	}

	*If any cases were found, then write link to close this section
	if `cases_found' == 1 noi report_wikilink , report_tempfile("`report_tempfile'") wikifragment("Outdated_Syntax")


	/***********************************************
		TEST - Type column
		Test for not matching begin/end group/repeat
	***********************************************/

	*Do tests related to the type column
	noi test_survey_type, report_tempfile("`report_tempfile'")

	*Ruturn the list of used choice lists to be compared with list of all lists
	return local all_lists_used				"`r(all_lists_used)'"

	/***********************************************
		Test name column
	***********************************************/

	noi test_survey_name, report_tempfile("`report_tempfile'")

	/***********************************************
		Test label column
	***********************************************/

	noi test_survey_label, surveysheetvars(`surveysheetvars_required') statalanguage(`statalanguage') report_tempfile("`report_tempfile'")


	/***********************************************
		TEST - require column
	***********************************************/

	*Create a dummy that is 1 for fields that the required column test is applicable to
	gen req_relevant = !(typeBeginEnd == 1 | /// begin_group, begin_repeat, end_group, end_repeat does not need to be required
		inlist(type, "calculate", "calculate_here") | /// calculate fields does not need to be required
		inlist(type, "audio_audit", "text_audit") | /// quality control meta fields does not need to be reqired
		inlist(type, "start", "end", "deviceid", "subscriberid", "simserial", "phonenumber", "username", "caseid") | /// Default meta types doen not need to be required
		missing(type)) /// Rows that are not fields shold be skipped

	*List and output non-note, non-label fields that are not required
	gen nonnote_nonrequired = (req_relevant == 1 & type != "note" & appearance != "label" & lower(required) != "yes")
	count if nonnote_nonrequired == 1
	if `r(N)' > 0 {

		*Prepare message and write it
		local error_msg "Fields of types other than note should all be required so that it cannot be skipped during the interview. The following fields are not required and could therfore be skipped by the enumerator:"
		noi report_file add , report_tempfile("`report_tempfile'") wikifragment("Required_Column") message("`error_msg'")  table("list row type name if nonnote_nonrequired == 1") testname("NON-REQUIRED NON-NOTE TYPE FIELD")
	}

	*List and output note fields that are required
	gen note_required 		= (req_relevant == 1 & type == "note" & lower(required) == "yes")
	count if note_required == 1
	if `r(N)' > 0 {

		*Prepare message and write it
		local error_msg "Fields of type note creates an impassable view that are impossible for the enumerator to sweep pass. Make sure that is the inentional behavior for the following fields:"
		noi report_file add , report_tempfile("`report_tempfile'") wikifragment("Required_Column") message("`error_msg'")  table("list row type name if note_required == 1") testname("REQUIRED NOTE TYPE FIELD")
	}

	*List and output required label fields in field-list groups
	gen label_required 		= (req_relevant == 1 & appearance == "label" & lower(required) == "yes")
	count if label_required == 1
	if `r(N)' > 0 {

		*Prepare message and write it
		local error_msg "Fields with appearance [label] (inside a field-list group) must not be required. Label fields are currently required in the following rows:"
		noi report_file add , report_tempfile("`report_tempfile'") wikifragment("Required_Column") message("`error_msg'")  table("list row type name if label_required == 1") testname("REQUIRED LABEL FIELD")
	}

}
end

capture program drop test_survey_type
		program 	 test_survey_type , rclass
qui {

	//noi di "test_survey_type command ok"
	syntax ,  [report_tempfile(string)]
	//noi di "test_survey_type syntax ok"

	/***********************************************
		Standardizing name of type values
	***********************************************/

	replace type = "begin_group" 	if type == "begin group"
	replace type = "begin_repeat" 	if type == "begin repeat"
	replace type = "end_group" 		if type == "end group"
	replace type = "end_repeat" 	if type == "end repeat"

	replace type = "text_audit" 	if type == "text audit"
	replace type = "audio_audit" 	if type == "audio audit"


	/***********************************************
		Test end and begin
	***********************************************/

	*********
	*Short hand for begin_ or end_
	gen typeBegin 		= (type == "begin_group" 	| type == "begin_repeat")
	gen typeEnd 		= (type == "end_group" 		| type == "end_repeat")

	gen typeBeginEnd 	= (typeBegin | typeEnd)

	local begin_end_error = 0


	*********

	**********************
	* Test if any end_repeat or end_group has no name (begin are tested by server). This is not incorrect, but bad practice as it makes bug finding much more difficult.

	gen end_has_no_name = (typeEnd == 1 & missing(name))
	count if end_has_no_name != 0
	if `r(N)' > 0 {

		*Prepare message and write it
		local error_msg "It is bad practice to leave the name column empty for end_group or end_repeat fields. While this is allowed in ODK, it makes error finding harder and slower. The following repeat or end groups have empty name columns:"
		noi report_file add , report_tempfile("`report_tempfile'") wikifragment("Matching_begin_.2Fend") message("`error_msg'")  table("list row type name if end_has_no_name == 1") testname("MISSING END_GROUP/END_REPEAT NAME")

	}


	**********************
	*Loop over all rows to test if begin and end match NAME prefectly

	*Keep track if any cases are found
	local cases_found 0

	*Loop over all rows
	local num_rows = _N
	forvalues row = 1/`num_rows' {

		*This only applies to rows that end or begin a group or a repeat
		if typeBeginEnd[`row'] == 1 {

			* Get type and name for this row
			local row_type = type[`row']
			local row_name = name[`row']
			local isBegin = typeBegin[`row']

			*Add begin group to stack if either begin_group or begin_repeat
			if `isBegin' {

				local begintype = substr("`row_type'", 7,.)
				local type_and_name "`begintype'#`row_name'#`row' `type_and_name'"

			}

			*If end_group or end_repeat, test that the corresponding group or repeat group was the most recent begin, otherwise throw an error.
			else {

				*Get the type and name of the end_group or end_repeat of this row
				local endtype = substr("`row_type'", 5,6) //Remove the "end_" part of the type
				local endname = "`row_name'"
				local endrow  = `row' + 1 //First row in Excel is column name

				*Get the type and name of the most recent begin_group or begin_repeat
				local lastbegin : word 1 of `type_and_name'			//the most recent is the first in the list


				*Parse the begintype and reomve parse charecter from rest
				gettoken begintype beginnameandrow : lastbegin , parse("#")
				local beginnameandrow = subinstr("`beginnameandrow'","#","", 1)	//Remove the parse char "#"

				*Parse name and row and remove parse charcter from row
				gettoken beginname beginrow : beginnameandrow , parse("#")
				local beginrow = subinstr("`beginrow'","#","", 1)	//Remove the parse char "#"

				*If the name are not the same it is most likely a different group or repeat group that is incorrectly being closed
				if "`endname'" != "`beginname'" & !missing("`endname'") {

					local error_msg "begin_`begintype' [`beginname'] on row `beginrow' and end_`endtype' [`endname'] on row `endrow'"

					*Write header and intro if this is the first case
					if `cases_found' == 0 {

						*Create title
						noi report_title , report_tempfile("`report_tempfile'") testname("END/BEGIN NAME MISMATCH")

						*Display introduction
						local intro_msg "The name in the end group/repeat does not match the name in the most recent begin group/repeat. This does not cause an error in ODK, but is recommended to solve programming errors with missmatching group/repeats fields. These cases were found:"
						noi report_file add , report_tempfile("`report_tempfile'")  message("`intro_msg'")

						*Display error for the first case
						noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'")

						*Indicate that a case have been found
						local cases_found 1
					}
					else {
						*Display error for all other cases but the first
						noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'") remove_space_before
					}

				}

				*Name and type are the same, this is a correct ending of the group or repeat group
				else {
					* The begin_group or begin_repeat is no longer the most recent, so remove it from the string
					local type_and_name = trim(substr("`type_and_name'", strlen("`lastbegin'")+1, .))
				}
			}
		}
	}

	*If any cases were found, then write link to close this section
	if `cases_found' == 1 noi report_wikilink , report_tempfile("`report_tempfile'") wikifragment("Matching_begin_.2Fend")


	**********************
	*Loop over all rows to test if begin and end match TYPE prefectly

	*Keep track if any cases are found
	local cases_found 0

	*Loop over all rows
	local num_rows = _N
	forvalues row = 1/`num_rows' {

		*This only applies to rows that end or begin a group or a repeat
		if typeBeginEnd[`row'] == 1 {

			* Get type and name for this row
			local row_type = type[`row']
			local row_name = name[`row']
			local isBegin = typeBegin[`row']

			*Add begin group to stack if either begin_group or begin_repeat
			if `isBegin' {

				local begintype = substr("`row_type'", 7,.)
				local type_and_name "`begintype'#`row_name'#`row' `type_and_name'"

			}

			*If end_group or end_repeat, test that the corresponding group or repeat group was the most recent begin, otherwise throw an error.
			else {

				*Get the type and name of the end_group or end_repeat of this row
				local endtype = substr("`row_type'", 5,6) //Remove the "end_" part of the type
				local endname = "`row_name'"
				local endrow  = `row' + 1 //First row in Excel is column name

				*Get the type and name of the most recent begin_group or begin_repeat
				local lastbegin : word 1 of `type_and_name'			//the most recent is the first in the list


				*Parse the begintype and reomve parse charecter from rest
				gettoken begintype beginnameandrow : lastbegin , parse("#")
				local beginnameandrow = subinstr("`beginnameandrow'","#","", 1)	//Remove the parse char "#"

				*Parse name and row and remove parse charcter from row
				gettoken beginname beginrow : beginnameandrow , parse("#")
				local beginrow = subinstr("`beginrow'","#","", 1)	//Remove the parse char "#"

				* If name are the same but types are differnt, then it is most likely a typo in type
				if "`endtype'" != "`begintype'" {

					*Prepare error message from this case.
					local error_msg "begin_`begintype' [`beginname'] on row `beginrow' and end_`endtype' [`endname'] on row `endrow'"

					*Write header and intro if this is the first case
					if `cases_found' == 0 {

						*Create test title
						noi report_title , report_tempfile("`report_tempfile'") testname("END/BEGIN TYPE MISMATCH")

						*Display introduction
						local intro_msg "The type in the end group/repeat does not match the type in the most recent begin group/repeat. This is an error in ODK, and is caught by SurveyCTO's server, but here row numbers are listed so it is easier to solve. These cases were found:"
						noi report_file add , report_tempfile("`report_tempfile'")  message("`intro_msg'")

						*Display error for the first case
						noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'")

						*Indicate that a case have been found
						local cases_found 1
					}
					else {
						*Display error for all other cases but the first
						noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'") remove_space_before
					}
				}

				*Name and type are the same, this is a correct ending of the group or repeat group
				else {
					* The begin_group or begin_repeat is no longer the most recent, so remove it from the string
					local type_and_name = trim(substr("`type_and_name'", strlen("`lastbegin'")+1, .))
				}
			}
		}
	}

	*If any cases were found, then write link to close this section
	if `cases_found' == 1 noi report_wikilink , report_tempfile("`report_tempfile'") wikifragment("Matching_begin_.2Fend")


	/***********************************************
		Parse select_one, select_multiple values
	***********************************************/

	*********
	*seperate choices lists from the select_one or select_many word
	split type, gen(type)
	*Makse sure that 3 variables were created even if not
	forvalues i = 1/3 {
		cap gen type`i' = ""
	}

	*Order new vars after original var, drop original var, and then give them descriptive nams
	order type?, after(type)
	drop type
	rename type1 type				//This stores field type, i.e. text, number, select_one, calculate, begin_group etc.
	rename type2 choiceList			//If select_one or select_multiple this stores the choice list used
	rename type3 choiceListOther	//If built in other option is used, it ends up here

	*Get a list with all the list names
	levelsof choiceList, clean local("all_lists_used")

	/***********************************************
		Return values
	***********************************************/

	return local all_lists_used				"`all_lists_used'"
}
end

capture program drop test_survey_name
		program 	 test_survey_name , rclass
qui {

	//noi di "test_survey_name command ok"
	syntax ,  [report_tempfile(string)]
	//noi di "test_survey_name syntax ok"

	/***********************************************
		Gen value needed in tests
	***********************************************/

	gen namelen = strlen(name)
	order namelen, after(name) //jsut to make dev easier

	//Generate a variable that indicates if a variable will be a variable or not
	gen will_be_field = !((inlist(type, "start", "end" )) | (typeBeginEnd == 1))

	/***********************************************
		Create vars that require going over
		all loops
	***********************************************/

	gen num_nested_repeats = 0

	*Loop over all rows
	local num_rows = _N

	forvalues row = 1/`num_rows' {

		if `row' > 1 {

			local lastrow = `row' -1

			if type[`row'] == "begin_repeat" {
				replace num_nested_repeats = num_nested_repeats[`lastrow'] + 1 if _n == `row'
			}
			else if type[`row'] == "end_repeat" {
				replace num_nested_repeats = num_nested_repeats[`lastrow'] - 1 if _n == `row'
			}
			else {
				replace num_nested_repeats = num_nested_repeats[`lastrow'] if _n == `row'
			}
		}
	}

	/***********************************************
		TEST - Long variable names
	***********************************************/

	gen namelen_repeat1 = namelen + num_nested_repeats * 2 //Adding "_1" for each loop
	gen namelen_repeat2 = namelen + num_nested_repeats * 3 //Adding "_10" for each loop

	*Names that are always too long
	gen longname    = (namelen > 32)
    gen longname1   = (namelen_repeat1 > 32 & longname 	== 0) 	//if longname is 1, then this test is redundant
    gen longname2   = (namelen_repeat2 > 32 & longname1 == 0) 	//if longname1 is 1, then this test is redundant

	cap assert longname == 0
	if _rc {

		local error_msg "These variable names are longer then 32 characters. That is allowed in the data formats used in SurveyCTO - and is therefore allowed in their test - but will cause an error when the data is imported to Stata. The following names should be shortened:"

		noi report_file add , report_tempfile("`report_tempfile'") testname("TOO LONG FIELD NAMES")  message("`error_msg'") wikifragment("Field_Name_Length") table("list row type name if longname == 1")

	}

	cap assert longname1 == 0
	if _rc {

		local error_msg "These variable are inside one or several repeat groups. When this data is imported to Stata it will add [_x] to the variable name for each repeat group this variable is in, where [x] is the repeat count for that repeat. This test assumed that the repeat count is less than 9 so that only two characters ([_x]) are needed. The following variables's name will be longer then 32 characters if two characters are added per repeat group and should therefore be shortened:"

		noi report_file add , report_tempfile("`report_tempfile'") testname("TOO LONG FIELD NAMES WITH REPEAT SUFFIX") message("`error_msg'") wikifragment("Repeat_Group_Field_Name_Length") table("list row type name num_nested_repeats if longname1 == 1")

	}

	cap assert longname2 == 0
	if _rc {

		local error_msg "These variable are inside one or several repeat groups. When this data is imported to Stata it will add [_xx] to the variable name for each repeat group this variable is in, where [xx] is the repeat count for that repeat. This test assumed that the repeat count is between 10 and 99 so that up to three characters [_xx] are needed. The following variables are are longer then 32 characters if two characters will be added per repeat group and should therefore be shortened:"

		noi report_file add , report_tempfile("`report_tempfile'") testname("TOO LONG FIELD NAMES WITH REPEAT SUFFIX (double digit)") message("`error_msg'") wikifragment("Repeat_Group_Field_Name_Length") table("list row type name num_nested_repeats if longname2 == 1")

	}

	/***********************************************
		TEST - Name conflict after long to wide
	***********************************************/

	*Keep track if any cases are found
	local cases_found 0

	**List all field names and test if there is a risk that any fieldnames
	* have name conlicts when repeat field goes from long to wide and
	* number are suffixed to the end.
	qui levelsof name if will_be_field == 1 , local(listofnames) clean
	noi wide_name_conflicts, fieldnames("`listofnames'")

	*Get any conflicts
	local conflicts "`r(conflicts)'"

	*Loop over all identified conflicts. This is skipped if there are none
	while ("`conflicts'" != "") {

		*Get the next conflict
		gettoken two_fields conflicts : conflicts

		*Get the two field names from this conflict
		gettoken field fieldFound : two_fields, parse("@")
		local fieldFound = subinstr("`fieldFound'", "@", "", .)

		*Get name and row num from field
		gettoken fieldName fieldRow : field, parse("#")
		local fieldRow = subinstr("`fieldRow'", "#", "", .)

		*Get name and row num from fieldFound
		gettoken fieldFoundName fieldFoundRow : fieldFound, parse("#")
		local fieldFoundRow = subinstr("`fieldFoundRow'", "#", "", .)


		*Prepare the error message for this case
		local error_msg "Repeat field [`fieldName'] on row `fieldRow' and field [`fieldFoundName'] on row `fieldFoundRow'"

		*Write header and intro if this is the first case
		if `cases_found' == 0 {

			noi report_title , report_tempfile("`report_tempfile'") testname("NAME CONFLICT ACROSS REPEAT GROUP")

			*Display introduction
			local intro_msg "There is a potential name conflict between field a field inside a repeat group with a field outside the repeat group. When variables in repeat groups are imported to Stata they will be given the suffix fieldname_1, fieldname_2 etc. for each repeat in the repeat group. It is therefore bad practice to have a field name that share the name as a field in a repeat group followed by an underscore and a number, no matter how big the number is. The potential conflicts are:"
			noi report_file add , report_tempfile("`report_tempfile'")  message("`intro_msg'")

			*Display error for the first case
			noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'")

			*Indicate that a case have been found
			local cases_found 1
		}
		else {
			*Display error for all other cases but the first
			noi report_file add , report_tempfile("`report_tempfile'")  message("`error_msg'") remove_space_before
		}
	}

	*If any cases were found, then write link to close this section
	if `cases_found' == 1 noi report_wikilink , report_tempfile("`report_tempfile'") wikifragment("Repeat_Group_Name_Conflict")

}
end

capture program drop wide_name_conflicts
	program wide_name_conflicts , rclass
qui {
		syntax , fieldnames(string)

		//Loop over all field names
		foreach field of local fieldnames {

			**The regular expression starts with the field
			* name, this is modified in each loop
			local regexpress "`field'"

			**Names are unique so this is to get the number of nested repeat
			* groups deep this field is. If it is zero the name loop below is
			* skipped as this only relates to field inside loops
			sum num_nested_repeats if name == "`field'"
			local numNestThisField = `r(mean)'

			**Loop over each level of nesting and add the _# regular
			* expression for each level of nesting
			forvalues nest = 1/`numNestThisField' {

				*Add one more level of _# to the regular expresison
				local regexpress "`regexpress'_[0-9]+"

				*Start the recursive regression that looks for potential conflicts
				noi wide_name_conflicts_rec, field("`field'") fieldnames("`fieldnames'") regexpress("`regexpress'")

				*Concatenate any conflicts found
				local conflicts "`conflicts' `r(conflicts)'"
			}
		}

		*Return cases found
		return local conflicts	=trim(itrim("`conflicts'"))
}
end

capture program drop wide_name_conflicts_rec
	program wide_name_conflicts_rec , rclass
	qui {
		syntax , field(string) fieldnames(string) regexpress(string)

		*Is there at least one match to the regular expression
		local isFieldFound 	= regexm("`fieldnames'" ," `regexpress' ")

		*If there is a match, write error and test if there are more matches
		if `isFieldFound'  == 1 {

			*Get the name of the matched field
			local fieldFound	= trim(regexs(0))

			**Prepare the string to recurse on. Remove eveything up to the matched
			* field [strpos("`fieldnames'","`fieldFound'")] and the field
			* itself [strlen("`fieldFound'")] and use only everything after
			* that [substr("`fieldnames'",`stringCut', .)]
			local stringCut = strpos("`fieldnames'","`fieldFound'") + strlen("`fieldFound'")
			local newFieldnames = substr("`fieldnames'",`stringCut', .)

			*Make the recursive call
			noi wide_name_conflicts_rec, field("`field'") fieldnames("`newFieldnames'") regexpress("`regexpress'")

			*Get row for the main field
			sum row if name == "`field'"
			local fieldRow `r(mean)'

			*Get row for the field found
			sum row if name == "`fieldFound'"
			local fieldFoundRow `r(mean)'

			*Return cases found
			return local conflicts	"`field'#`fieldRow'@`fieldFound'#`fieldFoundRow' `r(conflicts)'"
		}
	}
end


capture program drop test_survey_label
		program 	 test_survey_label , rclass
qui {

		syntax , surveysheetvars(varlist) [statalanguage(string) report_tempfile(string)]

		/***********************************************
			TEST - Stata language for variable labels
			Test that there is one column with variable
			labels formatted for stata.
		***********************************************/

		*User specified stata label name thar is not simply stata
		if "`statalanguage'" != "" {
			local labelstata "label`statalanguage'"
		}
		*Otherwise use the default name
		else {
			local labelstata "labelstata"
		}

		*Test if the Stata language column exists
		if `:list labelstata in surveysheetvars' == 0 {

			*The user specified stata label language name does not exist. Throw error
			if "`statalanguage'" != "" {

				noi di as error "{phang}The label langauge specified in {inp:statalanguage(`statalanguage')} does not exist in the survey sheet. A column in the survey sheet must have a name that is [label:`statalanguage'].{p_end}"
				noi di ""
				error 198

			}
			*The default stata label language name does not exist. Throw warning (error for now)
			else {

				local error_msg "There is no column in the survey sheet with the name [label:stata]. This is best practice as this allows you to automatically import variable labels optimized for Stata, making the data set easier to read."

				noi report_file add , report_tempfile("`report_tempfile'") testname("NO STATA FIELD LABEL") message("`error_msg'") wikifragment("Stata_Labels_Columns")

			}
		}
		else {

		/***********************************************
			TEST - Long variable labels
			Test that variable labels are no longer than
			80 characters
		***********************************************/

			*Test the length of the Stata label
			gen labellength = strlen(`labelstata')

			*Names that are always too long
			gen longlabel	= (labellength > 80 & type != "note")

			*Report if a label is too long and will be truncated
			cap assert longlabel == 0
			if _rc {

				local error_msg "These stata labels are longer then 80 characters which means that Stata will cut them off. The point of having a Stata label variable is to manually make sure that the labels documenting the variables in the data set makes sense to a human reader. The following labels should be shortened:"

				noi report_file add , report_tempfile("`report_tempfile'") testname("TOO LONG FIELD LABEL") message("`error_msg'") wikifragment("Survey_Sheet_Stata_Labels") table("list row type name labellength `labelstata' if longlabel == 1")

			}
		}
}
end

*Program that test that exactly one of multiple allowed column names was used. Returns valid used name.
capture program drop test_colname
		program 	 test_colname , rclass

qui {

	syntax , var(string) sheetvars(string) sheetname(string)

	*Load the allowed names for each column:
	if "`var'" == "choice_valuevar" local allowed_names value name
	if "`var'" == "choice_list_name" local allowed_names listname list_name

	*Initate a local that keep track of whether a column with an allowed name was found
	local correct_found = 0

	foreach allowed_name of local allowed_names {

		*Test if name exists
		if `:list posof "`allowed_name'" in sheetvars' != 0 {

			*Test that this is the first name that was found
			if `correct_found' == 1 {
				noi di as error "{phang}The `sheetname' sheet of may only include one of the following columns: [`allowed_names'].{p_end}"
				error 688
			}

			*If the first name found, return it
			return local checked_varname "`allowed_name'"
			local correct_found = 1
    	}
	}

	*No allowed name found for this required variable
	if `correct_found' == 0 {
		noi di as error "{phang}The `sheetname' sheet of must include one column named one of these names: [`allowed_names'].{p_end}"
		error 688
	}
}
end

*Program that test if column has illegal chars that will cause this command to
capture program drop test_illegal_chars
		program 	 test_illegal_chars , rclass
qui {

		syntax varname, sheet(string)

		**Test if three are any illegal characters in varname. This is done by removing all
		* legal characters and test if the trimmed result is the empty string.
		tempvar  illegal_char
		gen		`illegal_char' = (trim(regexr(`varlist',"[a-zA-Z0-9_/-]*","")) != "")

		*Test if any observation had illegal characters. If so display those cases and an error message.
		cap assert `illegal_char' == 0
		if _rc {
			noi di as error "{phang}The following values in column `varlist' in the `sheet' sheet contains non-standard characters or have a space in the middle. The only characters allowed are a-z, A-Z, 0-9 and _ (underscore). The value has been cleaned from regular spaces before and after the value, but Excel allows for different types of spaces. SurveyCTO's server is able to remove them, but these characters must be removed for this command to work properly. These characters are sometimes the result of copying and pasting text from other resources, so one way to make sure they are not included is to go to the cell with the value in Excel and manually re-enter the text.{p_end}"
			noi list row `varlist' if `illegal_char' == 1
			error 688
		}
}
end


capture program drop report_file
		program 	 report_file , rclass
qui {

		//noi di "report_file command ok"
		syntax anything , report_tempfile(string) [testname(string) message(string) filepath(string) wikifragment(string) table(string) metav(string) metaid(string) metatitle(string) metafile(string) remove_space_before replace]
		//noi di "report_file syntax ok [`anything']"

		local allowed_tasks		"setup add write"

		*Get task subcommand
		gettoken task anything : anything

		*test that task is allowed
		if `:list task in allowed_tasks' == 0 {
			noi di as error "{phang}In command report_file task [`task'] is not in allowed_tasks [`allowed_tasks'].{p_end}"
			error 198
		}

		*test that only one word is used for task
		if "`anything'" != "" {
			noi di as error "{phang}In command report_file multiple words used for tasks.{p_end}"
			error 198
		}

		*No matter task you need a handler
		tempname report_handler

		*Setup files
		if "`task'" == "setup" {

			local user = c(username)
			local date = subinstr(c(current_date)," ","",.)

			*Write the title rows defined above
			cap file close 	`report_handler'
			file open  		`report_handler' using "`report_tempfile'", text write replace
			file write  	`report_handler' ///
				_n ///
				"This report was created by user `user' on `date' using the Stata command ietestform" _n ///
				_n ///
				"Use either of these links to read more about this command:" _n ///
				",https://github.com/worldbank/iefieldkit" _n ",https://dimewiki.worldbank.org/wiki/Ietestform" _n _n ///
				",Form ID,`metaid'" _n ",Form Title,`metatitle'" _n ",Form Version,`metav'" _n ",Form File,`metafile'" _n _n

			file close 		`report_handler'
		}

		*Add item to report
		else if "`task'" == "add" {

			*Add table if applicable
			if "`testname'" != "" noi report_title , report_tempfile("`report_tempfile'") testname("`testname'")

			*Chop the message up in charwidth
			noi report_message , report_tempfile("`report_tempfile'") message("`message'") charwidth(100) `remove_space_before'

			*Add table if applicable
			if "`table'" != "" noi report_table `table' , report_tempfile("`report_tempfile'")

			*Add table if applicable
			if "`wikifragment'" != "" noi report_wikilink , report_tempfile("`report_tempfile'") wikifragment("`wikifragment'")

		}

		*Write final file to disk
		else if "`task'" == "write" {

			*Write and save report
			cap file close 	`report_handler'
			file open  		`report_handler' using "`report_tempfile'", text write append
			file write  	`report_handler' ///
				"----------------------------------------------------------------------" _n ///
				"----------------------------------------------------------------------" _n ///
				_n ///
				"This is the end of the report." _n
			file close 		`report_handler'

			*Write temporary file to disk
			cap copy "`report_tempfile'" "`filepath'",  `replace'

			if _rc == 608 {
				noi di as error "{phang}The file `filepath' cannot be overwritten. If you have this file open, close it and run the command again.{p_end}"
				error 608
			}
			else if _rc == 602 {
				noi di as error "{phang}The file `filepath' already exists. Either use a different name in {cmd:report()} or use the {cmd:replace} option if you want to overwrite the file.{p_end}"
				error 602
			}
			else if !_rc {
				noi di as result `"{phang}Report saved to: {browse "`filepath'":`filepath'} "'
			}
			else {
				*Something did not work, run the command again to get full error message and return error code
				copy "`report_tempfile'" "`filepath'", `replace'
			}
		}

		*Just for programming purposes, should never show
		else {
			noi di as error "Task error"
			error 198
		}
}
end

*Write the title of each test section
capture program drop report_title
		program 	 report_title , rclass

	qui {

		syntax, report_tempfile(string) testname(string)

			tempname report_handler
			*Add seperator and error message
			cap file close 	`report_handler'
			file open  		`report_handler' using "`report_tempfile'", text write append
			file write  	`report_handler' ///
				"----------------------------------------------------------------------" _n ///
				"----------------------------------------------------------------------" _n ///
				"TEST: `testname'" _n ///
				"----------------------------------------------------------------------" _n
			file close 		`report_handler'
	}
end

*Write the ending of each test section
capture program drop report_wikilink
		program 	 report_wikilink , rclass

	qui {

		syntax, report_tempfile(string) wikifragment(string)

			tempname report_handler
			*Add link to wiki at the bottom
			cap file close 	`report_handler'
			file open  		`report_handler' using "`report_tempfile'", text write append
			file write  	`report_handler' _n _n ///
				"Read more about this test and why this is an error or does not follow the best practices we recommend here:" _n ///
				"https://dimewiki.worldbank.org/wiki/Ietestform#`wikifragment'" _n _n
			file close 		`report_handler'
	}
end



capture program drop report_table
		program 	 report_table , rclass
qui {


	//noi di "report_table command ok"
	syntax anything [if], report_tempfile(string) [options(string)]
	//noi di "report_table syntax ok [`anything']"

	preserve

		tempname report_handler

		local allowed_cmds		"list"

		*Get task subcommand
		gettoken command varlist : anything

		*test that task is allowed
		if `:list command in allowed_cmds' == 0 {
			noi di as error "{phang}In command report_file tasks [`command'] is not in allowed_tasks [`allowed_cmds'].{p_end}"
			error 198
		}

		*apply if condition if applicable
		if "`if'" != "" keep `if'

		if "`command'" == "list" {

			local rows = _N
			keep `varlist'


			*Prepare title row and name it tablestr0
			foreach var of local varlist {
				local title `"`title',"`var'" "'

				cap confirm string variable `var'
				if _rc == 0 {
					replace `var' = subinstr(`var', char(34), "", .) //remove " sign
					replace `var' = subinstr(`var', char(96), "", .) //remove ` sign
					replace `var' = subinstr(`var', char(36), "", .) //remove $ sign
					replace `var' = subinstr(`var', char(10), "", .) //remove line end
				}
			}

			*Write and save report
			cap file close 	`report_handler'
			file open  		`report_handler' using "`report_tempfile'", text write append
			file write  	`report_handler' _n `"`title'"' _n
			file close 		`report_handler'

			*Loop over all cases and prepare tablestrs and numbe rthem
			forvalue row = 1/`rows' {

				local row_str ""

				*loop over each var and prepare the row
				foreach var of local varlist {
					local cell_value = `var'[`row']
					local row_str `"`row_str',"`cell_value'""'
				}

				*Write and save report
				cap file close 	`report_handler'
				file open  		`report_handler' using "`report_tempfile'", text write append
				file write  	`report_handler' `"`row_str'"' _n
				file close 		`report_handler'
			}

		}

	restore
}

end


*Chops up messages in appropriate lengths, and make sure that the cutoff is always a space
capture program drop report_message
		program 	 report_message , rclass
qui {

	syntax , report_tempfile(string) message(string) charwidth(numlist) [remove_space_before]

	tempname report_handler

	if "`remove_space_before'" == "" {
		*Create one empty row above
		cap file close 	`report_handler'
		file open  		`report_handler' using "`report_tempfile'", text write append
		file write  	`report_handler' _n
		file close 		`report_handler'
	}

	*Loop over message and chop up in segments
	while "`message'" != "" {

		*Reste num_char in row to maximum
		local num_char 	= `charwidth'

		*If remaining part of message is less than maximum, then move to next step
		if (strlen("`message'")>`num_char' ) {

			*Find longest string possbile chopped of at appropriate spot (a space). Start with max lenght
			local ok_end 	= 0
			while `ok_end' != 1 {

				*Test if this length ends ond a space
				if (substr("`message'",`num_char',1) == " ") {
					*It ends on space, this length ends on space
					local ok_end 	= 1
				}
				else {
					*This lenght does not end on a space, make lenght 1 shorted and test again
					local --num_char
				}
			}
		}

		*Use the valid lenghts to cut out this string
		local this_row	= substr("`message'",1,`num_char')

		*Write that line of the message
		cap file close 	`report_handler'
		file open  		`report_handler' using "`report_tempfile'", text write append
		file write  	`report_handler' `""`this_row'""' _n
		file close 		`report_handler'

		*Remove the string we cut out from message, and repeat until all of message is used.
		local message	= substr("`message'",`num_char'+1,.)
	}
}

end
