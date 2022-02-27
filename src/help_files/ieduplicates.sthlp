{smcl}
{* 14 Feb 2022}{...}
{hline}
help for {hi:ieduplicates}
{hline}

{title:Title}

{phang2}{cmdab:ieduplicates} {hline 2} Identify duplicates in ID variable and export them in
an Excel file that also can be used to correct the duplicates

{phang2}For a more descriptive discussion on the intended usage and work flow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/Ieduplicates":DIME Wiki}.

{title:Syntax}

{phang2}
{cmdab:ieduplicates}
{it:ID_varname} {help using} {it:"/path/to/duplicates_report.xlsx"}
, {cmdab:unique:vars(}{it:varlist}{cmd:)} {break}
[{cmdab:force} {cmdab:keep:vars(}{it:varlist}{cmd:)} {cmdab:tostringok} {cmdab:droprest}
{cmdab:nodaily} {break}
{cmdab:duplistid(}{it:string}{cmd:)} {cmdab:datelisted(}{it:string}{cmd:)}
{cmdab:datefixed(}{it:string}{cmd:)} {cmdab:correct(}{it:string}{cmd:)}{break}
{cmdab:drop(}{it:string}{cmd:)} {cmdab:newid(}{it:string}{cmd:)}
{cmdab:initials(}{it:string}{cmd:)} {cmdab:notes(}{it:string}{cmd:)}
{cmdab:listofdiffs(}{it:string}{cmd:)}]{p_end}



{phang2}where {it:ID_varname} is the variable that will be controlled for duplicates, and {it:"/path/to/duplicates_report.xlsx"} is the absolute file path where the duplicates report will be saved.

{marker opts}{...}
{synoptset 28}{...}
{synopthdr:options}
{synoptline}
{synopt :{cmdab:unique:vars(}{it:varlist}{cmd:)}}variables used as unique ID within groups of duplicates in {it:ID_varname}. May not be in date or time format.{p_end}
{synopt :{cmdab:force}}specifies that all unresolved duplicates with respect to {it:ID_varname} be dropped.{p_end}
{synopt :{cmdab:keep:vars(}{it:varlist}{cmd:)}}variables used to be included in the Excel report in addition to {it:ID_varname} and {cmdab:unique:vars()} {p_end}
{synopt :{cmdab:tostringok}}allows {it:ID_varname} to be recasted to string if required{p_end}
{synopt :{cmdab:droprest}}disables the requirement that duplicates must be explicitly deleted{p_end}
{synopt :{cmdab:nodaily}}disables daily back-up copies of the Excel report{p_end}

{pstd}{it:    {ul:{hi:Excel variable name options:}}}{p_end}

{pstd}This option allows users to customize the column names in the report Excel spreadsheet. This option is intended for situations when the dataset already has variable(s) named the same as the default Excel spreadsheet name. {p_end}

{synopt :{cmdab:duplistid(}{it:string}{cmd:)}}customizes variable {it:duplistid}{p_end}
{synopt :{cmdab:datelisted(}{it:string}{cmd:)}}customizes variable {it:datelisted}{p_end}
{synopt :{cmdab:datefixed(}{it:string}{cmd:)}}customizes variable {it:datefixed}{p_end}
{synopt :{cmdab:correct(}{it:string}{cmd:)}}customizes variable {it:correct}{p_end}
{synopt :{cmdab:drop(}{it:string}{cmd:)}}customizes variable {it:drop}{p_end}
{synopt :{cmdab:newid(}{it:string}{cmd:)}}customizes variable {it:newid}{p_end}
{synopt :{cmdab:initials(}{it:string}{cmd:)}}customizes variable {it:initials}{p_end}
{synopt :{cmdab:notes(}{it:string}{cmd:)}}customizes variable {it:notes}{p_end}
{synopt :{cmdab:listofdiffs(}{it:string}{cmd:)}}customizes variable {it:listofdiffs}{p_end}


{synoptline}

{title:Description}

{dlgtab:In brief:}
{pstd}{cmd:ieduplicates} outputs a report with any duplicates in {it:ID_varname} to an Excel file
and return the data set {it:without} those duplicates. Each time {cmd:ieduplicates} executes, it first
looks for an already created version of the Excel report, and applies any corrections already listed in it
before generating a new report. Note that there is no need to import the corrections manually. This command
reads the corrections directly from the Excel file as long as it is saved with the same file name.

