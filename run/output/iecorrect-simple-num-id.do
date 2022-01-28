* Write header here

** Correct entries in numeric variables 
replace length = 0 if length == 184
 replace price = 1 if  id == 74 


** Correct entries in string variables 
replace make = "News 98" if make == "Olds 98" 
replace make = "Dodge Platinum" if id == 29


** Adjust categorical variables to include 'other' values 
replace foreign = 2 if origin == "Local"
replace origin = "Martian" if origin == "Local"
replace foreign = 3 if origin == "Alien"


** Drop observations 
drop if id == 7 


***************************************************************** End of do-file