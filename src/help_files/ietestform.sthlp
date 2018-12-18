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

<<<<<< develop-ietestform
{pstd}{cmd:Groups and repeats:} Each begin_group should have a matching end_group, and repeats should be properly structured.

{pstd}{cmd:Long variable names:} Variable names must not be too long for Stata. This includes variables inside
=======
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
>>>>>> master
repeat groups whose names will become too long once suffixes are added in wide format.

{pstd}{cmd:Group and repeat names:} There should be no unnamed repeat or group. This is not strictly an error but it is good practice.

{pstd}{cmd:Stata language:} There must be one column with variable names formatted for Stata, using the multiple language support format.
These labels should be in English, be no longer than 32 characters, and use no special characters.

{pstd}{cmd:Long variable labels:} There must be one column with variable labels formatted for Stata, using the multiple language support format.
These labels should be in English, be no longer than 80 characters, and use no special characters.

{pstd}{cmd:Name conflict after long to wide:} Variable names resulting from adding repeat group suffixes
 must not be the same as other existing variables.

{dlgtab 0:Choices}

{pstd}{cmd:Numeric values:} All values in the value column must be numeric. Having non-numeric values
will cause conflicts when importing to Stata.

{pstd}{cmd:No unused lists:} All lists in the choices sheets must be used at least once in the survey sheet.

<<<<<< develop-ietestform
{pstd}{cmd:No duplicated labels:} There should be no duplicated labels within a list_name.

{pstd}{cmd:Value labels with no values:} All entries in the label column on the survey sheet must have at least one value and name on the choices sheet.

{pstd}{cmd:Unlabelled values:} All values must have a label.
=======
{phang}{cmdab:surveyform(}{it:survey_filepath}{cmd:)}

{phang}{cmdab:report(}{it:string}{cmd:)}

{phang}{cmdab:statalanguage(}{it:string}{cmd:)}
>>>>>> master

{pstd}{cmd:No duplicated name/value:} All combinations of list_name and value must be unique.

{pstd}{cmd:Stata language:} There must be one column with value labels formatted for Stata.
These labels should be in English, be no longer than 32 characters, and use no special characters.

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
