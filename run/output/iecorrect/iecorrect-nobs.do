/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 11 Dec 2022 at 18:59:47
==============================================================================*/



** Drop observations 
drop if (foreign == 1)
drop if (make == "Test") & (foreign == 0)


***************************************************************** End of do-file