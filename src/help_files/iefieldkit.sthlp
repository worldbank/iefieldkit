{smcl}
{* 31 Jul 2023}{...}
{hline}
help for {hi:iefieldkit}
{hline}

{title:Title}

{phang}{cmdab:iefieldkit} {hline 2} Returns information on the version of iefieldkit installed

{phang}For a more descriptive discussion on the intended usage and work flow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/iefieldkit":DIME Wiki}.

{title:Syntax}

{phang}
{cmdab:iefieldkit}

{pstd}Note that this command takes no arguments at all.{p_end}

{marker desc}
{title:Description}

{pstd}This command returns the version of iefieldkit installed. It
	can be used in the beginning of a Master Do-file that is intended to be used
	by multiple users to programmatically test if iefieldkit is not installed for
	the user and therefore need to be installed, or if the version the user has
	installed is too old and needs to be upgraded.{p_end}

{pstd}This package includes the following commands:{p_end}
{pmore}- {help iecodebook}{p_end}
{pmore}- {help ieduplicates} and {help iecompdup}{p_end}
{pmore}- {help ietestform}{p_end}

{marker optslong}
{title:Options}

{phang}This command does not take any options.

{marker example}
{title:Examples}

{pstd}The code below is an example code that can be added to the top of any do-file.
	the example code first test if the command is installed, and install it if not. If it is
	installed, it test if the version is less than version 5.0. If it is, it
	replaces the iefieldkit file with the latest version. In your code you can skip
	the second part if you are not sure which version is required. But you should
	always have the first part testing that {inp:r(version)} has a value before using
	it in less than or greater than expressions.{p_end}

{inp}    cap iefieldkit
{inp}    if "`r(version)'" == "" {
{inp}      *iefieldkit not installed, install it
{inp}      ssc install iefieldkit
{inp}    }
{inp}    else if `r(version)' < 5.0 {
{inp}      iefieldkit version too old, install the latest version
{inp}      ssc install iefieldkit , replace
{inp}    }{text}

{title:Authors}

{phang}DIME Analytics, The World Bank, DECIE

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "iefieldkit iefieldkit" in the subject line to the email address
		 found {browse "https://github.com/worldbank/iefieldkit":here}

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through
		 the github repository of iefieldkit:{break}
		 {browse "https://github.com/worldbank/iefieldkit"}
