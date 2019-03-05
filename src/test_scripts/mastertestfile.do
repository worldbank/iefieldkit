gl base "C:\Users\Saori\Documents\Github\iefieldkit\src\test"

clear
discard 
set more off
cd "$base"
quietly log using test, replace
do test
quietly log close

