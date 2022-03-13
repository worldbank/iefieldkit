/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 13 Mar 2022 at 14:18:41
==============================================================================*/



** Drop observations 
drop if (foreign == 1)
drop if (make == "Test") & (foreign == 0)


***************************************************************** End of do-file