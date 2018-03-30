# iefieldkit

## introduction
Stata commands designed for primary data collection using [SurveyCTO](https://www.surveycto.com/index.html). Some features of the command might require meta data specific to SurveyCTO, but you are of course free to try these commands on any use case. iefieldkit is similar to the package [ietoolkit](https://github.com/worldbank/ietoolkit) but the commands in iefieldkit relates only yo primary data collection using SurveyCTO.

When using this package of commands for the first time, we recommend you to check out the section on the intended work flow. Some commands have features that assumes that the commands earlier in the work flow have been used. You will be notified if that is the case, and to the degree possible, the commands will have other ways to implement those features.

## work flow
Not sure what the most markdown friendly format for this work flow would be, let me know if you have suggestions, but for now it is a list

* Questionnaire design
  * ietestform - command that tests the SurveyCTO questionnaire form for risky practices. This is not a substitute to the test SurveyCTO's servers do when uploading a form, but a complement. SurveyCTO's server checks that the syntax is correct, while ieformtest warns you and bring your attention to practices that are not incorrect from a syntax perspecitve, but are practices that are prone to errors, or should only be used in very specific cases.
* Data collection
  * ieimport - similar to ODK meta. Applies labels etc. Stores meta data from the form to the vars in the data set.
  * ieduplicates and iecompdup - already exists in ietoolkit, will be moved here in time for the first version of iefieldkit. Finds duplicates, assists in identifying why they are duplicates, and provides an easy way to correct them.
  * iehfc - set of commands with iehfc being the main command that runs high frequency checks
* After data collection
  * iebatchcorrection - simplifies applying a lot of corrections on a large number of variables. It uses an Excel sheet as input and this sheet can then later function as a documentation better structured and more easily overviewed than a humongous do-file.
  * ieappend - helps document all the small edits needed when appending data sets from multiple rounds or from very similar surveys from different locations.
