/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 12 Sep 2023 at 15:10:30
==============================================================================*/



** Correct entries in numeric variables 
replace gear_ratio = 150 if (gear_ratio == float(3.58))
replace gear_ratio = 60 if (gear_ratio == float(2.53))


***************************************************************** End of do-file