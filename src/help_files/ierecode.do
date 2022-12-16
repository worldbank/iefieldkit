{synopt :{cmdab:other}}
  Include the "other" correction sheet to categorize open-ended responses. 
  This is an advanced option. It must be specified at the template subcommand 
  and at the apply subcommand to implement.
  See {help iecorrect##CatCorrections:corrections to categorical variables} below for more details.{p_end}

 {synopt :{cmdab:gen:erate}}
  Specify this option along with with option {cmdab:other} 
  to add new variables to the datasets when making corrections to categorical variables. 
  Use with caution and read the full documentation for this option. 

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
