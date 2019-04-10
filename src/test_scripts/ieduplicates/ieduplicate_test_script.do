
*Test for user specified variable names in Excel report
********************************************************
cscript ieduplicates_test adofile ieduplicates
which ieduplicates 

clear all

di "The user for this case is: " c(username)

if "`c(username)'" == "Saori" {
	global base "C:\Users\Saori\Desktop\Semester 4\z Other\DIME\iedup test"
	cd "$base"
	qui do "C:\Users\Saori\Documents\Github\iefieldkit\src\ado_files\ieduplicates.ado"

} 
	else {  // *.... add other people's global here
		di as err "Add path for your machine here"
		e
	}



*Should return no error
***********************************
*1) With no options
	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) 

	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) 
*No error
	rm "$base\iedupreport.xlsx"


*2) With options
*Keep vars
	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	keepvars(rep rate age wgt) 

	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	keepvars(rep rate age wgt) 
*No error
	rm "$base\iedupreport.xlsx"


*Tostringok
	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id)

	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	tostringok
*No error
	rm "$base\iedupreport.xlsx"



*Droprest
	use "$base\ieduplicates_test", clear
	local new= _N+1
	set obs `new'
	replace iid=80865 if _n==_N
	replace unique_id=_N if _n==_N
	save "$base\ieduplicates_test2", replace 
	ieduplicates iid 		, folder("$base") uniquevars(unique_id)

	use "$base\ieduplicates_test2", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	droprest
*No error
	rm "$base\iedupreport.xlsx"



*Nodaily
	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	nodaily

	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	nodaily
*No error
	rm "$base\iedupreport.xlsx"



*Suffix
	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	suffix(_test)

	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id)
*No error
	rm "$base\iedupreport_test.xlsx"
	rm "$base\iedupreport.xlsx"


*Excel var name specification
	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
							duplistid("   DuplicateID") datelisted("Date_Listed    ") datefixed("DateFixed") correct(Keep_this) drop("This_is_mistake ") newid(ID) initials(Signature) notes(Remarks)

	use "$base\ieduplicates_test", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
							duplistid("   DuplicateID") datelisted("Date_Listed    ") datefixed("DateFixed") correct(Keep_this) drop("This_is_mistake ") newid(ID) initials(Signature) notes(Remarks)
*No error
	rm "$base\iedupreport.xlsx"



*3) With multiiple options
*All of the options
	use "$base\ieduplicates_test2", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	keepvars(rep rate age wgt) tostringok droprest nodaily suffix(_test) ///
	duplistid("   DuplicateID") datelisted("Date_Listed    ") datefixed("DateFixed") correct(Keep_this) drop("This_is_mistake ") newid(ID) initials(Signature) notes(Remarks)

	use "$base\ieduplicates_test2", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	keepvars(rep rate age wgt) tostringok droprest nodaily suffix(_test) ///
	duplistid("   DuplicateID") datelisted("Date_Listed    ") datefixed("DateFixed") correct(Keep_this) drop("This_is_mistake ") newid(ID) initials(Signature) notes(Remarks)
*No error
	rm "$base\iedupreport_test.xlsx"


* Mix of options at random
	use "$base\ieduplicates_test2", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	tostringok droprest nodaily ///
	duplistid("   DuplicateID") 

	use "$base\ieduplicates_test2", clear
	ieduplicates iid 		, folder("$base") uniquevars(unique_id) ///
	tostringok droprest nodaily ///
	duplistid("   DuplicateID") 
*No error
	rm "$base\iedupreport.xlsx"


*ieduplicate listing of variables that differs
	use "$cd\ieduplicates_test", clear
	
	gen this_a_fake_long_named_variable1 =.
	replace this_a_fake_long_named_variable1=1 if unique_id==80865

	gen this_a_fake_long_named_variable2 =.
	replace this_a_fake_long_named_variable2=1 if unique_id==80865

	gen this_a_fake_long_named_variable3 =.
	replace this_a_fake_long_named_variable3=1 if unique_id==80865

	gen this_a_fake_long_named_variable4 =.
	replace this_a_fake_long_named_variable4=1 if unique_id==80865

	gen this_a_fake_long_named_variable5 =.
	replace this_a_fake_long_named_variable5=1 if unique_id==80865

	gen this_a_fake_long_named_variable6 =.
	replace this_a_fake_long_named_variable6=1 if unique_id==80865

	gen this_a_fake_long_named_variable7 =.
	replace this_a_fake_long_named_variable7=1 if unique_id==80865

	gen this_a_fake_long_named_variable8 =.
	replace this_a_fake_long_named_variable8=1 if unique_id==80865

	gen this_a_fake_long_named_variable9 =.
	replace this_a_fake_long_named_variable9=1 if unique_id==80865

	save "$base\test3", replace
	use "$base\test3", clear

	ieduplicates iid 		, folder("C:\Users\Saori\Desktop\Semester 4\z Other\DIME\iedup test") uniquevars(unique_id) ///
	duplistid("   DuplicateID") datefixed(notes_enumerators) ///
	tostringok droprest nodaily 


* Test with duplicate IDs where all variables differ
	use "$base\test3", clear
	replace iid=80865 if iid==80866

	save "$base\test4", replace
	use "$base\test4", clear

	ieduplicates iid 		, folder("C:\Users\Saori\Desktop\Semester 4\z Other\DIME\iedup test") uniquevars(unique_id) ///
	duplistid("   DuplicateID") datefixed(notes_enumerators) ///
	tostringok droprest nodaily 


* Test with duplicate IDs where only one variable differs
	use "$base\test3", clear
	expand 2 if iid==1
	replace unique_id=125224 if _n==125224

	save "$base\test4", replace
	use "$base\test4", clear

	ieduplicates iid 		, folder("C:\Users\Saori\Desktop\Semester 4\z Other\DIME\iedup test") uniquevars(unique_id) ///
	duplistid("   DuplicateID") datefixed(notes_enumerators) ///
	tostringok droprest nodaily 

*****************SI_NOTE: The report after importing the Excel Report, the variable "listofdiffs" include excel file's variables as well as the data set's.

*No error
	rm "$base\iedupreport.xlsx"
