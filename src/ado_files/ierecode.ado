cap program drop ierecode
	program 	 ierecode
		
	syntax [anything] using/, ///
		[ 									 ///
			NOIsily 						 ///
			save(string) 					 ///
			replace 						 ///
			debug 							 ///
			listvalues(varname)				 ///
		]
		
	preserve
	
	restore
	
end