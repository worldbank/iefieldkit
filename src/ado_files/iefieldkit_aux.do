/* 
	This do-file contains functions to perform the following tasks:
*/

/*******************************************************************************
 GET FILE COMPONENTS 
 - Folder path
 - File extension and file name
********************************************************************************/
cap program drop ieaux_filename
	program		 ieaux_filename, rclass

	syntax using/
	
        * Standardize file path
		local using = subinstr("`using'", "\", "/", .)
		
		* Separate the folder name from the file name
        local r_lastslash = strlen(`"`using'"') - strpos(strreverse(`"`using'"'),"/")
        if strpos(strreverse(`"`using'"'),"/") == 0 local r_lastslash -1 // Set to -1 if there is no slash

		* If a folder was not specified, get the folder path
		local folder = substr(`"`using'"',1,`r_lastslash')

		* Everything that comes after the folder path is the file name and format
		local file	 = substr("`using'", `r_lastslash' + 2, .)

		* If a filename was specified, separate the file name from the file format
		if "`file'" != "" {

			* Get index of separation between file name and file format
			local r_lastsdot = strlen(`"`file'"') - strpos(strreverse(  `"`file'"'),".")
			
			local fileext    = substr(`"`file'"',`r_lastsdot'+1,.) // File format starts at the last period and ends at the end of the 
			if  "`fileext'" == "" local fileext 1
			
			local filename		= substr("`file'", 1, `r_lastsdot') // File name starts at the beginning and ends at the last period

		}
		
		return local folder    `folder'
		return local file      `file'
		return local filename  `filename'
		return local fileext   `fileext'
		return local using     `using'
end	


/*******************************************************************************
TEST IF A FOLDER ALREADY EXISTS
- option "folderpath" is the path to the directory
- option "description" will be used in the error message to explain where this folder path was referenced

********************************************************************************/
cap program drop ieaux_folderpath
    program      ieaux_folderpath
	
	syntax using/,  [description(string)]
	ieaux_filename using  `using'
	
	* Test that the folder for the report file exists
	if !missing("`r(folder)'"){
			 mata : st_numscalar("r(dirExist)", direxists("`r(folder)'"))
	         if `r(dirExist)' == 0  {
	 	     noi di as error `"{phang}The folder path [`r(folder)'/] used `description' does not exist.{p_end}"'
		     error 601
	         }			
	}
	
end 


/*******************************************************************************
TEST IF THE FILE EXTENSION IS THE CORRECT 
- option "testfileext" is a namelist of the correct extensions that the file may only have

********************************************************************************/

cap program drop ieaux_fileext
	program 	 ieaux_fileext, rclass
	
	syntax using/, testfileext(string) 
	ieaux_filename using  `using'
	
    * Check if the file extension is the correct 
	local ext ""
	foreach value in `testfileext' {
		if (".`value'" == "`r(fileext)'")  local errorfile 1
		local ext `".`value' `ext'"' 
	}	
	
	local wcount = `: word count `testfileext''
	if ("`errorfile'" != "1") & ("`r(fileext)'" != "1") {
	   if `wcount' > 1 local pluralms= "s"
	   noi di as error `"{phang}The file {bf:`using'} may only have the extension format`pluralms' [`ext']. The format [`r(fileext)'] is not allowed.{p_end}"'
	   error 198
	}
	
	* If no file extension was used, then add the extension
	if  "`r(fileext)'" == "1" { 
		local ext = word("`testfileext'",1) // If there are more than one extension, get first 
		local using  "`using'.`ext'"
		
	}	
	return local using `using'
end


	