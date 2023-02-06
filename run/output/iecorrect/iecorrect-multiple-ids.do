/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on  6 Feb 2023 at 11:19:20
==============================================================================*/



** Correct entries in numeric variables 
replace price = 2 if (make == "Buick Skylark")


** Correct entries in string variables 
replace origin = "foo" if (origin == "Alien") & (make == "Cad. Eldorado") & (id == 15)
replace origin = "bar" if (origin == "Local")


***************************************************************** End of do-file