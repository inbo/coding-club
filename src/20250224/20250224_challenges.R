# CHALLENGE 1 ####

# Load libraries:
library(tidyverse)      # to do datascience
library(here)           # to work easily with paths
library(sf)             # to work with geospatial vector data
library(leaflet)        # to make dynamic maps
library(DT)             # to make interactive tables
library(flexdashboard)  # to make dashboards


# Read data
cray_df <- readr::read_tsv(
  here::here("data", "20250224", "20250224_craywatch_cleaned.txt"),
  na = "",
  guess_max = 10000
)


## Chart 1 - top - Plot per date (year/month) and species ####

n_obs_per_month_species <-
  cray_df %>%
  count(year, month, species) %>%
  # combine year and month to a single date
  mutate(date = as.Date(paste0(year, "-", month, "-01"))) %>%
  arrange(date, species) %>%
  relocate(date,species, n, everything())
ggplot(n_obs_per_month_species,
       aes(x = date, y = n, fill = species)) +
  geom_bar(stat = 'identity') +
  # Use inferno colors for the species
  scale_fill_viridis_d(option = "inferno") +
  # Add title and labels
  ggtitle("Number of observations per month and species") +
  xlab("Date") + ylab("Number of observations")



## Chart 2 - bottom - Leaflet map ####
cray_fl <- sf::st_as_sf(cray_df,
                        coords = c("decimalLongitude", "decimalLatitude"),
                        crs = 4326)

# Create a palette that maps species to colors
pal <- colorFactor("inferno", cray_fl$species)
leaflet(cray_fl) %>%
  addTiles() %>%
  addCircleMarkers(popup = ~paste0(cray_fl$eventDate, ": ", cray_fl$species),
                   color = pal(cray_fl$species),
                   stroke = FALSE,
                   fillOpacity = 0.5,
                   radius = 4) %>%
  addLegend(pal = pal, values = ~species,
            position = "bottomright")



# CHALLENGE 2 ####

## Gauge chart and value box  on top ####

# Number of observations linked to craywatch (via waarnemingen.be)
dataset_name <- "Waarnemingen.be - Non-native animal occurrences in Flanders and the Brussels Capital Region, Belgium"
n_obs_craywatch <- cray_df %>%
  filter(datasetName == dataset_name) %>%
  nrow()
tot_obs <- nrow(cray_df)
percentage_craywatch <- n_obs_craywatch / tot_obs * 100


# BONUS CHALLENGE ####

cray_raw_df <- readr::read_tsv(
  here::here("data", "20250224", "20250224_craywatch_raw.txt"),
  na = "",
  guess_max = 10000
)

cray_cleaned_df <- cray_raw_df %>%
  filter(!is.na(year)) %>%
  select(gbifID, occurrenceID, species, speciesKey, decimalLatitude,
         decimalLongitude, coordinateUncertaintyInMeters,
         eventDate, year, month, countryCode, stateProvince,
         county, locality, basisOfRecord, individualCount,
         datasetName)

cray_cleaned_df %>%
  readr::write_tsv(here::here("data",
                              "20250224",
                              "20250224_craywatch_cleaned.txt")
  )

