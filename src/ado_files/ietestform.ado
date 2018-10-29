*! version 0.1 15DEC2017  DIME Analytics lcardosodeandrad@worldbank.org

capture program drop ietestform
		program ietestform , rclass

	syntax , surveyform(string) [csheetaliases(string) statalanguage(string)]

	local SCTO_NAME_VARS  "name"
	local SCTO_CMD_VARS  "type required readonly appearance"
	local SCTO_MSG_VARS  "label hint constraintmessage requiredmessage"
	local SCTO_CODE_VARS "default constraint  relevance  calculation repeat_count choice_filter"

	local SCTO_VARS "`SCTO_NAME_VARS' `SCTO_CMD_VARS' `SCTO_MSG_VARS' `SCTO_CODE_VARS'"

	importchoicesheet, form("`surveyform'") statalanguage(`statalanguage')
	return list

	//importsurveysheet, form("`surveyform'")



end

capture program drop importchoicesheet
		program importchoicesheet , rclass
qui {
		noi di "importchoicesheet command ok"
		syntax , form(string) [statalanguage(string)]
		noi di "importchoicesheet syntax ok"

		*Gen the tempvars needed
		tempvar countmissing item_dup label_dup

		*Import the choices sheet
		import excel "`form'", sheet("choices") clear first

		
		*Drop rows with all values missing
		egen `countmissing' = rownonmiss(_all)
		noi drop if `countmissing' == 0
		
		
		*Create a list of all variables in the choice sheet
		ds
		local choicesheetvars `r(varlist)'

		*Create a list of the variables with labels (multiple in case of multiple languages)
		foreach var of local choicesheetvars {
			if substr("`var'", 1, 5) == "label" local labelvars "`labelvars' `var'"
		}


		*Get a list with all the list names
		levelsof list_name, clean local("all_list_names")

		/*
			TEST - Numeric name
			Test that all variables in the name
			variable are numeric
		*/
		cap confirm numeric variable name
		if _rc {

			*TODO: Find a way to list the non-numeric values identified

			noi di as error "{phang}There are non numeric values in the [name] column in the choices sheet{p_end}"
			error 198
		}

		/*
			TEST - No duplicates combinations
			Test that all combinations of
			list_name and name is unique
		*/
		duplicates tag list_name name, gen(`item_dup')
		count if `item_dup' != 0
		if `r(N)' > 0 {
			noi di as error "{phang}There are duplicates in the following list_names:{p_end}"
			noi list list_name name if `item_dup' !=
			error 198
		}

		/*
			TEST - No duplicates labels in list
			Test that there are no duplicate
			labels within a list
		*/

		** Loop over each list and each language for
		*  that list and test if there are duplicate labels
		foreach list of local all_list_names {
			foreach labelvar of local labelvars {

				**Test for duplicates in the label var and display
				* errors if any observation do not have a unique,
				* i.e. `label_dup' != 0, label
				duplicates tag `labelvar', gen(`label_dup')
				count if `label_dup' != 0
				if `r(N)' > 0 {
					noi di as error "{phang}There are duplicate labels in the column `labelvar' within the `list' list  in the following labels:{p_end}"
					noi list list_name name `labelvar' if `label_dup' != 0
					error 198
				}
				*Drop the tempvar so that it can be generated again by duplicates
				drop `label_dup'
			}
		}

		/*
			TEST - Stata language for labels
			Test that there is one column with labels formatted for stata
		*/		
		
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
				error 198			
			}
		}

		//return local all_fields_used_as_labels 	"11"
		return local all_list_names				"`all_list_names'"

}
end



ietestform , surveyform("C:\Users\kbrkb\Dropbox\iefieldkit\Survey CTO\moz_ag_survey.xlsx")
