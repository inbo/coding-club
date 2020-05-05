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

province_map <-
  tm_shape(provinces) +
  tm_borders() +
  tm_fill(col = "SURFACE.GIS.km2", title = "Area (km2)") +
  tm_facets("TX_RGN_DESCR_NL")
province_map

# You can make the two plots apart and then merge them via tmap_arrange()

# Extra: you can add text with province names using tm_text()
province_map +
  tm_text("TX_PROV_DESCR_NL", size = 0.6)

## INTERMEZZO

# You can switch between interactive and static plotting with
# tmap_mode('view') and tmap_mode('plot')
tmap_mode(mode = "view") # interactive (html)
province_map

# You can also switch from "plot" to "view" mode and viceversa by running ttm()
# Test
ttm()
province_map
ttm()
province_map

# For more control on interactive maps we need leaflet.
# Start point:
leaflet() %>%
  addTiles() # default: Open Street Map (OSM)



## CHALLENGE 2

# Read butterfly data (they are already in WGS84 projection)
obs_butterflies_df <- read_csv(
  "./data/20200326/20200326_butterflies.txt",
  na = "")
# Transform obs_butterflies to a sf data.frame (data in WGS84)
obs_butterflies_sf <-
  st_as_sf(obs_butterflies_df,
           coords = c("decimal_longitude", "decimal_latitude"),
           crs = 4326)

# Double check the Coordinate Reference System (CRS)
st_crs(obs_butterflies_sf)

# make a leaflet map centered at lng 4.89 and lat 51.01 with zoom level 7. Add
# markers at butterfly observations coordinates (decimal_longitude,
# decimal_latitude). Cluster them using the cluster option. Add pop-ups to the
# markers showing the eventDate as "Date: 2015-09-20. Add also labels to the
# markers showing the species.
# Hint:
# https://rstudio.github.io/leaflet/markers.html
# https://rstudio.github.io/leaflet/popups.html

# Here your code...

# Option 1: if you use the sf object obs_butterflies_sf you don't need to
# specify longitude and latitude: leaflet reads them directly from geometry.
map_butterflies_1 <-
  leaflet(obs_butterflies_sf) %>%
  setView(lng = 4.89,
          lat = 51.01,
          zoom = 7) %>%
  addTiles() %>%
  addMarkers(clusterOptions = markerClusterOptions(),
             popup = ~htmlEscape(paste0("Date:",paste(year,
                                           month,
                                           day,
                                           sep = "-"))),
             label = ~species)

map_butterflies_1

# Option 2: if you use the data.frame obs_butterfly_df you must pass
# the right column names to the arguments lng (longitdue) and lat (latitude).
map_butterflies_2 <-
  leaflet(obs_butterflies_df) %>%
  setView(lng = 4.89,
          lat = 51.01,
          zoom = 7) %>%
  addTiles() %>%
  addMarkers(lng = ~decimal_longitude,
             lat = ~decimal_latitude,
             clusterOptions = markerClusterOptions(),
             popup = ~htmlEscape(paste0("Date:",paste(year,
                                           month,
                                           day,
                                           sep = "-"))),
             label = ~species)

map_butterflies_2

# Notice the use of htmlEscape() in popup value. The code works even without it
# (as shown during coding club). However, it is strongly suggested in leaflet
# documentation for security reasons (run ?addMarkers and scroll down to the
# description of argument popup for more info.



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

# Create the palette function to map values into colors
pal <- colorBin(palette = "plasma",
                domain = provinces$SURFACE.GIS.km2)

provinces_leaflet <-
  leaflet(provinces) %>%
  addTiles() %>%
  addPolygons(color = "black",
              weight = 1,
              fillColor = ~pal(SURFACE.GIS.km2)) %>%
  addLegend(pal = pal,
            values = ~SURFACE.GIS.km2,
            opacity = 0.7,
            title = "Area (km2)",
            position = "bottomleft") %>%
  addMarkers(
    # centroids are not saved in provinces$geometry,
    # we need to pass the columns with lng and lat
    lng = ~lng, lat = ~lat,
    label = ~htmlEscape(TX_PROV_DESCR_NL),
    popup = ~htmlEscape(paste("Area:", round(SURFACE.GIS.km2)))
)

provinces_leaflet

# You can specify the data in the layers as well. Way better especially when
# makings maps with multiple layers (see BONUS Challenge)
provinces_leaflet2 <-
  leaflet() %>% # no data here
  addTiles() %>%
  addPolygons(data = provinces, # data goes here
              color = "black",
              weight = 1,
              fillColor = ~pal(SURFACE.GIS.km2)) %>%
  addLegend(data = provinces, # data goes here
            pal = pal,
            values = ~SURFACE.GIS.km2,
            opacity = 0.7,
            title = "Area (km2)",
            position = "bottomleft") %>%
  addMarkers(data = provinces, # data goes here
             lng = ~lng, lat = ~lat,
             label = ~htmlEscape(TX_PROV_DESCR_NL),
             popup = ~htmlEscape(paste("Area:", round(SURFACE.GIS.km2))))

provinces_leaflet2



## BONUS CHALLENGE

# We know that the GPS uncertainty in meters for the butterfly observations is
# function of the observation year. We add it in column
# coord_uncertainty_in_meters
obs_butterflies_df <-
  obs_butterflies_df %>%
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
obs_butterflies_selection_df <-
  obs_butterflies_df %>%
  filter(species %in%
           c("Citroenvlinder","Grote vos","Kleine vos","Oranjetipje"))

# Transform to sf data.frame
obs_butterflies_selection_sf <-
  obs_butterflies_selection_df %>%
  st_as_sf(coords = c("decimal_longitude", "decimal_latitude"),
           crs = 4326)
# Show the observations of these species as circles whose radius in meters is
# equal to the uncertainty as expressed in column coord_uncertainty_in_meters
# and the color represents the species. Add also a layer with provinces and
# correspondent legend. Let the user to show/hide these two layers and to choose
# between Esri.WorldImagery and the default Open Street Map as background.
# Hint: https://rstudio.github.io/leaflet/showhide.html

n_species <- length(unique(obs_butterflies_selection_df$species))
speciespal <- colorFactor(topo.colors(n_species),
                          obs_butterflies_selection_df$species)

butterflies_provinces_leaflet <-
  leaflet() %>%
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(providers$Esri.WorldImagery,
                   group = "World Imagery") %>%
  addCircles(data = obs_butterflies_selection_df,
             lng = ~decimal_longitude, # if you use obs_butterflies_selection_sf this is not needed
             lat = ~decimal_latitude, # if you use obs_butterflies_selection_sf this is not needed
             radius = ~coord_uncertainty_in_meters,
             color = ~speciespal(species),
             label =  ~year,
             group = "Butterflies") %>%
  addLegend(data = obs_butterflies_selection_df,
            pal = speciespal,
            values = ~species,
            opacity = 0.7, title = NULL,
            position = "bottomright",
            group = "Butterflies") %>%
  addPolygons(data = provinces,
              color = "black",
              weight = 1,
              fillColor = ~pal(SURFACE.GIS.km2),
              group = "Provinces") %>%
  addLegend(data = provinces,
            pal = pal,
            values = ~SURFACE.GIS.km2,
            opacity = 0.7, title = NULL,
            position = "bottomleft",
            group = "Provinces") %>%
  addLayersControl(
    baseGroups = c("OSM (default)",
                   "World Imagery"),
    overlayGroups = c("Butterflies",
                      "Provinces"),
    options = layersControlOptions(collapsed = FALSE)
  )

butterflies_provinces_leaflet
