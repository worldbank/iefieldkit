/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 21 Jul 2022 at 10:30:15
==============================================================================*/



** Correct entries in numeric variables 
replace headroom = 5 if (make == "Test") & (foreign == 1)
replace headroom = 3 if (headroom == float(3)) & (make == "Test")


***************************************************************** End of do-file