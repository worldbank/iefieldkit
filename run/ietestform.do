
	do "${GitHub}/iefieldkit/src/ado_files/ietestform.ado"
	
	
/*******************************************************************************
	Should return no error
*******************************************************************************/

	ietestform 	using "$form/ietestform_surveyform.xlsx", ///
				reportsave("$form/ietestform_result.csv") ///
				replace ///
				date 
			
/*******************************************************************************
	Should return error
*******************************************************************************/
*-------------------------------------------------------------------------------
* 	Including using and survey form in same code 
*------------------------------------------------------------------------------- 
	
	cap ietestform 	using "$form/ietestform_surveyform.xlsx", ///
					surveyform("$form/ietestform_surveyform.xlsx") ///
					reportsave("$form/ietestform_result.csv") ///
					replace ///
					date 
	assert _rc == 198
	
*-------------------------------------------------------------------------------
* 	Missing "using"
*------------------------------------------------------------------------------- 
	
	cap ietestform "$form/ietestform_surveyform.xlsx", ///
					reportsave("$form/ietestform_result.csv") ///
					replace ///
					date 
	assert _rc == 101
	
*-------------------------------------------------------------------------------
* 	Missing file extenstion
*------------------------------------------------------------------------------- 
	
	cap ietestform 	using "$form/ietestform_surveyform", ///
					reportsave("$form/ietestform_result.csv") ///
					replace ///
					date 
	assert _rc == 601
	
	cap ietestform 	using "$form/ietestform_surveyform.xlsx", ///
					reportsave("$form/ietestform_result.") ///
					replace ///
					date 
	assert _rc == 601
	
*-------------------------------------------------------------------------------
* 	Incorrect file extenstion
*------------------------------------------------------------------------------- 
	
	cap ietestform 	using "$form/ietestform_surveyform.xls", ///
					reportsave("$form/ietestform_result.csv") ///
					replace ///
					date 
	assert _rc == 601					

	cap ietestform 	using "$form/ietestform_surveyform.xsl", ///
					reportsave("$form/ietestform_result.csv") ///
					replace ///
					date 
	assert _rc == 601		
	
	cap ietestform 	using "$form/ietestform_surveyform.xlsx", ///
					reportsave("$form/ietestform_result.cvs") ///
					replace ///
					date 
	assert _rc == 601	
	
	
*-------------------------------------------------------------------------------
* 	Stata label doesn't exist
*------------------------------------------------------------------------------- 
	
	cap ietestform 	using "$form/ietestform_surveyform.xlsx", ///
					reportsave("$form/ietestform_result.csv") ///
					replace ///
					date ///
					statalanguage(stata)
	assert _rc == 198
	
*-------------------------------------------------------------------------------
* 	Stata label incorrectly specified
*------------------------------------------------------------------------------- 

	cap ietestform 	using "$form/ietestform_surveyform.xlsx", ///
					reportsave("$form/ietestform_result.csv") ///
					replace ///
					date ///
					statalanguage(Stata)
	assert _rc == 198
	
