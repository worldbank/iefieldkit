/*==============================================================================
This do-file was created using iecorrect
Last updated by bbdaniels on  9 Jan 2023 at 14:16:33
==============================================================================*/



** Correct entries in numeric variables 
replace gear_ratio = 150 if (gear_ratio == float(3.58))
replace gear_ratio = 60 if (gear_ratio == float(2.53))


***************************************************************** End of do-file