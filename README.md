**iefieldkit - Stata Commands for Primary Data Collection**
=====

### **Install and Update**

#### Installing published versions of `iefieldkit`
To install **iefieldkit**, type **`ssc install iefieldkit`** in Stata. This will install the latest published version of **iefieldkit**. The main version of the code in the repo (the `master` branch) is what is published on SSC as well.

 If you think something is different in version in this repo, and the version installed on your computer, make sure that you both look at the `master` branch in this repo, and that you have the most recent version of **iefieldkit** installed. To update all files associated with **iefieldkit** type **`adoupdate iefieldkit, update`** in Stata. (It is wise to be in the habit of regularly checking if any of your .ado files installed in Stata need updates by typing **`adoupdate`**.)

 When we are publishing new versions of **iefieldkit** then there could be a discrepancy between the master branch and the version on SSC as the master branch is updates a couple of days before. You can confirm if that could be the case by checking if we recently published a new [release](https://github.com/worldbank/iefieldkit/releases).

#### Installing unpublished branches of this repository
Follow the instructions above if you want the most recent published version of **iefieldkit**. If you want a yet to be published version of **iefieldkit** then you can use the code below. The code below installs the version currently in the `master` branch, but replace _master_ in the URL below with the name of the branch you want to install from. You can also install older version of **iefieldkit** like this but it will only go back to January 2019 when we set up this method of installing the package.
```
    net install iefieldkit , from("https://raw.githubusercontent.com/worldbank/iefieldkit/master/src") replace
```

If you are using a work computer where you are not permitted to make a `net` call to the internet from Stata, then you can do the following. Download the files from this repository by clicking the green _Clone or download_ button. Click the `<> code` tab if you do not see that button. Unzip the folders on your computer and change the URL in `from()` in the code above to the location of the _src_ folder where you unzipped the files on your computer.

### Updating the command
If you are testing the command and want to make sure that you have the latest version of the package, run `net uninstall iefieldkit` before repeating the installation described above. 
    
## Introduction
The `iefieldkit` is a package of commands for **primary data collection**. This is a topic with fewer user-written commands than for example analysis, and we think the reason for that is that there are not as many expert Stata coders in the field. But since primary data collection is equally important to quantitative research as analysis, we hope that `iefieldkit` will cover a part of this gap.

This package currently supports three major components of that workflow: **survey design**; **survey completion**; and **data cleaning and survey harmonization**.

Some features of the command might require meta data specific to SurveyCTO, but you are of course free to try these commands on any use case. **iefieldkit** is similar to the package [ietoolkit](https://github.com/worldbank/ietoolkit) but the commands in **iefieldkit** relates only to primary data collection using SurveyCTO.

When using this package of commands for the first time, we recommend that you read the section on the intended work flow. Some commands have features that assumes that the commands earlier in the work flow have been used. You will be notified if that is the case as some features might not work, but to the degree possible, the commands will have other ways to implement those features.

In this first version, `iefieldkit` performs the following three tasks:
* _Before data collection_ , `ietestform` is a compliment to the ODK syntax test on SurveyCTO server as `ietestform` runs tests related to best practices on how to, and how not to use features in the ODK programming language to ensure data quality, especially if the data will be imported to Stata that has other restrictions than ODK syntax.
* _During data collection_, `ieduplicates` and `iecompdup` (both previously released as a part of the package `ietoolkit` but now moved to this package) provide a workflow for detecting and resolving duplicate entries in the dataset, ensuring that the final survey dataset will be a correct record of the survey sample to merge onto the master sampling database. 
* _After data collection_, the `iecodebook` commands provide a workflow for rapidly cleaning, harmonizing, and documenting datasets. `iecodebook` uses input specified in an Excel sheet, which provides a much more well-structured and easy to follow (especially for non-technical users) overview that the same operations written directly to a dofile.
