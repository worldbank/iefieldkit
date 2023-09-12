/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 12 Sep 2023 at 15:10:31
==============================================================================*/



** Drop observations 
drop if (foreign == 1)
drop if (make == "Test") & (foreign == 0)


***************************************************************** End of do-file