*! version 3.2 31JUL2023  DIME Analytics dimeanalytics@worldbank.org

// Main syntax ---------------------------------------------------------------------------------

cap program drop iecodebook
  program def  iecodebook

  version 13 // Requires 13.0 due to use of long macros

  cap syntax [anything] using/ , [*]
  if _rc == 100 {
    di "  __   _______   ______    ______    _______   _______ .______     ______     ______    __  ___  "
    di " |  | |   ____| /      |  /  __  \  |       \ |   ____||   _  \   /  __  \   /  __  \  |  |/  /  "
    di " |  | |  |__   |  .----' |  |  |  | |  .--.  ||  |__   |  |_)  | |  |  |  | |  |  |  | |  '  /   "
    di " |  | |   __|  |  |      |  |  |  | |  |  |  ||   __|  |   _  <  |  |  |  | |  |  |  | |    <    "
    di " |  | |  |____ |  '----. |  '--'  | |  '--'  ||  |____ |  |_)  | |  '--'  | |  '--'  | |  .  \   "
    di " |__| |_______| \______|  \______/  |_______/ |_______||______/   \______/   \______/  |__|\__\  "
    di " "
    di "Welcome to {bf:iecodebook}!"
    di "It seems you have left out something important – the codebook!"
    di "If you are new to {bf:iecodebook}, please {stata h iecodebook:view the help file}."
    di "Enjoy!"
    error 100
  }
  else if _rc != 0 {
    syntax [anything] using/ , [*]
  }

  // Select subcommand
  noi di " "
  gettoken subcommand anything : anything

  // Check folder exists

  // Start by standardize all slashes to forward slashes, and get the position of the last slash
  local using = subinstr("`using'","\","/",.)
  local r_lastslash = strlen(`"`using'"') - strpos(strreverse(`"`using'"'),"/")
  if strpos(strreverse(`"`using'"'),"/") == 0 local r_lastslash -1 // Set to -1 if there is no slash

  // Get the full folder path and the file name
  local r_folder = substr(`"`using'"',1,`r_lastslash')
  local r_file = substr(`"`using'"',`r_lastslash'+2,.)

  // Test that the folder for the report file exists
  mata : st_numscalar("r(dirExist)", direxists("`r_folder'"))
  if `r(dirExist)' == 0  {
    noi di as error `"{phang}The folder [`r_folder'/] does not exist.{p_end}"'
    error 601
  }

  // Find the position of the last dot in the file name and get the file format extension
  local r_lastsdot = strlen(`"`r_file'"') - strpos(strreverse(`"`r_file'"'),".")
  local r_fileextension = substr(`"`r_file'"',`r_lastsdot'+1,.)

  // If no fileextension was used, then add .xslx to "`using'"
  if "`r_fileextension'" == "" {
    local using  "`using'.xlsx"
  }
  // Throw an error if user input uses any extension other than the allowed
  else if !inlist("`r_fileextension'",".xlsx",".xls") & !regexm(`"`options'"',"tempfile") {
    di as error "The codebook may only have the file extension [.xslx] or [.xls]. The format [`r_fileextension'] is not allowed."
    error 601
  }


  // Throw error on [template] if codebook cannot be created
   if inlist("`subcommand'","template","export") & !regexm(`"`options'"',"replace") & !regexm(`"`options'"',"verify") {

    cap confirm file "`using'"
    if (_rc == 0) & (!strpos(`"`options'"',"replace")) {
      di as err "That codebook already exists. {bf:iecodebook} will only overwrite it if you specify the [replace] option."
      error 602
    }

    cap confirm new file "`using'"
    if (_rc != 0) & (!strpos(`"`options'"',"replace")) {
      di as error "{bf:iecodebook} could not create file `using'. Check that the file path is correctly specified."
      error 601
    }
  }

  // Make sure some subcommand is specified
  if !inlist("`subcommand'","template","apply","append","export") {
    di as err "{bf:iecodebook} requires [template], [apply], [append], or [export] to be specified with a target [using] codebook. Type {bf:help iecodebook} for details."
    error 197
  }

  // Execute subcommand
  iecodebook_labclean // Do this first in case export or template syntax
  iecodebook_`subcommand' `anything' using "`using'" , `options'
  iecodebook_labclean // Do this again to clean up after apply or append
  if inlist("`subcommand'","apply","append") qui cap compress // Clean up after apply or append

end

// Label cleaning ------------------------------------------------------------------------------

cap program drop iecodebook_labclean
program iecodebook_labclean

  qui labelbook , problems
  local unused `r(unused)'
  foreach l of local unused {
    la drop `l'
  }