{dlgtab:In more detail:}
{pstd}{cmd:ieduplicates} takes duplicates observations in {it:ID_varname} and exports
them to a duplicates report in the Excel file specified by {help using}. {it:ID_varname}
is by definition not unique in this Excel report and {cmdab:unique:vars(}{it:varlist}{cmd:)}
needs to be specified in order to have a unique reference for each row in the Excel report
when merging the corrections back to the original data set. The
{it:varlist} in {cmdab:unique:vars(}{it:varlist}{cmd:)} must uniquely and fully identify all
observations in the Excel report, either on its own or together with {it:ID_varname}. {cmd:ieduplicates}
then returns the data set without these duplicates.

{pstd}The Excel report includes three columns called {it:correct}, {it:drop} and {it:newid}.
Each of them represents one way to correct the duplicates. If {it:correct} is indicated with
a "correct" then that observation is kept unchanged, if {it:drop} is indicated with a "drop" then
that observation is deleted and if {it:newid} is indicated then that observation is assigned
a new ID using the value in column {it:newid}. After corrections are entered, the report should
be saved in the same location and without any changes to its name.

{pstd}Before outputting a new report {cmd:ieduplicates} always checks if there already is an
Excel report with corrections and applies those corrections before generating a new report. It is
at this stage that {cmdab:unique:vars(}{it:varlist}{cmd:)} is required as it otherwise is impossible
to know which duplicate within a group of duplicates that should be corrected in which way.

{pstd}{cmdab:keep:vars(}{it:varlist}{cmd:)} allows the user to include more variables in the Excel report
that can help identifying each duplicate is supposed to be corrected. The report also includes two
columns {it:initials} and {it:notes}. Using these columns is not required but it is recommended to use {it:initials}
to keep track of who decided how to correct that duplicate and to use {it:notes} to document why
the correction was chosen. If {it:initials} and {it:notes} are used, then the Excel report also functions
as an excellent documentation of the correction made.

{space 4}{hline}

{title:Options}

{phang}{help cmdab:using} specifies the file path where previous Excel
files will be looked for, and where the updated Excel report will be saved. Note that this needs to be
an absolute file path. A subfolder called {it:Daily}, where the duplicate report file is backed up daily,
will be created in the same folder as this file.

{phang}{cmdab:unique:vars(}{it:varlist}{cmd:)} list variables that by themselves or together
with {it:ID_varname} uniquely identifies all observations. This varlist is required when the corrections are
imported back into Stata and merged with the original data set. Time variables
are not allowed in {cmdab:uniquevars()} as Stata and Excel stores date and time slightly different, which
can casue errors when using these varaibles to merge the input in the Excel report back
into Stata. The time variable can be turned into a string variable using {inp: generate timevar_str = string(timevar,"%tc")} and
then be used in this options. Data that has been downloaded from
a server usually has a variable called "KEY" or similar. Such a variable would be optimal
for {cmdab:unique:vars(}{it:varlist}{cmd:)}.

{phang}{cmdab:force} specifies that all unresolved duplicates with respect to {it:ID_varname} be dropped.
This option is required when there are unresolved duplicates as a reminder that these observations
will be dropped, and the resulting data will be different from the original. Do not save the
data returned by {cmd:ieduplicates} with option force over the raw data, as information will be lost
and {cmd:ieduplicates} will not function on this data set, preventing reproducibility of the process.{p_end}

{phang}{cmdab:keep:vars(}{it:varlist}{cmd:)} list variables to be included in the exported
Excel report. These variables can help team members identifying which observation to keep,
drop and assign a new ID to. For data integrity reasons, be careful not to export and share
Excel files including both identifying variables and names together with {it:ID_varname}.

{phang}{cmdab:tostringok} allows {it:ID_varname} to be turned into a string variable in case
{it:ID_varname} is numeric but a value listed in {it:newid} is non-numeric. Otherwise an error is generated.

