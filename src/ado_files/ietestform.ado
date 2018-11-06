*! version 0.1 15DEC2017  DIME Analytics dimeanalytics@worldbank.org

capture program drop ietestform
		program ietestform , rclass

	syntax , surveyform(string) [csheetaliases(string) statalanguage(string)]

	
	/***********************************************
		Test the choice sheet inpependently
	***********************************************/		
	importchoicesheet, form("`surveyform'") statalanguage(`statalanguage')
	
	*Get all choice lists actaually used
	local all_list_names `r(all_list_names)'
	
	
	/***********************************************
		Test the survey sheet inpependently
	***********************************************/	
	importsurveysheet, form("`surveyform'") statalanguage(`statalanguage')
	
	*Get all choice lists actaually used
	local all_lists_used `r(all_lists_used)'
	

	/***********************************************
		Tests based on info from multiple sheets
	***********************************************/		
	
	*Test that all lists in the choice sheet was actually used in the survey sheet
	local unused_lists : list all_list_names - all_lists_used
	if "`unused_lists'" != "" {
		noi di as error "{phang}There are lists in the choices sheets that are not used in any field in the survey sheet. These are the unused list(s): [{inp:`unused_lists'}].{p_end}"
		//error 688
		noi di ""
		noi di "end of error"
		noi di ""
	}

end

capture program drop importchoicesheet
		program 	 importchoicesheet , rclass
qui {
	//noi di "importchoicesheet command ok"
	syntax , form(string) [statalanguage(string)]
	//noi di "importchoicesheet syntax ok"

	*Gen the tempvars needed
	tempvar countmissing item_dup label_dup label_dup_all

	/***********************************************
		Load choices sheet from form
	***********************************************/		
	
	*Import the choices sheet
	import excel "`form'", sheet("choices") clear first

	
	/***********************************************
		Get info from columns/variables and 
		make tests on them
	***********************************************/			
	
	*Create a list of all variables in the choice sheet
	ds
	local choicesheetvars `r(varlist)'
	
	*Test if old name "name" is used for value column
	if `:list posof "name" in choicesheetvars' ! = 0 {
		local valuevar "name"
	}
	*Test if new name "value" is used for value column
	else if `:list posof "value" in choicesheetvars' ! = 0 {
		local valuevar "value"
	}
	*Neither "name" or "value" is a name of a column, one must be used
	else {
		noi di as error "{phang}Either a column named [name] or a column named [value] is needed in the choice sheet.{p_end}"
		error 688
	}

	*Create a list of the variables with labels (multiple in case of multiple languages)
	foreach var of local choicesheetvars {
		if substr("`var'", 1, 5) == "label" local labelvars "`labelvars' `var'"
	}
	
	
	/***********************************************
		Get info from rowa/labels and 
		make tests on them
	***********************************************/			
	
	*Drop rows with all values missing
	egen `countmissing' = rownonmiss(_all), strok
	drop if `countmissing' == 0	
	
	*Get a list with all the list names
	levelsof list_name, clean local("all_list_names")

	
	/***********************************************
		TEST - Numeric name
		Test that all variables in the name
		variable are numeric
	***********************************************/
	
	*Test if variable is numeric
	cap confirm numeric variable `valuevar'
	
	*Test if error code is 7, other codes should return other error message
	if _rc == 7 {

		*TODO: Find a way to list the non-numeric values identified

		noi di as error "{phang}There are non numeric values in the [`valuevar'] column in the choices sheet{p_end}"
		error 198
	} 
	else if _rc != 0 {
		noi di as error "{phang}ERROR IN CODE LOGIC [cap confirm numeric variable `valuevar']{p_end}"
		error 198
	}

	
	/***********************************************
		TEST - No duplicates combinations
		Test that all combinations of
		list_name and name is unique
	***********************************************/
	
	*Test for duplicates and return error if not all combinations are unique
	duplicates tag list_name `valuevar', gen(`item_dup')
	count if `item_dup' != 0
	if `r(N)' > 0 {
		noi di as error "{phang}There are duplicates in the following list_names:{p_end}"
		noi list list_name `valuevar' if `item_dup' != 0
		error 198
	}

	
	/***********************************************
		TEST - No duplicates labels in list
		Test that there are no duplicate
		labels within a list
	***********************************************/
	
	*Local to indicate if error should be shown after all loops have completed
	local throw_label_dup_error 0
	
	*Initialize the dummy that indicate if there are duplicates to 0. This is used to store errors on
	gen `label_dup_all' = 0

	** Loop over each label language column
	foreach labelvar of local labelvars {
		
		*Reset vars and locals used in each label column
		replace `label_dup_all' = 0
		local lists_with_dups ""
		
		*Loop over each list name
		foreach list of local all_list_names {
		
			**Test for duplicates in the label var and display
			* errors if any observation do not have a unique,
			* i.e. `label_dup' != 0, label
			duplicates tag `labelvar' if list_name == "`list'", gen(`label_dup')
			
			*Was any duplicates found in this list
			count if `label_dup' == 1
			if `r(N)' > 0 {
				*Copy duplicate values to main 
				replace `label_dup_all' = 1 if `label_dup' == 1
				
				local lists_with_dups =trim("`lists_with_dups' `list'")
			}
			
			*Drop the tempvar so that it can be generated again by duplicates
			drop `label_dup'
		}
		
		**If there are any duplicates in label within a list for this
		* label column, display error and list those cases
		count if `label_dup_all' == 1
		if `r(N)' > 0 {
			noi di as error "{phang}There are duplicate labels in the column `labelvar' within the [`lists_with_dups'] list(s) in the following labels:{p_end}"
			noi list list_name `valuevar' `labelvar' filter if `label_dup_all' == 1
			
			*Indicate that at least one error was thrown and that command should exit on error code.
			local throw_label_dup_error 1
		}
	}
	
	*Throw error code if at least one lable duplicate was found
	if `throw_label_dup_error' == 1 {
		error 141
	}

	
	/***********************************************
		TEST - Stata language for labels
		Test that there is one column with labels formatted for stata
	***********************************************/		
	
	*User specified stata label name thar is not simply stata
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
			noi di as error "{phang}The label langauge specified in {inp:statalanguage(`statalanguage')} does not exist in the choice sheet. A column in the choice sheet must have a name that is [label:`statalanguage'].{p_end}"
			error 198
		}
		*The default stata label language name does not exist. Throw warning (error for now)
		else {
			noi di as error "{phang}There is no column in the choice sheet with the name [label:stata]. This is best practice as this allows you to automatically import choice list labels optimized for Stata's value labels making the data set easier to read.{p_end}"
			error 688			
		}
	}
	
	
	/***********************************************
		Return values
	***********************************************/		
	
	return local all_list_names				"`all_list_names'"

}
end

