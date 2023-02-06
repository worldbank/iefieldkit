/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on  6 Feb 2023 at 11:19:20
==============================================================================*/



** Drop observations 
drop if (foreign == 1)
drop if (make == "Test") & (foreign == 0)


***************************************************************** End of do-file