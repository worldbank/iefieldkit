{smcl}
{* 31 Jul 2023}{...}
{hline}
help for {hi:ietestform}
{hline}

{title:Title}

{phang2}{cmdab:ietestform} {hline 2} Tests SurveyCTO form definition file for errors and best practices that the server does not check for.

{phang2}{it: This help file only covers information needed to run this command in Stata, for a description of the tests performed by this command please see this} {browse "https://dimewiki.worldbank.org/wiki/Ietestform":DIME Wiki article}.

{title:Syntax}

{phang2}
{cmdab:ietestform} using {it:"/path/to/form.xlsx"}, {cmdab:r:eportsave(}{it:"/path/to/report.csv"}{cmd:)} [{cmdab:stata:language(}{it:string}{cmd:)} {cmd:replace} {cmd:date}]


{marker opts}{...}
{synoptset 32}{...}
{synopthdr:Options}
{synoptline}
{phang}{it:Required}{p_end}
{synopt :{cmdab:using }{it:"/path/to/form.xlsx"}}Specify the file path to the file with the SurveyCTO form definition.{p_end}
{synopt :{cmdab:r:eportsave(}{it:"/path/to/report.csv"}{cmd:)}}Specify the file path to the .csv report you want to create listing all issues found.{p_end}

{phang}{it:Optional}{p_end}
{synopt :{cmdab:stata:language(}{it:string}{cmd:)}}Specify the name used for the Stata language label in the form definition. Default is {it:stata} which works if the column name is {it:label:stata}.{p_end}
{synopt :{cmd:replace}}Replaces the report file if there is already a file with that name in that location.{p_end}
{synopt :{cmd:date}}Adds the current date to the report file name.{p_end}
{synoptline}

{title:Description}

{pstd}{cmd:ietestform} takes a SurveyCTO form definition in Excel format and parses
 it to test for errors and best practices that the SurveyCTO server does not check for. Some
 of these test are testing that DIME Analytics' best practices are used, especially in
 the context of collecting data that will be imported to Stata.

{title:Tests performed}

{pstd}This helpfile is only meant to describe how to use the command in Stata. The tests this command performs are all described in detail in this {browse "https://dimewiki.worldbank.org/wiki/Ietestform":DIME Wiki article}.

{title:Options}

{phang}{cmdab:using }{it:"/path/to/form.xlsx"} specifies the file path to the file with the SurveyCTO form definition. The form definition can be either in .xlsx or .xls format. If you are using an older version of Stata and a newer version of Excel, then you might encounter issues with the .xslx format. You can then save the file in .xls format but you might lose conditional formatting and other newer features, although no data will be lost. The old syntax {inp:surveyform(}{it:"/path/to/form.xlsx"}{inp:)} is still allowed for backward compatibility with earlier versions of {cmd:ietestform}.{p_end}

{phang}{cmdab:r:eportsave(}{it:"/path/to/report.csv"}{cmd:)} specifies the file path to the .csv report you want to create listing all issues found.{p_end}

{phang}{cmdab:stata:language(}{it:string}{cmd:)} specifies the name used for the Stata language label in the form definition. Default is {it:stata} which works if the column name is {it:label:stata}. Whatever you call your columns, do not include {it:label:} in this option, only what comes after the colon in the column name in the form definition.{p_end}

{phang}{cmd:replace} replaces the report file if there is already a file with that name in that location. If replace is not used, then an error is thrown if a file already exist.{p_end}

{phang}{cmd:date} adds the current date to the report file name. If this option is used in combination with {cmd:replace}, then the last report generated each day will be saved on disk for future documentation.{p_end}

{title:Examples}

{pstd}All examples will use the following globals as folder paths:{p_end}

{pstd}{inp:global project "}C:\username\Documents\ProjectA{inp:"}{p_end}
{pstd}{inp:global formdef "}$project\form_definitions\{inp:"}{p_end}
{pstd}{inp:global output "}$project\ietestform_reports{inp:"}{p_end}

{pstd}{hi:Example 1.}

{pstd}{inp:ietestform using} {it:"$formdef/form.xlsx"}, {inp:reportsave(}{it:"$output/report.csv"}{inp:)}

{pstd}This is the simplest possible way this command can be run. In this example the form {it:form.xslx} is read and all tests are applied to the form definition. A report with the name {it:report.csv} written to disk and it will include any cases caught by the command.{p_end}

{pstd}{hi:Example 2.}

{pstd}{inp:ietestform using} {it:"$formdef/form.xlsx"}, {inp:reportsave(}{it:"$output/report.csv"}{inp:)} {inp:date} {inp:replace}

{pstd}This example will work very similarly to Example 1. But this command will overwrite any report already in the {it:$output} folder since the option {cmd:replace} is used. Also, since the option {cmd:date} the name of the report file will be {it:report_31JAN2019.csv} (the date will obviously be updated to the current date). Since {cmd:replace} and {cmd:date} are used together, then the last report created each day will be saved for documentation.{p_end}

{title:Author}

{phang}All commands in iefieldkit is developed by DIME Analytics at DECIE, The World Bank's unit for Development Impact Evaluations.

{phang}Author: Kristoffer Bjarkefur, DIME Analytics, The World Bank Group

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "iefieldkit ietestform" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/iefieldkit":the GitHub repository of iefieldkit}.{p_end}
