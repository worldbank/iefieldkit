/*==============================================================================
This do-file was created using iecorrect
Last updated by bbdaniels on  9 Jan 2023 at 14:16:34
==============================================================================*/



** Correct entries in numeric variables 
replace mpg = 23 if (mpg == 22)
replace mpg = 12 if (mpg == 14)


***************************************************************** End of do-file