{phang}{cmdab:droprest} disables the requirement that duplicates must be explicitly deleted.
The default is that if one of the duplicates in a group of duplicates has a
correction, then that correction is only valid if all other duplicates in that
group have a correction as well. For example, if there are four observations with
the same value for {it:ID_varname} and one is correct, one needs a new ID and
two are incorrect and should be deleted. Then the first one is indicated to be
kept in the {it:correct} column, the second one is given a new ID in {it:newid}
and the other two observations must be indicated for deletion in {it:drop}
unless {cmdab:droprest}. The first two corrections are not considered valid and
will cause an error in case if {cmdab:droprest} is not specified and the other
two observations are not explicitly indicated to be dropped. It is recommended
to not use {cmdab:droprest} and to manually indicate all deletions to avoid
mistakes, but this option exists for cases when that might be very inconvenient.

{phang}{cmdab:nodaily} disables the generation of daily back-up copies of the
Excel report. The default is that the command saves dated copies of the Excel
report in a sub-folder called Daily in the folder specified in {help using}. If
the folder /Daily/ does not exist, then it is created unless the
option {cmdab:nodaily} is used.

{title:Excel variable name options:}

{phang}{cmdab:duplistid(}{it:string}{cmd:)} {cmdab:datelisted(}{it:string}{cmd:)}
{cmdab:datefixed(}{it:string}{cmd:)} {cmdab:correct(}{it:string}{cmd:)}
{cmdab:drop(}{it:string}{cmd:)} {cmdab:newid(}{it:string}{cmd:)}
{cmdab:initials(}{it:string}{cmd:)} {cmdab:notes(}{it:string}{cmd:)}
{cmdab:listofdiffs(}{it:string}{cmd:)}
allow the user to set a unique name for each default variable names (e.g. {it:duplistid}, {it:datelisted}, etc.) in the Excel report spreadsheet.
This is meant to be used when the variable name already exists in the dataset. To avoid error, the command offers a way to modify the variable name in the Excel Report spreadsheet. {p_end}


{title:The Excel Report}

{pstd}A report of duplicates will be created in the file path specified by {help using}
if any duplicates in {it:ID_varname} were found. The command will create a subfolder called {it:Daily}
in the folder where this report is saved. Daily back-ups of the report will be saved in the {it: Daily}
subfolder. If a report is backed up already that day, that report will not be overwritten. In case
the command is run more than once in a day, and creates different reports, a time-stamped report for
the same date will be saved instead.

{pstd}All duplicates in a group of duplicates must have a correction indicated. If
one or more duplicates are indicated as correct in {it:correct} or assigned a new
ID in {it:newid}, then all other duplicates with the same value in {it:ID_varname} must
be explicitly indicated for deletion. This requirement may (but probably
shouldn't) be disabled by option {cmdab:droprest}.

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

{dlgtab:Columns in Excel Report with data from the data set:}

{pstd}The columns above are followed by the values in {cmdab:unique:vars(}{it:varlist}{cmd:)}
and in {cmdab:keep:vars(}{it:varlist}{cmd:)}. These column keeps the name the
variables have in the data set. These variables can help the team to identify
which correction should be applied to which duplicate.

{space 4}{hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmdab:ieduplicates} stores the following results in {hi:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(numDup)}}number of unresolved duplicates{p_end}
{p2colreset}{...}

{pstd}
{cmd:r(numDup)} is intended to allow for the option to pause Stata in case unresolved duplicates
are found. See example 4 below for a code example on how to use {cmd:r(numDup)}. See {help pause} for instructions
on how to resume the execution of the code if Stata is paused.


{title:Examples}

{pstd}
{hi:Example 1.}

{phang2}{inp:ieduplicates HHID "C:\myImpactEvaluation\baseline\data\DuplicatesReport.xls" uniquevars(KEY)}{p_end}

{pmore}Specified like this {cmdab:ieduplicates} start by looking for the file
"C:\myImpactEvaluation\baseline\data\DuplicatesReport.xls". If there is a report
with corrections, those corrections are applied to the data set. Then the command looks for
unresolved duplicates in HHID and exports a new report if any duplicates were found. The data
set is returned without any of the unresolved duplicates. The variable KEY is used to separate
observations that are duplication in the ID var.

{phang}
{hi:Example 2.}

{phang2}{inp:ieduplicates HHID using "C:\myImpactEvaluation\baseline\data\DuplicatesReport.xls", keepvars(enumerator) uniquevars(KEY)}{p_end}

{pmore}Similar to the example above, but it also includes the variable enumerator in the Excel
report which is most likely helpful if the data set is collected through a household survey.

{phang}
{hi:Example 3.} Using {cmd:r(numDup)} to pause the execution of the code if
unresolved duplicates were found

