/*==============================================================================
This do-file was created using iecorrect
Last updated by bbdaniels on  9 Jan 2023 at 14:16:33
==============================================================================*/



** Correct entries in string variables 
replace make = "News 98" if (make == "Olds 98")
replace make = "Dodge Platinum" if (id == 29)


***************************************************************** End of do-file