end

// Template subroutine -------------------------------------------------------------------------

cap program drop iecodebook_template
program iecodebook_template

  syntax [anything] [using/] , [*]

  // Select the right syntax and pass through to templating options
  if `"`anything'"' == `""' {
    // [apply] template if no arguments
    noi iecodebook apply using "`using'" , `options' template
  }
  else {
    // [append] template if arguments
    noi iecodebook append `anything' using "`using'" , `options' template
  }

end

// signdata subroutine for export --------------------------------------------------------------

cap prog drop iecodebook_signdata
prog def iecodebook_signdata

  syntax ///
    using/     /// Location of the desired datafile placement
  , ///
    [reset]    /// reset dtasig if sign fails

  // Check existing sign, if any
  cap datasignature confirm  using "`using'" , strict
    // If not found OR altered and no reset
    if ("`reset'" == "") {
      if _rc == 601 {
        di as err "There is no datasignature created yet." ///
          " Specify the [reset] option to initialize one."
      }
      datasignature confirm using "`using'" , strict
    }
    // If altered OR missing
    else {
      datasignature set , saving("`using'" , replace) reset
    }

end

// Export subroutine ---------------------------------------------------------------------------

cap program drop iecodebook_export
  program    iecodebook_export

  syntax [anything] [using/]  ///
    , [replace] [save] [saveas(string asis)] /// User-specified options
      [trim(string asis)] [trimkeep(string asis)]  /// User-specified options
      [SIGNature] [reset] [PLAINtext(string)] [noexcel] [verify]      /// Signature and verify options
      [match] [template(string asis)] [tempfile]    // Programming options

