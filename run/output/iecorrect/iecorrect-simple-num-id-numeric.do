/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 19 Jul 2022 at 14:11:14
==============================================================================*/



** Correct entries in numeric variables 
replace length = 0 if (length == 184)
replace price = 1 if (id == 74)


***************************************************************** End of do-file