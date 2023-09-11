library(tidyverse)
library(sf)
library(terra)
library(maptiles)
library(mapview)
library(leaflet)
library(htmltools)
library(htmlwidgets)
library(leafem)
library(crosstalk)
library(DT)



## CHALLENGE 1 - Plots

# 1 Vector data (continuous variable)
natura2000 <- sf::st_read("./data/20230831/20230831_protected_areas.gpkg")

ggplot2::ggplot(natura2000) +
  ggplot2::geom_sf(aes(fill = Shape_area), color = "black") +
  ggplot2::scale_fill_viridis_c()

pajottenland_municipalities <- st_read("./data/20230831/20230831_Pajottenland_municipalities.gpkg")

ggplot2::ggplot(pajottenland_municipalities) +
  ggplot2::geom_sf(aes(fill = Shape_Area), color = "black") +
  ggplot2::scale_fill_viridis_c()

ggplot2::ggplot(pajottenland_municipalities) +
  ggplot2::geom_sf(aes(fill = NameDut), color = "black")


# 2. Raster data (continous variable)
nitrogen <- terra::rast("./data/20230831/20230831_nitrogen.tif")
nitrogen

terra::plot(nitrogen,
     type = "continuous",
     legend = TRUE,
     range = c(10,47),
     col = hcl.colors(100, "Blue-Red 3")
)


# 3. Raster data (categorical values)
lu_nara_2016 <- terra::rast("./data/20230831/20230831_lu_nara_2016_100m.tif")
legend_land_use <- dplyr::tibble( # a tibble is a "nicely printed" data.frame
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


terra::plot(lu_nara_2016,
            type = "classes",
            col = legend_land_use$color,
            levels = legend_land_use$land_use,
            main = "Land use in Flanders"
)



## CHALLENGE 2 - static maps

# 1

# Dowload tiles and compose raster (SpatRaster)
natura2000_osm <- maptiles::get_tiles(natura2000, zoom = 9)

# Display map
maptiles::plot_tiles(natura2000_osm)

# Add Natura2000 areas
plot(st_geometry(natura2000), col = NA, add = TRUE)

# Add credit
mtext(text = get_credit("OpenStreetMap"),
      side = 1, line = -1, adj = 1, cex = .9,
      font = 3)


# 2

# Dowload other tiles and compose raster (SpatRaster)
natura2000_natgeo <- maptiles::get_tiles(
  natura2000,
  provider = "Esri.NatGeoWorldMap", # more info on [National Geographic Basemap](https://www.esri.com/news/arcuser/0312/national-geographic-basemap.html)
  zoom = 9)

# Display map
maptiles::plot_tiles(natura2000_natgeo)

# Fill the Natura2000 areas with a color based on their area (column `Shape_area`).
plot(st_geometry(natura2000), col = natura2000$Shape_area, add = TRUE)

# Add credit
mtext(text = get_credit("Esri.NatGeoWorldMap"),
      side = 1, line = -1, adj = 1, cex = .9,
      font = 3)


# EXTRA: how to save such a static map? To save it as a png file? Use function
# `png()` First, create the file, then run the code to produce the image and
# finally close the file. Use `?png()` to check how to specify image size and
# much more. Need to save in other formats? See `bmp()`, `pdf()` or `svg()`.

# Create a new file with png extension and open the graphics device
png("20230831_great_old_plot.png")
# Generate the image (copy paste code above)
natura2000_natgeo <- maptiles::get_tiles(
  natura2000,
  provider = "Esri.NatGeoWorldMap", # more info on [National Geographic Basemap](https://www.esri.com/news/arcuser/0312/national-geographic-basemap.html)
  zoom = 9)
maptiles::plot_tiles(natura2000_natgeo)
plot(st_geometry(natura2000), col = natura2000$Shape_area, add = TRUE)
mtext(text = get_credit("Esri.NatGeoWorldMap"),
      side = 1, line = -1, adj = 1, cex = .9,
      font = 3)
# close graphics device, (which we opened at the beginning via `png()`)
dev.off()



## CHALLENGE 3 - dynamic maps

# read data.frame with number of moths species for each UTM1km cell (`TAG`
# identifier)
n_moths <- readr::read_csv("./data/20230831/20230831_n_moths.txt")
n_moths

# read the geospatial file containing the UTM1km cells of Pajottenland
utm1_pajottenland <- sf::st_read(
  "./data/20230831/20230831_utm1km_Pajottenland.gpkg"
)

# Join data
n_moths <- utm1_pajottenland %>%
  dplyr::left_join(n_moths, by = "TAG")

n_moths

# 1
map_n_moths <- mapview(n_moths,
                   zcol = "n",
                   legend = TRUE,
                   color = "red"
)

map_n_moths

# EXTRA: how to specify your own color palette in mapview?
colpal <- colorRampPalette(c("white", "grey", "pink", "darkgreen"))

map_n_moths <- mapview(n_moths,
                       zcol = "n",
                       legend = TRUE,
                       color = "red",
                       na.color = "black",
                       col.regions = colpal,
                       map.types = "OpenStreetMap",
                       alpha = 50)
map_n_moths


# 2

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


# 3

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


# 4

combined_map <- map_pajottenland_municipalities + map_n_moths_advanced

combined_map


# 5

img <- "https://raw.githubusercontent.com/inbo/coding-club/master/docs/assets/images/coding_club_logo.svg"
combined_map_final <-
  combined_map %>%
  leafem::addLogo(img, url = "https://inbo.github.io/coding-club/")
combined_map_final


# EXTRA: how to save dynamic maps as html files?
htmlwidgets::saveWidget(combined_map_final,
                        file = "n_moth_species_pajottenland_utm1.html"
)



## Challenge 3 - dynamic maps: rasters

library(plainview)

lu_nara_2016_raster <- raster::raster(lu_nara_2016)
nitrogen_raster <- raster::raster(nitrogen)
mapview(lu_nara_2016_raster, maxpixels = 3434753)
mapview(nitrogen_raster, at = seq(0, 50, 5))



## BONUS CHALLENGE 1 - leaflet
htmltools::save_html(combined_map_final, file = "qdqsd.html")

# 1
pal <- leaflet::colorNumeric(
  palette = "viridis",
  domain = n_moths$n)

map_n_moths <- leaflet(n_moths) %>%
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

map_n_moths


# 2
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


# 3
map_n_moths %>%
  addPolygons(data = pajottenland_municipalities,
              color = "red",
              fillOpacity = 0)



## BONUS CHALLENGE 2 - leaflet + crosstalk

# 1

shared_n_moths_centroids <- crosstalk::SharedData$new(n_moths_centroids)

# create same leaflet as in BONUS CHALLENGE 1 but starting from new object wich
# allows us to link data to circles
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


# 2

# See solution in
# `src/20230831/20230801_challenge_solutions_bonus_challenge_2.html`
