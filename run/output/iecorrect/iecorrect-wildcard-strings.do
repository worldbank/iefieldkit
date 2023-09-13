/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 12 Sep 2023 at 15:10:32
==============================================================================*/



** Correct entries in numeric variables 
replace mpg = 23 if (mpg == 22)
replace mpg = 12 if (mpg == 14)


***************************************************************** End of do-file