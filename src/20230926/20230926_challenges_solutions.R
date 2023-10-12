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

## CHALLENGE 3

# See package in zipped folder.
