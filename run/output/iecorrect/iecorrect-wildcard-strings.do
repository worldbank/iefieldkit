/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 13 Mar 2022 at 18:57:47
==============================================================================*/



** Correct entries in numeric variables 
replace mpg = 23 if (mpg == 22)
replace mpg = 12 if (mpg == 14)


***************************************************************** End of do-file