* Write header here



** Drop observations 
drop if  (foreign == 1)
drop if  (make == "Test") &  (foreign == 0)


***************************************************************** End of do-file