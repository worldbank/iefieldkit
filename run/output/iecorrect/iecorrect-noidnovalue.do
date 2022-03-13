/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 13 Mar 2022 at 18:57:48
==============================================================================*/



** Correct entries in numeric variables 
replace headroom = 5 
replace headroom = 3 if (headroom == float(3))


***************************************************************** End of do-file