library(tidyverse)
library(sf) # to deal with spatial vector data
library(qgisprocess)
library(terra) # to deal with raster data
library(mapview)   # optional: to easily create maps for visualization purposes

# Read `20261029_watersurfaces_hab.gpkg` using sf package
water <- sf::st_read("./data/20261029/20261029_watersurfaces_hab.gpkg",
                     layer = "watersurfaces_hab_polygons"
)

# Show water with mapview
mapview::mapview(water)

# Read `20261029_habitatsprings.geojson`
hab_springs <- sf::st_read("./data/20261029/20261029_habitatsprings_flanders.geojson")

mapview::mapview(hab_springs)


# CHALLENGE 0 ####

# Get all QGIS algorithm providers
qgis_providers()

# Read input data from sf package
input <- sf::read_sf(system.file("shape/nc.shp", package = "sf"))
plot(sf::st_geometry(input)) # Not present in example online

# Run the QGIS algorithm "native:buffer" with the input data, a distance of 1,
# and dissolve set to TRUE
result <- qgis_run_algorithm(
  "native:buffer",
  INPUT = input,
  DISTANCE = 1,
  DISSOLVE = TRUE
)

result

output_sf <- sf::st_as_sf(result)
plot(sf::st_geometry(output_sf))

mapview::mapview(output_sf)  + mapview::mapview(input)

# CHALLENGE 1 ####

## 1.1 ####
qgis_show_help(algorithm = "native:buffer")
qgis_get_argument_specs(algorithm = "native:buffer")
qgis_get_output_specs(algorithm = "native:buffer")


## 1.2 ####

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

output_shortest_hab_to_water <- qgis_extract_output(
  shortest_paths_hab_to_water,
  "OUTPUT"
)
# Convert to sf
output_shortest_hab_to_water_sf <- sf::st_as_sf(output_shortest_hab_to_water)
# visualize via mapview
mapview(output_shortest_hab_to_water_sf) +
  mapview(hab_springs) +
  mapview(water)

## 1.3 & 1.4 ####
output_shortest_sf <-
  water %>%
  qgis_run_algorithm_p(
    algorithm = "native:shortestline",
    DESTINATION = hab_springs) %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

# Alternatively, use `shortestline()` function defined above
output_shortest_sf <-
  water %>%
  shortestline(DESTINATION = hab_springs) %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

View(output_shortest_sf)

mapview(output_shortest_sf) +
  mapview(hab_springs) +
  mapview(water)


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


# CHALLENGE 2 ####

hydrocotyle_ranunculoides <- sf::st_read(
  "./data/20261029/20261029_hydrocotyle_ranunculoides.geojson"
)

## 2.1 ####
qgis_search_algorithms("count")

counts_function <- qgis_function("native:countpointsinpolygon")

n_obs <- counts_function(
  POLYGONS = water,
  POINTS = hydrocotyle_ranunculoides) %>%
  # Only "OUTPUT" returned: `qgis_extract_output()` can be omitted. Try out!
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

# View the number of points per polygon: order by NUMPOINTS from high to low
n_obs %>%
  dplyr::arrange(desc(NUMPOINTS)) %>%
  View()

# or via mapview (only the ones with NUMPOINTS > 0)
n_obs %>%
  dplyr::filter(NUMPOINTS > 0) %>%
  mapview(zcol = "NUMPOINTS")


## 2.2 ####
hab_springs_buffer <- hab_springs %>%
  qgis_run_algorithm_p(
    "native:buffer",
    # pi is not supported by QGIS
    DISTANCE = 'expression: sqrt("area_m2"/pi())') %>%
  st_as_sf()

# Another way to write the expression for DISTANCE
hab_springs_buffer <- hab_springs %>%
  qgis_run_algorithm_p(
    "native:buffer",
    # pi is not supported by QGIS
    DISTANCE = 'expression: sqrt("area_m2"/pi())') %>%
  st_as_sf()


mapview::mapview(hab_springs_buffer) + mapview(hab_springs)


## 2.3 ####
qgis_search_algorithms("validity")
qgis_show_help("native:checkvalidity")
# The algorithm returns three outputs: valid, invalid and error features
qgis_get_output_specs("native:checkvalidity")

check_water <- qgis_run_algorithm(
  "native:checkvalidity",
  INPUT_LAYER = water)

# Use outputs `INVALID_COUNT` to get the number of invalid features
check_water$INVALID_COUNT == 0
# Or use the output `VALID_cOUNT` to get the number of valid features
check_water$VALID_COUNT == nrow(water)

# Same check in sf, for comparison
sum(!sf::st_is_valid(water))


## 2.4 ####

invalid <- sf::st_sf(
  case = c("bowtie", "self-touching ring", "hole outside shell", "duplicate point"),
  geometry = sf::st_as_sfc(c(
    # bowtie: the ring crosses itself
    "POLYGON((0 0, 2 2, 2 0, 0 2, 0 0))",
    # ring touches itself in a single point
    "POLYGON((5 0, 8 0, 8 3, 6 1, 5 3, 5 0, 7 1, 5 0))",
    # hole lies completely outside the outer ring
    "POLYGON((10 0, 14 0, 14 4, 10 4, 10 0), (20 20, 21 20, 21 21, 20 21, 20 20))",
    # repeated vertex (usually still valid, a good contrast case)
    "POLYGON((0 10, 4 10, 4 10, 4 14, 0 14, 0 10))"
  )),
  crs = 31370
)

plot(invalid, col = c("red", "orange", "yellow", "green"), border = "black")
sf::st_is_valid(invalid)
# Explains why each one is invalid
sf::st_is_valid(invalid, reason = TRUE)

