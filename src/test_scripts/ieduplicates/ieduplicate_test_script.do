
*Test for user specified variable names in Excel report
********************************************************
cscript ieduplicates_test adofile ieduplicates
which ieduplicates 

clear all

global base "C:\Users\Saori\Desktop\Semester 4\z Other\DIME\iedup test"
cd "$base"
qui do "C:\Users\Saori\Documents\Github\iefieldkit\src\ado_files\ieduplicates.ado"





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


