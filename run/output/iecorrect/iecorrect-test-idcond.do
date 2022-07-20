/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 19 Jul 2022 at 14:11:16
==============================================================================*/



** Correct entries in numeric variables 
replace headroom = 5 if (make == "Test") & (foreign == 1)
replace headroom = 3 if (headroom == float(3)) & (make == "Test")


***************************************************************** End of do-file