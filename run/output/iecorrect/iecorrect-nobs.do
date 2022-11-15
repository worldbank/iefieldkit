/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 15 Nov 2022 at 11:24:13
==============================================================================*/



** Drop observations 
drop if (foreign == 1)
drop if (make == "Test") & (foreign == 0)


***************************************************************** End of do-file