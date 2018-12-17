{smcl}
{* 29 Nov 2018}{...}
{hline}
help for {hi:iecodebook}
{hline}

    _                     __     __                __
   (_)__  _________  ____/ /__  / /_  ____  ____  / /__
  / / _ \/ ___/ __ \/ __  / _ \/ __ \/ __ \/ __ \/ //_/
 / /  __/ /__/ /_/ / /_/ /  __/ /_/ / /_/ / /_/ / ,<
/_/\___/\___/\____/\__,_/\___/_.___/\____/\____/_/|_|


{title:Title}

{p}{cmdab:iecodebook} {hline 2} performs common data cleaning tasks using dataset definitions (codebooks) written in Excel files. {p_end}

{title:Functions}

{p 2 4}{cmdab:iecodebook template}{break} creates an Excel template that describes the current or targeted dataset(s),
with empty columns for you to specify the changes or harmonizations for the other {bf:iecodebook} commands.{p_end}
{break}
{p 2 4}{cmdab:iecodebook apply}{break} reads an Excel codebook that specifies
renames, recodes, variable labels, and value labels, and applies them to the current dataset.{p_end}
{break}
{p 2 4}{cmdab:iecodebook append}{break} reads an Excel codebook that specifies how variables should be harmonized across
two or more datasets - rename, recode, variable labels, and value labels - applies the harmonization, and appends the datasets.{p_end}
{break}
{p 2 4}{cmdab:iecodebook export}{break} creates an Excel codebook that describes the current dataset,
and optionally produces an export version of the dataset with only variables used in specified dofiles.{p_end}

{title:Description}
{marker description}{...}

{p 2 4}{cmdab:iecodebook} is designed to automate repetitive data cleaning tasks in two situations:
{bf:apply}, where a large number of variables need to have arbitrary {help rename}, {help recode}, or {help label} commands applied to them;
and {bf:append}, when two or more datasets need to be harmonized to have the same variable names, labels, and value labels ("choices")
in order to be appended together.{p_end}

{p 2 4}The purpose of {cmdab:iecodebook} is therefore to (1) make the coding much more compact
for an arbitrary number of commands, usually to a single line of code; and (2) to leave a human-readable record of the adjustments
that were made and how they correspond across datasets in the case of {bf:append}. {cmdab:iecodebook} also provides an {bf:export} utility so that a human-readable record of the variables and their labels in a dataset
can be instantly created at any time.{p_end}

{p 2 4}For the {bf:apply} and {bf:append} syntaxes, {cmdab:iecodebook} provides a {bf:template} command
that will correctly set up a codebook or harmonization template
designed to be both human- and machine-readable.
In both cases, you will need to manually complete the template
in order to tell the command the exact adjustments that you want to be made in the dataset.{p_end}

{title:Syntax}

{p}{it:Setting up a template to apply to the current data:}{p_end}

{p 2}{cmdab:iecodebook template} {help using} {it:"/path/to/codebook.xlsx"}{p_end}

{p}{it:Applying the completed template to the current data:}{p_end}

