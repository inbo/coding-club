library(tidyverse)
library(sf)
library(BelgiumMaps.StatBel)
library(leaflet)
library(htmltools)
library(tmap)

## CHALLENGE 1

# Load Belgian provinces
data("BE_ADMIN_PROVINCE")
provinces <- st_as_sf(BE_ADMIN_PROVINCE)
# Check CRS (coordinate reference system): wgs84 (EPSG code 4326).
st_crs(provinces)

# Plot a map with Belgian provinces using tmap. Documentation:
# https://workshop.mhermans.net/thematic-maps-r/04_plot.html#thematic_maps_with_tmap
# Show the borders, fill the provinces with a color based on their area (column
# SURFACE.GIS.km2) and provide a nice title to the legend, i.e. "Area (km2)".
# Divide them by region using facets.

# Here your code...


## CHALLENGE 2

# Read butterfly data
obs_butterflies <- read_csv(
  "./data/20200326_butterflies.txt",
  na = "")
# Extract coordinates
coords_obs_butterflies <-
  obs_butterflies %>%
  select(decimal_longitude, decimal_latitude)
# Transfomr obs_butterflies to a sf data.frame (data in WGS84)
obs_butterflies <-
  st_as_sf(obs_butterflies,
           coords = c("decimal_longitude", "decimal_latitude"),
           crs = 4326)
# Add coordinates as two extra columns
obs_butterflies <-
  obs_butterflies %>%
  bind_cols(coords_obs_butterflies)

# Double check the Coordinate Reference System (CRS)
st_crs(obs_butterflies)

# make a leaflet map centered at lng 4.89 and lat 51.01 with zoom level 7. Add
# markers at butterfly observations coordinates (decimal_longitude,
# decimal_latitude). Cluster them using the cluster option. Add pop-ups to the
# markers showing the eventDate as "Date: 2015-09-20. Add also labels to the
# markers showing the species.
# Hints:
# https://rstudio.github.io/leaflet/markers.html
# https://rstudio.github.io/leaflet/popups.html

# Here your code...

## CHALLENGE 3

# Transform to Lambert 31370, typical metrical projection for Belgium:
provinces_31370 <- st_transform(provinces, 31370)
# Calculate centroids
centroids_provinces_31370 <- st_centroid(provinces_31370)
# Transform centroids back to WGS84 (EPSG code 4326)
centroids_provinces <- st_transform(centroids_provinces_31370,
                                    crs = 4326)
# Extract coordinates centroids
coords_centroids <-
  st_coordinates(centroids_provinces) %>%
  as_tibble()
coords_centroids <-
  coords_centroids %>%
  rename(lng = X,
         lat = Y)
# Add coordinates of centroids to provinces
provinces <-
  provinces %>%
  bind_cols(coords_centroids)

# Make a choropleth map of belgian provinces based on their area
# (SURFACE.GIS.km2). Provide a legend as well. Then add markers at the centroids
# of the provinces. Add labels using the Dutch name of the provinces (column
# `TX_PROV_DESCR_NL`).
# Hint: https://rstudio.github.io/leaflet/choropleths.html

# Here your code...

## BONUS CHALLENGE

# We know that the GPS uncertainty in meters for the butterfly observations is
# function of the observation year. We add it in column
# coord_uncertainty_in_meters
obs_butterflies <-
  obs_butterflies %>%
  mutate(coord_uncertainty_in_meters = case_when(
    year < 1994 ~ 1000,
    year < 1998 ~ 500,
    year < 2005 ~ 200,
    year < 2008 ~ 100,
    year < 2014 ~ 50,
    TRUE ~ 30
  ))

# We focus on observations of Citroenvlinder, Grote vos, Kleine vos and
# Oranjetipje
obs_butterflies_selection <-
  obs_butterflies %>%
  filter(species %in%
           c("Citroenvlinder","Grote vos","Kleine vos","Oranjetipje"))

# Show the observations of these 4 species as circles whose radius in meters is
# equal to the uncertainty as expressed in column coord_uncertainty_in_meters
# and the color represents the species. Add also a layer with provinces and
# correspondent legend. Let the user to show/hide these two layers and to choose
# between Esri.WorldImagery and the default Open Street Map as background.
# Hint: https://rstudio.github.io/leaflet/showhide.html

# Here your code...
