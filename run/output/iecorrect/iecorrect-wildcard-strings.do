/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 21 Jul 2022 at 10:30:15
==============================================================================*/



** Correct entries in numeric variables 
replace mpg = 23 if (mpg == 22)
replace mpg = 12 if (mpg == 14)


***************************************************************** End of do-file