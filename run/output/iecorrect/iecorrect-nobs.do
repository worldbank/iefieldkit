/*==============================================================================
This do-file was created using iecorrect
Last updated by bbdaniels on  9 Jan 2023 at 14:16:34
==============================================================================*/



** Drop observations 
drop if (foreign == 1)
drop if (make == "Test") & (foreign == 0)


***************************************************************** End of do-file