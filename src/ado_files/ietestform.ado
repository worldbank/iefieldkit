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

		*Import the choices sheet
		import excel "`form'", sheet("choices") clear first

		*Create a list of all variables in the choice sheet
		ds
		local choicesheetvars `r(varlist)'

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

		
		
		//return local all_fields_used_as_labels 	"11"
		return local all_list_names				"`all_list_names'"

}
end



ietestform , surveyform("C:\Users\kbrkb\Dropbox\iefieldkit\Survey CTO\moz_ag_survey.xlsx")
