library(tidyverse)

## Challlenge 1

species_df <- read_csv("./data/20191024_species.csv", na = "")

### Set columns `species_id` and `taxa` lowercase


### sort vector of species_id label alphabetically


### extract species_id labels longer than 2 letters



## CHALLENGE 2

### genus + species in new column called canonicalName


# Remove census related label from taxa column



## INTERMEZZO  (program with us!)

example_string <- "I. love. the. 2019(!!) INBO. Coding. Club! Session. of. 24/10/2019...."

# How to detect/remove/extract:

#   - any digit?

# any "."

# the last .

# All . at the end

#   - any extra "." , i.e. any . preceded by .


# Test some other rules, play with it...


## Challenge 3

## Clean column authorship






## Bonus challenge

### Concatenate the coumns PlaatsGemeente, PlaatsToponym, PlaatsToponymDetail in
### a new column called observation_location formatted as
### "PlaatsGemeente, PlaatsToponym: PlaatsToponymDetail"
bird_obs <- read_csv("./data/20191024_bird_observations.csv", na = "")


### Try to do the same with this other file containing NAs
bird_obs2 <- read_csv("/data/20191024_bird_observations_with_na.csv", na = "")
