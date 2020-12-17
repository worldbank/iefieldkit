
	do "${iefieldkit}/src/ado_files/iecorrect.ado"
	
	
	sysuse auto, clear
	
	cap erase "${testouput}/iecorrect-template.xlsx"
	iecorrect template using "${testouput}/iecorrect-template.xlsx"
	
	cap iecorrect template using "${testouput}/iecorrect-template.xlsx"
	assert _rc == 601
	
	
	sysuse auto, clear
	gen 	foreign_o = "Local" in 5
	replace foreign_o = "Alien" in 12
	
	encode 	make,	gen(id)
	
	tempfile tocorrect
	save 	`tocorrect'
	
	iecorrect apply using "${AnalyticsDB}/Data Coordinator/iefieldkit/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id)
	
	use 	`tocorrect', clear
	
	iecorrect apply using "${AnalyticsDB}/Data Coordinator/iefieldkit/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) save("${testouput}/iecorrect-simple-num-id.do") replace
	
	
	use 	`tocorrect', clear
	
	iecorrect apply using "${AnalyticsDB}/Data Coordinator/iefieldkit/iecorrect/iecorrect-simple-num-id.xlsx", idvar(id) noisily
	
	
	use 	`tocorrect', clear
	
	iecorrect apply using "${AnalyticsDB}/Data Coordinator/iefieldkit/iecorrect/iecorrect-simple-gen.xlsx", idvar(id)
