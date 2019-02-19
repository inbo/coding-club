# Getting started

## Introduction

Welcome! We're glad you are interested in our exploration of R, coding and data analysis. The docing club is an environment where we experiment together, share code and learn from each other. Everyone has an equal say and can express themselves freely. We are convinced that everyone can learn from each other, irrespective of the experience. As a particant, we ask you to check and respect our [code of conduct](https://github.com/inbo/coding-club/blob/master/.github/CODE_OF_CONDUCT.md).

This page provides the information for first-time participants as well as some information to get you started for each new session. If anyhting is missing in these instructions, please raise an [New issue](https://github.com/inbo/coding-club/issues/new) on GitHub or [adapt the notes directly](https://github.com/inbo/coding-club/edit/master/docs/gettingstarted.md).

## Technical setup

### First time installation

* Install Rstudio: If you have admin rights on your computer, download the installer [here](https://www.rstudio.com/products/rstudio/download/#download). INBO employees, contact the [IT helpdesk](mailto:ict.helpdesk@inbo.be). After installation, [these instructions](https://inbo.github.io/tutorials/installation/user/user_install_rstudio/) (_in dutch_) will get you started.
* Open Rstudio
* Within Rstudio, start a new Rstudio project:
    * Go to `File`  and choose `New Project...`
    * Pick `New directory`
    * Pick `New project`
    * Fill in the Directory name `coding-club`. You can choose the location on your computer (`Create project as subdirectory of:`) yourself by browsing to a folder. Leave the options `Create git repository` and  `use packrat with this project` empty.
* Still within Rstudio, install some essential packages by typing the following command in the `Console`: `install.packages("tidyverse")` and clicking ENTER button.
* Using file explorer, navigate to your `coding-club` folder and create two (empty) subfolders inside the directory of your new `coding-club` directory:
    * a folder called `data`
    * a folder called `src`

__Note for git-users__ When familiar with Git, you can setup a coding club using the git-integration of Rstudio. Go to `File`  and choose `New Project...`. Pick `Version control`, next `Git`  and fill in the URL of the coding club in the `Repository URL`: `https://github.com/inbo/coding-club`

### Each session

* Open the existing Rstudio project called `coding-club`:
    * Go to `File`  and choose `Open Project...`
    * Navigate to your `coding-club` folder
    * Select the file `coding-club.Rproj`

To complete the challenges, both data sets and R code are used in the sessions:
* When data sets are used during the challenges: put data inside the `data` folder
* When scripts are used during the challenges: put in `src` folder

__How to download a single file__
The links to the data sets and source code will be provided, e.g. [this script](https://github.com/inbo/coding-club/blob/master/src/20180821_challenge_1.R). Go to the page and look for the button `Raw` or `Download`. Next, right click on this button and choose `Save link as...` (or _Link opslaan als..._). Navigate to the respective folder (either `src` or `data`)

__Note for git-users__ You can do `git pull origin master` (or click the `pull` button in the git tab) to download the new material.

## The challenges

- sticky note concept:

![:scale 100%]({{ site.baseurl}}/assets/images/coding_club_sticky_concept.png)


__Tip__ using Rstudio projects... Relative file names... read_csv("./) + ../  instead of setwd en C:/...