{phang2}{inp:ieduplicates HHID using "C:\myImpactEvaluation\baseline\data\DuplicatesReport.xls", uniquevars(KEY)}{p_end}
{phang2}{inp:if (r(numDup) != 0) {c -(}}{p_end}
{phang3}{inp:pause}{p_end}
{phang2}{inp:{c )-}}{p_end}

{phang}
{hi:Example 4.} Using the Excel file. The table below could be the report generated in Example 2 above. Make the viewer window wider and reload the page if the table below does not display properly!

{col 3}{c TLC}{hline 130}{c TRC}
{col 3}{c |}{col 4}HHID{col 10}duplistid{col 21}datelisted{col 33}datefixed{col 44}correct{col 53}drop{col 59}newid{col 65}initials{col 75}notes{col 94}KEY{col 107}enumerator{col 121}listofdiffs{col 134}{c |}
{col 3}{c LT}{hline 130}{c RT}
{col 3}{c |}{col 4}4321{col 10}1{col 21}27Dec2015{col 33}02Jan2016{col 44}correct{col 53}   {col 59}    {col 65}KB{col 75}double submission{col 94}{it:uniquevalue}{col 107}{it:keepvarvalue}{col 121}{it:varlist}{col 134}{c |}
{col 3}{c |}{col 4}4321{col 10}2{col 21}27Dec2015{col 33}02Jan2016{col 44}   {col 53}drop{col 59}    {col 65}KB{col 75}double submission{col 94}{it:uniquevalue}{col 107}{it:keepvarvalue}{col 121}{it:varlist}{col 134}{c |}
{col 3}{c |}{col 4}7365{col 10}3{col 21}03Jan2016{col 33}         {col 44}   {col 53}   {col 59}    {col 65}  {col 75}                 {col 94}{it:uniquevalue}{col 107}{it:keepvarvalue}{col 121}{it:varlist}{col 134}{c |}
{col 3}{c |}{col 4}7365{col 10}4{col 21}03Jan2016{col 33}         {col 44}   {col 53}   {col 59}    {col 65}  {col 75}                 {col 94}{it:uniquevalue}{col 107}{it:keepvarvalue}{col 121}{it:varlist}{col 134}{c |}
{col 3}{c |}{col 4}1145{col 10}5{col 21}03Jan2016{col 33}11Jan2016{col 44}   {col 53}   {col 59}1245{col 65}IB{col 75}incorrect id     {col 94}{it:uniquevalue}{col 107}{it:keepvarvalue}{col 121}{it:varlist}{col 134}{c |}
{col 3}{c |}{col 4}1145{col 10}6{col 21}03Jan2016{col 33}11Jan2016{col 44}correct{col 53}   {col 59}    {col 65}IB{col 75}correct id       {col 94}{it:uniquevalue}{col 107}{it:keepvarvalue}{col 121}{it:varlist}{col 134}{c |}
{col 3}{c |}{col 4}9834{col 10}7{col 21}11Jan2016{col 33}         {col 44}   {col 53}   {col 59}    {col 65}  {col 75}                 {col 94}{it:uniquevalue}{col 107}{it:keepvarvalue}{col 121}{it:varlist}{col 134}{c |}
{col 3}{c |}{col 4}9834{col 10}8{col 21}11Jan2016{col 33}         {col 44}   {col 53}   {col 59}    {col 65}  {col 75}                 {col 94}{it:uniquevalue}{col 107}{it:keepvarvalue}{col 121}{it:varlist}{col 134}{c |}
{col 3}{c BLC}{hline 130}{c BRC}

{pmore}The table above shows an example of an Excel report with 4 duplicates groups with
two duplicates in each groups. The duplicates in 4321 and in 1145 have both been corrected
but 7365 and 9834 are still unresolved. Before any observation was corrected, all observations had
{it:datefixed}, {it:correct}, {it:drop}, {it:newid}, {it:initials} and {it:note} empty just like the observations for ID 7365 and 9834. {it:datefixed}
is not updated by the user, the command adds this date the first time the correction is made.

{pmore}Observation with duplistid == 5 was found to have been
assigned the incorrect ID while the data was collected. This observation is assigned the correct ID in {it:newid}
and observation duplistid == 6 is indicated to be correct. Someone with initials IB made this
correction and made a note. This note can and should be more descriptive but is kept short in this example.

