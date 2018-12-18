{smcl}
{hline}
help for {hi:ietestform}
{hline}

{title:Title}

{phang2}{cmdab:ietestform} {hline 2} Test SurveyCTO form definition file for errors and best practices the server does not check for.

{phang2}{it: For a more descriptive discussion on the intended usage and workflow of this command please see the}
{browse "https://dimewiki.worldbank.org/wiki/Ietestform":DIME Wiki}.

{title:Syntax}

{phang2}
{cmdab:ietestform}
, {cmdab:s:urveyform(}{it:"/path/to/surveyform.xlsx"}{cmd:)} /// {break}
{cmdab:r:eport(}{it:"/path/to/report.csv"}{cmd:)} /// {break}
[{cmdab:stata:language(}{it:column_name}{cmd:)}]


{marker opts}{...}
{synoptset 28}{...}
{synopthdr:Options}
{synoptline}
{phang}{it:Required}{p_end}
{synopt :{cmdab:s:urveyform()}}Specify the filepath to the file with the SurveyCTO form definition.{p_end}
{synopt :{cmdab:r:eport()}}Specify the filepath to the .csv report you want to create listing all issues found.{p_end}

{phang}{it:Optional}{p_end}
{synopt :{cmdab:stata:language()}}Specify the name of the column with Stata labels in the form definition (if it is {it:not} "label:stata").{p_end}
{synoptline}

{title:Description}

{pstd}{cmd:ietestform} takes a SurveyCTO form definition in Excel format and parses
 it to test for errors and best practices that the SurveyCTO server does not check for. Some
 of these test are testing that DIME Analytics' best practices are used, especially in
 the context of collecting data that will be imported to Stata.

{title:Tests performed:}

{pstd}{it:For a more detailed discussion on each of the tests below and why they are best practices, please see the}
{browse "https://dimewiki.worldbank.org/wiki/Ietestform":DIME Wiki}.

{dlgtab 0:Survey}

{p 2 4}{cmd:Groups and repeats close:}{break}
Each begin_group should have a matching end_group, and repeats should be properly structured.
{p_end}

{p 2 4}{cmd:Group and repeats have names:}{break}
There should be no unnamed repeat or group. This is not strictly an error but it is good practice.
{p_end}

{p 2 4}{cmd:Group and repeat variable names do not conflict:}{break}
Variable names resulting from adding repeat group suffixes must not be the same as other existing variables.
This includes when converting from long format to wide format.
{p_end}

{p 2 4}{cmd:Variable names are not too long:}{break}
Variable names must not be too long for Stata.
This includes variables inside repeat groups whose names will become too long once suffixes are added in wide format.
{p_end}

{p 2 4}{cmd:Stata-compliant variable labels:}{break}
There must be one column with variable labels formatted for Stata, using the multiple language support format, such as {it:label:stata}.
These labels should be in English, be no longer than 80 characters, and use no special characters.
{p_end}

{dlgtab 0:Choices}

{p 2 4}{cmd:Stata-compliant value labels:}{break}
There must be one column with value labels formatted for Stata, using the multiple language support format, such as {it:label:stata}.
These labels should be in English, be no longer than 32 characters, and use no special characters.
{p_end}

{p 2 4}{cmd:All entries are unique:}{break}
All combinations of {it:list_name} and {it:value} must be unique.
{p_end}

{p 2 4}{cmd:All values are labelled:}{break}
All values must have a label.
{p_end}

{p 2 4}{cmd:No duplicated labels:}{break}
There should be no duplicated labels within a {it:list_name}.
{p_end}

{p 2 4}{cmd:All values are numeric:}{break}
All values in the {it:value} column must be numeric. Having non-numeric values will cause conflicts when importing to Stata.
{p_end}

{p 2 4}{cmd:No unused choice lists:}{break}
All lists in the {it:choices} sheets must be used at least once in the survey sheet.
{p_end}

{p 2 4}{cmd:No undefined value labels:}{break}
All entries in the {it:label} column on the {it:survey} sheet must have at least one value and name on the {it:choices} sheet.
{p_end}

 {hline}

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
