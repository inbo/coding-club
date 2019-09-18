library(tidyverse)
library(here)


## CHALLENGE 1

# file path
area_districts_f <- here("data", "oppervlakte_straat_wijken_Brugge.csv")
area_districts <- read_delim(area_districts_f, delim = ";")

# minimum area
min_area <- min(area_districts$OPPERVLAKTE, na.rm = TRUE) # min
# distict with smallest area
smallest_district <- area_districts$NAAM[which.min(area_districts$OPPERVLAKTE)]

# maximum area
max_area <- max(area_districts$OPPERVLAKTE, na.rm = TRUE) # max
# district with biggest area
biggest_district <- area_districts$NAAM[which.max(area_districts$OPPERVLAKTE)]

# average area
average_area <- mean(area_districts$OPPERVLAKTE, na.rm = TRUE) # mean
# the district with area most similar to average
average_district <- area_districts$NAAM[which.min(abs(area_districts$OPPERVLAKTE - average_area))]

# summarize these info in data frame (output)
info_districts <- tibble(min_area = min_area,
                             smallest_district = smallest_district,
                             max_area = max_area,
                             biggest_district = biggest_district,
                             average_area = average_area,
                             average_district = average_district)

################################################################################

## CHALLENGE 2

# Adapt the function get_info_districts so that you can reuse your function to
# tackle also "oppervlakte_straat_wijken_Antwerpen.csv" without
# altering the data itself



################################################################################

