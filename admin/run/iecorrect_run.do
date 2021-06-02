
	sysuse auto, clear
	
	do "C:\Users\wb501238\Documents\GitHub\iefieldkit\src\ado_files/iecorrect.do"

	*erase "C:\Users\wb501238\Desktop/iecorrect_template.xlsx"
	*iecorrect template using "C:\Users\wb501238\Desktop/iecorrect_template.xlsx"

	iecorrect apply using "C:\Users\wb501238\Desktop/iecorrect_template.xlsx", save("C:\Users\wb501238\Desktop/iecorrect_do.do") replace	
