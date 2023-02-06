/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on  6 Feb 2023 at 11:19:19
==============================================================================*/



** Correct entries in numeric variables 
replace length = 0 if (length == 184)
replace price = 1 if (id == 74)


***************************************************************** End of do-file