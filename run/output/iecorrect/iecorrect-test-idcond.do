/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 12 Sep 2023 at 15:10:31
==============================================================================*/



** Correct entries in numeric variables 
replace headroom = 5 if (make == "Test") & (foreign == 1)
replace headroom = 3 if (headroom == float(3)) & (make == "Test")


***************************************************************** End of do-file