qui {

  // Return a warning if there are lots of variables
  if `c(k)' >= 1000 noi di "This dataset has `c(k)' variables. This may take a long time! Consider subsetting your variables first."

  // Store current data
  tempfile allData
    save `allData' , emptyok replace

  // Template Setup
    // Load dataset if argument
    if `"`anything'"' != "" {
      use `anything' , clear
    }

    // Setup for name of data source
    if "`template'" != "" {
      local template_colon ":`template'"  // colon for titles
      local template_us "_`template'"     // underscore for sheet names
      local TEMPLATE = 1                  // flag for template functions
    }
    else local TEMPLATE = 0

  // Option to [trim] variable set to variables specified in selected dofiles
  if `"`trim'"' != `""' {
    // Initialize datafile of variable names
    unab theVarlist : *
    preserve
      clear

      tempfile a
        save `a' , replace emptyok

    // Stack up all the lines of code from all the dofiles in a dataset
    foreach dofile in `trim' {

      // Check for dofile
      if !strpos(`"`dofile'"',".do") {
        di as err "The specified file does not include a .do extension." ///
          "Make sure it is a Stata .do-file and you include the file extension."
        error 610
      }

      // Load dofile contents as data
      import delimited "`dofile'" , clear varnames(nonames)

      unab allv : *
      gen v = ""

      foreach v in `allv' {
        cap tostring `v' , replace
        replace v = v + `v'
      }

      keep v
      rename v v1

      append using `a'
      tempfile a
        save `a' , replace
    }

    // Clean up common characters
    foreach character in , . < > / [ ] | & ! ^ + - : = ( ) # "{" "}" "`" "'" {
      replace v1 = subinstr(v1,"`character'"," ",.)
    }
      replace v1 = subinstr(v1, char(34), "", .) // Remove " sign
      replace v1 = subinstr(v1, char(96), "", .) // Remove ` sign
      replace v1 = subinstr(v1, char(36), "", .) // Remove $ sign
      replace v1 = subinstr(v1, char(10), "", .) // Remove line end

    // Reshape one word per line
      split v1
      drop v1
      gen i = _n
      reshape long v1, i(i) j(j)
      tempvar v
      clonevar `v' = v1
      drop i j v1
      drop if `v' == ""
      duplicates drop

    // Make sure there are no hanging *
      local length = substr("`: type `v''",4,.)
      local stars = "*"
      forv i = 1/`length' {
        replace `v' = "" if `v' == "`stars'"
        local stars "`stars'*"
      }

    // Cheat to get all the variables in the dataset
    foreach item in `theVarlist' {
      gen `item' = .
    }

    // Get all the variables in the dofiles
    qui count
    forvalues i = 1/`r(N)' {
      local next = `v'[`i']
      cap novarabbrev unab vars : `next'
        if (_rc == 0 & strpos("`vars'","__")!=1 ) local allVars "`allVars' `vars'"
    }

    // Keep only those variables
    local theKeepList : list uniq allVars

    // Restore and keep variables
    restore
      if "`theKeepList'" == "" {
        di as err "You are dropping all variables. This is not allowed. {bf:iecodebook} will now exit."
        error 198
      }
      keep `theKeepList' `trimkeep' // Keep only variables mentioned in the dofiles
  } // End [trim] option

  // Prepare to save and sign
  compress
    local savedta = subinstr(`"`using'"',".xls",".dta",.)
    local savedta = subinstr(`"`savedta'"',".dtax",".dta",.)
    local signloc = subinstr(`"`savedta'"',".dta","-sig.txt",.)

  // Check signature if requested
  if "`signature'" != "" {
    noisily : iecodebook_signdata using `"`signloc'"' , `reset'
    noi di `"Data signature can be found at at {browse `"`signloc'"':`signloc'}"'
  }

  // Prepare to save data copy if requested
  if ("`save'" != "") | (`"`saveas'"' != "") {
    if `"`saveas'"' != ""  local savedta = `saveas'
    if !strpos("`savedta'",".dta") local savedta "`savedta'.dta"
    tempfile outdata
    save `outdata'
  }

  // Error if attempting to verify without Excel codebook
	if !missing("`verify'") & !missing("`excel'") {
		di as err "The [noexcel] and [verify] options cannot be combined."
		err 184
	}

  // Write text codebook ONLY if requested
  if !missing("`plaintext'") {

	noisily {

		if "`plaintext'" == "compact" {
			local compact 	 , compact
		}
		else if "`plaintext'" == "detailed" {
		}
		else {
			di as err "Option [plaintext] was incorrectly specified. Please select one of the following formats: [compact] or [detailed]."
			err 198
		}

		local theTextFile = subinstr(`"`using'"',".xls",".txt",.)
		local theTextFile = subinstr(`"`using'"',".xlsx",".txt",.)

		local old_linesize `c(linesize)'
		set linesize 75

		cap log close signdata
			log using "`theTextFile'" , nomsg text `replace' name(signdata)
			noisily : codebook `compact'
		log close signdata

		set linesize `old_linesize'
		noi di `"Codebook in plaintext created using {browse "`theTextFile'":`theTextFile'}

		if !missing("`excel'") exit
	}
  }
  else {
	if !missing("`excel'") {
		noi di as err "Option [noexcel] can only be used in combination with option [plaintext()]."
		noi error 198
	}
  }



  // Otherwise, write XLSX file and VERIFY if requested
    // Record dataset info

      local allVariables
      local allLabels
      local allChoices

      foreach var of varlist * {
        local theVariable = "`var'"
        local theLabel    : var label `var'
        local theChoices  : val label `var'
        local theType     : type `var'

        local allVariables   `"`allVariables'   `theVariable'   "'
        local allLabels      `"`allLabels'      "`theLabel'"    "'
        local allChoices     `"`allChoices'     "`theChoices'"  "'
        local allTypes       `"`allTypes'       "`theType'"     "'
      }

    // Get all value labels for export
    uselabel _all, clear
      // Handle if no labels in dataset
      if c(k) == 0 {
        gen trunc = ""
        gen lname = ""
        gen value = ""
        gen label = ""
      }

      ren lname list_name
      drop trunc
      tostring value , replace

      count
      if `r(N)' == 0 {
        set obs 1
      }

      tempfile theVallabs
        save `theVallabs' , replace

    // Get existing codebook if VERIFY option and check variable lists
    if "`verify'" != "" {
    local QUITFLAG = 0
      import excel "`using'", clear first sheet("survey")
      levelsof name , local(oldVars) clean
      local both : list allVariables & oldVars

      // Check excess variables in data
      local extra : list allVariables - oldVars
      if "`extra'" != "" {
        local QUITFLAG = 1
        noi di as err "The following variables are in this data but not the codebook:"
        foreach item in `extra' {
          noi di "  `item'"
        }
      }

      // Check excess variables in codebook
      local missing : list oldVars - allVariables
      if "`missing'" != "" {
        local QUITFLAG = 1
        noi di as err "The following variables are in the codebook but not the data:"
        foreach item in `missing' {
          noi di "  `item'"
        }
      }

      // Check attributes of all overlapping variables
      local theN : word count `allVariables'
      forvalues i = 1/`theN' {
        local theVariable : word `i' of `allVariables'
        local theLabel    : word `i' of `allLabels'
        local theChoices  : word `i' of `allChoices'
        local theType     : word `i' of `allTypes'

        // Proceed to all checks if variable is in both locations
        if strpos("`both'"," `theVariable' ") {
        preserve
          keep if name == "`theVariable'"

          local theOldType = type[1]
          if ("`theOldType'" != "`theType'") & ///
            !(strpos("`theOldType'","str") & strpos("`theType'","str")) {
              local QUITFLAG = 1
              di as err "The type of {bf:`theVariable'} has changed:"
              di as err `"  it was `theOldType' and is now `theType'."'
          }
          local theOldLabel = label[1]
          if "`theOldLabel'" != "`theLabel'" {
            local QUITFLAG = 1
            di as err "The label of {bf:`theVariable'} has changed:"
            di as err `"  it was `theOldLabel' and is now `theLabel'."'
          }
          local theOldChoices = choices[1]
          if "`theOldChoices'" == "." local theOldChoices ""
          if "`theOldChoices'" != "`theChoices'" {
            local QUITFLAG = 1
            di as err "The value label of {bf:`theVariable'} has changed:"
            di as err `"  it was `theOldChoices' and is now `theChoices'."'
          }
        restore
        }
      }

      // Check all value labels
      import excel "`using'", clear first sheet("choices")
        ren label label_old
        merge 1:1 list_name value using `theVallabs'

        qui count
        forv i = 1/`r(N)' {
          local list = list_name[`i']
          local value = value[`i']
          local oldlab = label_old[`i']
          local lab = label[`i']
          local merge = _merge[`i']

          if `merge' == 1 {
          local QUITFLAG = 1
            di as err `"Choice list `list' = `value' (`oldlab') was found in the existing codebook but not the data."'
          }
          else if `merge' == 2 {
          local QUITFLAG = 1
            di as err `"Choice list `list' = `value' (`lab') was found in the data but not the existing codebook."'
          }
          else if `"`oldlab'"' != `"`lab'"' {
          local QUITFLAG = 1
            di as err `"Choice list `list' = `value' is (`oldlab') in the codebook but (`lab') in the data."'
          }
        }

      // Throw error if any differences found
      if `QUITFLAG' == 1 {
        di as err ""
        di as err "Differences were encountered between the existing data and the codebook."
        di as err "{bf:iecodebook} will now exit."
        use `allData', clear
        error 7
      }
    } // end VERIFY option for variable characteristics

    // Create XLSX file with all current/remaining variable names and labels
    clear

      local theN : word count `allVariables'

      local templateN ""
      if `TEMPLATE' & "`match'" == "" {
        import excel "`using'", clear first sheet("survey")

        count
        local templateN "+ `r(N)'"
      }

      set obs `=`theN' `templateN''

      gen name`template' = ""
        label var name`template' "name`template_colon'"
      gen label`template' = ""
        label var label`template' "label`template_colon'"
      gen type`template' = ""
        label var type`template' "type`template_colon'"
      gen choices`template' = ""
        label var choices`template' "choices`template_colon'"
      if `TEMPLATE' gen recode`template' = ""
        if `TEMPLATE' label var recode`template' "recode`template_colon'"

      forvalues i = 1/`theN' {
        local theVariable : word `i' of `allVariables'
        local theLabel    : word `i' of `allLabels'
        local theChoices  : word `i' of `allChoices'
        local theType     : word `i' of `allTypes'

        replace name`template'    = `"`theVariable'"'  in `=`i'`templateN''
        replace label`template'   = `"`theLabel'"'     in `=`i'`templateN''
        replace type`template'    = `"`theType'"'      in `=`i'`templateN''
        replace choices`template' = `"`theChoices'"'   in `=`i'`templateN''
      }

      if `TEMPLATE' & "`match'" != "" {
        tempfile newdata
        save `newdata' , replace

        import excel "`using'", clear first sheet("survey")

        qui lookfor name
        clonevar name`template' = `: word 2 of `r(varlist)''
          local theNames = "`r(varlist)'"
          label var name`template' "name`template_colon'"

        // Allow matching for more rounds
        local nNames : list sizeof theNames
        if `nNames' > 2 {
          forvalues i = 2/`nNames' {
            replace name`template' = `: word `i' of `theNames'' if name`template' == ""
          }
        }

        tempvar order
        gen `order' = _n

        merge m:1 name`template' using `newdata' , nogen
        replace name`template' = "" if type`template' == ""

        sort `order' , stable
        drop `order'
      }

      // Export variable information to "survey" sheet
      if "`verify'" == "" {
        cap export excel "`using'" , sheet("survey") sheetreplace first(varl)
        local rc = _rc
        if `rc' == 9901 {
          di as err "There are invalid variable labels in your data. Correct the following:"
          tempfile test
          forv i = 1/`c(N)' {
            preserve
            keep in `i'
            local faultLab  = label[1]
            local faultName = name[1]

            cap export excel label using `test'  , replace
              if _rc != 0 di as err `"  `faultName' {tab} [`faultLab']"'
            restore
          }
        }
        else forvalues i = 1/10 {
          if `rc' != 0 {
            sleep `i'000
            cap export excel "`using'" , sheet("survey") sheetreplace first(varl)
            local rc = _rc
          }
        }
        if `rc' != 0 di as err "A codebook didn't write properly. This can be caused by file syncing the file or having the file open."
        if `rc' != 0 di as err "If the file is not currently open, consider turning file syncing off or using a non-synced location. You may need to delete the file and try again."
        if `rc' != 0 error 603

        // Export value labels to "choices" sheet
        use `theVallabs' , clear
          cap export excel "`using'" , sheet("choices`template_us'") sheetreplace first(var)
          local rc = _rc
          if `rc' == 9901 {
            di as err "There are invalid value labels in your data. Correct the following:"
            tempfile test
            forv i = 1/`c(N)' {
              preserve
              keep in `i'
              local faultLab  = label[1]
              local faultName = lname[1]

              cap export excel label using `test'  , replace
                if _rc != 0 di as err `"  `faultName' {tab} [`faultLab']"'
              restore
            }
          }
          else forvalues i = 1/10 {
            if `rc' != 0 {
              sleep `i'000
              cap export excel "`using'" , sheet("choices`template_us'") sheetreplace first(var)
              local rc = _rc
            }
          }
          if `rc' != 0 di as err "A codebook didn't write properly. This can be caused by Dropbox syncing the file or having the file open."
          if `rc' != 0 di as err "Consider turning Dropbox syncing off or using a non-Dropbox location. You may need to delete the file and try again."
          if `rc' != 0 error 603

        // Reload original data
        use "`allData'" , clear

        // Success message
        if `c(N)' > 1 & "`tempfile'" == "" {
          noi di `"Codebook for data created using {browse "`using'":`using'}
        }
      }
      else {
        noi di "Existing codebook and data structure verified to match."
      }
  use `allData' , clear

  // Save data copy if requested
  if ("`save'" != "") | (`"`saveas'"' != "") {
    copy `outdata' "`savedta'", `replace'
    noi di `"Copy of data saved at {browse `"`savedta'"':`savedta'}"'
  }

} // end qui

