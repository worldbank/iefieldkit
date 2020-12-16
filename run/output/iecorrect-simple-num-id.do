* Write header here

** Correct entries in numeric variables 
replace length = 0 if length == 184
replace price = 1 if  id == 74


** Correct entries in string variables 
replace make = "News 98" if make == "Olds 98" 
replace make = "Dodge Platinum" if id == 29


** Adjust categorical variables to include 'other' values 
replace foreign = 2 if foreign_o == "Local"
replace foreign_o = "" if foreign_o == "Local"
replace foreign = 3 if foreign_o == "Alien"


** Drop observations 
drop if id == 7 


***************************************************************** End of do-file