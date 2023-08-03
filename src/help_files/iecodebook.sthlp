{smcl}
{* 31 Jul 2023}{...}
{hline}
help for {hi:iecodebook}
{hline}

{title:Title}

{p}{cmdab:iecodebook} {hline 2} performs common data cleaning tasks using dataset definitions (codebooks) written in Excel files. {p_end}
{p}For more detailed instructions, please refer to the {browse "https://dimewiki.worldbank.org/wiki/Iecodebook":iecodebook DIME Wiki entry}.

{title:Description}
{marker description}{...}

{p 2 4}{cmdab:iecodebook} is designed to automate repetitive data cleaning tasks in two situations:
{bf:apply}, where a large number of variables need to have arbitrary {help rename}, {help recode}, or {help label} commands applied to them;
and {bf:append}, where two or more datasets need to be harmonized to have the same variable names, labels, and value labels ("choices") in order to be appended together.
{cmdab:iecodebook} also provides an {bf:export} utility so that a human-readable record of the variables and their labels in a dataset
can be instantly created at any time.
{p_end}

{p 2 4}The purpose of {cmdab:iecodebook} is therefore to:{break}
(1) reduce the Stata coding required for an arbitrary number of commands, usually to a single command; and {break}
(2) to leave a human-readable record of the adjustments that were made to each dataset in Excel.
{p_end}

{p 2 4}For the {bf:apply} and {bf:append} syntaxes, {cmdab:iecodebook} provides a {bf:template} command
that will correctly set up the appropriate codebook or harmonization template.
In both cases, you then need to manually complete the template in order to tell the command the exact adjustments that you want to be made in the dataset.
This completed template becomes a more readable record of the changes made in data cleaning than a dofile typically is.
{p_end}

{title:Functions}

{p 2 4}{cmdab:iecodebook template}{break} creates an Excel codebook template that describes the current or targeted dataset(s),
with empty columns for you to specify the changes or harmonizations for the other {bf:iecodebook} commands.{p_end}
{break}
{p 2 4}{cmdab:iecodebook apply}{break} reads an Excel codebook that specifies
renames, recodes, variable labels, and value labels, and applies them to the current dataset.{p_end}
{break}
{p 2 4}{cmdab:iecodebook append}{break} reads an Excel codebook that specifies how variables should be harmonized across
two or more datasets - rename, recode, variable labels, and value labels - applies the harmonization, and appends the datasets.{p_end}
{break}
{p 2 4}{cmdab:iecodebook export}{break} creates an Excel or plaintext codebook that describes the current dataset,
optionally creates or verifies a datasignature for record-keeping, optionally re-saves the dataset in the specified location,
and optionally reduces the dataset to only the variables used in a set of specified dofiles.{p_end}

{title:Syntax}

