/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 21 Jul 2022 at 10:30:13
==============================================================================*/



** Correct entries in string variables 
replace make = "News 98" if (make == "Olds 98")
replace make = "Dodge Platinum" if (id == 29)


***************************************************************** End of do-file