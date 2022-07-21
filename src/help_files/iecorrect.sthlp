{smcl}
{* 13 Aug 2020}{...}
{hline}
help for {hi:iecorrect}
{hline}

{title:Title}

{phang2}{cmdab:iecorrect} {hline 2} Modify data points in a dataset
using an external human-readable changelog (spreadsheet) and
maintain non-code documentation for all manual data point edits.

{phang2} {cmdab:iecorrect} provides a workflow to make changes (corrections) 
to individual data points in a dataset without extensive Stata coding,
while documenting who made each change and why. 
The changelog spreadsheet serves as both the instructions
for {cmdab:iecorrect} to implement corrections as well as
a human-readable record of all changes made to data points.

{phang2} {cmdab:iecorrect} consists of two separate subcommands. 
See the {help iecorrect##IntendedWokflow:Intended workflow} section
for a full description of how to use the command.
For a more descriptive discussion on the intended usage and workflow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/iecorrect":DIME Wiki entry}.

{title:Functions}

{p 2 4} {p_end}
{break}
{p 2 4}{cmdab:iecorrect template} creates an Excel spreadsheet template
with empty columns for users to specify and document the corrections to be made by {bf:iecorrect apply}.
This subcommand will be run once per data set to set up the changelog template,
then changes will be manually entered.
{p_end}
{break}
{p 2 4}{cmdab:iecorrect apply} reads an Excel changelog spreadsheet created
by filling out the template created by {bf:iecorrect template}. 
All data point corrections specified in the spreadsheet will be applied to the dataset in memory.
A do-file implementing the complete set of corrections may optionally be generated and saved.
{p_end}
{break}

{title:Syntax}

{phang2}
{cmdab:iecorrect template}
{help using} {it:"/path/to/corrections/file.xlsx"}, {cmdab:idvar(}{it:varlist}{cmd:)} {break}
  [{cmdab:other}]
{p_end}

{phang2}
{cmdab:iecorrect apply}
{help using} {it:"/path/to/corrections_file.xlsx"}, {cmdab:idvar(}{it:varlist}{cmd:)} {break}
[
{cmdab:sheet:s(}{it:string}{cmd:)}
{cmdab:noi:sily}
{cmdab:other}
{cmdab:gen:erate} 
{cmdab:save(}{it:/path/to/do_file.do}{cmd:)} 
{cmdab:replace}
]{p_end}

{marker opts}{...}
{synoptset 28}{...}
{synopthdr:Options}
{synoptline}
{phang} {it:Corrections} {p_end}{break}
{synopt :{cmdab:idvar(}{it:varlist}{cmd:)}}
  Specify the variable list that uniquely identifies the dataset. 
  Values from these variables will be used to select the observations to be changed. 
  This option is always required. {p_end}
{synopt :{cmdab:sheet:s(}{it:string}{cmd:)}}
  Select which {help iecorrect##TypeCorrections:types of corrections} will be made.
  By default, corrections will be made from numeric, string, and drop sheets
  if this option is not specified.
  This option allows the user to select only a subset of them.
  {p_end}
{break}
{phang}{it:Documentation} {p_end}
{synopt :{cmdab:save(}{it:string}{cmd:)}}
  Save the do-file that makes modifications to the dataset
  in the requested location.{p_end}
{synopt :{cmdab:replace}}
  Overwrite the do-file that makes modifications to the dataset if it already exists.{p_end}
{synopt :{cmdab:noi:sily}}
  Print the code and list of modifications as they run.{p_end}
{break}
{phang} {it:Advanced Corrections} {p_end}
{synopt :{cmdab:other}}
  Include the "other" correction sheet to categorize open-ended responses. 
  This is an advanced option. It must be specified at the template subcommand 
  and at the apply subcommand to implement.
  See {help iecorrect##CatCorrections:corrections to categorical variables} below for more details.{p_end}
{synopt :{cmdab:gen:erate}}
  Specify this option along with with option {cmdab:other} 
  to add new variables to the datasets when making corrections to categorical variables. 
  Use with caution and read the full documentation for this option. 

{marker IntendedWokflow}{...}
{title:Intended workflow}

{pstd}When starting the data correction process for any dataset,
first run {cmd:iecorrect template} to create an empty Excel form.
This form should only be created once,
and then filled to indicate the changes that will be made to the data.
Once the form is filled, run {cmd:iecorrect apply} to apply the changes 
indicated in the form to the dataset that is currently in memory.{p_end}

{pstd}The Excel report includes three sheets by default, 
called {it:string}, {it:numeric}, and {it:drop}.
The {it:other} sheet may be added by specifying the {cmdab:other} option.
Each of these sheets indicates one type of correction.
Each type of correction requires slightly different input from the user, discussed below.
Do not delete any of the sheets or the headers in the template form, or the command will not run properly. {p_end}

{marker TypeCorrections}{...}
{title:Types of corrections}

{dlgtab:Columns for documentation:}

{pstd}The columns {it:initials} and {it:notes} are included in all tabs, and should be used to document the changes made to the code.{p_end}

{phang2}{it:initials} allows the team working with this data to keep track of {bf:who}
decided on corrections.{p_end}

{phang2}{it:notes} allows the team working with this data to document {bf:how} the 
issue and the correct value were identified.{p_end}

{dlgtab:Corrections to string and numeric variables:}

{pstd} String and numeric variable correction can be made through the {bf:string} and {bf:numeric} tabs of the Excel spreadsheet. 

{phang2}First, one column will appear for each specified {it:idvar}. 
These must be filled with the value of the ID variable in the observation to be corrected.
If filled with *, corrections will be applied to all relevant observations
with the indicated current value of the variable to be corrected,
as well as matching values of any other completed {it:idvar} columns.  
{p_end}

{phang2}After the columns for the specified {it:idvars}, the sheet contains the following columns:{p_end}

{phang2}{it:varname}, which should be filled with the {bf:name of the string variable to be corrected}. 
Filling this column is {bf:required} for this type of correction to run properly.{p_end}

{phang2}{it:value}, which should be filled with the {bf:desired corrected value} 
of the variable to be replaced in the selected observations.
This value will replace the current value once {cmd:iecorrect apply} is run. 
Filling this column is {bf:required} for this type of correction to run properly.{p_end}

{phang2}{it:valuecurrent}, which should be filled with the current, {bf:incorrect value}
of the string variable in
the observation to be corrected. Filling this column is not required for this 
type of correction to run properly, but either this column or the {it:idvalue}
column must be filled.{p_end}

{dlgtab:Dropping observations:}

{pstd}Corrections made by {it:dropping} observations are implemented through the 
{it:drop} tab of the Excel spreadsheet. This tab has two {bf:required} columns:{p_end}

{phang2}First, one column will appear for each specified {it:idvar}. 
These must be filled with the value of the ID variable in the observation to be corrected.
If filled with *, all relevant observations will be dropped
with the indicated current value of the variable to be corrected,
as well as matching values of any other completed {it:idvar} columns.  
{p_end}

{phang2}{it:n_obs}, which must be filled with the exact number of observations 
that should be dropped by the conditions specified in the corresponding line.
This column must always be filled for this type of correction to be performed
and it does not accept wildcards.
{cmd:iecorrect} will return an error if the number of observations 
that have the ID values specified in the line does not match
the value entered in this column.
It will also return the number of observations that were detected matching the ID pattern,
so that you can check your expectations against the data.{p_end}


{marker CatCorrections}{...}
{dlgtab:Corrections involving categorical variables:}

{pstd} 
In Stata, categorical variables are represented by numbers with associated value labels.
This tab allows string variables, such as the "Other, Specify" variables
that accompany categorical responses in many surveys, to be incorporated into categorical variables.
If the {bf:other} option is specified during the {bf:template} subcommand,
the spreadsheet template will have a sheet called {bf:other}.
If the {bf:other} option is specified during the {bf:apply} subcommand,
the modifications requested in the {bf:other} sheet will be applied to the data.
{p_end}

{pstd}
To use the {bf:other} sheet with categorical variables, do the following.
You will identify the string variable which is intended to be incorporated,
the value which you want to incorporate, the categorical variable that should
be modified, and the numerical value that the categorical variable should take.
You will then request changes through the {bf:other} sheet, using the following columns:{p_end}

{phang2}{it:strvar}, which must be filled with the name of the string variable representing 
the variable that needs to be encoded.  Filling this column 
is {bf:required} for this type of correction to run properly.{p_end}

{phang2}{it:strvaluecurrent}, which should be filled with the value of the 
string variable in the observation to be corrected. 
Filling this column is {bf:required} for this type of correction to run properly.{p_end}

{phang2}{it:catvar}, which should be filled with the {bf:name of the categorical variable to be corrected}. 
Filling this column is {bf:required} for this type of correction to run properly.
If this variable does not yet exist, the option {cmdab:gen:erate} can be used to create it. {p_end}

{phang2}{it:catvalue}, which should be filled with the {bf:correct value} of the categorical variable.
This value will replace the current value of the categorical variable
once {cmd:iecorrect apply} is run. (If the variable is already labeled,
those value labels will still work; but new labels for new values will need to be created separately.)
Filling this column is {bf:required} for this type of correction to run properly.{p_end}

{pstd}If the variable listed under the {bf:catvar} column does not exist, 
then the command will return an error indicating so. 
To have {cmd:iecorrect apply} create the specified variable,
use the option {cmdab:gen:erate}.
Any requested categorical variables that do not exist will be created.{p_end}

{pstd}{p_end}

{space 4}{hline}

{title:Examples}

{pstd}
{hi:Example 1: template subcommand}

{phang2}{inp:iecorrect template using "C:/myImpactEvaluation/baseline/documentation/Corrections.xlsx"}{p_end}

{pmore}Specified like this, {cmdab:iecorrect} will create a template Excel spreadsheet at
"C:/myImpactEvaluation/baseline/documentation/corrections.xlsx".
This template will be empty, and 
each tab in this template must be filled by the user following the instructions above
before running the {bf:apply subcommand} to implement the corrections.{p_end}

{phang}
{hi:Example 2: apply subcommand}

{phang2}{inp:iecorrect apply "C:/myImpactEvaluation/baseline/documentation/corrections.xlsx", idvar(key)}{p_end}

{pmore}Specified like this, {cmdab:iecorrect} starts by looking for the file
"C:/myImpactEvaluation/baseline/documentation/corrections.xlsx". If there is a report
with corrections, those corrections are applied to the data set.{p_end}

{title:Acknowledgements}

{phang}We would like to acknowledge the help in testing and proofreading we received in relation to this command and help file from (in alphabetic order):{p_end}
{pmore}Benjamin Daniels{break}Timo Kapelari{break}Matteo Ruzzante{break}Ankriti Singh{break}

{title:Author}

{phang}All commands in iefieldkit are developed by DIME Analytics at the World Bank's Development Impact Evaluations department.

{phang}Main authors: Luiza Cardoso de Andrade and Denisse Orozco Pereira, DIME Analytics, The World Bank Group

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "iefieldkit iecorrect" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/iefieldkit":the GitHub repository of iefieldkit}.{p_end}
