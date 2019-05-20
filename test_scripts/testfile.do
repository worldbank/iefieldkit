
di "The user for this case is: " c(username)

if "`c(username)'" == "Saori" {
	gl base "C:\Users\Saori\Documents\Github\iefieldkit\src\test"
} 
	else {  // *.... add other people's global here
		di as err "Add path for your machine here"
		e
	}

cd "$base"

about
query compilenumber
do ieduplicate_test /* assert */

do merge /* merge/append */
do nchi2 /* nchi2() function */
