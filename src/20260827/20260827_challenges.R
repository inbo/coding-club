library(DBI)
library(RSQLite)
library(tidyverse)

# CHALLENGE 1 ####



# CHALLENGE 2 ####



# CHALLENGE 3 ####



# BONUS CHALLENGE

counts <- readr::read_csv(
  file = "data/20260827/20260827_counts.csv",
  na = ""
)

events <- readr::read_csv(
  file = "data/20260827/20260827_events.csv",
  na = "",
  col_types = cols(
    location_id = col_integer(),
    month =  col_integer(),
    year = col_integer(),
  )
)

counters <- readr::read_csv(
  file = "data/20260827/20260827_counters.csv",
  na = ""
)




