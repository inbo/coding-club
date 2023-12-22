library(tidyverse)
library(sf) # to deal with spatial vector data
library(qgisprocess)
library(terra) # to deal with raster data
library(mapview)   # optional: to easily create maps for visualization purposes

# Read `20231214_watersurfaces_hab.gpkg` using sf package
water <- sf::st_read("./data/20231214/20231214_watersurfaces_hab.gpkg",
                     layer = "watersurfaces_hab_polygons"
)

mapview::mapview(water)

# Read `20231214_habitatsprings.geojson`
hab_springs <- sf::st_read("./data/20231214/20231214_habitatsprings_flanders.geojson")

mapview::mapview(hab_springs)

## CHALLENGE 1

# 1
qgis_show_help(algorithm = "native:buffer")
qgis_get_argument_specs(algorithm = "native:buffer")
qgis_get_output_specs(algorithm = "native:buffer")

# 2

# Find the algorithm to use via keywords
qgis_search_algorithms("shortest")
# Get more info about the algorithm
qgis_show_help(algorithm = "native:shortestline")
# Create a function to easily use autocompletion in RStudio
shortestline <- qgis_function("native:shortestline")
# Calculate shortest_paths from each `hab_springs` to `water`
shortest_paths_hab_to_water <- shortestline(SOURCE = hab_springs,
                                            DESTINATION = water
)

output_shortest_hab_to_water <- qgis_extract_output(shortest_paths_hab_to_water, "OUTPUT")
# Convert to sf
output_shortest_hab_to_water_sf <- sf::st_as_sf(output_shortest_hab_to_water)
# visualize via mapview
mapview(output_shortest_hab_to_water_sf) +
  mapview(hab_springs)

# 3 - 4
output_shortest_sf <-
  water %>%
  qgis_run_algorithm_p(
    algorithm = "native:shortestline",
    DESTINATION = hab_springs) %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

View(output_shortest_sf)

mapview::mapview(output_shortest_sf) +
  mapview::mapview(water)

## INTERMEZZO

# Example

library(tictoc) # install it first, if needed

tic("buffer via sf")
buffer_via_sf <- sf::st_buffer(water, nQuadSegs = 5000, dist = 100)
toc()

tic("buffer via qgisprocess")
buffer_via_qgisprocess <- qgis_run_algorithm(
  INPUT = water,
  algorithm = "native:buffer",
  SEGMENTS = 5000,
  DISTANCE = 100
)
toc()


## CHALLENGE 2

qgis_search_algorithms("count")

counts_function <- qgis_function("native:countpointsinpolygon")

ludwigia_grandiflora <- sf::st_read(
  "./data/20231214/20231214_ludwigia_grandiflora.geojson"
)

n_obs <- counts_function(
  POLYGONS = water,
  POINTS = ludwigia_grandiflora) %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

View(n_obs)

# or via mapview
mapview(n_obs, zcol = "NUMPOINTS")

n_individuals_water <- counts_function(
  POLYGONS = water,
  POINTS = ludwigia_grandiflora,
  WEIGHT = "individualCount") %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

n_individuals_water %>%
  dplyr::arrange(desc(.data$NUMPOINTS)) %>%
  View()


hab_springs_buffer <- hab_springs %>%
  qgis_run_algorithm_p(
    "native:buffer",
    DISTANCE = 'expression: sqrt("area_m2"/3.14)') %>% # pi is not supported by QGIS
  st_as_sf()

mapview::mapview(hab_springs_buffer)

## CHALLENGE 3

temperature <- terra::rast("./data/20231214/20231214_tdiff_tmax_tmin_january.tif")
temperature
land_use <- terra::rast("./data/20231214/20231214_land_use_nara_2016_100m.tif")
land_use
prot_areas <- sf::st_read("./data/20231214/20231214_natura2000_protected_areas.gpkg")


qgis_search_algorithms("statistics") %>%
  View()

t_diff_statistics <- qgis_run_algorithm("native:rasterlayerstatistics",
                                      INPUT = temperature,
                                      BAND = 1)
t_diff_statistics

tmin_statistics <- qgis_run_algorithm("native:rasterlayerstatistics",
                                      INPUT = temperature,
                                      BAND = 2)
tmin_statistics

tmax_statistics <- qgis_run_algorithm("native:rasterlayerstatistics",
                                      INPUT = temperature,
                                      BAND = 3)


tmax_statistics

# 3

qgis_search_algorithms("zonal")

qgis_get_argument_specs("native:zonalstatisticsfb") %>% View()

# Notice that the other algorithm, native:zonalstatistics, is DEPRECATED and
# works in place: the temporary file contains the solution, but
# is destroyed subsequently. More info in https://github.com/r-spatial/qgisprocess/issues/193

qgis_get_output_specs("native:zonalstatisticsfb")

zonalstatisticsfb <- qgis_function("native:zonalstatisticsfb")

prot_areas_zonal <- zonalstatisticsfb(INPUT = prot_areas,
                                      INPUT_RASTER = land_use,
                                      RASTER_BAND = 1,
                                      COLUMN_PREFIX = "zonal_", # optional, default: "_"
                                      STATISTICS = c("Majority", "Minority")) %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

View(prot_areas_zonal) # notice the two new columns: zonal_majority and zonal_minority

mapview::mapview(prot_areas_zonal, zcol = "zonal_majority")