end

// Apply subroutine ----------------------------------------------------------------------------

cap program drop iecodebook_apply
  program    iecodebook_apply

  syntax [anything] [using/] , [template] [replace] [drop] ///
    [survey(string asis)] [MISSingvalues(string asis)] [tempfile]

qui {
  // Setups

    if "`survey'" == "" local survey "current"

  // Template setup
  if "`template'" != "" {
    // First create empty codebook with placeholder variable (for the new entries)
    preserve
      clear
      set obs 1
      gen _template = 0
        label var _template "(Ignore this placeholder, but do not delete it. Thanks!)"
        label def yesno 0 "No" 1 "Yes" .d "Don't Know" .r "Refused" .n "Not Applicable"
        label val _template yesno
      noi iecodebook export using "`using'" , `replace'
    restore
    // Append the codebook for the current dataset to the placeholder codebook
    tempfile current
    save `current' , replace
    noi iecodebook export `current' using "`using'" , template(`survey') replace
  exit
  }

  // Apply codebook
  unab allVars : *
  preserve
  import excel "`using'" , clear first sheet(survey) allstring

  // Confirm survey names match codebook
  cap confirm variable name`survey'
    if _rc {
      di as err "The survey name `survey' does not appear in the codebook."
      error 111
    }

    // Check for broken things, namely quotation marks
    foreach var of varlist name`survey' name label choices recode`survey' {
      cap confirm string variable `var'
      if _rc == 0 {
        replace `var' = subinstr(`var', char(34), "", .) // Remove " sign
        replace `var' = subinstr(`var', char(96), "", .) // Remove ` sign
        replace `var' = subinstr(`var', char(36), "", .) // Remove $ sign
        replace `var' = subinstr(`var', char(10), "", .) // Remove line end
      }
    }

    // Remove leading/trailing spaces
    replace choices = trim(choices)
    replace name    = trim(name)
    replace label   = trim(label)

    // Check for duplicate names and return informative error
    local theNameList ""
    count
    forvalues i = 2/`r(N)' {
      local theName = name`survey'[`i']
      local theNameList "`theNameList' `theName'"
    }
    if "`: list allVars - theNameList'" != "" {
      if "`drop'" != "" {
        local firstDrop  "drop `: list allVars - theNameList'"
      }
      else {
        di as err "The following variables in the `survey' data are not handled in the codebook:"
          foreach item in `: list allVars - theNameList' {
            di as err "  `item'"
          }
        di as err "Add them to the codebook to be managed, or use [drop] to remove all unused variables."
        di as err "If you are getting this message from [iecodebook append], remove [keepall] to drop variables."
        error 198
      }
    }
    if "`: list dups theNameList'" != "" {
      di as err "You have multiple entries for the same original variable in name:`survey'."
      di as err "The duplicates are: `: list dups theNameList'"
      di as err "This will cause conflicts. {bf:iecodebook} will now quit."
    }

    // Loop over survey sheet and accumulate rename, relabel, recode, vallab
    count
    local QUITFLAG = 0
    forvalues i = 2/`r(N)' {
      local theName    = name`survey'[`i']
      local theRename   = name[`i']
      local theRename = trim("`theRename'")
      local theLabel    = label[`i']
      local theChoices  = choices[`i']
      local theRecode   = recode`survey'[`i']
        // Check new name validity
        if strtoname("`theRename'") != "`theRename'" & "`theRename'" != "." {
          di as err "Error: [`theRename'] on line `=`i'+1' is not a valid Stata variable name."
          local QUITFLAG = 1
        }
        // Check choice list validity
        if strtoname("`theChoices'") != "`theChoices'" & "`theChoices'" != "." {
          di as err "Error: [`theChoices'] on line `=`i'+1' is not a valid Stata choice list name."
          local QUITFLAG = 1
        }

      if "`theName'" != "" {

        // Report error when variable is missing from original data
        if !regex(" `allVars' ", " `theName' ") {
          di as error "Error: You requested changes to variable [`theName'] on line `=`i'+1', but it was not found in the data."
          local QUITFLAG = 1
        }

        // Prepare to drop any variable that is renamed "." ; or left blank if [drop] option
        if ("`drop'" != "" & "`theRename'" == "") | ("`theRename'" == ".") {
          local allDrops "`allDrops' `theName'"
        }

        // Otherwise process requested changes as long as there is something specified
        else {
          if "`theRename'"  != "" local allRenames1 = `"`allRenames1' `theName'"'
          if "`theRename'"  != "" local allRenames2 = `"`allRenames2' `theRename'"'
          if "`theLabel'"   != "" local allLabels   = `"`allLabels' `"label var `theName' "`theLabel'" "' "'
          if "`theChoices'" != "" local allChoices  = `"`allChoices' "label val `theName' `theChoices'""'
          if "`theRecode'"  != "" local allRecodes  = `"`allRecodes' "recode `theName' `theRecode'""'
        }
      }
    }

    gen badlabel = (strpos(type,"str") & choices!="")
      qui su badlabel
      if `r(max)' != 0 {
        di as err "You are trying to label the following non-numeric variables:"
        di as err " "
        di as err "{col 4} Line {col 11} Name {col 24} Label"
        forv i = 1/`c(N)' {
            local mi = badlabel[`i']
            local li = name[`i']
            local la = label[`i']
            if "`mi'" == "1" di as err "{col 4} `=`i'+1' {col 11} `li' {col 24} `la'"
          }
          di as err " "
          error 100
      }

    if `QUITFLAG' error 198

    // Loop over choices sheet and accumulate vallab definitions

      // Prepare list of value labels needed.
      levelsof choices , local(theValueLabels)

      // Prepare list of values for each value label.
      import excel "`using'" , first clear sheet(choices) allstring
        replace list_name = trim(list_name)
        drop if list_name == ""
      // Catch undefined levels
      count if missing(value)
      if r(N) > 0 {
        di as err "You have specified value labels without corresponding values."
        di as err "{bf:iecodebook} will exit. Complete the following value labels and re-run the command to continue:"
        di as err " "
        di as err "{col 4} Line {col 11} List {col 24} Label"
          forv i = 1/`c(N)' {
            local mi = value[`i']
            local li = list_name[`i']
            local la = label[`i']
            if "`mi'" == "" di as err "{col 4} `=`i'+1' {col 11} `li' {col 24} `la'"
          }
          di as err " "
          error 100
      }
      // Catch any labels called on choices that are not defined in choice sheet
      levelsof list_name , local(theListedLabels)
      local period "."
      local leftovers : list theValueLabels - theListedLabels
      local leftovers : list leftovers - period
      if `"`leftovers'"' != "" {
        di as err "You have specified a value label in [choices] which is not defined in the {it:choices} sheet."
        di as err "{bf:iecodebook} will exit. Define the following value labels and re-run the command to continue:"
        di as err " "
        foreach element in `leftovers' {
          di as err "  [`element']"
        }
        di as err " "
        error 100
      }

      // Check for broken things, namely quotation marks
      foreach var of varlist * {
        cap confirm string variable `var'
        if _rc == 0 {
          replace `var' = subinstr(`var', char(34), "", .) //remove " sign
          replace `var' = subinstr(`var', char(96), "", .) //remove ` sign
          replace `var' = subinstr(`var', char(36), "", .) //remove $ sign
          replace `var' = subinstr(`var', char(10), "", .) //remove line end
        }
      }

      // Load all entries
      count
      local n_vallabs = `r(N)'
      forvalues i = 1/`n_vallabs' {
        local theNextValue = value[`i']
        local theNextLabel = label[`i']
        local theValueLabel = list_name[`i']
        local L`theValueLabel' `" `L`theValueLabel'' `theNextValue' "`theNextLabel'" "'
      }

      // Add missing values if requested
      if `"`missingvalues'"' != "" {
        foreach theValueLabel in `theValueLabels' {
          if "`theValueLabel'" != "." local L`theValueLabel' `" `L`theValueLabel'' `missingvalues' "'
        }
      }

  // Back to original dataset to apply changes from codebook
  restore

    // Define value labels
    foreach theValueLabel in `theValueLabels' {
      if "`theValueLabel'" != "." label def `theValueLabel' `L`theValueLabel'', replace
      }

    // Drop leftovers if requested
    local toKeep : list allVars - allDrops
    if "`toKeep'" == "" {
      noi di as err "You are dropping all the variables in a dataset. This is not allowed. {bf:iecodebook} will exit."
      error 102
    }
    keep `toKeep'
    `firstDrop'


    // Apply all recodes, choices, and labels
    foreach type in Recodes Choices Labels {
      foreach change in `all`type'' {
        cap `change'
        if      _rc == 181            di as err `"Variable `: word 3 of `change'' is a string and cannot have a value label."'
        else if _rc == 111            di as err `"Variable `: word 3 of `change'' was not found."'
        // Generic error message
        else if _rc != 0 & _rc != 100 di as err `"One of your `=lower("`type'")' failed: check `change' in the codebook."'
      }
    }

    // Rename variables and catch errors
    cap rename (`allRenames1') (`allRenames2')
    if _rc != 0 & !("`allRenames1'" == "" & "`allRenames2'" == "") {
      di as err "That codebook contains a rename conflict. Please check and retry. {bf:iecodebook} will exit."
      rename (`allRenames1') (`allRenames2') // Throw error from [rename] directly
    }

  // Success message
  di `"Applied codebook to `survey' data using `using'"'
  di `"{bf:Note: strings are sanitized} – any backticks, quotation marks, dollar signs, and line breaks have been removed."'

} // end qui
end

// Append subroutine ---------------------------------------------------------------------------

cap program drop iecodebook_append
  program    iecodebook_append

  syntax [anything] [using/] , ///
    surveys(string asis) [GENerate(string asis)] ///
    [clear] [match] [KEEPall] [report] /// User options
    [template] [replace] /// System options
    [*]

qui {

  // Generated variable is "survey" if not otherwise specified
  if "`generate'" == "" {
    local generate = "survey"
  }

  // Require [clear] option
  if "`clear'" == "" & "`template'" == "" {
    di as err "[iecodebook] loads new data from disk. Therefore you must specify the [clear] option."
    error 4
  }

  // Optional no-drop
  if "`keepall'" == "" {
    local drop "drop"
  }
  else {
    noi di "You have specified [keepall], which means you are forcing all variables to be appended even if you did not manually harmonize them."
    noi di "Make sure to check the resulting dataset carefully. Forcibly appending data, especially of different types, may result in loss of information."
    local drop ""
  }

  // Final dataset setup
  tempfile raw_data
    save `raw_data' , emptyok
  clear
  tempfile final_data
    save `final_data' , replace emptyok

  // Template setup
  if "`template'" != "" {
    // Use tempfile for writing loop to avoid problems if failure
    tempfile codebook

    // Create empty codebook
    preserve
      clear
      set obs 1
      gen `generate' = 0
        label var `generate' "Data Source (do not edit this row)"
        label def yesno 0 "No" 1 "Yes" .d "Don't Know" .r "Refused" .n "Not Applicable"
        label val `generate' yesno
      noi iecodebook export using "`codebook'" , `replace' tempfile
    restore

    // Append or merge one codebook per survey
    local x = 0
    foreach survey in `surveys' {
      if `x' == 1 local matchopt "`match'"
      local ++x
      local filepath : word `x' of `anything'
      noi iecodebook export "`filepath'" using "`codebook'" ///
        , template(`survey') `matchopt' replace tempfile
    }

    // On success copy to final location
    copy "`codebook'" `"`using'"' , `replace'
    noi di `"Codebook for data created using {browse "`using'":`using'}"'

  use `raw_data' , clear
  exit
  }

  // Loop over datasets and apply codebook
  local x = 0
  foreach dataset in `anything' {
    local ++x
    local survey : word `x' of `surveys'

    use "`dataset'" , clear

    iecodebook apply using "`using'" , survey(`survey') `drop' `options'

    cap confirm variable `generate'
      if _rc==0 {
        di as err "There is a variable called `generate' in your dataset."
        di as err "This conflicts with using that name to identify the data source."
        di as err "Please specify a different name for the new variable in the [generate()] option."
        error 110
      }
    cap labelbook `generate'
      if _rc==0 {
        di as err "There is a value label called `generate' in your dataset."
        di as err "This conflicts with using that name to identify the data source."
        di as err "Please specify a different name for the new variable in the [generate()] option."
        error 110
      }

    gen `generate' = `x'
    tempfile next_data
      save `next_data' , replace
    use `final_data' , clear
    append using `next_data'
      label def `generate' `x' "`survey'" , add
      label val `generate' `generate'
      label var `generate' "Data Source"
      save `final_data' , replace emptyok
    di `"..."'
  }

  // Success message
  noi di `"Applied codebook {browse `using'} to `anything' – check your data carefully!"'

  // Final codebook
  local using = subinstr("`using'",".xls","_report.xls",.)
    use `final_data' , clear
    if "`report'" != "" {
      iecodebook export using "`using'" , `replace'
      noi di `"Wrote report to {browse `using'}!"'
    }

} // end qui
end

// Have a lovely day!
