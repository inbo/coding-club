## INSTRUCTIONS

# 1. Do not forget to save the functions in a SEPARATE FILE in the same folder
# as the challenge. You can call the file as `20240926_functions.R`.

# 2. SOURCE it every time you update the file with new functions, e.g.
# source("./src/20240926/20240926_functions.R") or use the SOurce button in the
# upright corner of this window.

#' function solutions are saved in `20240926_functions_solutions.R`
source("./src/20240926/20240926_functions_solutions.R")


## CHALLENGE 0

# Use `make_doughs() as defined in the `20240926_functions_solutions.R` file
# to create the doughs
doughs1 <- make_doughs(grains = 20, yeast = 1, water = 2, salt = 3)
doughs1$bread
doughs1$focaccia

doughs2 <- make_doughs(grains = 10, yeast = 0.5, water = 1, salt = 1)
doughs2$bread
doughs2$focaccia


## CHALLENGE 1.1

ha_2010 <- get_obs_2010(species = "Harmonia axyridis")
cb_2010 <- get_obs_2010(species = "Chorthippus biguttulus")


## CHALLENGE 1.2

ha_2011 <- get_obs(species = "Harmonia axyridis", year = 2011)
cb_2010 <- get_obs(species = "Chorthippus biguttulus", year = 2010)


#' A little extras: it could be wise to check inputs and also pass an extra
#' argument for the root folder to allow using some different directories than
#' "./data/20240926/"
ha_2011 <- get_obs_extra(species = "Harmonia axyridis",
                         year = 2011,
                         root_folder = "./data/20240926/"
)

cb_2010 <- get_obs_extra(species = "Chorthippus biguttulus",
                         year = 2010,
                         root_folder = "./data/20240926/"
)


## CHALLENGE 2

ha_2011_cleaned <- clean_data(df = ha_2011)
cb_2010_cleaned <- clean_data(df = cb_2010) # all rows removed
# change the max coordinate uncertainty allowed
cb_2010_cleaned <- clean_data(df = cb_2010, max_coord_uncertain = 4000)


# Notice how you can use default values by not specifying them
ha_2011_with_cellcode <- calc_grid_cell(ha_2011_cleaned)

# Use other column names (`decimalLatitude` and `decimalLongitude` don't exist)
cb_2010_with_cellcode <- calc_grid_cell(cb_2010_cleaned,
                                        name_lon = "longitude",
                                        name_lat = "latitude")

# Use another grid size
ha_2011_with_cellcode_big_cells <- calc_grid_cell(ha_2011_cleaned,
                                                  x_size = 1,
                                                  y_size = 1)


# This step is quite straightforward. It must not be always difficult to make a
# function out of some code :-)
n_obs_ind_ha_2011 <- calc_n_obs_ind(ha_2011_with_cellcode)
n_obs_ind_cb_2010 <- calc_n_obs_ind(cb_2010_with_cellcode)

# Plot, finally!
# Use the default value of `binwidth`
plot_distr_cells(n_obs_ind_ha_2011)

# Other in bin width value
plot_distr_cells(n_obs_ind_cb_2010, bin_width = 10)

## CHALLENGE 3

# The function `analyse_obs` is a wrapper for all the previous functions.
output_analysis_ha_2011 <- analyse_obs(species = "Harmonia axyridis",
                                       year = 2011,
                                       root_folder = "./data/20240926/")
output_analysis_ha_2011$n_obs_ind
output_analysis_ha_2011$plot

output_analysis_cb_2010 <- analyse_obs(species = "Chorthippus biguttulus",
                                       year = 2010,
                                       root_folder = "./data/20240926/",
                                       max_coord_uncertain = 10000,
                                       name_lon = "longitude",
                                       name_lat = "latitude",
                                       x_size = 0.05,
                                       y_size = 0.05,
                                       bin_width = 3)
output_analysis_cb_2010$n_obs_ind
output_analysis_cb_2010$plot