{pmore}Observations with duplistid == 1 and duplistid == 2 were identified as a duplicate submissions of the same
observation. One is kept and one is dropped, usually it does not matter which you keep and which you drop, but that should be confirmed.

{pmore}Both corrections described in the example would have been easily identified using this command's sister command {help iecompdup}.



{phang}
{hi:Example 5.} {inp:ieduplicates HHIDusing "C:\myImpactEvaluation\baseline\data\DuplicatesReport.xls", uniquevars(KEY) drop(out) notes(notes_enumerators)}

{col 3}{c TLC}{hline 116}{c TRC}
{col 3}{c |}{col 4}HHID{col 10}duplistid{col 21}datelisted{col 33}datefixed{col 44}correct{col 53}out{col 59}newid{col 65}initials{col 75}notes_enumerators{col 94}KEY{col 107}listofdiffs{col 120}{c |}
{col 3}{c LT}{hline 116}{c RT}
{col 3}{c |}{col 4}4321{col 10}1{col 21}27Dec2015{col 33}02Jan2016{col 44}correct{col 53}   {col 59}    {col 65}KB{col 75}double submission{col 94}{it:uniquevalue}{col 107}{it:varlist}{col 120}{c |}
{col 3}{c |}{col 4}4321{col 10}2{col 21}27Dec2015{col 33}02Jan2016{col 44}   {col 53}drop{col 59}    {col 65}KB{col 75}double submission{col 94}{it:uniquevalue}{col 107}{it:varlist}{col 120}{c |}
{col 3}{c |}{col 4}7365{col 10}3{col 21}03Jan2016{col 33}         {col 44}   {col 53}   {col 59}    {col 65}  {col 75}                 {col 94}{it:uniquevalue}{col 107}{it:varlist}{col 120}{c |}
{col 3}{c |}{col 4}7365{col 10}4{col 21}03Jan2016{col 33}         {col 44}   {col 53}   {col 59}    {col 65}  {col 75}                 {col 94}{it:uniquevalue}{col 107}{it:varlist}{col 120}{c |}
{col 3}{c |}{col 4}1145{col 10}5{col 21}03Jan2016{col 33}11Jan2016{col 44}   {col 53}   {col 59}1245{col 65}IB{col 75}incorrect id     {col 94}{it:uniquevalue}{col 107}{it:varlist}{col 120}{c |}
{col 3}{c |}{col 4}1145{col 10}6{col 21}03Jan2016{col 33}11Jan2016{col 44}correct{col 53}   {col 59}    {col 65}IB{col 75}correct id       {col 94}{it:uniquevalue}{col 107}{it:varlist}{col 120}{c |}
{col 3}{c |}{col 4}9834{col 10}7{col 21}11Jan2016{col 33}         {col 44}   {col 53}   {col 59}    {col 65}  {col 75}                 {col 94}{it:uniquevalue}{col 107}{it:varlist}{col 120}{c |}
{col 3}{c |}{col 4}9834{col 10}8{col 21}11Jan2016{col 33}         {col 44}   {col 53}   {col 59}    {col 65}  {col 75}                 {col 94}{it:uniquevalue}{col 107}{it:varlist}{col 120}{c |}
{col 3}{c BLC}{hline 116}{c BRC}

{pmore} The variable names in Excel Report is now changed to the user speficied. If the user changed any of the variable names in the Excel Report, when importing the Excel file back to apply the decisions, run exactly the same code:{p_end}
{pmore}{inp:ieduplicates HHIDusing "C:\myImpactEvaluation\baseline\data\DuplicatesReport.xls", uniquevars(KEY) drop(out) notes(notes_enumerators)}{p_end}


{title:Acknowledgements}

{phang}We would like to acknowledge the help in testing and proofreading we received in relation to this command and help file from (in alphabetic order):{p_end}
{pmore}Mehrab Ali{break}Michell Dong{break}Paula Gonzalez{break}Seungmin Lee

{title:Author}

{phang}All commands in ietoolkit is developed by DIME Analytics at DECIE, The World Bank's unit for Development Impact Evaluations.

{phang}Main author: Kristoffer Bjarkefur, DIME Analytics, The World Bank Group

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "ietoolkit ieduplicates" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/ietoolkit":the GitHub repository of ietoolkit}.{p_end}
