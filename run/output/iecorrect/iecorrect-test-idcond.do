/*==============================================================================
This do-file was created using iecorrect
Last updated by bbdaniels on  9 Jan 2023 at 14:16:34
==============================================================================*/



** Correct entries in numeric variables 
replace headroom = 5 if (make == "Test") & (foreign == 1)
replace headroom = 3 if (headroom == float(3)) & (make == "Test")


***************************************************************** End of do-file