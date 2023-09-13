/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 12 Sep 2023 at 15:10:30
==============================================================================*/



** Correct entries in numeric variables 
replace length = 0 if (length == 184)
replace price = 1 if (id == 74)


***************************************************************** End of do-file