{smcl}
{* 24 Oct 2018}{...}
{hline}
help for {hi:iecodebook}
{hline}

{title:Title}

{phang}{cmdab:iecodebook} {hline 2} imports or exports dataset definitions (codebooks) written in Excel files.

{title:Functions}

{phang}{cmdab:iecodebook apply} reads an Excel codebook that specifies
renames, recodes, variable labels, and value labels, and applies them to the current dataset.{p_end}
{break}
{phang}{cmdab:iecodebook append} reads an Excel codebook that specifies how variables should be harmonized across
two or more datasets – rename, recode, variable labels, and value labels – applies the harmonization, and appends the datasets.{p_end}
{break}
{phang}{cmdab:iecodebook export} creates an Excel codebook that describes the current dataset.{p_end}

{title:Syntax}

{phang}{cmdab:iecodebook apply} {help using} {it:"/path/to/codebook.xlsx"}, [template] [drop]{p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt template}}Requests that {cmdab:iecodebook} create a codebook template based on the current dataset,
 for you then complete, at {it:"/path/to/codebook.xlsx"}.
 Otherwise, it will read from a codebook at that location.{p_end}{break}
{synopt:{opt drop}}When applying a codebook from {it:"/path/to/codebook.xlsx"}, requests that {cmdab:iecodebook} drop any variables which are not given "final" names in the codebook.
The default behavior is to retain "unselected" variables. {p_end}
{synoptline}


{phang}{cmdab:iecodebook append} {it:"/path/to/survey1.dta" ["/path/to/survey2.dta"] [...]} {break} {help using} {it:"/path/to/codebook.xlsx"}, surveys(Survey1Name [Survey2Name] [...]) [template]{p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt surveys()}}{bf:This option is always required.} When creating a template {it:or} reading a codebook from {it:"/path/to/codebook.xlsx"}, {cmdab:iecodebook} will use this list of names
to identify each survey in the codebook. These should be exactly one word for each survey, and they must come in the same order as the filepaths.
When importing, this will also be used to create a variable identifying the source of each observation.{p_end}{break}
{synopt:{opt template}}Requests that {cmdab:iecodebook} create a codebook template based on the specified datasets,
 for you to then complete, at {it:"/path/to/codebook.xlsx"}.
 Otherwise, it will read from a codebook at that location.{p_end}
{synoptline}


{phang}{cmdab:iecodebook export} {help using} {it:"/path/to/codebook.xlsx"}{p_end}
{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt iecodebook export}} has no options.{p_end}
{synoptline}

{marker desc}
{title:Description}

{pstd}{cmdab:iecodebook} is designed to automate repetitive data cleaning tasks in two situations:
{bf:apply}, where a large number of variables need to have arbitrary {help rename}, {help recode},or {help label} commands applied to them;
and {bf:append}, when two or more datasets need to be harmonized to have the same variable names, labels, and value labels ("choices")
in order to be appended together.
{cmdab:iecodebook} also provides an {bf:export} utility so that a human-readable record of the variables and their labels in a dataset
can be instantly created at any time.{p_end}

{pstd}In the {bf:apply} and {bf:append} syntaxes, {cmdab:iecodebook} provides a {it:template} option
that will correctly set up a codebook or harmonization template
designed to be both human- and machine-readable.
In both cases, you will need to manually complete the template
in order to tell the command the exact adjustments that you want to be made in the dataset.{p_end}

{pstd}The purpose of {cmdab:iecodebook} is therefore to (1) make the coding much more compact
for an arbitrary number of commands, usually to a single line of code; and (2) to leave a human-readable record of the adjustments
that were made and how they correspond across datasets in the case of {bf:append}.{p_end}

{marker example}
{title:Examples}

{inp}    // Create a codebook template for iecodebook apply
{inp}    	sysuse auto.dta  , clear
{inp}    	iecodebook apply using "codebook.xlsx" , template
{inp}
{inp}    // Read and apply the codebook (once filled out by user)
{inp}    	sysuse auto.dta , clear
{inp}    	iecodebook apply using "codebook.xlsx"
{inp}
{inp}    // Create two dummy datasets for testing iecodebook append
{inp}    	sysuse auto.dta , clear
{inp}    	save data1.dta , replace
{inp}    	save data2.dta , replace
{inp}
{inp}    // Create a harmonization template for iecodebook append
{inp}    	iecodebook append ///
{inp}    	  "data1.dta" "data2.dta" ///
{inp}    	  using "codebook.xlsx" ///
{inp}    	, surveys(First Second) template
{inp}
{inp}    // Read and apply the harmonization template (once filled out by user)
{inp}    	iecodebook append ///
{inp}    	  "data1.dta" "data2.dta" ///
{inp}    	  using "codebook.xlsx" ///
{inp}    	, surveys(First Second)
{inp}
{inp}    // Create a simple codebook
{inp}    	sysuse auto.dta , clear
{inp}    	iecodebook export using "codebook.xlsx"

{title:Acknowledgements}

{phang}We would like to acknowledge the help in testing and proofreading we received
 in relation to this command and help file from (in alphabetical order):{p_end}{break}
{pmore}Kristoffer Bjarkefur{break}Luiza Cardoso De Andrade{break}Maria Ruth Jones{break}and all DIME Research Assistants {break}

{title:Authors}

{phang}Benjamin Daniels, The World Bank, DEC

{phang}Please send bug reports, suggestions and requests for clarifications
		 writing "iefieldkit iecodebook" in the subject line to the email address
		 found {browse "https://github.com/worldbank/iefieldkit":here}.

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through
		 the GitHub repository of iefieldkit:{break}
		 {browse "https://github.com/worldbank/iefieldkit"}
