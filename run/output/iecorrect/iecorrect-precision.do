/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 19 Jul 2022 at 14:11:13
==============================================================================*/



** Correct entries in numeric variables 
replace gear_ratio = 150 if (gear_ratio == float(3.58))
replace gear_ratio = 60 if (gear_ratio == float(2.53))


***************************************************************** End of do-file