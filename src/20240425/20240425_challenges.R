library(tidyverse)


## CHALLENGE 1

obs <- readr::read_csv("./data/20240425/20240425_observations.csv")

# Preview
glimpse(obs)




## CHALLENGE 2 - Summaries







## CHALLENGE 3 - Two-table verbs

media <- read_csv("./data/20240425/20240425_media.csv", na = "")

# Preview
glimpse(media)







## BONUS CHALLENGE 1 - dplyr + tidyr = love

ias <- read_csv("./data/20240425/20240425_ias_plants.csv", na = "")

# Preview
glimpse(ias)




## BONUS CHALLENGE 2 - dplyr + stringr = love

a <- tibble::tibble(
  name = c("Damiano", "Amber", "Rhea", "Dirk", "Emma", "Raïsa"),
  my_favorite_number_string = c("104", "023", "7", "666", "3", "9")
)
a





## BONUS CHALLENGE 3 - dplyr + tidyverse packages = love

si_data <- readr::read_csv(
  file = "./data/20240425/20240425_si_species_per_year_cell.csv"
)





## BOUNS CHALLENGE 4 - dealing with lists? purrr!

library(jsonlite) # install it first, if needed
datapackage_json <-
  jsonlite::read_json("https://raw.githubusercontent.com/inbo/etn/main/inst/assets/datapackage.json")


