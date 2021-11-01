cap program drop ieaux_filename
	program		 ieaux_filename, rclass

	syntax using/
	/***********************************************************************
		Get the folder name
	************************************************************************/	
        * Standardize file path
		local using = subinstr("`using'", "\", "/", .)
		
		* Separate the folder name from the file name
        local r_lastslash = strlen(`"`using'"') - strpos(strreverse(`"`using'"'),"/")
        if strpos(strreverse(`"`using'"'),"/") == 0 local r_lastslash -1 // Set to -1 if there is no slash

		* If a folder was not specified, get the folder path
		if `r_lastslash' != -1 {
			local folder = substr(`"`using'"',1,`r_lastslash')
		}
		else {
			noi di as error	"{phang}You have not specified a folder path to the duplicates report. An absolute folder path is required.{p_end}"
			noi di as error `"{phang}This command will not work if you are trying to use {inp:cd} to set the directory and open or save files. To know more about why this practice is not allowed, {browse "https://dimewiki.worldbank.org/wiki/Stata_Coding_Practices#File_paths":see this article in the DIME Wiki}.{p_end}"'
			noi di as error	""
			error 198
			exit // It is necessary to put exist?
		}

	/***********************************************************************
			Get the file and ext name
	************************************************************************/
		
		* Everything that comes after the folder path is the file name and format
		local file	 	 = substr("`using'", `r_lastslash' + 2, .)

		* If a filename was specified, separate the file name from the file format
		if "`file'" != "" {

			* Get index of separation between file name and file format
			local r_lastsdot = strlen(`"`file'"') - strpos(strreverse(  `"`file'"'),".")
			local fileext    = substr(`"`file'"',`r_lastsdot'+1,.) // File format starts at the last period and ends at the end of the 
			local filename		= substr("`file'", 1, `r_lastsdot') // File name starts at the beginning and ends at the last period

		}
		if  "`fileext'" == "" local fileext 1
		
		
		return local folder    `folder'
		return local filename  `filename'
		return local fileext   `fileext'
		return local file      `file'
		return local using     `using'
end	


cap program drop ieaux_testfolder
    program      ieaux_testfolder 
	
	syntax, folderpath(string) [description(string)]
	
	* Test that the folder for the report file exists
	 mata : st_numscalar("r(dirExist)", direxists("`folderpath'"))
	 if `r(dirExist)' == 0  {
	 	noi di as error `"{phang}The folder path [`folderpath'/] used `description' does not exist.{p_end}"'
		error 601
	 }	
	
end 


cap program drop ieaux_fileext
	program 	 ieaux_fileext
	
	syntax using/ , fileext(namelist) testfileext(string)     // sometimes we want to validate more than 1 extention format
	
    * Check if the file extension is the correct 
	local ext ""
	foreach value in `fileext' {
		if (".`val'" == "`testfileext'")  local errorfile 1
		local ext `".`val' `ext'"' 		
	}	
	
	local wcount = `: word count `fileext''
	if ("`errorfile'" != "1") & ("`testfileext'" != "1") {
	   if `wcount' > 1 local pluralms= "s"
	   noi di as error `"{phang}The file {bf:`using'} may only have the extension format`pluralms' [`ext']. The format [`fileext'] is not allowed.{p_end}"'
	   error 198
	}
	
	
	* If no file extension was used, then add the extension
	if  "`testfileext'" == "1" { 
		local ext = word("`valfileext'",1) // If there are more than one extension, get first 
		local using  "`using'`ext'"
	}	
end


/* 2 types of error when we want to test file 
   - If the file already exist
   - if the file doesn't exist
   typeerror option validate it*/

/* When replace option is available for the comand,
   replace_ms add an aditional description to show that the
   user can used replace option to overwrite the file*/
   
cap program drop ieaux_testfile
	program      ieaux_testfile
	
	syntax using/ , typeerror(string) [replace(string) description(string) replace_ms(string)]
  
	* Error message if file already exists a
	cap confirm file "`using'"
    if (_rc == 0) & missing("`replace'") & ("`typeerror'" == "fileexist" ) {
		
		if !missing("`replace_ms'") {
		   local replace_ms = " Use [replace] option if yo want to overwrite it."
		}
	    noi di as error `"{phang}The file used [`using'] `description' already exists.`replace_ms' {p_end}"'
	    error 602	
	}
	 if (_rc == 601)  & ("`typeerror'" == "filenoexist" ) {
	    noi di as error `"{phang}The template is not found. The template must be created before the apply subcommand can be used. {p_end}"'
		error 601 
	 }
	
end 
 




	