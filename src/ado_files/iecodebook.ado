*! version 1.3 7JUN2019  DIME Analytics dimeanalytics@worldbank.org

// Main syntax ---------------------------------------------------------------------------------

cap program drop iecodebook
  program def  iecodebook

  version 13 // Requires 13.0 due to use of long macros

  cap syntax [anything] using/ , [*]
  if _rc == 100 {
    di "    _                     __     __                __     "
    di "   (_)__  _________  ____/ /__  / /_  ____  ____  / /__   "
    di "  / / _ \/ ___/ __ \/ __  / _ \/ __ \/ __ \/ __ \/ //_/   "
    di " / /  __/ /__/ /_/ / /_/ /  __/ /_/ / /_/ / /_/ / ,<      "
    di "/_/\___/\___/\____/\__,_/\___/_.___/\____/\____/_/|_|     "
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
  gettoken subcommand anything : anything

  // Throw error on [template] if codebook already exists
  if ("`subcommand'" == "template") {

    cap confirm new file "`using'"
    if _rc != 0 {
      di as err "That template already exists. {bf:iecodebook} does not allow you to overwrite an existing template,"
      di as err " since you may already have set it up. If you are {bf:sure} that you want to delete this template,"
      di as err `" you need to manually remove it from `file'. {bf:iecodebook} will now exit."'
      error 602
    }

    cap confirm new file "`using'"
    if _rc {
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
  iecodebook_`subcommand' `anything' using "`using'" , `options'

end

// Template subroutine -------------------------------------------------------------------------

cap program drop iecodebook_template
program iecodebook_template

  syntax [anything] [using/] , [*]

  // Select the right syntax and pass through to templating options
  if `"`anything'"' == `""' {
    // [apply] template if no arguments
    iecodebook apply using "`using'" , `options' template
  }
  else {
    // [append] template if arguments
    iecodebook append `anything' using "`using'" , `options' template
  }

end

// Export subroutine ---------------------------------------------------------------------------

cap program drop iecodebook_export
  program    iecodebook_export

  syntax [anything] [using/] [if] [in] ///
    , [merge] [template(string asis)] [trim(string asis)]

qui {

  // Return a warning if there are lots of variables
  if `c(k)' >= 1000 di "This dataset has `c(k)' variables. This may take a long time! Consider subsetting your variables first."

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

   // Store current data and apply if/in via [marksample]
     tempfile allData
     save `allData' , emptyok replace

     marksample touse
     keep if `touse'
       drop `touse'

  // Set up temps
  preserve
    clear

    tempfile theLabels

    tempfile theCommands
      save `theCommands' , replace emptyok
  restore

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

    // Loop through every variable in the current dataset and put its name wherever it occurs
    local x = 1
    foreach item in `theVarlist' {
      local ++x
      gen v`x' = "`item'" if strpos(v1,"`item'")
    }

    // Collapse to one column to get every variable mentioned in any dofile
    collapse (firstnm) v* , fast
      gen n = 1
      reshape long v , i(n) // Reshape to column of varnames
      keep v
      drop if v == ""
      drop in 1

    // Loop over variable names to build list of variables to keep
    count
    forvalues i = 1/`r(N)' {
      local theNextVar = v[`i']
      local theKeepList = "`theKeepList' `theNextVar'"
    }

    // Restore and keep variables
    restore
      if "`theKeepList'" == "" {
        di as err "You are dropping all variables. This is not allowed. {bf:iecodebook} will now exit."
        error 198
      }
      keep `theKeepList' // Keep only variables mentioned in the dofiles
      compress
      local savedta = subinstr(`"`using'"',".xlsx",".dta",.)
      save "`savedta'" , replace
  } // End [trim] option

  // Create XLSX file with all current/remaining variable names and labels
  preserve

    // Record dataset info

      local allVariables
      local allLabels
      local allChoices

      foreach var of varlist * {
        local theVariable = "`var'"
        local theLabel    : var label `var'
        local theChoices  : val label `var'
        local theType     : type `var'

        local allVariables   `"`allVariables'   "`theVariable'" "'
        local allLabels      `"`allLabels'      "`theLabel'"    "'
        local allChoices     `"`allChoices'     "`theChoices'"  "'
        local allTypes       `"`allTypes'       "`theType'"     "'
      }

    // Write to new dataset

      clear

      local theN : word count `allVariables'

      local templateN ""
      if `TEMPLATE' & "`merge'" == "" {
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

    if `TEMPLATE' & "`merge'" != "" {
      tempfile newdata
        save `newdata' , replace

      import excel "`using'", clear first sheet("survey")

      qui lookfor name
      clonevar name`template' = `: word 2 of `r(varlist)''
        label var name`template' "name`template_colon'"

      merge 1:1 name`template' using `newdata' , nogen 
      replace name`template' = "" if type`template' == ""
    }

    // Export variable information to "survey" sheet
    cap export excel "`using'" , sheet("survey") sheetreplace first(varl)
    local rc = _rc
    forvalues i = 1/10 {
      if `rc' != 0 {
        sleep `i'000
        cap export excel "`using'" , sheet("survey") sheetreplace first(varl)
        local rc = _rc
      }
    }
    if `rc' != 0 di as err "A codebook didn't write properly. This can be caused by Dropbox syncing the file or having the file open."
    if `rc' != 0 di as err "Consider turning Dropbox syncing off or using a non-Dropbox location. You may need to delete the file and try again."
    if `rc' != 0 error 603
  restore

  // Create value labels sheet

    // Fill temp dataset with value labels
    foreach var of varlist * {
      use `var' using `allData' in 1 , clear
      local theLabel : value label `var'
      if "`theLabel'" != "" {
        cap label save `theLabel' using `theLabels' ,replace
        if _rc==0 {
          import delimited using `theLabels' , clear delimit(", modify", asstring)
          append using `theCommands'
            save `theCommands' , replace emptyok
        }
      }
    }

    // Clean up value labels for export - use SurveyCTO syntax for sheet names and column names
    use `theCommands' , clear
    count
    if `r(N)' > 0 {
      duplicates drop
      drop v2
      replace v1 = trim(subinstr(v1,"label define","",.))
      split v1 , parse(`"""')
      split v11 , parse(`" "')
      keep v111 v112 v12
      order v111 v112 v12

      rename (v111 v112 v12)(list_name value label)
    }
    else {
      set obs 1
      gen list_name = ""
      gen value = ""
      gen label = ""
    }

    // Export value labels to "choices" sheet
    cap export excel "`using'" , sheet("choices`template_us'") sheetreplace first(var)
    local rc = _rc
    forvalues i = 1/10 {
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
  if "`template'" == "" local template "current"
  if `c(N)' > 1 di `"Codebook for `template' data created using {browse "`using'": `using'}"'

} // end qui
end

// Apply subroutine ----------------------------------------------------------------------------

cap program drop iecodebook_apply
  program    iecodebook_apply

  syntax [anything] [using/] , [template] [drop] ///
    [survey(string asis)] [MISSingvalues(string asis)]

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
      iecodebook export using "`using'"
    restore
    // Append the codebook for the current dataset to the placeholder codebook
    tempfile current
    save `current' , replace
    iecodebook export `current' using "`using'" , template(`survey')
  exit
  }

  // Apply codebook
  preserve
  import excel "`using'" , clear first sheet(survey) allstring

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

    // Check for duplicate names and return informative error
    local theNameList ""
    count
    forvalues i = 2/`r(N)' {
      local theName = name`survey'[`i']
      local theNameList "`theNameList' `theName'"
    }
    if "`: list dups theNameList'" != "" {
      di as err "You have multiple entries for the same original variable in name:`survey'."
      di as err "The duplicates are: `: list dups theNameList'"
      di as err "This will cause conflicts. {bf:iecodebook} will now quit."
      error 198
    }

    // Loop over survey sheet and accumulate rename, relabel, recode, vallab
    count
    local QUITFLAG = 0
    forvalues i = 2/`r(N)' {
      local theName    = name`survey'[`i']
        local theRename   = name[`i']
        if strtoname("`theRename'") != "`theRename'" & "`theRename'" != "." {
          di as err "Error: [`theRename'] on line `i' is not a valid Stata variable name."
          local QUITFLAG = 1
        }
      local theLabel    = label[`i']
      local theChoices  = choices[`i']
      local theRecode   = recode`survey'[`i']

      if "`theName'"   != "" {
        // Drop if requested
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
    if `QUITFLAG' error 198

    // Loop over choices sheet and accumulate vallab definitions

      // Prepare list of value labels needed.
      levelsof choices , local(theValueLabels)

      // Prepare list of values for each value label.
      import excel "`using'" , first clear sheet(choices) allstring

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
        local theLabelList_`theValueLabel' `" `theLabelList_`theValueLabel'' `theNextValue' "`theNextLabel'" "'
      }

      // Add missing values if requested
      if `"`missingvalues'"' != "" {
        foreach theValueLabel in `theValueLabels' {
          local theLabelList_`theValueLabel' `" `theLabelList_`theValueLabel'' `missingvalues' "'
        }
      }

  // Back to original dataset to apply changes from codebook
  restore

    // Define value labels
    foreach theValueLabel in `theValueLabels' {
      label def `theValueLabel' `theLabelList_`theValueLabel'', replace
      }

    // Drop leftovers if requested
    cap drop `allDrops'

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
    [clear] [merge] [template] [KEEPall] [*]

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
    di "You have specified [keepall], which means you are forcing all variables to be appended even if you did not manually harmonize them."
    di "Make sure to check the resulting dataset carefully. Forcibly appending data, especially of different types, may result in loss of information."
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
    // create empty codebook
    preserve
      clear
      set obs 1
      gen `generate' = 0
        label var `generate' "Data Source (do not edit this row)"
        label def yesno 0 "No" 1 "Yes" .d "Don't Know" .r "Refused" .n "Not Applicable"
        label val `generate' yesno
      iecodebook export using "`using'"
    restore
    // append one codebook per survey
    local x = 0
    foreach survey in `surveys' {
      if `x' == 1 local mergeopt "`merge'"
      local ++x
      local filepath : word `x' of `anything'
      iecodebook export "`filepath'" using "`using'", template(`survey') `mergeopt'
    }
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
  di `"Applied codebook using `using' to `anything' – check your data carefully!"'

  // Final codebook
  local using = subinstr("`using'",".xlsx","_appended.xlsx",.)
    iecodebook export using "`using'"
    use `final_data' , clear

} // end qui
end

// Have a lovely day!
