{smcl}
{* 24 Oct 2018}{...}
{hline}
help for {hi:iecodebook}
{hline}

{title:Title}

{phang}{cmdab:iecodebook} {hline 2} imports or exports dataset definitions (codebooks) written in Excel files.

{title:Functions}

{phang}{cmdab:iecodebook template} creates an Excel template that describes the current or targeted dataset(s),
with empty columns for you to specify the changes or harmonizations for the other {bf:iecodebook} commands.{p_end}
{break}
{phang}{cmdab:iecodebook apply} reads an Excel codebook that specifies
renames, recodes, variable labels, and value labels, and applies them to the current dataset.{p_end}
{break}
{phang}{cmdab:iecodebook append} reads an Excel codebook that specifies how variables should be harmonized across
two or more datasets - rename, recode, variable labels, and value labels - applies the harmonization, and appends the datasets.{p_end}
{break}
{phang}{cmdab:iecodebook export} creates an Excel codebook that describes the current dataset,
and optionally produces an export version of the dataset with only variables used in specified dofiles.{p_end}

{title:Template Setup}
{break}
{break} {it:To apply to current dataset:}
{phang}{cmdab:iecodebook template} {help using} {it:"/path/to/codebook.xlsx"}{p_end}
{break}
{break} {it:To append target datasets:}
{phang}{cmdab:iecodebook template} {it:"/path/to/survey1.dta" ["/path/to/survey2.dta"] [...]}
{break} {help using} {it:"/path/to/codebook.xlsx"}, surveys(Survey1Name [Survey2Name] [...]){p_end}

{title:Codebook Usage}

{phang}{cmdab:iecodebook apply} {help using} {it:"/path/to/codebook.xlsx"}, [drop]{p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt drop}}When applying a codebook from {it:"/path/to/codebook.xlsx"}, requests that {cmdab:iecodebook} drop any variables which are not given "final" names in the codebook.
The default behavior is to retain "unselected" variables. {p_end}
{synoptline}


{phang}{cmdab:iecodebook append} {it:"/path/to/survey1.dta" ["/path/to/survey2.dta"] [...]}
{break} {help using} {it:"/path/to/codebook.xlsx"}, surveys(Survey1Name [Survey2Name] [...]) {p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt surveys()}}{bf:This option is always required.} When creating a template {it:or} reading a codebook from {it:"/path/to/codebook.xlsx"}, {cmdab:iecodebook} will use this list of names
to identify each survey in the codebook. These should be exactly one word for each survey, and they must come in the same order as the filepaths.
When importing, this will also be used to create a variable identifying the source of each observation.{p_end}
{synoptline}


{phang}{cmdab:iecodebook export} {help using} {it:"/path/to/codebook.xlsx"} , {bf:[}trim({it:"/path/to/dofile1.do"} [{it:"/path/to/dofile2.do"}] [...]){bf:]}{p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt trim()}} Takes one or more dofiles and trims the current dataset to only include variables used in those dofiles,
and saves an identically named .dta file at the location specified in {it:"/path/to/codebook.xlsx"}.{p_end}
{synoptline}

{marker desc}
{title:Description}

{pstd}{cmdab:iecodebook} is designed to automate repetitive data cleaning tasks in two situations:
{bf:apply}, where a large number of variables need to have arbitrary {help rename}, {help recode}, or {help label} commands applied to them;
and {bf:append}, when two or more datasets need to be harmonized to have the same variable names, labels, and value labels ("choices")
in order to be appended together.{p_end}

{pstd}The purpose of {cmdab:iecodebook} is therefore to (1) make the coding much more compact
for an arbitrary number of commands, usually to a single line of code; and (2) to leave a human-readable record of the adjustments
that were made and how they correspond across datasets in the case of {bf:append}. {cmdab:iecodebook} also provides an {bf:export} utility so that a human-readable record of the variables and their labels in a dataset
can be instantly created at any time.{p_end}

