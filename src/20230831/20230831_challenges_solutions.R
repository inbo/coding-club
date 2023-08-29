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

# read data.frame with number of moths species for each UTM1km cell (`TAG`
# identifier)
n_moths <- readr::read_csv("./data/20230831/20230831_n_moths.txt")
n_moths

# read the geospatial file containing the UTM1km cells of Pajottenland
utm1_pajottenland <- sf::st_read(
  "./data/20230831/20230831_utm1km_Pajottenland.gpkg"
)

n_moths <- utm1_pajottenland %>%
  dplyr::left_join(n_moths, by = "TAG")

n_moths

map_n_moths <- mapview(n_moths,
                   zcol = "n",
                   legend = TRUE,
                   color = "red"
)

map_n_moths

# 2. Let's fine tuning this map. Use "OpenStreetMap" map tiles only, set the
# opacity of the areas to 0.9 and the contour lines to 0.2. Set "number of moth species" as
# legend title and layer name. Hint:
# mapview [advance vignette](https://r-spatial.github.io/mapview/articles/mapview_02-advanced.html)

map_n_moths_advanced <- mapview(
  n_moths,
  zcol = "n",
  legend = TRUE,
  color = "red",
  map.types = "OpenStreetMap",
  alpha.regions = 0.9,
  layer.name = "number of moth species",
  lwd = 0.2
)

map_n_moths_advanced

# 3. Create a separate map with the municipalities of Pajottenland. The code to
# read geopackage with municipalities is provided. Use black as line color. Set
# layer name as `"municipality"`. Again, allow Open Street Map tiles only.
# Remove legend. Set line width to 1 and set opacity of the polygons to 0.

pajottenland_municipalities <- st_read("./data/20230831/20230831_Pajottenland_municipalities.gpkg")

map_pajottenland_municipalities <- mapview(pajottenland_municipalities,
                                           zcol = NULL,
                                           color = "black",
                                           map.types = "OpenStreetMap",
                                           alpha.regions = 0.0,
                                           layer.name = "municipality",
                                           label = NULL,
                                           legend = NULL,
                                           lwd = 1
)

map_pajottenland_municipalities

# 4. Combine the two maps. Make sure the hover text still shows the number of
# moth species.

combined_map <- map_pajottenland_municipalities + map_n_moths_advanced

combined_map

# 3. You have already installed leafem, so you should see by default the mouse
# coordindates (lat,lon) and zoom level on top right. If not check how to add on
# [extra leaflet functionalities](https://r-spatial.github.io/mapview/articles/mapview_06-add.html)
# vignette. Add also the INO coding club logo to the map with a link to the INBO
# coding club homepage: https://inbo.github.io/coding-club/. Link to the image
# provided in the code.

img <- "https://raw.githubusercontent.com/inbo/coding-club/master/docs/assets/images/coding_club_logo.svg"
combined_map_final <-
  combined_map %>%
  leafem::addLogo(img, url = "https://inbo.github.io/coding-club/")
combined_map_final


# dynamic maps: rasters

#Based on [mapview
#documentation](https://r-spatial.github.io/mapview/articles/mapview_01-basics.html#raster-data),
#we can still make dynamic maps with rasters as well. Notice that mapview
#doesn't support terra's rasters (class `SpatRaster`).

# > mapview(lu_nara_2016, maxpixels = 3434753)
# Error in (function (classes, fdef, mtable)  :
#             unable to find an inherited method for function ‘mapView’ for signature ‘"SpatRaster"’

# Conversion to a `RasterLayer` (raster package) is needed and code is provided based on [conversion article](https://geocompx.github.io/post/2021/spatial-classes-conversion/).
#See on [advanced
#vignette](https://r-spatial.github.io/mapview/articles/mapview_02-advanced.html)
#how to define a range for the nitrogen raster.


library(plainview)

lu_nara_2016_raster <- raster::raster(lu_nara_2016)
nitrogen_raster <- raster::raster(nitrogen)
mapview(lu_nara_2016_raster, maxpixels = 3434753)
mapview(nitrogen_raster, at = seq(0, 50, 5))
nitrogen_raster

## BONUS CHALLENGE 1 - leaflet

# 1. We didn't spoken about R package leaflet. To challenge yourself with
# leaflet, create a map with a leaflet map similar to the one you created with
# mapview in challenge 3. Some differences: make sure that the label shows the
# number of occurrences while the pop up diplays only the `TAG` of the UTM cell.
# The color of the areas should linked via viridis palette to the number of moth
# species. Show the legend as well on the bottomright. Use ``"number of moth
# species"` as legent title. Hint:
# [choropleths](https://rstudio.github.io/leaflet/choropleths.html) chapter

pal <- colorNumeric(
  palette = "viridis",
  domain = n_moths$n)

leaflet(n_moths) %>%
  addTiles() %>%
  addPolygons(popup = ~htmlEscape(TAG),
              label = ~htmlEscape(n),
              fillColor = ~pal(n),
              fillOpacity = 0.9,
              weight = 0.2,
              color = "red") %>%
  addLegend("bottomright", pal = pal, values = ~n,
            title = "number of moth species",
            opacity = 1
  )


# 2. Another kind of map now. Instead of polygons, let's use **circle markers**.
# Place the circles at the center of the UTM cells by using sf centroid
# function: `st_centroid(n_moths)`. Use same color palette as in 1. Set radius
# of the circles as `n/10`. Same popup and label text. Remove the stroke, i.e.
# the border of the circles. Set opacity of the circles to 0.5.

n_moths_centroids <- sf::st_centroid(n_moths)

map_n_moths_circles <- leaflet(n_moths_centroids) %>%
  addTiles() %>%
  addCircleMarkers(popup = ~htmlEscape(TAG),
                   label = ~htmlEscape(n),
                   radius = ~n/10,
                   color = ~pal(n),
                   stroke = FALSE,
                   fillOpacity = 0.5)
map_n_moths_circles

## BONUS CHALLENGE 2 - leaflet + crosstalk

# 1. Combine leaflet with data table via
# [crosstalk](https://rstudio.github.io/crosstalk/index.html). Unfortunately,
# crosstalk doesn't support polygons at the moment (see
# https://github.com/rstudio/crosstalk/issues/55). So, use the leaflet map with
# circle markers you created in the last exercise of BONUS CHALLENGE 1. Hint:
# everything you are doing is html. So, use the R package
# [DT](https://rstudio.github.io/DT/) to display the data.frame as HTML
# "tables".

shared_n_moths_centroids <- crosstalk::SharedData$new(n_moths_centroids)

# create same leaflet as before but starting from new object wich allows us to
# link data to circles
map_shared_n_moths <- leaflet(shared_n_moths_centroids) %>%
  addTiles() %>%
  addCircleMarkers(popup = ~htmlEscape(TAG),
                   label = ~htmlEscape(n),
                   radius = ~n/10,
                   color = ~pal(n),
                   stroke = FALSE,
                   fillOpacity = 0.5)

# create table with the data
data_table <- datatable(
  shared_n_moths_centroids,
  extensions="Scroller",
  style="bootstrap",
  class="compact",
  width="100%",
  options=list(deferRender=TRUE, scrollY=300, scroller=TRUE)
)

# combine map with table
bscols(map_shared_n_moths, data_table)

# 3. How to add a **filter slider** based on the number of observations?
# See 20221206_challenges_bonus_challenges1.Rmd and its rendered html version
# 20221206_challenges_bonus_challenge.html in src/20221206 folder
