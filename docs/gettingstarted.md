# Getting started

## Introduction

Welcome! We're glad you are interested in our exploration of R, coding and data analysis. The coding club is an environment where we experiment together, share code and learn from each other. Everyone has an equal say and can express themselves freely. We are convinced that everyone can learn from each other, irrespective of the experience. As a particant, we ask you to check and respect our [code of conduct](https://github.com/inbo/coding-club/blob/master/.github/CODE_OF_CONDUCT.md).

This page provides the information for first-time participants as well as some information to get you started for each new session. If anyhting is missing in these instructions, please raise a [New issue](https://github.com/inbo/coding-club/issues/new) on GitHub or [adapt the notes directly](https://github.com/inbo/coding-club/edit/master/docs/gettingstarted.md).

## Technical setup

### In advance

* Install Rstudio: If you have admin rights on your computer, download the installer [here](https://www.rstudio.com/products/rstudio/download/#download). INBO employees, contact the [IT helpdesk](mailto:ict.helpdesk@inbo.be). After installation, [these instructions](https://inbo.github.io/tutorials/installation/user/user_install_rstudio/) (_in dutch_) will get you started.

### First time setup

* Open Rstudio
* Within Rstudio, start a new Rstudio project:
    * Go to `File`  and choose `New Project...`
    * Pick `New directory`
    ![:scale 50%]({{ site.baseurl}}/assets/images/getting_started_new_project1.png)
    * Pick `New project`
    ![:scale 50%]({{ site.baseurl}}/assets/images/getting_started_new_project2.png)
    * Fill in the Directory name `coding-club`. You can choose the location on your computer (`Create project as subdirectory of:`) yourself by browsing to a folder. Leave the options `Create git repository` and  `use packrat with this project` empty.
    ![:scale 50%]({{ site.baseurl}}/assets/images/getting_started_new_project3.png)
    * Click `Create project` (Rstudio will now open in the newly created project)
* Still within Rstudio, install some essential packages by typing the following command in the `Console`: `install.packages("tidyverse")` and clicking ENTER button.
![:scale 85%]({{ site.baseurl}}/assets/images/getting_started_new_project4.png)
* Using file explorer (you can either use your operating systems file explorer or Rstudio's file explorer which is in the `Files` pane), navigate to your `coding-club` folder and create two (empty) subfolders inside the directory of your new `coding-club` directory:
    * a folder called `data`
    * a folder called `src`
    
![:scale 85%]({{ site.baseurl}}/assets/images/getting_started_new_project5.png)
When done, the coding club folder on your computer should look like:
```
├── coding-club.Rproj
├── data
└── src
```

__Note for git-users__: When familiar with Git, you can setup a coding club using the git-integration of Rstudio. Go to `File`  and choose `New Project...`. Pick `Version control`, next `Git`  and fill in the URL of the coding club in the `Repository URL`: `https://github.com/inbo/coding-club`

### Each session setup

* Open the existing Rstudio project called `coding-club`:
    * Go to `File`  and choose `Open Project...`
    * Navigate to your `coding-club` folder
    * Select the file `coding-club.Rproj`

To complete the challenges, both data sets and R code are used in the sessions:
* When data sets are used during the challenges: put data inside the `data/yyyymmdd` folder
* When scripts are used during the challenges: put them in the `src/yyyymmdd` folder

__How to download a single file__? The links to the data sets and source code will be provided, e.g. [this script](https://github.com/inbo/coding-club/blob/master/src/20180821_challenge_1.R). Go to the page and look for the button `Raw` or `Download`. Next, right click on this button and choose `Save link as...` (or _Link opslaan als..._). Navigate to the respective folder (either `src` or `data`) and save the file.

__How to donwload data automatically?__ We wrote an R function to help you downloading all material you need. In your `coding-club` project: just run `inborutils::setup_codingclub_session()`. For downloading a past coding club edition pass the date in the `"yyyymmdd"` format to the function.

__Note for git-users__: You can do `git pull origin master` (or click the `pull` button in the git tab) to download the new material.

## The challenges

Each coding club session focuses on a specific theme with a number of challenges to solve. Altough we aim to solve these challenges by the end of the session, learning from each other is the main purpose. To achieve this, we use our home-brew _sticky note concept_:

![:scale 100%]({{ site.baseurl}}/assets/images/coding_club_sticky_concept.png)

## Tips and tricks

__The power of TAB button__: When writing code in Rstudio, you can use the TAB keyboard-button to autocomplete variables and function names!

__No more `setwd`__: By using the Rstudio projects, you no longer need to use `setwd()`, or full file paths inside `read_csv()`-like functions. Instead, you can use a _relative file path_, e.g. `read_csv("data/mydatafile.csv)` instead of `read_csv("C://users/AnakinSkywalker/Documents/coding-club/data/mydatafile.csv)`. As such, it becomes much easier to share your code with others (having another folder structure on their computer). In case you need to refer to a parent folder using relative links, use two dots `../folder-name` to go up one folder level. Don't forget the power of the TAB button as well, as Rstudio will autocomplete file/folder names as well.

