library(tidyverse)

occs <-  read_tsv("data/20190423/20190423_species.csv")

# Challenge 1: ----
# Extract the columns
#   scientificName, decimalLatitude, decimalLongitude,
#   coordinateUncertaintyInMeters, eventDate, year, identifiedBy,
#   speciesKey and issue
# for the observations
#   - from June
#   - from either `Lycopus europaeus`, `Phragmites australis`, `Cymatia bonsdorffi` or `Lemna minor`
#   - where the `issue` (column in table) is NA

# YOUR CODE...
occs %>%
  filter(month == 6) %>%
  filter(species %in% c("Lycopus europaeus",
                        "Phragmites australis",
                        "Lemna minor",
                        "Cymatia bonsdorffi")) %>%
  filter(is.na(issue)) %>%
  select(scientificName, decimalLatitude, decimalLongitude,
         coordinateUncertaintyInMeters, eventDate, year,
         identifiedBy, speciesKey, issue)

# Challenge 2: ----
# Create a new column, called `grid_resolution_km`, which derives the grid resolution
#   using the `coordinateUncertaintyInMeters` information:
#   `gridresolution = sqrt(2)* coordinateUncertaintyInMeters/1000`
# Sort the columns from newest to oldest observation

occs %>%
  select(scientificName, decimalLatitude, decimalLongitude,
         coordinateUncertaintyInMeters, eventDate, year,
         issue) %>%  # YOUR CODE...
  mutate(grid_resolution_km = sqrt(2) * coordinateUncertaintyInMeters/1000) %>%
  arrange(desc(eventDate))


# Challenge 3 ----
# How many observations (count the number of rows) are available _for each_ year

occs %>%
  select(scientificName, genus, decimalLatitude, decimalLongitude,
         coordinateUncertaintyInMeters, eventDate, year, month,
         identifiedBy, speciesKey, issue) %>% # YOUR CODE...
  group_by(year) %>%
  count()

# Challenge 3 BONUS ----
# Check the `surveys` data set (20180222_surveys.csv), containing weights of
# different animals.
# Calculate the median, mean and number of records _for each_ `species_id`

surveys <-  read_csv("data/20180222/20180222_surveys.csv") %>%
  filter(!is.na(weight))

# YOUR CODE...
surveys %>%
  group_by(species_id) %>%
  summarise(mean_weight = mean(weight),
            median_weight = median(weight),
            n_values = n())

