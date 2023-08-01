/*==============================================================================
This do-file was created using iecorrect
Last updated by luizaandrade on 31 Jul 2023 at 19:15:43
==============================================================================*/



** Correct entries in numeric variables 
replace price = 2 if (make == "Buick Skylark")


** Correct entries in string variables 
replace origin = "foo" if (origin == "Alien") & (make == "Cad. Eldorado") & (id == 15)
replace origin = "bar" if (origin == "Local")


***************************************************************** End of do-file