/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 31 Jul 2023 at 19:15:42
==============================================================================*/



** Drop observations 
drop if (foreign == 1)
drop if (make == "Test") & (foreign == 0)


***************************************************************** End of do-file