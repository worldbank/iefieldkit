{smcl}
{* 15 Dec 2017}{...}
{hline}
help for {hi:surveytoolkit}
{hline}

{title:Title}

{phang}{cmdab:surveytoolkit} {hline 2} Returns information on the version of surveytoolkit installed

{phang}For a more descriptive discussion on the intended usage and work flow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/surveytoolkit":DIME Wiki}.

{title:Syntax}

{phang}
{cmdab:surveytoolkit}

{pstd}Note that this command takes no arguments at all.{p_end}

{marker desc}
{title:Description}

{pstd}{cmdab:iegraph} This command returns the version of surveytoolkit installed. It
	can be used in the beginning of a Master Do-file that is intended to be used
	by multiple users to programmatically test if surveytoolkit is not installed for
	the user and therefore need to be installed, or if the version the user has
	installed is too old and needs to be upgraded.

{marker optslong}
{title:Options}

{phang}This command does not take any options.

{marker example}
{title:Examples}

{pstd}The code below is an example code that can be added to the top of any do-file.
	the example code first test if the command is installed, and install it if not. If it is
	installed, it test if the version is less than version 5.0. If it is, it
	replaces the surveytoolkit file with the latest version. In your code you can skip
	the second part if you are not sure which version is required. But you should
	always have the first part testing that {inp:r(version)} has a value before using
	it in less than or greater than expressions.

{inp}    cap surveytoolkit
{inp}    if "`r(version)'" == "" {
{inp}      *surveytoolkit not installed, install it
{inp}      ssc install surveytoolkit
{inp}    }
{inp}    else if `r(version)' < 5.0 {
{inp}      surveytoolkit version too old, install the latest version
{inp}      ssc install surveytoolkit , replace
{inp}    }{text}

{title:Acknowledgements}

{phang}We would like to acknowledge the help in testing and proofreading we received
 in relation to this command and help file from (in alphabetic order):{p_end}
{pmore}Luiza Cardoso De Andrade{break}Seungmin Lee{break}

{title:Authors}

{phang}Kristoffer Bjarkefur, The World Bank, DECIE

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "surveytoolkit surveytoolkit" in the subject line to the email address
		 found {browse "https://github.com/worldbank/ietoolkit":here}

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through
		 the github repository of surveytoolkit:{break}
		 {browse "https://github.com/worldbank/surveytoolkit"}
