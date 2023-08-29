library(tidyverse)
library(sf)
library(terra)
library(maptiles)
library(mapview)
library(leaflet)
library(htmltools)
library(leafem)
library(crosstalk)
library(DT)


## CHALLENGE 1 - Plots

# Plotting is still important. Let's warm-up by plotting some geospatial data.

# 1. GIS data (continuous variable)
natura2000 <- st_read("./data/20221206/20221206_protected_areas.gpkg")

ggplot(natura2000) +
  geom_sf(aes(fill = Shape_area), color = "black") +
  scale_fill_viridis_c()

# 2. Raster data (continuous variable)
nitrogen <- rast("./data/20221206/20221206_nitrogen.tif")
nitrogen

plot(nitrogen,
     type = "continuous",
     legend = TRUE,
     range = c(10,47),
     col = hcl.colors(100, "Blue-Red 3")
)

# 3. Raster data (categorical values)
lu_nara_2016 <- rast("./data/20221206/20221206_lu_nara_2016_100m.tif")
legend_land_use <- tibble( # a tibble is a "nicely printed" data.frame
  id = c(1:9),
  land_use = c(
    "Open natuur",
    "Bos",
    "Grasland",
    "Akker",
    "Urbaan",
    "Laag groen",
    "Hoog groen",
    "Water",
    "Overig"
  ),
  color = c(
    rgb(red = 223, green = 115, blue = 255, maxColorValue = 255),
    rgb(38, 115, 0, maxColorValue = 255),
    rgb(152, 230, 0, maxColorValue = 255),
    rgb(255, 255, 0, maxColorValue = 255),
    rgb(168, 0, 0, maxColorValue = 255),
    rgb(137, 205, 102, maxColorValue = 255),
    rgb(92, 137, 68, maxColorValue = 255),
    rgb(0, 197, 255, maxColorValue = 255),
    rgb(204, 204, 204, maxColorValue = 255)
  )
)
legend_land_use


plot(lu_nara_2016,
     type = "classes",
     col = legend_land_use$color,
     levels = legend_land_use$land_use,
     main = "Land use in Flanders")


## CHALLENGE 2 - static maps

# Let's make a static map of the borders of the natura2000 areas in Flanders
# using OpenStreetMaps using the R package maptiles.

# Dowload tiles and compose raster (SpatRaster)
natura2000_osm <- get_tiles(natura2000, zoom = 9)
# Display map
plot_tiles(natura2000_osm)
# Add Natura2000 areas
plot(st_geometry(natura2000), col = NA, add = TRUE)
# Add credit
mtext(text = get_credit("OpenStreetMap"),
      side = 1, line = -1, adj = 1, cex = .9,
      font = 3)

# 2. Use another tile provider and assign colors to the Natura2000 areas based
# on their area (column `Shape_area`).

# Dowload tiles and compose raster (SpatRaster)
natura2000_natgeo <- get_tiles(
  natura2000,
  provider = "Esri.NatGeoWorldMap", # more info on [National Geographic Basemap](https://www.esri.com/news/arcuser/0312/national-geographic-basemap.html)
  zoom = 9)
# Display map
plot_tiles(natura2000_natgeo)
# Fill the Natura2000 areas with a color based on their area (column `Shape_area`).
plot(st_geometry(natura2000), col = natura2000$Shape_area, add = TRUE)
# Add credit
mtext(text = get_credit("Esri.NatGeoWorldMap"),
      side = 1, line = -1, adj = 1, cex = .9,
      font = 3)


## CHALLENGE 3 - dynamic maps

# Using mapview:

# 1. Show Natura2000 areas on a map. The color of the areas should represent the
# number of hogweed occurrences in Flanders collected from 2010. Display the
# legend as well. Set the contour of the polygons in red. What happens when
# clicking on an area? Beautiful, isn't?

# read occurrences giant hogweed
occs_hogweed <- readr::read_tsv(
  file = "./data/20221206/20221206_gbif_occs_hogweed.txt",
  na = ""
)
# transform to sf spatial data.frame
occs_hogweed <- st_as_sf(occs_hogweed,
                         coords = c("decimalLongitude", "decimalLatitude"),
                         crs = 4326)
