/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 15 Nov 2022 at 11:24:13
==============================================================================*/



** Correct entries in numeric variables 
replace headroom = 5 if (make == "Test") & (foreign == 1)
replace headroom = 3 if (headroom == float(3)) & (make == "Test")


***************************************************************** End of do-file