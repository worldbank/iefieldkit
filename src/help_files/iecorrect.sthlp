{smcl}
{* 13 Aug 2020}{...}
{hline}
help for {hi:iecorrect}
{hline}

{title:Title}

{phang2}{cmdab:iecorrect} {hline 2} Modify data points in a dataset and
create accompanying documentation to clarify why the changes were made.

{phang2} {cmdab:iecorrect} creates a workflow to make changes (corrections) to individual data points in a dataset,
while documenting who and why changes were madeFor a more descriptive discussion on the intended usage and workflow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/Iecorrect":DIME Wiki}.

{title:Functions}

{p 2 4}iecorrect consists of two separate subcommands. See section {help iecorrect##IntendedWokflow:Intended workflow} for a full description of how to use the command. {p_end}
{break}
{p 2 4}{cmdab:iecorrect template}{break} creates an Excel template
with empty columns for you to specify the modification to be made when using {bf:iecorrect apply}.{p_end}
{break}
{p 2 4}{cmdab:iecorrect apply}{break} reads an Excel file created
by iecorrect template and filled by the user to specify which changes should be made to the dataset and applies them to the current dataset.{p_end}
{break}

{title:Syntax}

{phang2}
{cmdab:iecorrect template}
{help using} {it:"/path/to/corrections/file.xlsx"}
{p_end}

{phang2}
{cmdab:iecorrect apply}
{help using} {it:"/path/to/corrections/file.xlsx"},
[
{cmdab:idvar(}{it:varlist}{cmd:)}
{cmdab:gen:erate} 
{cmdab:replace}
{cmdab:save(}{it:string}{cmd:)} 
{cmdab:noi:sily}
{cmdab:sheet(}{it:string}{cmd:)}]{p_end}

{marker opts}{...}
{synoptset 28}{...}
{synopthdr:options}
{synoptline}
{synopt :{cmdab:idvar(}{it:varlist}{cmd:)}}variable that uniquely identifies the dataset. Used to select specific observations to be changed. Required when using the {bf:apply} subcommand. {p_end}
{synopt :{cmdab:sheet(}{it:string}{cmd:)}}select which {help iecorrect##TypeCorrections:types of corrections} will be made.{p_end}
{synopt :{cmdab:gen:erate}}used to add new variables to the datasets when making corrections to categorical variables. Use with caution. See {help iecorrect##CatCorrections:corrections to categorical variables} below for more details.{p_end}
{synopt :{cmdab:save(}{it:string}{cmd:)}}save the do-file that makes modifications to the dataset.{p_end}
{synopt :{cmdab:replace}}overwrite the do-file that makes modifications to the dataset if it already exists.{p_end}
{synopt :{cmdab:noi:sily}}print the code and list of modifications as they run..{p_end}
{synoptline}

{marker IntendedWokflow}{...}
{title:Intended workflow}

{pstd}When starting the data correction process for any dataset, first run {cmd:iecorrect template} to create an empty Excel form. This form should only be created once, and then filled to indicate the changes that will be made to the data. Once the form is filled, run {cmd:iecorrect apply} to apply the changed indicated in the form to the dataset that is currently in memory.{p_end}

{pstd}The Excel report includes four sheets, called {it:categorical}, {it:string}, {it:numeric}, and {it:drop}. Each of these sheets indicates one type of correction. Each type of correction requires slightly different input from the user, discussed below. Do not delete the sheets and headers in the template form, or the command will not run properly. {p_end}

{marker TypeCorrections}{...}
{title:Types of corrections}

{dlgtab:Columns for documentation:}

{pstd}The columns {it:initials} and {it:notes} are included in all tabs, and should be used to document the changes made to the code.{p_end}

{phang2}{it:initials} allows the team working with this data to keep track of {bf:who}
decided on corrections.{p_end}

{phang2}{it:notes} allows the team working with this data to document {bf:how} the 
issue and the correct value were identified.{p_end}

{dlgtab:Corrections to string variables:}

{pstd} These correction can be made through the {bf:string} tab of the Excel spreadsheet. It contains the following columns:

{phang2}{it:strvar}, which should be filled with the {bf:name of the string variable to be corrected}. 
Filling this column is {bf:required} for this type of correction to run properly.{p_end}

{phang2}{it:idvalue}, which should be filled with the value of the ID variable in the observation 
o be corrected. Filling this column is not required for this type of correction 
to run properly, but {bf:either this column or the {it:valuecurrent} column must be filled}.
{p_end}

{phang2}{it:valuecurrent}, which should be filled with the current, {bf:incorrect value}
of the string variable in
the observation to be corrected. Filling this column is not required for this 
type of correction to run properly, but either this column or the {it:idvalue}
column must be filled.{p_end}

{phang2}{it:value}, which should be filled with the {bf:correct value} of the variable.
This value will replace the current value once {cmd:iecorrect apply} is run. 
Filling this column is {bf:required} for this type of correction to run properly.{p_end}

{dlgtab:Corrections to numeric variables:}

{pstd} These correction can be made through the {bf:numeric} tab of the Excel spreadsheet. It contains the following columns:{p_end}

{phang2}{it:numvar}, which should be filled with the {bf:name of the numeric variable to be corrected}. 
Filling this column is {bf:required} for this type of 
correction to run properly.{p_end}

{phang2}{it:idvalue}, which should be filled with the value of the ID variable 
in the observation to be corrected. Filling this column is not required for 
this type of correction to run properly, 
{bf:but either this column or the {it:valuecurrent} column must be filled}.
{p_end}

{phang2}{it:valuecurrent}, which should be filled with the current, 
{bf:incorrect value} of the numeric variable in the observation to be corrected. 
Filling this column is not required for this type of correction to run properly, 
{bf:but either this column or the {it:idvalue} column must be filled}.{p_end}

{phang2}{it:value}, which should be filled with the {bf:correct value} of the variable.
This value will replace the current value once {cmd:iecorrect apply} is run. 
Filling this column is {bf:required} for this type of correction to run properly.{p_end}

{marker CatCorrections}{...}
{dlgtab:Corrections to categorical variables:}

{pstd} These correction can be made through the {bf:other} tab of the Excel 
spreadsheet. 
The tab is called "other" because it is meant to enable the addition new categories 
based on the string values on "Other: specify" fields. 
If combined with the option generate, it can also be used to encode open-ended 
fields and create a categorical variable to represent them.{p_end}

{pstd}In Stata, categorical variables are represented by numbers with associated value
 labels. Differently from the other sheets, where the column to be correct is also used 
 to identify the rows to be corrected, this sheet uses values of a text column 
 (the string variable or {bf:strvar}) as a reference to replace values in a categorical 
 column (the {bf:catvar}). It contains the following columns:{p_end}
 
{phang2}{it:strvar}, which should be filled with the name of the string variable representing 
the "Other: specify" question (or whatever variable needs to be encoded).  Filling this column 
is {bf:required} for this type of correction to run properly.{p_end}

{phang2}{it:strvaluecurrent}, which should be filled with the value of the 
string variable in the observation to be corrected. 
Filling this column is {bf:required} for this type of correction to run properly.{p_end}

{phang2}{it:strvalue}, which should be filled with the value you want to replace 
the string variable with, in case you also want to correct it. 
Filling this column is not required for this type of correction to run properly.{p_end}

{phang2}{it:catvar}, which should be filled with the {bf:name of the categorical variable to be corrected}. 
Filling this column is {bf:required} for this type of correction to run properly.
If this variable does not yet exist, the option {cmdab:gen:erate} can be used to create it. {p_end}

{phang2}{it:catvalue}, which should be filled with the {bf:correct value} of the categorical variable.
This value will replace the current value of the categorical variable
once {cmd:iecorrect apply} is run. 
Filling this column is not required for this type of correction to run properly.{p_end}


{pstd}{it:If the variable listed under the {bf:catvar} column does not exist, then the command will return an error indicating so. To override this error and create the specified variable, use the option {cmdab:gen:erate}.}{p_end}

{pstd}{p_end}

{dlgtab:Dropping observations:}

{pstd}Corrections made by {it:dropping} observations are implemented through the 
{it:drop} tab of the Excel spreadsheet. This tab only has one {bf:require} column:{p_end}

{phang2}{it:idvalue}, which should be filled with the value of the ID variable in the observations to be dropped.{p_end}


{space 4}{hline}

{title:Examples}

{pstd}
{hi:Example 1: template subcommand}

{phang2}{inp:iecorrect template using "C:\myImpactEvaluation\baseline\documentation\Corrections.xlsx"}{p_end}

{pmore}Specified like this, {cmdab:iecorrect} will create a template Excel spreadsheet at
"C:\myImpactEvaluation\baseline\documentation\Corrections.xlsx".
This template will be empty, and 
each tab in this template must be filled by the user following the instructions above
before running the {bf:apply subcommand} to implement the corrections.{p_end}

{phang}
{hi:Example 2: apply subcommand}

{phang2}{inp:iecorrect apply "C:\myImpactEvaluation\baseline\documentation\Corrections.xlsx", idvar(key)}{p_end}

{pmore}Specified like this, {cmdab:iecorrect} starts by looking for the file
"C:\myImpactEvaluation\baseline\documentation\Corrections.xlsx". If there is a report
with corrections, those corrections are applied to the data set.{p_end}

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
