cap program drop iecorrect
	program 	 iecorrect
		
	syntax using
		
		preserve
		
			noi di "import excel file"
			import excel `using', sheet("other") firstrow allstring clear
			
			tempname	corrections
			tempfile	correctionsfile

		cap	file close 	corrections
			file open  	corrections using "`correctionsfile'", text write replace
			
			
			noi di "enter write loop"
			
			count
			forvalues row = 1/`r(N)' {
				
				local strvar			= strvar[`row']
				
				local strvaluecurrent 	= strvaluecurrent[`row']
				local strvaluecurrent	= `""`strvaluecurrent'""'
				
				local strvalue		 	= strvalue[`row']
				local strvalue			= `""`strvalue'""'
				
				local catvar		 	= catvar[`row']
				local catvalue		 	= catvalue[`row']

				if "`catvar'" != ""	{
					noi di "enter first if"
					file write corrections		`"replace `catvar' = `catvalue' if `strvar' == `strvaluecurrent'"' _n
				}
				if !(regex(`strvalue',`strvaluecurrent') & regex(`strvalue',`strvaluecurrent'))	{
					noi di "enter second if"
					file write corrections		`"replace `strvar' = `strvalue' if `strvar' == `strvaluecurrent'"' _n
				}

			}
			
			noi di "exit write loop"
			file close corrections
		
		restore
		
		noi di "Back to original file"
		
		noi di "Read corretions"
		file open corrections using "`correctionsfile'", read
		file read corrections line
		
		noi di "Run each line"
		while r(eof)==0 {
			display `"`line'"'
			`line'
			file read corrections line
		}

		noi di "Close corrections"
		file close corrections
		
	end
