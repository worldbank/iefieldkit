/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 11 Dec 2022 at 21:51:55
==============================================================================*/



** Correct entries in numeric variables 
replace headroom = 5 if (make == "Test") & (foreign == 1)
replace headroom = 3 if (headroom == float(3)) & (make == "Test")


***************************************************************** End of do-file