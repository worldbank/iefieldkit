
di "The user for this case is: " c(username)

if "`c(username)'" == "Saori" {
	gl base "C:\Users\Saori\Documents\Github\iefieldkit\src\test"
} 
	else {  // *.... add other people's global here
		di as err "Add path for your machine here"
		e
	}


clear
discard 
set more off
cd "$base"
quietly log using test, replace
do test
quietly log close