# count number of "points" in Natura2000 areas
occs_in_areas <- st_contains(natura2000, occs_hogweed)
# get number of points in each polygon as a vector
natura2000$n_occs <- purrr::map_dbl(occs_in_areas, function(x) length(x))


hogweed_in_prot_areas <- mapview(
  natura2000,
  zcol = "n_occs",
  legend = TRUE,
  color = "red"
)
hogweed_in_prot_areas

# 2. Let's fine tuning this map. Use "OpenStreetMap" only as map tiles, set the
# opacity of the areas to 0.9 and the contour lines to 0.2. Set "n. obs" as
# legend title and label while hovering on the areas in the form "x obs".  Hint:
# mapview [advance vignette](https://r-spatial.github.io/mapview/articles/mapview_02-advanced.html)

hogweed_in_prot_areas <- mapview(
  natura2000,
  zcol = "n_occs",
  legend = TRUE,
  color = "red",
  map.types = "OpenStreetMap",
  alpha.regions = 0.9,
  layer.name = "n obs",
  lwd = 0.2
)

hogweed_in_prot_areas

# 3. You have already installed leafem, so you should see by default the mouse
# coordindates (lat,lon) and zoom level on top right. If not check how to add on
# [extra leaflet functionalities](https://r-spatial.github.io/mapview/articles/mapview_06-add.html)
# vignette. Add also the INO coding club logo to the map with a link to the INBO
# coding club homepage: https://inbo.github.io/coding-club/. Link to the image
# provided in the code.

img <- "https://raw.githubusercontent.com/inbo/coding-club/master/docs/assets/images/coding_club_logo.svg"
hogweed_in_prot_areas_final <-
  hogweed_in_prot_areas %>%
  leafem::addLogo(img, url = "https://inbo.github.io/coding-club/")
hogweed_in_prot_areas_final


## BONUS CHALLENGE 1 - leaflet + crosstalk

# 1. We didn't spoken about R package leaflet. Only in the 3rd challenge, you
# have seen a little of it. To challenge yourself with leaflet, create a map
# with a leaflet map similar to the one you created with mapview in challenge 2.
# Make sure that the label shows the number of occurrences while the pop up
# diplays the name of the area. The color of the areas should linked via viridis
# palette to the number of occurrences. Show the legend as well. Hint: [choropleths](https://rstudio.github.io/leaflet/choropleths.html) chapter

pal <- colorNumeric(
  palette = "viridis",
  domain = natura2000$n_occs)

leaflet(natura2000) %>%
  addTiles() %>%
  addPolygons(popup = ~htmlEscape(NAAM),
              label = ~htmlEscape(n_occs),
              fillColor = ~pal(n_occs),
              fillOpacity = 0.9,
              weight = 0.2,
              color = "red") %>%
  addLegend("bottomright", pal = pal, values = ~n_occs,
            title = "n obs",
            opacity = 1
  )


# 2. Combine leaflet with data table via
# [crosstalk](https://rstudio.github.io/crosstalk/index.html). Unfortunately,
# crosstalk doesn't support polygons at the moment (see
# https://github.com/rstudio/crosstalk/issues/55). Make a leaflet with markers
# using the centroids of the areas (use `st_centroids()`). Hint: everything you
# are doing is html. So, use the R package [DT](https://rstudio.github.io/DT/)
# to display the data.frame as HTML "tables".
natura2000_centroids <- st_centroid(natura2000)
shared_natura2000 <- SharedData$new(natura2000_centroids)

leaflet_map <- leaflet(shared_natura2000) %>%
  addTiles() %>%
  addMarkers(popup = ~htmlEscape(NAAM),
             label = ~htmlEscape(n_occs))
data_table <- datatable(
  shared_natura2000, extensions="Scroller", style="bootstrap", class="compact", width="100%",
  options=list(deferRender=TRUE, scrollY=300, scroller=TRUE)
)
bscols(leaflet_map, data_table)

# 3. How to add a **filter slider** based on the number of observations?
# See 20221206_challenges_bonus_challenges1.Rmd and its rendered html version
# 20221206_challenges_bonus_challenge.html in src/20221206 folder
