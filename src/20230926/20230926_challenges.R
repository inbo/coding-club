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


#######################################
## CODE TO BE CONVERTED TO FUNCTIONS ##
#######################################


# STEP 1: read observations

## define species
species <- "Harmonia axyridis"
## set scientific name to lowercase
species <- tolower(species)
## replace spaces with underscores
species <- str_replace_all(
  species,
  pattern = " ",
  replacement = "_"
)

## compose filename
file_name <- paste0("20230926_", species, "_2010", ".txt")

## read file
ha_2010 <- read_tsv(paste0("./data/20230926/",
                           file_name))


# STEP 2: data cleaning, remove imprecise or unverified observations, absences
# Remove data with coordinate uncertainty higher than 1000 meters
ha_2010 <-
  ha_2010 %>%
  filter(coordinateUncertaintyInMeters < 1000 | is.na(coordinateUncertaintyInMeters))

## Remove data with some issues
ha_2010 <-
  ha_2010 %>%
  filter(!issue %in% c(
    "ZERO_COORDINATE",
    "COORDINATE_OUT_OF_RANGE",
    "COORDINATE_INVALID",
    "COUNTRY_COORDINATE_MISMATCH"
  ))

## Remove obs linked to absences or exclusions

ha_2010 <-
  ha_2010 %>%
  filter(!occurrenceStatus %in% c(
    "absent",
    "excluded"
  ))


## Step 3: get the grid cell code each observation belongs to and add it to
## the data.frame. We use grid cells of 0.1 lon degrees x 0.05 lat degrees
ha_2010 <-
  ha_2010 %>%
    mutate(cell_code = paste0(
      "01x005",
      "E", floor(decimalLongitude/0.1),
      "N", floor(decimalLatitude/0.05)))


## Step 4: calculate number of observations and the number of individuals in
## each grid cell
n_obs_ind_ha_2010 <-
  ha_2010 %>%
  group_by(cell_code) %>%
  summarise(n_observations = n(), # number of observations (rows)
            n_individuals = sum(individualCount)) # number of individuals

## Step 5: plot cells distribution: how many cells for each value of number of
## observations/individuals?
n_obs_ind_ha_2010 <-
  n_obs_ind_ha_2010 %>%
  tidyr::pivot_longer(cols = c(n_observations, n_individuals),
                      values_to = "n",
                      names_to = "indicator",
                      names_pattern = "n_?(.*)"
                      )

p <- ggplot(n_obs_ind_ha_2010) +
  geom_histogram(aes(x = n, fill = indicator),
                 position = "dodge",
                 binwidth = 5) +
  xlab("n (binwidth: 5)") +
  ggtitle(label = "Grid cells distribution")
p
