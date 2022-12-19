/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 21 Jul 2022 at 10:30:16
==============================================================================*/



** Correct entries in numeric variables 
replace price = 2 if (make == "Buick Skylark")


** Correct entries in string variables 
replace origin = "foo" if (origin == "Alien") & (make == "Cad. Eldorado") & (id == 15)
replace origin = "bar" if (origin == "Local")


***************************************************************** End of do-file