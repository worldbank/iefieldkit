# Features, inputs, outputs of the commands in iefieldkit

## Format

This first section describes where to put what information in the bullet points for each command below so that we can find what we are looking for once these list are well populated.

### commandname

* features
  * What should this command do? Be specific if you can, but suggestions without details is ok too.
* input
  * What is needed when specifying the command?
  * What format does those inputs need to be in and what format mustn't they be in?
  * What can be prepared by another command in iefieldkit?
  * Naming conventions for options. Make sure to list all the option names used here and a brief description of what they do, and always check the other commands if there already is a naming practice you can copy to your command
* output
  * what outputs do we expect? What modifications to data set in memory? What returned results? What files written to computer?

## Commands in development

### ietestform

This command takes a SurveyCTO form definition in Excel format and parse it to test for errors and best practices that SCTO's server does not check for. Some of these test are testing that our own best practices are used, especially in the context collecting data that will be imported to Stata which is not something that SCTO's server assumes.

This command will make a difference between tests returning an error or a warning.

* input
  * -[ ] Data
    * -[x] The only input this command takes is the questionnaire form definition in Excel format
    * -[ ] Back up option to enter form by csv if strange error with excel format. Need one csv for choice sheet one for survey sheet
* features
  * Survey Sheet
    * type column
      * -[x] Test for not matching begin/end group/repeat, and provide a helpful error message to find which group/repeat field is causing the error, the SCTO server does this as well, but do not provide helpful error message. The helpful error message requires that _end_group_ and _end_repeat_ has names
    * name column
      * -[x] Test for too long names - error
      * -[x] Test for too long names in repeat groups when going from long to wide and one or many suffixes like \_1 are added - error
      * -[x] Not giving a name to end repeat/group - not an error but good practice.
      * -[x] Test that there will be no name conflicts when making repeat group long to wide. For example if there is a field called _name_ in a repeat group it will be named *name_1*, *name_2*, *name_3* etc. in wide format, at the same time there is a variable outside the repeat group that is already named *name_1*, then there will be a naming conflict. - error
    * labels
      * -[x] If the Stata label column does not exist output that this is best practice to have this - warning
        * -[x] If it exist, make sure that no label is longer than 80 characters - error    
    * range column
      * -[ ] All decimal/integer fields should have a ranges - warning
    * repeat count column
      * test that there is a repeat count. Many cases when that is not needed but a good check nonetheless
    * required column
      *  -[ ] test that all fields apart from note are required
      *  -[ ] test that note fields are _NOT_ required. There are cases when this is meant to be the case, but since they are exceptions, there should be a warnings
    * survey sheet other
      * -[ ] Big high priority stuff that we would like to have but is not sure that they are easy to implement:
        * -[ ] What is the maximum number of variables that this form could output?
   * Choice sheet
     * -[x] test that the value/name column is numeric
     * -[x] Test that there are no duplicates in the list options - error
       * -[x] duplicated combinations of value/name and list named
       * -[x] duplicated labels inside a list
     * -[x] Test that all list options are used at least once - warning
     * -[x] Test that there is a Stata label column
     * -[x] Test that all values are labelled
     * -[x] Test that all labels have a corresponding non-missing value
     * -[ ] Test that the each list is written at the same place. It might be a sign of a typo error if the same list is written at multiple places 
  * Options
    * -[x] form() - File path to questionnaire form
    * -[ ] suppress() - An option that takes a list of tests that the user want to skip
    * -[ ] suppreqtext() - An option that takes a list of text fields that the user intended to be required and therefore should not yield a warning
    * -[ ] Output() - Where to output the logfile
* output
  * Display all errors and warnings in the result window
  * Log file with output written to file.

### iehfc
* features
* input
* output
### ieappend
* features
* input
* output

## Next commands to be developed

### ieimport
* features
  * Option to delete calculate fields with a suboption to list which ones should be kept
* input
* output
