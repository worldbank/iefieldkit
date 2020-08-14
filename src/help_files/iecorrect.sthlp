{smcl}
{* 13 Aug 2020}{...}
{hline}
help for {hi:iecorrect}
{hline}

{title:Title}

{phang2}{cmdab:iecorrect} {hline 2} Modify data points in a dataset and
create accompanying documentation to clarify why the changes were made.

{phang2}For a more descriptive discussion on the intended usage and work flow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/Iecorrect":DIME Wiki}.

{title:Functions}

{p 2 4}{cmdab:iecorrect template}{break} creates an Excel template
with empty columns for you to specify the modification to be made when using {bf:iecorrect apply}.{p_end}
{break}
{p 2 4}{cmdab:iecorrect apply}{break} reads an Excel file that specifies
which changes should be made to the dataset and applies them to the current dataset.{p_end}
{break}

{title:Syntax}

{phang2}
{cmdab:iecorrect}
{help using} {it:"/path/to/corrections/file.xlsx"}
[, {cmdab:idvar(}{it:varlist}{cmd:)}
{cmdab:gen:erate} 
{cmdab:replace}
{cmdab:save(}{it:string}{cmd:)} 
{cmdab:noi:sily}
{cmdab:sheet(}{it:string}{cmd:)}]{p_end}

{marker opts}{...}
{synoptset 28}{...}
{synopthdr:options}
{synoptline}
{synopt :{cmdab:idvar(}{it:varlist}{cmd:)}}variable that uniquely identifies the dataset. Used to select specific observations to be changed. {p_end}
{synopt :{cmdab:gen:erate}} {p_end}
{synopt :{cmdab:replace}} {p_end}
{synopt :{cmdab:save(}{it:string}{cmd:)}}save the do-file that makes modifications to the dataset.{p_end}
{synopt :{cmdab:noi:sily}}print the code and messages for the modifications. {p_end}
{synopt :{cmdab:sheet(}{it:string}{cmd:)}}{p_end}
{synoptline}

{title:Description}

{dlgtab:In more detail:}
{pstd}{cmd:iecorrect} {p_end}

{pstd}The Excel report includes sheets columns called {it:categorical}, {it:string},
{it:numeric}, and {it:drop}.

{space 4}{hline}

{title:Options}

{phang}{help cmdab:using} specifies the file path where the Excel file
that documents modifications will be saved. This file with be created by the
{bf:template} subcommand, filled by the user to indicate the modifications
desired, and read by the {bf:apply} subcommand to modify the dataset.{p_end}

{phang}{cmdab:idvar(}{it:varlist}{cmd:)}}variable that uniquely identifies the dataset.
Used to select specific observations to be changed. This option is required so
the "idvalue" column in the Excel file can be used.{p_end}

{phang}{cmdab:gen:erate}} {p_end}

{phang}{cmdab:replace}} {p_end}

{phang}{cmdab:save(}{it:string}{cmd:)}}save the do-file that makes modifications to the dataset.{p_end}

{phang}{cmdab:noi:sily}}print the code and messages for the modifications. {p_end}

{phang}{cmdab:sheet(}{it:string}{cmd:)}}{p_end}

{title:The Excel Report}

{pstd}This file with be created by the
{bf:template} subcommand, filled by the user to indicate the modifications
desired, and read by the {bf:apply} subcommand to modify the dataset.{p_end}

{dlgtab:Columns in Excel Report filled in automatically:}

{phang}{it:duplistid} stores an auto incremented duplicate list ID that is used
to maintain the sort order in the Excel Report regardless of how the data in memory
is sorted at the time {cmd:ieduplicates} is executed.

{phang}{it:datelisted} stores the date the duplicate was first identified.

{phang}{it:datefixed} stores the date a valid correction was imported the first
time for that duplicate.

{phang}{it:listofdiffs} stores a list with the names of the variables that are
different in two different observations. This list is truncated at 250 characters
and is only stores when there are exactly two duplicates. For full list or cases
where there are more then two duplicates, {help:iecompdup} should be used.

{dlgtab:Columns in Excel Report to be filled in manually by a user:}

{phang}{it:correct} is used to indicate that the duplicate should be kept. The only
valid value is "correct" to reduce the risk of unintended entries ("yes" is also
allowed for backward compatibility). The values are not sensitive to case. If {it:correct}
is indicated then both {it:drop} and {it:newid} must be left empty.

{phang}{it:drop} is used to indicate that the duplicate should be deleted. The only
valid value is "drop" to reduce the risk of unintended entries ("yes" is also
allowed for backward compatibility). The values are not sensitive to case. If {it:drop}
is indicated then both {it:correct} and {it:newid} must be left empty.

{phang}{it:newid} is used to assign a new ID values to a duplicate. If {it:ID_varname}
is a string then all values are valid for {it:newid}. If {it:ID_varname} is numeric then
only digits are valid, unless the option {cmdab:tostringok} is specified.
If {cmdab:tostringok} is specified and {it:newid} is non-numeric, then {it:ID_varname}
is recasted to a string variable. If {it:newid} is indicated then both {it:correct} and {it:drop} must be
left empty.

{phang}{it:initials} allows the team working with this data to keep track on who
decided on corrections.

{phang}{it:notes} allows the team working with this data to document the reason
for the duplicates and the why one type of correction was chosen over the others.

{space 4}{hline}

{title:Examples}

{pstd}
{hi:Example 1: template subcommand}

{phang2}{inp:iecorrect template using "C:\myImpactEvaluation\baseline\documentation\Corrections.xlsx"}{p_end}

{pmore}Specified like this {cmdab:iecorrect} start by looking for the file
"C:\myImpactEvaluation\baseline\data\DuplicatesReport.xls". If there is a report
with corrections, those corrections are applied to the data set. Then the command looks for
unresolved duplicates in HHID and exports a new report if any duplicates were found. The data
set is returned without any of the unresolved duplicates. The variable KEY is used to separate
observations that are duplication in the ID var.

{phang}
{hi:Example 2: apply subcommand}

{phang2}{inp:iecorrect apply "C:\myImpactEvaluation\baseline\documentation\Corrections.xlsx", idvar(key)}{p_end}

{pmore}Similar to the example above, b

{title:Acknowledgements}

{phang}We would like to acknowledge the help in testing and proofreading we received in relation to this command and help file from (in alphabetic order):{p_end}
{pmore}Timo Kapelari{break}Matteo Ruzzante{break}Ankriti Singh{break}

{title:Author}

{phang}All commands in iefieldkit are developed by DIME Analytics at the World Bank's Development Impact Evaluations department.

{phang}Main author: Luiza Cardoso de Andrade, DIME Analytics, The World Bank Group

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "iefieldkit iecorrect" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/iefieldkit":the GitHub repository of iefieldkit}.{p_end}
