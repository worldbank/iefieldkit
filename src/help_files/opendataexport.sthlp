{smcl}
{* Nov 29th 2018}
{hline}
Help for {hi:opendataexport}
{hline}

{title:Description}

{p 2 4 4}{cmd:opendataexport} reads the currently open dataset and either (A) creates a codebook for it in the specified location; or (B) reads a series of .dofiles that reference the data and keeps only the variables that those dofiles reference.

{title:Syntax}

{p 2 4 4}{cmd:opendataexport} {it:saving_location} {help using} {it:dofile_list} 

{title:Things to Remember}

{p 2 4 4}{cmd:opendataexport} can only use dofiles that reference the FULL NAME of each variable. Using shortcuts and abbreviations will cause the dataset to be incorrect. It will also keep variables whose names contain other variables that are referenced.

{title:Demo}

	global folder "{directory}"
	sysuse auto , clear
	
	opendataexport "$folder/opendataexport_codebook" using `" "demo1.do"  "demo2.do" "'
	opendataexport "$folder/opendataexport_compact" 	, compact


{title:Author}

Benjamin Daniels
DIME Analytics
World Bank Group

bdaniels@worldbank.org
{smcl}
{* Feb 8th 2018}
{hline}
Help for {hi:opendataexport}
{hline}

{title:Description}

{p 2 4 4}{cmd:opendataexport} reads the currently open dataset and either (A) creates a codebook for it in the specified location; or (B) reads a series of .dofiles that reference the data and keeps only the variables that those dofiles reference.

{title:Syntax}

{p 2 4 4}{cmd:opendataexport} {it:saving_location} {help using} {it:dofile_list} 

{title:Things to Remember}

{p 2 4 4}{cmd:opendataexport} can only use dofiles that reference the FULL NAME of each variable. Using shortcuts and abbreviations will cause the dataset to be incorrect. It will also keep variables whose names contain other variables that are referenced.

{title:Demo}

	global folder "{directory}"
	sysuse auto , clear
	
	opendataexport "$folder/opendataexport_codebook" using `" "demo1.do"  "demo2.do" "'
	opendataexport "$folder/opendataexport_compact" 	, compact


{title:Author}

Benjamin Daniels
DIME Analytics
World Bank Group

bdaniels@worldbank.org