# Search algorithm to fix the polygons
qgis_search_algorithms("fix")

qgis_show_help("native:fixgeometries")

valid <- qgis_run_algorithm("native:fixgeometries", INPUT = invalid) %>%
  sf::st_as_sf()

# Notice that the hole (3rd case) is not a hole anymore, but a separate polygon
valid
plot(valid, col = c("red", "orange", "yellow", "green"), border = "black")



# INTERMEZZO 2 ####
input <- sf::read_sf(system.file("shape/nc.shp", package = "sf"))

# Using qgisprocess
input %>%
  qgisprocess::qgis_run_algorithm_p(
    algorithm = "native:buffer",
    DISTANCE = 0.2,
    DISSOLVE = TRUE,
    END_CAP_STYLE = "Flat") %>%
  sf::st_as_sf() %>%
  plot()

# Using qgis R package
input %>%
  qgis::qgis_buffer(
    DISTANCE = 0.2,
    DISSOLVE = TRUE,
    END_CAP_STYLE = "Flat") %>%
  st_as_sf() %>%
  plot()



# CHALLENGE 3A ###

prot_areas <- sf::st_read(
  "./data/20261029/20261029_natura2000_protected_areas.gpkg"
)

## 3A.1 ####
water_in_prot <- qgis_run_algorithm(
  "native:clip",
  INPUT = water,
  OVERLAY = prot_areas
) %>%
  sf::st_as_sf()

mapview::mapview(prot_areas, col.regions = "green", alpha.regions = 0.3) +
  mapview::mapview(water_in_prot, col.regions = "red")

# Same output using the `native:intersection` algorithm
get_intersection <- qgis_function("native:intersection")
res <- get_intersection(
  INPUT = water,
  OVERLAY = prot_areas
)

mapview::mapview(water, col.regions = "blue") +
  mapview::mapview(prot_areas, col.regions = "green") +
  mapview::mapview(sf::st_as_sf(res), col.regions = "red")


## 3A.2 ####
water_outside_prot <- qgis_run_algorithm(
  "native:difference",
  INPUT = water,
  OVERLAY = prot_areas
) %>%
  sf::st_as_sf()

mapview::mapview(water_outside_prot, col.regions = "orange") +
  mapview::mapview(water_in_prot, col.regions = "red")



# CHALLENGE 3B ####
land_use <- terra::rast("./data/20231214/20231214_land_use_nara_2016_100m.tif")
land_use


## 3B.1 ####
qgis_search_algorithms("zonal")

qgis_get_argument_specs("native:zonalstatisticsfb") %>% View()

# Notice that the algorithm native:zonalstatistics is not shown (when using QGIS
# 3.44) and it is DEPRECATED and works in place: the temporary file contains the
# solution, but is destroyed subsequently. More info in
# https://github.com/r-spatial/qgisprocess/issues/193.
#  So, use `native:zonalstatisticsfb` instead.

qgis_get_output_specs("native:zonalstatisticsfb")

zonalstatisticsfb <- qgis_function("native:zonalstatisticsfb")

prot_areas_zonal <- zonalstatisticsfb(
  INPUT = prot_areas,
  INPUT_RASTER = land_use,
  RASTER_BAND = 1,
  COLUMN_PREFIX = "zonal_", # optional, default: "_"
  STATISTICS = c("Majority", "Minority")
) %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

# Notice the two new columns: `zonal_majority` and `zonal_minority`
View(prot_areas_zonal)

mapview::mapview(prot_areas_zonal, zcol = "zonal_majority")
mapview::mapview(prot_areas_zonal, zcol = "zonal_minority")

## 3B.2 ####
de_maten <- prot_areas %>% dplyr::filter(NAAM == "De Maten")

qgis_search_algorithms("clip") %>% View()
qgis_show_help("gdal:cliprasterbymasklayer")

land_use_clip <- qgis_run_algorithm(
  "gdal:cliprasterbymasklayer",
  INPUT = land_use,
  MASK = de_maten,
  CROP_TO_CUTLINE = TRUE, # crop the extent to the polygon
  KEEP_RESOLUTION = TRUE # don't resample the 100 m cells
) %>%
  qgis_extract_output("OUTPUT") %>%
  qgis_as_terra()

mapview::mapview(land_use_clip) + mapview::mapview(de_maten)

## 3B.3 ####
qgis_search_algorithms("sampling") %>% View()

springs_land_use <- hab_springs %>%
  qgis_run_algorithm_p(
    "native:rastersampling",
    RASTERCOPY = land_use,
    COLUMN_PREFIX = "land_use_" # optional, default: "SAMPLE_"
  ) %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

View(springs_land_use) # look at the new column(s) with prefix "land_use_"

# How many springs lie in each land use class?
springs_land_use %>%
  sf::st_drop_geometry() %>%
  dplyr::count(.data$land_use_1)

# Compare with terra
terra::extract(land_use, terra::vect(hab_springs)) %>%
  dplyr::count(.data[[names(land_use)[1]]])


## 3B.4 ####
qgis_show_help("gdal:polygonize")

land_use_polygons <- qgis_run_algorithm(
  "gdal:polygonize",
  INPUT = land_use,
  BAND = 1,
  FIELD = "class", # name of the field holding the cell value
  EIGHT_CONNECTEDNESS = FALSE
) %>%
  qgis_extract_output("OUTPUT") %>%
  sf::st_as_sf()

mapview::mapview(land_use_polygons[1:50000,], zcol = "class")
