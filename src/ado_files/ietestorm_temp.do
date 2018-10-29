capture program drop importsurveysheet
		program importsurveysheet , rclass	
	
	syntax , form(string)
	
	import delimited "`ssheet'", bindquotes(strict) clear //bindquotes(strict) - allows to enter labels with row breaks

	*Create a row number variable
	gen 	rowNumber = _n + 1 //+1 as so it mathces the excel sheet where column names are on row 1
	order 	rowNumber 
	

	
******************
*Remove rows and columns not used and test column name
******************		
	
	*********
	*Drop empty rows
	
	*Get number of columns
	qui describe	
	local var_num = `r(k)'
	
	*Get number of empty columns
	ds
	egen rowmiss = rowmiss(`r(varlist)')	
	
	*Drop observations with all columns empty (apart from rownumber we jsut constructed)
	drop if rowmiss == `var_num' - 1
	
	*Rename
	applyaliases, aliases("`ssheetaliases'") sctovars("`SCTO_VARS'")

	
	*********
	*Only keep rowNumver and columns with SCTO functionality
	
	*First make a list fo SCTO vars actually used
	local scto_keepvars
	foreach scto_var of local SCTO_VARS {
		cap confirm variable `scto_var' 
		if !_rc local scto_keepvars `scto_keepvars' `scto_var'
	}
	
	*Keep rowNumber and SCTO vars actually uses
	keep rowNumber `scto_keepvars' 

	
******************
*Start clean
******************		
	
	******************
	*clean type column
	******************

	*********
	*make command vars that sometimes are not used and then loaded as numeric
	foreach var of local SCTO_CMD_VARS  {
		
		tostring `var', replace 
		replace `var' = lower(itrim(trim(`var')))
		replace `var' = "" if `var' == "."
	}	
	
	*********
	*make all types one word using _
	replace type = "begin_group" 	if type == "begin group"
	replace type = "begin_repeat" 	if type == "begin repeat"
	replace type = "end_group" 		if type == "end group"
	replace type = "end_repeat" 	if type == "end repeat"
	
	replace type = "text_audit" 	if type == "text audit"
	replace type = "audio_audit" 	if type == "audio audit"
	
	*********
	*Short hand for begin_ or end_
	gen typeBegin 	= (type == "begin_group" 	| type == "begin_repeat")
	gen typeEnd 	= (type == "end_group" 		| type == "end_repeat")
	
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
	
	
******************
*Start tests
******************	
	
	
	******************
	*name column
	******************
	
	*********
	*duplicates - have happened that this passes SCTO tests. upper and lower case. Is also allowed if begin_ end_ repeat/group pair.
	duplicates tag name , gen(name_dup)
	
	*Pair dups are ok if a begin_ end_ group/repeat pair 
	sort name type
	by 	 name : gen beginEndDup = (name_dup == 1 & ((typeBegin == 1 & typeEnd[_n+1] == 1) | (typeEnd == 1 & typeBegin[_n-1] == 1))) 
	
	*Warning if not an exact begin_ end_ group/repeat pair with the same value for name
	gen dupBeginEndWarn = (name_dup != 1 & (typeBegin == 1 | typeEnd == 1 ))	
	
	*********
	*_# suffix, could cause error when taking loops from long to wide
	gen uscorePos 		= (strpos(reverse(name), "_") * -1) + 1 		// *-1 since string is reversed to get _ from right, +1 to not include _
	gen ucoreSuff		= substr(name,uscorePos,.) if uscorePos != 1	// if uscorePos != 1 to not include names with no _ for which uscorePos = (0*-1)+1	
	gen ucoreSuffWarn	= !missing(real(ucoreSuff)) 
	
	******************
	*name tests - lenght of name tests
	gen namelen = strlen(name)
	order namelen, after(name)
	
	*********
	*no names - not allowed by SCTO unless end_ group or repeat, but good to include anyways
	gen noname 		= (namelen == 0)
	gen nonameErr 	= (namelen == 0 & typeEnd == 0)
	gen nonameWarn 	= (namelen == 0	& typeEnd == 1)
	
	*********
	*too long names
	gen longname	= (namelen > 32)

	
	******************
	*required column
	******************
	gen reqNoteWarn		= (required == "yes" & type == "note")
	gen reqNoNoteWarn	= (required != "yes" & !inlist(type, "note", "end_group","end_repeat","begin_group","begin_repeat"))

	
	*******************
	compress
	
	drop reqNoNoteWarn
	
	keep rowNumber name type  *Err *Warn
	
	sort rowNumber
	
	egen numErr = rowtotal(*Err)
	egen numWarn = rowtotal(*Warn)
	
	order rowNumber name type numErr numWarn
	
	br if numErr > 0 | numWarn > 0
	
	
