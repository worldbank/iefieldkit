	
	sysuse auto, clear
	
	scatter weight length
	
	reg price mpg i.foreign
