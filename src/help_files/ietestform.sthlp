{smcl}
{hline}
help for {hi:ietesform}
{hline}

{title:Title}

{phang2}{cmdab:ietesform} {hline 2} Test SurveyCTO form definition file for errors and best practices the server does not check for.

{phang2}{it: For a more descriptive discussion on the intended usage and workflow of this command please see the}
{browse "https://dimewiki.worldbank.org/wiki/Ietestform":DIME Wiki}.

{title:Syntax}

{phang2}
{cmdab:ietestform}
, {cmdab:s:urveyform(}{it:"/path/to/survey.xlsx"}{cmd:)} /// {break}
{cmdab:r:eport(}{it:"/path/to/report.csv"}{cmd:)} /// {break}
[{cmdab:stata:language(}{it:column_name}{cmd:)}]

{marker opts}{...}
{synoptset 28}{...}
{synopthdr:options}
{synoptline}
{phang}{it:Required options}{p_end}
{synopt :{cmdab:s:urveyform()}}Specify the filepath to the file with the SurveyCTO form definition.{p_end}
{synopt :{cmdab:r:eport()}}Specify the filepath to the .csv report you want to create listing all issues found.{p_end}

{phang}{it:Optional options}{p_end}
{synopt :{cmdab:stata:language()}}Specify the name of the column with Stata labels in the form definition (if it is {it:not} "label:stata").{p_end}
{synoptline}

{title:Description}

{dlgtab:In brief:}
{pstd}{cmd:ietestform} takes a SurveyCTO form definition in Excel format and parses
 it to test for errors and best practices that SCTO's server does not check for. Some
 of these test are testing that DIME Analytics' best practices are used, especially in
 the context of collecting data that will be imported to Stata.

{dlgtab:Tests performed:}

{phang2}For a more detailed discussion on each of the test below and why they are best practices, please see
the {browse "https://dimewiki.worldbank.org/wiki/Ietestform":DIME Wiki}.

{title:Choice sheet}

{pstd}{cmd:Numeric name/value:} test that all values in the name/value column are numeric. Having non-numeric values
will cause conflicts when importing to Stata.

{pstd}{cmd:No unused lists:} test that all lists in the choices sheets are used at least once in the survey sheet.

{pstd}{cmd:No duplicated labels:} test that there are no duplicated labels within a list_name.

{pstd}{cmd:Value labels with no values:} test that all non-missing entries in the label column have a non-missing value/name.

{pstd}{cmd:Unlabelled values:} test that all values/names have a label.

{pstd}{cmd:No duplicated name/value:} test that all combinations of list_name and name/value are unique.

{pstd}{cmd:Stata language:} test that there is one column with value labels formatted for Stata.

{title:Survey sheet}

{pstd}{cmd:Type column:} test for not matching begin/end group/repeat.

{pstd}{cmd:Long variable names:} test for variable names that are too long for Stata. This includes variables inside
repeat groups whose names will become too long once suffixes are added in wide format.

{pstd}{cmd:Naming repeat/group:} test for unnamed repeat/group. Not an error but good practice

{pstd}{cmd:Stata language:} test that there is one column with variable labels formatted for Stata.

{pstd}{cmd:Long variable labels:} test that variable labels have no more than 80 characters.

{pstd}{cmd:Name conflict after long to wide:} test that variable names resulting from adding repeat group suffixes
 will not be the same as other existing variables.

{space 4}{hline}

{title:Options}

{phang}{cmdab:surveyform(}{it:survey_filepath}{cmd:)}

{phang}{cmdab:report(}{it:string}{cmd:)}

{phang}{cmdab:statalanguage(}{it:string}{cmd:)}




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
