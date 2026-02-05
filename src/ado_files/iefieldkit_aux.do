/* 
	This do-file contains functions to perform the following tasks:
*/

/*******************************************************************************
 GET FILE COMPONENTS 
 - Folder path
 - File extension and file name
********************************************************************************/
cap program drop ieutil_parse_filepath
	program		 ieutil_parse_filepath, rclass

	syntax using/
	
        * Standardize file path so Mac and Linux systems handle this path correctly
		local using = subinstr("`using'", "\", "/", .)
		
		* Separate the folder name from the file name
        local r_lastslash = strlen(`"`using'"') - strpos(strreverse(`"`using'"'),"/")
        if strpos(strreverse(`"`using'"'),"/") == 0 local r_lastslash -1 // Set to -1 if there is no slash

		* If a folder was specified, get the folder path
		local folder = substr(`"`using'"',1,`r_lastslash')

		* Everything that comes after the folder path is the file name and format
		local file	 = substr("`using'", `r_lastslash' + 2, .)

		* If a filename was specified, separate the file name from the file format
		if "`file'" != "" {

			* Get index of separation between file name and file format
			local r_lastsdot = strlen(`"`file'"') - strpos(strreverse(  `"`file'"'),".")
			
			local fileext    = substr(`"`file'"',`r_lastsdot'+1,.) // File format starts at the last period and ends at the end of the 
			
			local filename		= substr("`file'", 1, `r_lastsdot') // File name starts at the beginning and ends at the last period

		}
		
		return local folderpath       `folder'
		return local file             `file'
		return local filename         `filename'
		return local fileext          `fileext'
		return local filepath         `using'
end	


/*******************************************************************************
TEST IF A FOLDER ALREADY EXISTS
- option "folderpath" is the path to the directory
- option "description" will be used in the error message to explain where this folder path was referenced

********************************************************************************/
cap program drop ieutil_folderpath
    program      ieutil_folderpath
	
	syntax using/,  [description(string)]
	ieutil_parse_filepath using  `using'

	* Test that the folder for the report file exists
	if !missing("`r(folderpath)'"){
			 mata : st_numscalar("r(dirExist)", direxists("`r(folderpath)'"))
	         if `r(dirExist)' == 0  {
	 	     noi di as error `"{phang}The folder path [`r(folderpath)'/] used `description' does not exist.{p_end}"'
		     error 601
	         }			
	}
	
end 


/*******************************************************************************
TEST IF THE FILE EXTENSION IS THE CORRECT 
- option "testfileext" is a namelist of the correct extensions that the file may only have

********************************************************************************/

cap program drop ieutil_fileext
	program 	 ieutil_fileext, rclass
	
	syntax using/, allowed_exts(string) [default_ext(string)]
	
	*Parse the input
	ieutil_parse_filepath using  `using'
	local this_filename "`r(filename)'"
	local this_ext      "`r(fileext)'" 
	
	*Test if using has no file
	if missing("`this_filename'") {
		noi di as error `"{phang}The path {bf:`using'} does not have a file name for which extension can be tested.{p_end}"'
		error 198
	}	
	*Test is using has no file extension
	else if missing("`this_ext'") {
		
		*Test if no deafult ext was provided
		if missing("`default_ext'") {
			noi di as error `"{phang}The file in {bf:`using'} does not have a file extension and no default was provided.{p_end}"'
		error 198
		}
		
		*Apply the deafult extension
		else {
			
			local return_file  "`using'`default_ext'"
			
		}
	}
	
	* Using has both file and extension
	else {
		
		* Test if extension is among the allowed extensions
		if `: list this_ext in allowed_exts' == 1 {
			*Extension is allowed, return file name as is
			local return_file  "`using'"	
		}
		
		* File extension used is not allowed
		else {
		   noi di as error `"{phang}The file extension [`this_ext'] in file {bf:`using'} is not allowed. Allowed extensions: [`allowed_exts'].{p_end}"'
		   error 198
		}
	}
	
	*Return checked filename
	return local file_path `return_file'
end


	