capture program drop importsurveysheet
		program 	 importsurveysheet , rclass
qui {
	syntax , form(string) [statalanguage(string)]
	

	*Gen the tempvars needed
	tempvar countmissing

	/***********************************************
		Load choices sheet from file and 
		delete empty row
	***********************************************/		
	
	*Import the choices sheet
	import excel "`form'", sheet("survey") clear first

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
	foreach var of local choicesheetvars {
		if substr("`var'", 1, 5) == "label" local labelvars "`labelvars' `var'"
	}		
	
	*Variables that must be included every time
	local name_vars 		"name"
	local cmd_vars  		"type required readonly appearance"
	local msg_vars  		"`labelvars' hint constraintmessage requiredmessage"
	local code_vars 		"default constraint  relevance  calculation repeat_count choice_filter"

	local surveysheetvars_required "`name_vars' `cmd_vars' `msg_vars' `code_vars'"		
	
	*Test that all required vars are actually in the survey sheets
	if `: list surveysheetvars_required in surveysheetvars' == 0 {
		
		*Generate a list of the vars missing and display error
		local missing_vars : list surveysheetvars_required - surveysheetvars
		noi di as error "{phang}One or several variables required to run all the tests in this command are missing in this form. The following variable(s) are missing [`missing_vars'].{p_end}"
		error 688
	}
	
	keep `surveysheetvars_required'
	
	*********
	*make command vars that sometimes are not used and then loaded as numeric
	foreach var of local cmd_vars  {
		
		tostring `var', replace 
		replace `var' = lower(itrim(trim(`var')))
		replace `var' = "" if `var' == "."
	}		
	
	
	


}
end

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

pause on
ietestform , surveyform("C:\Users\kbrkb\Dropbox\work\CTO_HHMidline_v2.xls")
