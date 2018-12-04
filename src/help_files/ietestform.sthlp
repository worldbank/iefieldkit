{smcl}
{hline}
help for {hi:ietesform}
{hline}

{title:Title}

{phang2}{cmdab:ietesform} {hline 2} Test Survey CTO for errors and best practices SCTO's server does not check for.

{phang2}For a more descriptive discussion on the intended usage and work flow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/SurveyCTO_Coding_Practices":DIME Wiki}.

{title:Syntax}

{phang2}
{cmdab:ietestform}
, {cmdab:surveyform(}{it:survey_filepath}{cmd:)} [{cmdab:csheetaliases(}{it:string}{cmd:)}  {cmdab:statalanguage(}{it:string}{cmd:)}
{cmdab:textreport(}{it:string}{cmd:)}]

{phang2}where {it:survey_filepath} is the file path to the Excel file with the Survey CTO form definition

{marker opts}{...}
{synoptset 28}{...}
{synopthdr:options}
{synoptline}
{synopt :{cmdab:csheetaliases(}{it:string}{cmd:)}}WRITE DESCRIPTION HERE.{p_end}
{synopt :{cmdab:statalanguage(}{it:string}{cmd:)}}name of Stata label column in the form definition (if not "stata").{p_end}
{synopt :{cmdab:textreport(}{it:string}{cmd:)}}file path to .txt report listing all issues found.{p_end}
{synoptline}

{title:Description}

{dlgtab:In brief:}
{pstd}{cmd:ietestform} takes a SurveyCTO form definition in Excel format and parses
 it to test for errors and best practices that SCTO's server does not check for. Some 
 of these test are testing that DIME Analytics' best practices are used, especially in 
 the context of collecting data that will be imported to Stata.

{dlgtab:Tests performed:}
{pstd}{cmd:No unused lists:} test that all lists in the choices sheets are used in the survey sheet.

{pstd}{cmd:Numeric name:} test that all VARIABLES IN THE NAME VARIABLE are numeric. This will create an error.

{pstd}{cmd:No duplicated combinations:} test that there are no duplicated labels within a list_name. This will issue a 
warning, but not an error.

{pstd}{cmd:No duplicated labels:} test that all combinations of list_name and name are unique.

{pstd}{cmd:Stata language:} test that there is one column with labels formatted for Stata.

{pstd}{cmd:Type column:} test for not matching begin/end group/repeat.

{pstd}{cmd:Long variable names:} test for variable names that are too long for Stata.

{pstd}{cmd:Name conflict after long to wide} test that repeat group variable names will not become too long for Stata in wide format.

{space 4}{hline}

{title:Options}

{phang}{cmdab:surveyform(}{it:survey_filepath}{cmd:)} 

{phang}{cmdab:csheetaliases(}{it:string}{cmd:)} 

{phang}{cmdab:statalanguage(}{it:string}{cmd:)} 

{phang}{cmdab:textreport(}{it:string}{cmd:)} 



{title:Test performed}

{pstd}TEST 1

{title:Examples}

{title:Acknowledgements}

{phang}We would like to acknowledge the help in testing and proofreading we received in relation to this command and help file from (in alphabetic order):{p_end}
{pmore}NAME 1 {break}NAME 2{break}NAME 3

{title:Author}

{phang}All commands in ietoolkit is developed by DIME Analytics at DECIE, The World Bank's unit for Development Impact Evaluations.

{phang}Main author: Kristoffer Bjarkefur, DIME Analytics, The World Bank Group

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "iefieldkit ietestform" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/iefieldkit":the GitHub repository of iefieldkit}.{p_end}
