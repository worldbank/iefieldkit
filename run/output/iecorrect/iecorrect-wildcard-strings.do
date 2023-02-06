/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on  6 Feb 2023 at 11:19:20
==============================================================================*/



** Correct entries in numeric variables 
replace mpg = 23 if (mpg == 22)
replace mpg = 12 if (mpg == 14)


***************************************************************** End of do-file