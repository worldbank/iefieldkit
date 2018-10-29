*! version 0.1 15DEC2017  DIME Analytics lcardosodeandrad@worldbank.org

capture program drop ietestform
program ietestform , rclass
	
	syntax , ssheet(string) [ssheetaliases(string) csheet(string) csheetaliases(string)]
	
	local SCTO_NAME_VARS  "name"
	local SCTO_CMD_VARS  "type required readonly appearance"
	local SCTO_MSG_VARS  "label hint constraintmessage requiredmessage"
	local SCTO_CODE_VARS "default constraint  relevance  calculation repeat_count choice_filter"

	local SCTO_VARS "`SCTO_NAME_VARS' `SCTO_CMD_VARS' `SCTO_MSG_VARS' `SCTO_CODE_VARS'"

end

		}


		if _rc {
		
		
end