{p 2}{cmdab:iecodebook apply} {help using} {it:"/path/to/codebook.xlsx"}, [{bf:drop}] [{opt miss:ingvalues(# "label" [# "label" ...])}]{p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt drop}}When applying a codebook from {it:"/path/to/codebook.xlsx"}, requests that {cmdab:iecodebook} drop all variables which are not given "final" names in the codebook.
The default behavior is to retain all variables. Alternatively, to drop variables one-by-one, write "drop" in the "name" column of the codebook.{p_end}
{synopt:{opt miss:ingvalues()}}This option specifies standardized "extended missing values" to add to every value label definition.
For example, specifying {bf:missingvalues(}{it:.d "Don't Know" .r "Refused" .n "Not Applicable"}{bf:)} will add those codes to every coded answer.{p_end}
{synoptline}

{p}{it:Setting up a template to append multiple datasets:}{p_end}

{p 2 4}{cmdab:iecodebook template} /// {break}
{it:"/path/to/survey1.dta" "/path/to/survey2.dta" [...]} /// {break}
{help using} {it:"/path/to/codebook.xlsx"} /// {break}
, {bf:surveys(}{it:Survey1Name} {it:Survey2Name} [...]{bf:)}{p_end}

{p}{it:Using a completed template to harmonize and append multiple datasets:}{p_end}

{p 2 4}{cmdab:iecodebook append} /// {break}
{it:"/path/to/survey1.dta" "/path/to/survey2.dta" [...]} /// {break}
{help using} {it:"/path/to/codebook.xlsx"} /// {break}
, {bf:surveys(}{it:Survey1Name} {it:Survey2Name} [...]{bf:)} /// {break}
[{opt miss:ingvalues(# "label" [# "label" ...])}] [{bf:nodrop}]{p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt surveys()}}{bf:This option is always required.} When creating a template {it:or} reading a codebook from {it:"/path/to/codebook.xlsx"}, {cmdab:iecodebook} will use this list of names
to identify each survey in the codebook. These should be exactly one word for each survey, and they must come in the same order as the filepaths.
When importing, this will also be used to create a variable {it:survey} identifying the source of each observation.{p_end}
{synopt:{opt miss:ingvalues()}}This option specifies standardized "extended missing values" to add to every value label definition.
For example, specifying {bf:missingvalues(}{it:.d "Don't Know" .r "Refused" .n "Not Applicable"}{bf:)} will add those codes to every value-labeled answer.{p_end}
{synopt:{opt nodrop}}{bf:Specifying this option will keep all variables from all datasets. Use carefully!}
Forcibly appending data, especially of different types, can result in loss of information.
For example, appending a same-named string variable to a numeric variable may cause data deletion.
(This is common when one dataset has all missing values for a given variable.)
By default, {cmdab:iecodebook append} will {bf:drop} all variables without a new {it:name} explicitly written in the codebook to signify manual review for harmonization.{p_end}
{synoptline}

{p}{it:Exporting a full codebook of the current data:}{p_end}

{p 2 4}{cmdab:iecodebook export} [{help if}] [{help in}] /// {break}
{help using} {it:"/path/to/codebook.xlsx"} ,  /// {break}
[{bf:trim(}{it:"/path/to/dofile1.do"} [{it:"/path/to/dofile2.do"}] [...]{bf:)}]{p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt trim()}} Takes one or more dofiles and trims the current dataset to only include variables used in those dofiles,
and saves an identically named .dta file at the location specified in {it:"/path/to/codebook.xlsx"}.{p_end}
{synoptline}

{marker example}

{title:Example 1: Applying a codebook to current data}

{p 2 4}{it:Step 1: Use the {bf:template} function to create a codebook template for the current dataset:}{p_end}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    {stata iecodebook template using "codebook.xlsx":iecodebook template using "codebook.xlsx"}

{p 2 4}{it:Step 2: Fill out some instructions on the "survey" sheet.}{p_end}
{p 4}{it:The "name" column renames variables and the "label" column applies labels.}{p_end}
{p 4}{it:The "choices" column applies value labels (defined on the "choices" sheet in Step 3):}{p_end}

{col 3}{c TLC}{hline 91}{c TRC}
{col 3}{c |}{col 4} name{col 12}label{col 22}choices{col 31}name:current{col 45}label:current{col 60}choices:current{col 80}recode:current{col 95}{c |}
{col 3}{c LT}{hline 91}{c RT}
{col 3}{c |}{col 4} survey{col 12}{it:(Ignore this placeholder, but do not delete it.)}{col 45}{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4} {col 95}{c |}
{col 3}{c |}{col 4} car{col 12}Name{col 22}{col 31}make{col 45}Make and Model{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}{it:value}{col 31}{col 45}{col 60} {col 80}{it:recode}{col 95}{c |}
{col 3}{c |}{col 4}{it:rename}{col 12}{it:label}{col 22}{it:labels}{col 31}{it:Current names, labels, types, & value labels}{col 45}{col 60} {col 80}{it:commands}{col 95}{c |}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}  |{col 31}{col 45}{col 60} {col 80}  |{col 95}{c |}
{col 3}{c |}{col 4} dom{col 12}Domestic?{col 22}yesno{col 31}foreign{col 45}Car type{col 60}origin{col 80}(0=1)(1=0){col 95}{c |}
{col 3}{c BLC}{hline 91}{c BRC}

{p 2}{it:Step 3: Use the "choices" sheet to define variable labels according to the following syntax:}{p_end}
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

{p 2}{it:Step 4: Use the {bf:apply} function to read the completed codebook:}{p_end}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    {stata iecodebook apply using "codebook.xlsx":iecodebook apply using "codebook.xlsx"}
    {stata ta dom:tab dom}

{title:Example 2: Appending multiple datasets using a codebook}

{p 2}{it:Step 0: Create two dummy datasets for testing iecodebook append}{p_end}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    {stata save data1.dta , replace:save data1.dta , replace}
    {stata rename (price foreign mpg)(cost origin car_mpg):rename (price foreign mpg)(cost origin car_mpg)}
    {stata save data2.dta , replace:save data2.dta , replace}

{p 2 4}{it:Step 1: Create a harmonization template for iecodebook append}{p_end}
{p 4 6}{inp:iecodebook template}       ///
{break}{inp:"data1.dta" "data2.dta"}   /// {it: Note that this}
{break}{inp: using "codebook.xlsx"}    /// {it: clears current data.}
{break}{inp: , surveys(First Second)}
{break}{stata iecodebook template "data1.dta" "data2.dta" using "codebook.xlsx" , surveys(First Second):(Run)}
{p_end}

{p 2}{it:Step 2: Fill out some instructions on the "survey" sheet.}{p_end}
{break}{p 4}{it:The survey sheet is designed to be rearranged so that stacked variables are placed in the same row.}{p_end}
{break}{p 4}{it:There will also be one extra "choices" sheet per survey with existing value labels for your reference.}{p_end}
{col 3}{c TLC}{hline 91}{c TRC}
{col 3}{c |}{col 4} name{col 12}label{col 22}choices{col 31}name:First{col 45}recode:First{col 60}name:Second{col 80}recode:Second{col 95}{c |}
{col 3}{c LT}{hline 91}{c RT}
{col 3}{c |}{col 4} survey{col 12}{it:(Ignore this placeholder, but do not delete it.)}{col 45}{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4} {col 95}{c |}
{col 3}{c |}{col 4} cost{col 12}Cost{col 22}{col 31}price{col 45}{col 60}cost{col 80}{col 95}{c |}<- {it:align old}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}{it:value}{col 31}{col 45}{col 60} {col 80}{col 95}{c |}   {it:names}
{col 3}{c |}{col 4}{it:rename}{col 12}{it:label}{col 22}{it:labels}{col 31}{it:Original names, labels, types, & value labels for reference}{col 45}{col 60} {col 80}{col 95}{c |}   {it:and new}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}  |{col 31}{col 45}{col 60} {col 80}{col 95}{c |}   {it:recode}
{col 3}{c |}{col 4} dom{col 12}Domestic?{col 22}yesno{col 31}foreign{col 45}(0=1)(1=0){col 60}origin{col 80}(0=1)(1=0){col 95}{c |}<- {it:commands}
{col 3}{c BLC}{hline 91}{c BRC}

{p 2}{it:Step 3: Read and apply the harmonization template:}{p_end}
{p 4 6}{inp:iecodebook append} 		/// {it:Note that the correct command is}
{break}{inp:"data1.dta" "data2.dta"} 	/// {it:created by replacing "template"}
{break}{inp: using "codebook.xlsx"} 	/// {it:with "append" after creating the template.}
{break}{inp: , surveys(First Second)}
{break}{stata iecodebook append "data1.dta" "data2.dta" using "codebook.xlsx" , surveys(First Second):(Run)}{p_end}

{title:Example 3: Creating a simple codebook}
{break}
{p 2 2}{stata sysuse auto.dta , clear:sysuse auto.dta , clear}
{break}{stata iecodebook export using "codebook.xlsx":iecodebook export using "codebook.xlsx"}{p_end}

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