{p 2 2}{it:Note that the correct command is always created by replacing}
	{break}{it:"apply" or "append" with "template" when creating the template,}
	{break}{it:and changing it back to use the completed codebook. It's that easy!}{p_end}

{dlgtab 0:Apply: Setting up and using a codebook to alter current data}

{p 2}{cmdab:iecodebook template} {help using} {it:"/path/to/codebook.xlsx"} , [{bf:replace}]{p_end}

{p 2 4 }{cmdab:iecodebook apply} {help using} {it:"/path/to/codebook.xlsx"} {break}
, [{bf:drop}] [{opt miss:ingvalues(# "label" [# "label" ...])}]{p_end}

{p 2 4 } {it:Note: This function operates on the dataset that is open in the current Stata session.}{p_end}

{dlgtab 0:Append: Setting up and using a codebook to harmonize and append multiple datasets}

{p 2 4}{cmdab:iecodebook template} {break}
{it:"/path/to/survey1.dta" "/path/to/survey2.dta" [...]} {break}
{help using} {it:"/path/to/codebook.xlsx"} {break}{p_end}
{p 2 3}, {bf:surveys(}{it:Survey1Name} {it:Survey2Name} [...]{bf:)}
{break} [{bf:match}] [{bf:replace}]{p_end}

{p 2 4}{cmdab:iecodebook append} {break}
{it:"/path/to/survey1.dta" "/path/to/survey2.dta" [...]} {break}
{help using} {it:"/path/to/codebook.xlsx"} {break} {p_end}
{p 2 3}, {bf:clear} {bf:surveys(}{it:Survey1Name} {it:Survey2Name} [...]{bf:)} {break}
[{opth gen:erate(varname)} {opt miss:ingvalues(# "label" [# "label" ...])}]{break}
[{bf:report}] [{bf:replace}] [{bf:keepall}] {p_end}


{dlgtab 0:Export: Creating codebooks and signatures for datasets}

{p 2 4}{cmdab:iecodebook export} ["/path/to/data"] {break}
{help using} {it:"/path/to/codebook.xlsx"} {break} {p_end}
{p 2 4}, [{bf:replace}] [{opt save}] [{bf:verify}] {break}
    [{opt sign:ature}] [{opt reset}] {break}
	[{opt plain:text}({it:compact} | {it:detailed})] [{opt noexcel}] {break}
    [{bf:trim(}{it:"/path/to/dofile1.do"} [{it:"/path/to/dofile2.do"}] [...]{bf:)}] [{opth trimkeep(varlist)}]{p_end}

{hline}

{title:Options}

{synoptset}{...}
{marker Options}{...}
{synopthdr:Apply Options}
{synoptline}
{synopt:{opt drop}}Requests that {cmdab:iecodebook} drop all variables which have no entry in the "name" column in the codebook.
The default behavior is to retain all variables. {bf:Alternatively, to drop variables (or remove value labels from variables) one-by-one,} write .
(a single period) in the "name" (or "choices") column of the codebook.
Unused value labels will always be removed from the datset by {cmdab:iecodebook},
but existing value labels will remain attached to variables by default.
Removing value labels explicitly with . is therefore recommended
when you wish to remove value label information from the dataset.{p_end}
{break}
{synopt:{opt miss:ingvalues()}}This option specifies standardized "extended missing values" to add to every value label definition in the "choices" column.
For example, specifying {bf:missingvalues(}{it:.d "Don't Know" .r "Refused" .n "Not Applicable"}{bf:)} will add those codes to every coded answer.{p_end}
{synoptline}

{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Append Options}
{synoptline}
{synopt:{opt clear}}{bf:This option is required}, as {cmdab:iecodebook append} will clear the data in memory.{p_end}
{break}
{synopt:{opt surveys()}}{bf:This option is always required in append.} When creating a template {it:or} reading a codebook from {it:"/path/to/codebook.xlsx"},
{cmdab:iecodebook} will use this list of names to identify each survey in the codebook.
{it:These must be exactly one word} for each survey, and they must come in the same order as the filepaths.
Names must have no spaces or special characters.
When importing, this will also be used to create a variable identifying the source of each observation.{p_end}
{break}
{synopt:{opt match}}This option can be used to "auto-align" the {bf:template} command when preparing for {bf:iecodebook append}.
If specified, it will cause any variables in later datasets with the same original name as a variable in the first dataset
to appear in the same row of the Excel sheet.{p_end}
{break}
{synopt:{opt gen:erate()}}This option names the variable identifying the source of each observation. If left blank, the default is "survey".{p_end}
{break}
{synopt:{opt miss:ingvalues()}}This option specifies standardized "extended missing values" to add to every value label definition in the "choices" column.
For example, specifying {bf:missingvalues(}{it:.d "Don't Know" .r "Refused" .n "Not Applicable"}{bf:)} will add those codes to every value-labeled answer.{p_end}
{break}
{synopt:{opt report}}This option writes a codebook in the standard {bf:export} format describing the appended dataset.
It will be placed in the same folder as the append codeboook, with the same name, with "_report" added to the filename.{p_end}
{break}
{synopt:{opt replace}}This option is required to overwrite a previous report.{p_end}
{break}
{synopt:{opt keep:all}}By default, {cmdab:iecodebook append} will only retain those variables with a new {it:name} explicitly written in the codebook to signify manual review for harmonization.
{bf:Specifying this option will keep all variables from all datasets. Use carefully!}
Forcibly appending data, especially of different types, can result in loss of information.
For example, appending a same-named string variable to a numeric variable may cause data deletion.
(This is common when one dataset has all missing values for a given variable.){p_end}
{synoptline}

{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Export Options}
{synoptline}
{synopt:{opt replace}}This option allows {cmdab:iecodebook export} to overwrite an existing codebook or dataset.{p_end}
{break}
{synopt:{opt save}}This option requests that a the data be saved at the same location as the codebook,
with the same name as the codebook.{p_end}
{break}
{synopt:{opt saveas()}}This option requests that a the data be saved at the specified location,
overwriting the codebook name.{p_end}
{break}
{synopt:{opt verify}}This option orders {cmdab:iecodebook export} to confirm that the current data precisely matches an existing codebook.
It will break with an error and describe all changes if there are any differences between the two.
A new codebook will not be written in this case.{p_end}
{break}
{synopt:{opt plain:text}({it:compact} | {it:detailed})}This option requests that the codebook be created as a plaintext file.
This file contains the default output of {help codebook} if argument {it:detailed}} is used,
and the compact output of {help codebook} if argument {it:compact} is used.
Only one of the arguments can be used}.{p_end}
{synopt:{opt noexcel}}This option requests that the codebook be created as a plaintext file.
It can only be used alongside option {opt plain:text()} and cannot be combined with {bf:verify}.{p_end}
{break}
{synopt:{opt sign:ature}}This option requests that a {help datasignature} be verified
in the same destination folder as the codebook and/or data are saved,
and will return an error if a datasignature file is not found or is different,
guaranteeing data has not changed since the last {bf:reset} of the signature.{p_end}
{break}
{synopt:{opt reset}}Specified with {opt sign:ature},
this option allows {cmdab:iecodebook export} to place a new datasignature
or overwrite an existing datasignature.{p_end}
{break}
{synopt:{opt trim()}}This option takes one or more dofiles as inputs, and trims the current dataset to only include variables used in those dofiles,
before executing any of the other {bf: export} tasks requested.{p_end}
{synopt:{opt trimkeep()}}This option adjusts {opt trim()} to retain additional
variables (such as ID variables) that are desired, but not used in code.{p_end}
{synoptline}

{marker example}
{title:Examples}

{dlgtab 0:Apply: Create and prepare a codebook to clean current data}

{p 2 4}{it:Step 1: Use the {bf:template} function to create a codebook template for the current dataset.}{p_end}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    {stata iecodebook template using "codebook.xlsx":iecodebook template using "codebook.xlsx"}

{p 2 4}{it:Step 2: Fill out some instructions on the "survey" sheet.}{p_end}
{p 4}{it:The "name" column renames variables and the "label" column applies labels.}{p_end}
{p 4}{it:The "choices" column applies value labels (defined on the "choices" sheet in Step 3):}{p_end}

{col 3}{c TLC}{hline 91}{c TRC}
{col 3}{c |}{col 4} name{col 12}label{col 22}choices{col 31}name:current{col 45}label:current{col 60}choices:current{col 80}recode:current{col 95}{c |}
{col 3}{c LT}{hline 91}{c RT}
{col 3}{c |}{col 4} _template{col 12}{it:(Ignore this placeholder, but do not delete it.)}{col 45}{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4} {col 95}{c |}
{col 3}{c |}{col 4} car{col 12}Name{col 22}{col 31}make{col 45}Make and Model{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}{it:value}{col 31}{col 45}{col 60} {col 80}{it:recode}{col 95}{c |}
{col 3}{c |}{col 4}{it:rename}{col 12}{it:label}{col 22}{it:labels}{col 31}{it:Current names, labels, types, & value labels}{col 45}{col 60} {col 80}{it:commands}{col 95}{c |}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}  |{col 31}{col 45}{col 60} {col 80}  |{col 95}{c |}
{col 3}{c |}{col 4} dom{col 12}Domestic?{col 22}yesno{col 31}foreign{col 45}Car type{col 60}origin{col 80}(0=1)(1=0){col 95}{c |}
{col 3}{c BLC}{hline 91}{c BRC}

{p 2}{it:Step 3: Use the "choices" sheet to define variable labels according to the following syntax.}{p_end}
{col 3}{c TLC}{hline 27}{c TRC}
{col 3}{c |}{col 4} list_name{col 15} value{col 22} label{col 31}{c |}
{col 3}{c LT}{hline 27}{c RT}
{col 3}{c |}{col 4} yesno{col 15} 0{col 22} No{col 31}{c |}
{col 3}{c |}{col 4} yesno{col 15} 1{col 22} Yes{col 31}{c |}
{col 3}{c |}{col 4}  {col 31}{c |}
{col 3}{c |}{col 4} {it:Each individual label}{col 31}{c |}
{col 3}{c |}{col 4} {it:gets an entry, grouped}{col 31}{c |}
{col 3}{c |}{col 4} {it:by the "list_name"}{col 31}{c |}
{col 3}{c |}{col 4} {it:corresponding to "choices"}{col 31}{c |}
{col 3}{c |}{col 4} {it:on the "survey" sheet.}{col 31}{c |}
{col 3}{c BLC}{hline 27}{c BRC}

{p 2}{it:Step 4: Use the {bf:apply} function to read the completed codebook.}{p_end}
{p 4 4}{it:Note that the correct command is created by replacing}
	{break}{it:"template" with "apply" after creating the template.}{p_end}
{break}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    {stata iecodebook apply using "codebook.xlsx":iecodebook apply using "codebook.xlsx"}
    {stata ta dom:tab dom}

{dlgtab 0:Append: Harmonize and combine multiple datasets using a codebook}

{p 2}{it:Step 0: Create two dummy datasets for testing iecodebook append.}{p_end}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    	{stata save data1.dta , replace:save data1.dta , replace}
    {stata rename (price foreign mpg)(cost origin car_mpg):rename (price foreign mpg)(cost origin car_mpg)}
    	{stata save data2.dta , replace:save data2.dta , replace}

{p 2 4}{it:Step 1: Create a harmonization template for iecodebook append.}{break}{it:Note that this clears current data.}{p_end}
{break}
{p 4 6}{inp:iecodebook template}
{break}{inp:"data1.dta" "data2.dta"}
{break}{inp: using "codebook.xlsx"}
{break}{inp: , surveys(First Second)}
{break}{stata iecodebook template "data1.dta" "data2.dta" using "codebook.xlsx" , surveys(First Second):(Run)}
{p_end}

{p 2}{it:Step 2: Fill out some instructions on the "survey" sheet.}{p_end}
{break}{p 4}{it:The survey sheet is designed to be rearranged so that stacked variables are placed in the same row.}{p_end}
{break}{p 4}{it:There will also be one extra "choices" sheet per survey with existing value labels for your reference.}{p_end}
{col 3}{c TLC}{hline 91}{c TRC}
{col 3}{c |}{col 4} name{col 12}label{col 22}choices{col 31}name:First{col 45}recode:First{col 60}name:Second{col 80}recode:Second{col 95}{c |}
{col 3}{c LT}{hline 91}{c RT}
{col 3}{c |}{col 4} survey{col 12}{it:Data Source (do not edit this row)}{col 45}{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4} {col 95}{c |}
{col 3}{c |}{col 4} cost{col 12}Cost{col 22}{col 31}price{col 45}{col 60}cost{col 80}{col 95}{c |}<- {it:align old}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}{it:value}{col 31}{col 45}{col 60} {col 80}{col 95}{c |}   {it:names}
{col 3}{c |}{col 4}{it:rename}{col 12}{it:label}{col 22}{it:labels}{col 31}{it:Original names, labels, types, & value labels for reference}{col 45}{col 60} {col 80}{col 95}{c |}   {it:and new}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}  |{col 31}{col 45}{col 60} {col 80}{col 95}{c |}   {it:recode}
{col 3}{c |}{col 4} dom{col 12}Domestic?{col 22}yesno{col 31}foreign{col 45}(0=1)(1=0){col 60}origin{col 80}(0=1)(1=0){col 95}{c |}<- {it:commands}
{col 3}{c BLC}{hline 91}{c BRC}
{p 2 4} {it: Note: When aligning the old variable names in the same row, cut and paste the whole variable entry.}
{break}{it:Don't just copy the names, leaving the old names in the original place.}

{p 2}{it:Step 3: Read and apply the harmonization template.}{p_end}
{p 4 4}{it:Note that the correct command is created by replacing}
	{break}{it:"template" with "append" after creating the template.}{p_end}
{break}
{p 4 6}{inp:iecodebook append}
{break}{inp:"data1.dta" "data2.dta"}
{break}{inp: using "codebook.xlsx"}
{break}{inp: , clear surveys(First Second)}
{break}{stata iecodebook append "data1.dta" "data2.dta" using "codebook.xlsx" , clear surveys(First Second):(Run)}{p_end}

{dlgtab 0:Export: Creating a simple codebook}
{break}
{p 2 2}{stata sysuse auto.dta , clear:sysuse auto.dta , clear}
{break}{stata iecodebook export using "codebook.xlsx":iecodebook export using "codebook.xlsx"}{p_end}

{hline}

{title:Acknowledgements}

{p 2 4}We would like to acknowledge the help in testing and proofreading we received
 in relation to this command and help file from (in alphabetical order):{p_end}{break}
{pmore}Kristoffer Bjarkefur{break}Luiza Cardoso De Andrade{break}Saori Iwamoto{break}Maria Ruth Jones{break}{break}...and all DIME Research Assistants and Field Coordinators{break}

{title:Authors}

{p 2}Benjamin Daniels, The World Bank, DEC

{p 2 4}Please send bug reports, suggestions and requests for clarifications
		 writing "iefieldkit: iecodebook" in the subject line to the email address
		 found {browse "https://github.com/worldbank/iefieldkit":here}.

{p 2 4}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through
		 the GitHub repository for iefieldkit:{break}
		 {browse "https://github.com/worldbank/iefieldkit"}
		 {p_end}
