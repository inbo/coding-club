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





## CHALLENGE 3

temperature <- terra::rast("./data/20231214/20231214_tdiff_tmax_tmin_january.tif")
temperature
# show first layer by default
mapview::mapview(temperature, maxpixels = 6998400) # it can take some seconds

land_use <- terra::rast("./data/20231214/20231214_land_use_nara_2016_100m.tif")
land_use
mapview::mapview(land_use, maxpixels = 3434753) #it can take some seconds

prot_areas <- sf::st_read("./data/20231214/20231214_natura2000_protected_areas.gpkg")
prot_areas
mapview::mapview(prot_areas)


