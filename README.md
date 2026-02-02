# **iefieldkit - Stata Commands for Primary Data Collection**

[Pre-print of Stata Journal article](https://github.com/worldbank/iefieldkit/blob/master/iefieldkit.pdf)

## **Installation**

```stata
ssc install iefieldkit
```

To install **iefieldkit**, type **`ssc install iefieldkit`** in Stata. This will install the most recent published version of **iefieldkit**. The main version of the code in the repo (the `main` branch) is what is published on SSC as well.

To make sure that you have the most recent published version of **iefieldkit** installed type `adoupdate iefieldkit, update` in Stata, or type `adoupdate` and follow the instructions to update all your user-written Stata commands (including **iefieldkit**) on your computer.

See [below](#more-on-installation) for more ways to installing the package and how to install unpublished versions of the package for development purposes.

## Introduction

The `iefieldkit` is a package of commands for **primary data collection**. This is a topic with fewer user-written commands than for example analysis, and we think the reason for that is that there are not as many expert Stata coders in the field. But since primary data collection is equally important to quantitative research as analysis, we hope that `iefieldkit` will cover a part of this gap.

This package currently supports three major components of that workflow: **survey design**; **survey completion**; and **data cleaning and survey harmonization**.

Read the [wiki articles](https://dimewiki.worldbank.org/wiki/Stata_Coding_Practices#iefieldkit) for these command for a thorough description on the use cases and work flows that these commands are intended for. See the helpfiles by typing `help` followed by the command name for instructions on how to run these commands in Stata.

Some features of the command might require meta data specific to SurveyCTO, but you are of course free to try these commands on any use case. **iefieldkit** is similar to the package [ietoolkit](https://github.com/worldbank/ietoolkit) but the commands in **iefieldkit** relates only to primary data collection using SurveyCTO.

In this first version, `iefieldkit` performs the following three tasks:

* _Before data collection_ , `ietestform` is a compliment to the ODK syntax test on SurveyCTO server as `ietestform` runs tests related to best practices on how to, and how not to use features in the ODK programming language to ensure data quality, especially if the data will be imported to Stata that has other restrictions than ODK syntax.
* _During data collection_, `ieduplicates` and `iecompdup` (both previously released as a part of the package `ietoolkit` but now moved to this package) provide a workflow for detecting and resolving duplicate entries in the dataset, ensuring that the final survey dataset will be a correct record of the survey sample to merge onto the sampling database.
* _After data collection_, the `iecodebook` commands provide a workflow for rapidly cleaning, harmonizing, and documenting datasets. `iecodebook` uses input specified in an Excel sheet, which provides a much more well-structured and easy to follow (especially for non-technical users) overview that the same operations written directly to a dofile.

## More on installation

The vast majority of users should install the command by typing `ssc install iefieldkit` in Stata. The only reason for not installing the package like that is if your are contributing to the development or testing not yet developed features and want to install unpublished versions of this package.

### Installing unpublished version of this package

 If you want a yet to be published version of **iefieldkit** then you can use the code below. The code below installs the version currently in the `main` branch, but replace _main_ in the URL below with the name of the branch you want to install from. You can also install older version of **iefieldkit** like this but it will only go back to January 2019 when we set up this method of installing the package.

```stata
**When working with multiple version from different sources, 
* then you should always start by making sure any previously 
* installed version of iefieldkit is removed
cap ado uninstall iefieldkit

*Install iefieldkit directly from the repository
net install iefieldkit , from("https://raw.githubusercontent.com/worldbank/iefieldkit/main/src") replace
```

If you are using a work computer where you are not permitted to make a `net` call to the internet from Stata, then you can do the following. Download the files from this repository by clicking the green _Clone or download_ button. Click the `<> code` tab if you do not see that button. Unzip the folders on your computer and change the URL in `from()` in the code above to the location of the _src_ folder where you unzipped the files on your computer.

### Installing the published version again

After you have done the contributions or testing that you intended to do, you have to manually make sure that you re-install the published and tested version of **iefieldkit**. Follow the code below to do so.

```stata
*Remove the installed version of iefieldkit
cap ado uninstall iefieldkit

*Install the most recent published version of iefieldkit
ssc install iefieldkit
```

### Errors after installing from multiple sources

If you have installed a package from multiple sources, then you might get the error below. If you get that error [follow instructions here](https://github.com/worldbank/iefieldkit/blob/main/admin/multiple-package-source-error.md).

![multiple-package-source-error](https://user-images.githubusercontent.com/15911801/52809664-cadc3900-305e-11e9-863f-bff31f07a9ef.png)

## License

This project is licensed under the MIT License together with the [World Bank IGO Rider](https://github.com/worldbank/.github/blob/main/WB-IGO-RIDER.md). The Rider is purely procedural: it reserves all privileges and immunities enjoyed by the World Bank, without adding restrictions to the MIT permissions. Please review both files before using, distributing or contributing.

## Contact

For questions, issues, or suggestions, please [open an issue](https://github.com/worldbank/iefieldkit/issues). Feel free to notify us directly at <dimeanalytics@worldbank.org> after opening the issues as we are sometimes not monitoring new issues regularly.