{pstd}For the {bf:apply} and {bf:append} syntaxes, {cmdab:iecodebook} provides a {bf:template} command
that will correctly set up a codebook or harmonization template
designed to be both human- and machine-readable.
In both cases, you will need to manually complete the template
in order to tell the command the exact adjustments that you want to be made in the dataset.{p_end}

{marker example}
{title:Example 1: Creating and applying a codebook}

{inp}    {it:Create a codebook template for iecodebook apply:}
{inp}    	sysuse auto.dta  , clear
{inp}    	iecodebook template using "codebook.xlsx"

{inp}    {it:Fill out some instructions on the "survey" tab:}
{col 3}{c TLC}{hline 91}{c TRC}
{col 3}{c |}{col 4}name{col 12}label{col 22}choices{col 31}name:current{col 45}label:current{col 60}choices:current{col 80}recode:current{col 95}{c |}
{col 3}{c LT}{hline 91}{c RT}
{col 3}{c |}{col 4}car{col 12}Name{col 22}{col 31}make{col 45}Make and Model{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4}.{col 95}{c |}
{col 3}{c |}{col 4}.{col 95}{c |}
{col 3}{c |}{col 4}.{col 95}{c |}
{col 3}{c |}{col 4}dom{col 12}Domestic?{col 22}yesno{col 31}foreign{col 45}Car type{col 60}origin{col 80}(2=0){col 95}{c |}
{col 3}{c BLC}{hline 91}{c BRC}

{inp}    {it:Then, in the "choices" tab:}
{col 3}{c TLC}{hline 27}{c TRC}
{col 3}{c |}{col 4}list_name{col 15}value{col 22}label{col 31}{c |}
{col 3}{c LT}{hline 27}{c RT}
{col 3}{c |}{col 4}yesno{col 15}0{col 22}No{col 31}{c |}
{col 3}{c |}{col 4}yesno{col 15}1{col 22}Yes{col 31}{c |}
{col 3}{c BLC}{hline 27}{c BRC}
{inp}
{inp}    {it:Read and apply the completed codebook:}
{inp}    	sysuse auto.dta , clear
{inp}    	iecodebook apply using "codebook.xlsx"

{title:Example 2: Setting up and executing an append}
{inp}
{inp}    {it:Create two dummy datasets for testing iecodebook append}
{inp}    	sysuse auto.dta , clear
{inp}    	save data1.dta , replace
{inp}    	save data2.dta , replace
{inp}
{inp}    {it:Create a harmonization template for iecodebook append}
{inp}    	iecodebook template 		///
{inp}    	  "data1.dta" "data2.dta" 	///
{inp}    	  using "codebook.xlsx" 	///
{inp}    	, surveys(First Second)
{inp}
{inp}    {it:Read and apply the harmonization template (once filled out by user)}
{inp}    	iecodebook append 		/// {it:Note that the correct command is}
{inp}    	  "data1.dta" "data2.dta" 	/// {it:created by replacing "template"}
{inp}    	  using "codebook.xlsx" 	/// {it:with "append" after creating the template.}
{inp}    	, surveys(First Second)
{inp}
{inp}    {it:Create a simple codebook}
{inp}    	sysuse auto.dta , clear
{inp}    	iecodebook export using "codebook.xlsx"

{title:Acknowledgements}

{phang}We would like to acknowledge the help in testing and proofreading we received
 in relation to this command and help file from (in alphabetical order):{p_end}{break}
{pmore}Kristoffer Bjarkefur{break}Luiza Cardoso De Andrade{break}Maria Ruth Jones{break}{break}...and all DIME Research Assistants and Field Coordinators{break}

{title:Authors}

{phang}Benjamin Daniels, The World Bank, DEC

{phang}Please send bug reports, suggestions and requests for clarifications
		 writing "iefieldkit iecodebook" in the subject line to the email address
		 found {browse "https://github.com/worldbank/iefieldkit":here}.

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through
		 the GitHub repository of iefieldkit:{break}
		 {browse "https://github.com/worldbank/iefieldkit"}
		 {p_end}