******************
*Start tests
******************	
	
	
		noi di as text ""
		noi di as error "{hline}"
		noi di as error "{pstd}Stata issued one or more warnings in relation to the tests in this balance table. Read the warning(s) below carefully before using the values generated for this table.{p_end}" 
		noi di as text ""
		
		noi di as text "{pmore}{bf:Difference-in-Means Tests:} The variance in both groups listed below is zero for the variable indicated and a difference-in-means test between the two groups is therefore not valid. Tests are reported as N/A in the table.{p_end}" 
		noi di as text ""
		
		noi di as text "{col 9}{c TLC}{hline 11}{c TT}{hline 12}{c TT}{hline 37}{c TRC}"
		noi di as text "{col 9}{c |}{col 13}Test{col 21}{c |}{col 25}Group{col 34}{c |}{col 39}Balance Variable{col 72}{c |}"
		noi di as text "{col 9}{c LT}{hline 11}{c +}{hline 12}{c +}{hline 37}{c RT}"
		
		noi di as text "{col 9}{c BLC}{hline 11}{c BT}{hline 12}{c BT}{hline 37}{c BRC}"
		noi di as text ""
		
		noi di as error "{pstd}Stata issued one or more warnings in relation to the tests in this balance table. Read the warning(s) above carefully before using the values generated for this table.{p_end}" 
		noi di as error "{hline}"
		noi di as text ""

end
	
capture program drop applyaliases
program applyaliases
	
	syntax, aliases(string) sctovars(string)
	
	*Create a local with the rowlabel input to be tokenized
	local ss_aliases_to_tokenize `aliases'

	while "`ss_aliases_to_tokenize'" != "" {
		
		*Parsing name and label pair
		gettoken nameAlias ss_aliases_to_tokenize : ss_aliases_to_tokenize, parse(",")

		*Splitting name and label
		gettoken name alias : nameAlias, parse("#")
		
		*Can't loop over items with spaces, and name should not have spaces
		local name  = subinstr(trim("`name'") ," ", "",.)
		local alias = subinstr(trim("`alias'")," ", "",.)
		
		foreach colname in name alias {
			
			local `colname' = subinstr("``colname''","#", "",.)
			local `colname' = subinstr("``colname''",":", "",.)
			
			local `colname' = lower("``colname''",":", "",.)
			
			noi di "`colname': ``colname''"
			
		}
		
		*** Test the input

		*Checking that the variables used in rowlabels() are included in the table
		local name_correct : list name in sctovars
		if `name_correct' == 0 {
			noi display as error "{phang}Variable [`name'] listed as alias in [`name'#`alias'] is not a valid column name. See help.{end}"
			error 111
		}		

		cap confirm variable `alias', exact
		if _rc {
			noi display as error "{phang}There is no varaible named [`alias'] to be renamed to the valid SCTO name [`name']. See help.{end}"
			error 111
		}		
		
		*Drop the varaible with the real SCTO name if it exist. (It might not exist if there was no default language)
		cap drop `name'
		
		*Rename the variable to be used with the SCTO name
		rename `alias' `name'
		
		*Parse char is not removed by gettoken
		local ss_aliases_to_tokenize = subinstr("`ss_aliases_to_tokenize'" ,",","",1)
	}
end
