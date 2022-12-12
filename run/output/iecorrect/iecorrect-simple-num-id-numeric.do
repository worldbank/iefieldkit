/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 11 Dec 2022 at 18:59:46
==============================================================================*/



** Correct entries in numeric variables 
replace length = 0 if (length == 184)
replace price = 1 if (id == 74)


***************************************************************** End of do-file