# iefieldkit

## installation - beta version
This is just a beta release for testing purposes. We know that there are still bugs to be resolved, output to be improved etc. before this package of commands is as user-friendly as we aim for it to be when the first non-beta version is released. With that said, we are immensely grateful for anyone who wants to help us test this command and report bugs, suggest improvements, ask for clarifications where documentation is not great etc. The non-beta version of the command will be released on _SSC_ but until then, the command is installed using the code below:
```
    net install iefieldkit , from("https://raw.githubusercontent.com/worldbank/iefieldkit/master/src") replace
```

If you are using a work computer where you are not permitted to make a `net` call to the internet from Stata, then you can do the following. Download the files from this repository by clicking the green _Clone or download_ button. Click the `<> code` tab if you do not see that button. Unzip the folders on your computer and change the URL in `from()` in the code above to the location of the _src_ folder where you unzipped the files on your computer.

### Updating the command
If you are testing the command and want to make sure that you have the latest version of the package, run `net uninstall iefieldkit` before repeating the installation described above. 
    
## introduction
Stata commands designed for primary data collection using [SurveyCTO](https://www.surveycto.com/index.html). Some features of the command might require meta data specific to SurveyCTO, but you are of course free to try these commands on any use case. **iefieldkit** is similar to the package [ietoolkit](https://github.com/worldbank/ietoolkit) but the commands in **iefieldkit** relates only to primary data collection using SurveyCTO.

When using this package of commands for the first time, we recommend that you read the section on the intended work flow. Some commands have features that assumes that the commands earlier in the work flow have been used. You will be notified if that is the case as some features might not work, but to the degree possible, the commands will have other ways to implement those features.

## Suggested commands

Only **ietestform** and **iecodebook** are released yet, and they are only released in beta version for testing.

* Questionnaire design
  * **ietestform** - command that tests the SurveyCTO questionnaire form for risky practices. This is not a substitute to the test SurveyCTO's servers do when uploading a form, but a complement. SurveyCTO's servers check that the syntax is correct, while **ietestform** warns you and bring your attention to practices that are not incorrect from a strict syntax perspecitve, but are practices that are prone to errors, or should only be used in very specific cases.
* Data collection
  * **ieimport** - similar to ODK meta. Applies labels etc. Stores meta data from the form to the vars in the data set.
  * **ieduplicates** and **iecompdup** - already exists in **ietoolkit**, will be moved here in time for the first version of **iefieldkit**. Finds duplicates, assists in identifying why they are duplicates, and provides an easy way to correct them.
  * **iehfc** - set of commands with iehfc being the main command that runs high frequency checks
  * **ieprogressreport** - Generates a table with number of interviews done. Exports in Excel form. First sheet is total, last day, last week. Then user can specify vars like district, data collection team, enumerator, etc. that this information is split by. Command should probably have a shorter name.
* After data collection
  * **iecodebook** - helps document all the small edits needed when appending data sets from multiple rounds or from very similar surveys from different locations.
