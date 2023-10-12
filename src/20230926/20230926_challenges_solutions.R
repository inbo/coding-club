library(readr) # to read data
library(dplyr) # to do data wrangling
library(tidyr) # to make data tidy
library(stringr) #to work with strings
library(ggplot2) # to plot data
library(docstring) #to create help from documentation of stand-alone functions

## INSTRUCTIONS

# 1. Do not forget to save the functions in a SEPARATE FILE in the same folder
# as the challenge. You can call the file as `20230926_functions.R`.

# 2. SOURCE it every time you update the file with new functions, e.g.
# source("./src/20230926/20230926_functions.R") or use the SOurce button in the
# upright corner of this window.

#' function solutions are saved in `20230926_functions_solutions.R`
source("./src/20230926/20230926_functions_solutions.R")

## CHALLENGE 1.1

ha_2010 <- get_obs_2010(species = "Harmonia axyridis")
cb_2010 <- get_obs_2010(species = "Chorthippus biguttulus")


## CHALLENGE 1.2

ha_2011 <- get_obs(species = "Harmonia axyridis", year = 2011)
cb_2010 <- get_obs(species = "Chorthippus biguttulus", year = 2010)


#' A little extra: it could be wise to pass an extra argument for the root
#' folder to allow using some different directtories than "./data/20230926/"
ha_2011 <- get_obs_extra(species = "Harmonia axyridis",
                         year = 2011,
                         root_folder = "./data/20230926/"
)

cb_2010 <- get_obs_extra(species = "Chorthippus biguttulus",
                         year = 2010,
                         root_folder = "./data/20230926/"
)


## CHALLENGE 2A

ha_2011_cleaned <- clean_data(df = ha_2011)
cb_2010_cleaned <- clean_data(df = cb_2010) # all rows removed
# change the max coordinate uncertainty allowed
cb_2010_cleaned <- clean_data(df = cb_2010, max_coord_uncertain = 4000)


# Notice how you can use default values by not specifying them
ha_2011_with_cellcode <- calc_grid_cell(ha_2011_cleaned)
cb_2010_with_cellcode <- calc_grid_cell(cb_2010_cleaned)

# Use another grid size
ha_2011_with_cellcode_big_cells <- calc_grid_cell(ha_2011_cleaned,
                                                  x_size = 1,
                                                  y_size = 1)


## CHALLENGE 2B

# This step is quite straightforward. It must not be always difficult to make a
# function out of some code :-)
n_obs_ind_ha_2011 <- calc_n_obs_ind(ha_2011_with_cellcode)
n_obs_ind_cb_2010 <- calc_n_obs_ind(cb_2010_with_cellcode)

# Plot, finally!
# default binwidth
plot_distr_cells(n_obs_ind_ha_2011)

# other in bin width value
plot_distr_cells(n_obs_ind_cb_2010, bin_width = 10)


## INTERMEZZO 3

#' Creating a package using `checklist` is possible, but at the moment of
#' writing the solutions the package `docstring` stops working as wished. So, we
#' make a package without following the INBO specifications via checklist, but
#' we use the generic `usethis` package. Here below some comments with a list of
#' commando to execute to create the entomolist package:
#'
#' 1. Run:
#' `usethis::create_package(path = "../entomologist", rstudio = TRUE, roxygen = TRUE, open = TRUE)`
#' Notice that you can change the path where to create the
#' package. In my case, I have a folder with all packages and projects I work
#' on and this is the parent directory of the INBO coding club folder.
#'
#' 2. A project called `entomologist.Rprj` has been created and opened
#' automatically in a new RStudio session. Notice also what you get on your
#' console before you are redirected to the new project.
#'
#' 3. Start by editing the `DESCRIPTION` file which you can find in
#' the root folder. Provide the title for your package as in slides:
#' `Analyze insect related GBIF occurrences`. Provide also the description as in slides:
#' `A collection of functions used to analyze insects data for the project of my life.`.
#' Notice that this file is not a R file: you don't need to insert `"` around these two strings!
#'
#' 4. Still in `DESCRIPTION`, provide the person details of the package creator,
#' that's you! :-)
#'
#' 5. Run `usethis::use_mit_license()` to add a MIT license to your package. The
#' choice of the license is personal or explicitly defined within the project
#' the package is intended. Still, MIT license is in most of the time a good
#' option for R packages. Notice that now the line with license has changed on
#' the fly: `License: MIT + file LICENSE` and two files has been added:
#' `LICENSE` and `LICENSE.md`.
#'
#' 6. Add a line with `Language: en-GB` to specify that your package is written
#' in British English. You can put it more or less wherever you want, but
#' typically it is placed under the `Encoding` line.

## CHALLENGE 3

#' 1. Add a R file called `get_obs.R` in `./R` subdirectory. If you don't want
#' to use the mouse too much, type:
#' `usethis::use_r(name = "get_obs")`
#' usethis will create the file for you in the right place!
#'
#' 2. Place the `get_obs()` function in it. Notice you need to add the
#' `get_obs()` function with the root folder argument as described in the
#' extra's of challenge 1. The package otherwise cannot find your files.
#'
#' 3. All needed packages must be "imported" to be available for the functions
#' in your package. To do so, you need a section in `DESCRIPTION` called
#' `Imports:`. Something like this based on `get_obs()` (to be extended):
#' Imports:
#'   assertthat,
#'   readr,
#'   stringr
#'
#' If you prefer, you can run:
#' `usethis::use_package("dplyr")`
#' `usethis::use_package("assertthat")`
#' `usethis::use_package("ggplot2")`
#' `usethis::use_package()` function will add automatically the packages for you
#' in `Imports` section of `DESCRIPTION`: package is not added if already
#' present.
