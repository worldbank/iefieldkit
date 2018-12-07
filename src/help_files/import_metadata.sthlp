{smcl}
{* Nov 28th 2018}
{hline}
Help for {hi:import_metadata}
{hline}

{title:Title} 

{phang2}{cmd:import_metadata} {hline 2} imports data from one or more spreadsheets(.xlsx files) and/or datasets(.dta files), and appends them, using a metadata spreadsheet containing information about the variables. {cmd:import_metadata} does this by creating a metadata spreadsheet from dataset(s) specified, containing information about variable names. {cmdab:import_metadata} recodes and labels variables in the dataset, and appends multiple datasets according to the metadata spreadsheet. More description at {help import_metadata##description:Description}.


{title:Syntax}

{phang2}{cmdab:import_metadata} {it:file_list} {help using} {it:metadata_file} {break} 
,[{opt p:rep}] [{help import_metadata##metadataprep:metadata_prep}] [{help import_metadata##fileimp:file_import_options}] [{help import_metadata##metadataoptions:metadata_options}] [{help import_metadata##outputoptions:output_options}]{p_end}


{synoptset 23}{...}
{synopthdr:options}
{synoptline}
{pstd}{it:    {ul:{hi:Preparation of metadata spreadsheet}}}{p_end}

{marker metadataprep}{...}
{synopt:{opt p:rep}} Creates the metadata spreadsheet from a file (.xlxs or .dta) that contains dataset. {cmdab:prep} will extract information about variable labels, variable names, value labels, etc. from the input file to create the metadata spreadsheet. This metadata spreadsheet will be used as the template spreadsheet in appending files. {break}
{break}
example: import_metadata "{it:file_name}" {help using} {it:"${directory}{it:/my_metadata}"}, prep{break}
where {it:file_name} is the file from which to create the metadata spreadsheet.{p_end}

{pstd}{it:    Metadata template options} {p_end}

{synopt:{opt name:row(#)}}Do not include this option if you wish to use column letters as variable names. Otherwise, indicate the row number of the master spreadsheets containing original variable names; this must me consistent across all spreadsheets. If using a .dta file, variable names will automatically be included.{p_end}{break}
{synopt: {opt head:row(#)}}Indicate the row in the master spreadsheets which contains data labels to prefill in the metadata sheet. Exclude this option to use the variable names as the prefilled labels. If using a .data file, variable labels will automatically be included.{p_end}{break}
{synopt:{opt sheet()}}Optionally indicate the names of the sheet on which data is located (one for each spreadsheet used, in order of listing in the command line. Include an "x" for .dta files).{p_end}{break}
{synopt:{opt r:eplace}}Required to write or overwrite metadata template.{p_end}
{synopt:}{p_end}


{pstd}{it:    {ul:{hi: Consolidation/Appending of dataset(s)}}}{p_end}

{marker fileimp}{...}
{pstd}{it: File import options}:{it: Except for {bf:sheet()}, specification must be consistent for all spreadsheets.} {p_end}

{synopt:{opt name:row(#)}}Do not include this option if you wish to use column letters as variable names. Otherwise, indicate the row number of the master spreadsheets containing original variable names; the specification must be consistent across all spreadsheets used. If using .dta files, variable names will automatically be included.{p_end}{break}
{synopt:{opt head:row(#)}}Indicate the last header row before data begins. If not specified, all rows are treated as data.{p_end}{break}
{synopt:{opt sheet()}}Optionally indicate the names of the sheet on which data is located (specify for each spreadsheet, in order of listing in the command line. Include an "x" for .dta files).{p_end}{break}
{synopt:{opt drop:col(letter)}}Indicate a column which, if empty, means that the row is not an observation. This avoids importing a large number of blank rows. If not specified, observations are dropped if column A is blank.{p_end}


{marker metadataoptions}{...}
{pstd}{it: Metadata use options    } {p_end}

{synopt:{opt old:name(names)}} Indicate the column name(s) containing the original variable names to match to the master files. If using multiple files, specify for each files, in order of listing in the command line. By default these will be oldname_1 for the first master file, oldname_2 for the second master file, and so on. These must be specified manually and if the column names are changed in metadata, command must be in the changed name.{p_end}{break}
{synopt:{opt rec:ode(names)}}Indicate the column name(s) containing the recode codes (STATA syntax), in the same order as the master files. By default there is only one recode column in metadata ("Recode"); if different recodes are needed for different master files these columns must be added and specified in the command.{p_end}


{marker outputoptions}{...}
{pstd}{it: Output options   } {p_end}

{synopt:{opt i:ndex(varname)}}Indicate a new variable name to identify the source of each observation. It will be given the values 1 2 3... in the order of the masters and can be coded in the metadata.{p_end}{break}
{synopt:{opt a:ppend}}Reads the {it:first} master file (assumed to already be a constructed dataset) for the highest already existing data of the variable name indicated in {opt i:ndex()} and begins index numbering from the next value, without replacing values in first master.{p_end}{break}
{synopt:{opt dem:erge()}}For the final-named variables specified, missing data is treated as vertically merged cells and any empty value is filled with the preceding values to "de-merge" the vertically merged Excel data.{p_end}
{synopt:}{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}{bf:import_metadata} imports any mix of .xlsx and .dta files, recodes and labels them according to a common metadata spreadsheet, and appends them. To begin, choose file(s) to be the basis of metadata spreadsheet. The file(s) may have a name for each column variable, specified with the {bf:namerow()}. If unspecified, the column letter will be used as the variable names. the row of the variable name, indicated with the {bf:namerow()} should be consistent across all .xlsx files.{break}
There should be no other rows with entries once the data has begun (except those excluded by {bf: dropcol()} if necessary), and the final row of the header (the last row before data begins, including names and labels), indicated with the {bf:headrow()}, should be consistent across all .xlsx files.{p_end}


{pstd}{hi:Metadata contents: Codebook Sheet}{p_end}
{pstd}The metadata file must have a {it:row} for every variable that exist in the file(s) to be used, in its first sheet, "Codebook". The columns should indicate:{p_end}
 
{p 4 7 2} 1) The "original" name of the variable that matches the file(s) to be imported, should be listed under the column "oldname_1" "oldname_2", etc. in the metadata spreadsheet. The order should be the same as the order of variables arranged in the file(s) to be imported. Specify which column to look for the "original" names with {bf:oldname()}. For example, if you list two files in the command to be imported, oldname(oldname_1 oldname_2). (These must match the names in the files {it:after} they are converted to STATA names by {help strtoname}.) {p_end}

{p 7 7 2} To extract variable names: {cmd:prep} option will create a spreadsheet with all variable names from the file used. These names can vary across files. These different names under oldname_1, oldname_2, etc. can be converted and consolidated to "Variable Name" when specified. {bf:oldname()} must be specified for each file to be imported, in the order of listing in the command line. Column names may be reused for multiple files.{p_end}

{p 4 7 2} 2) The final name for the variable listed under the column "Variable Name".{p_end}
{p 4 7 2} 3) Any necessary variable labels for the variable in Variable Label".{p_end}
{p 4 7 2} 4) A {bf:recode()} for the variable will be applied {bf:before} value labels. As in the original names, there must be one such entry for each file, even if no recodes are to occur for that file. Names can be repeated.{p_end}
{p 4 7 2} 5) Any necessary value label for the variable in {it:Value Label} (see {help import_metadata##label:Labels}).{p_end}


{marker label}{...}
{pstd}{hi:Metadata contents: Labels}{p_end}
{pstd}The Excel metadata file will also have a {it:Value Labels} sheet with a {it:row} for every value of every value label to be applied. The column entries {bf:must} indicate:{p_end}

{p 4 7 2} 1) The name of the value label (corresponding to the value labels in the first sheet) in {it:Value Label}.{p_end}
{p 4 7 2} 2) The value (unique within label; numeric) in {it:Value}.{p_end}
{p 4 7 2} 3) The label for the value in {it:Label}.{p_end}


{pstd}{hi:Metadata contents: Construct}{p_end}
{pstd}The Excel metadata file will also have a {it:construct} sheet with a {it:row} for every command to be executed, before variable labelling. This is an experimental feature and is not guaranteed. The column entries {bf:must} indicate:{p_end}

{p 4 7 2} 1) The command in {it:command}.{p_end}
{p 4 7 2} 2) The variable name when relevant in {it:varname}. For the commands {help generate} and {help egen}, the variables will be dropped from existing data and regenerated consistently for all data. This is primarily relevant when {opt a:ppend} is specified.{p_end}
{p 4 7 2} 3) The required arguments or expression in {it:expression}. Omit the = sign for {help generate}, {help egen}, and {help replace}.{p_end}


{title:Examples}

{pstd} 1: Creating the metadata spreadsheet called "prep_demo" using auto.xlsx.{p_end}

	qui do "${directory}/import_metadata.ado"

	import_metadata ///
		"$directory/auto.xlsx" ///
	using "$directory/prep_demo.xlsx" ///
		, prep replace namerow(1) headrow(2)

{pstd} 2: Importing the file into a dataset according to "auto_metadata" metadata spreadsheet.{p_end}

	import_metadata ///
		"$directory/auto.xlsx" ///
	using "$directory/auto_metadata.xlsx" ///
		, namerow(1) headrow(2) oldname(oldname_1)



{title:Author}

Benjamin Daniels
bbdaniels@gmail.com
{synoptline}
