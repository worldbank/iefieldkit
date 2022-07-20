/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 19 Jul 2022 at 14:11:14
==============================================================================*/



** Adjust categorical variables to include 'other' values 
replace foreign = 2 if origin == "Local"
replace foreign = 3 if origin == "Alien"


***************************************************************** End of do-file