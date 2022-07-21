/*==============================================================================
This do-file was created using iecorrect
Last updated by wb501238 on 21 Jul 2022 at 10:30:15
==============================================================================*/

gen model = .  


** Adjust categorical variables to include 'other' values 
replace model = 1 if make == "AMC Concord"
replace model = 1 if make == "AMC Pacer"
replace model = 1 if make == "AMC Spirit"
replace model = 2 if make == "Buick Century"
replace model = 2 if make == "Buick Electra"
replace model = 2 if make == "Buick LeSabre"
replace model = 2 if make == "Buick Opel"
replace model = 2 if make == "Buick Regal"
replace model = 2 if make == "Buick Riviera"
replace model = 2 if make == "Buick Skylark"


***************************************************************** End of do-file