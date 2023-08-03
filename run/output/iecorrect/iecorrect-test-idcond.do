/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 31 Jul 2023 at 19:15:42
==============================================================================*/



** Correct entries in numeric variables 
replace headroom = 5 if (make == "Test") & (foreign == 1)
replace headroom = 3 if (headroom == float(3)) & (make == "Test")


***************************************************************** End of do-file