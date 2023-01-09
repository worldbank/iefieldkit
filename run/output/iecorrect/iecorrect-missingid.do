/*==============================================================================
This do-file was created using iecorrect
Last updated by bbdaniels on  9 Jan 2023 at 14:16:34
==============================================================================*/



** Correct entries in numeric variables 
replace price = 2 if (make == "Buick Skylark")


** Correct entries in string variables 
replace origin = "foo" if (origin == "Alien") & (make == "Cad. Eldorado") & (id == 15)
replace origin = "bar" if (origin == "Local")


***************************************************************** End of do-file