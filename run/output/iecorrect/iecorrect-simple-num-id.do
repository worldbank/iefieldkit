/*==============================================================================
This do-file was created using iecorrect
Last updated by bbdaniels on  9 Jan 2023 at 14:16:34
==============================================================================*/



** Correct entries in numeric variables 
replace length = 0 if (length == 184)
replace price = 1 if (id == 74)


** Correct entries in string variables 
replace make = "News 98" if (make == "Olds 98")
replace make = "Dodge Platinum" if (id == 29)


** Drop observations 
drop if (id == 7)


***************************************************************** End of do-file