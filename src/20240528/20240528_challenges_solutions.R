library(sf)         # To work with vector spatial data
library(tidyverse)  # To do datascience
library(mapview)    # Optional: for fast visualization purposes


# File paths
lepidoptera_filepath <- "./data/20240528/20240528_lepidoptera_2024.tsv"
pa_filepath <- "./data/20240528/20240528_protected_areas_BE.gpkg"
utm_10_filepath <- "./data/20240528/20240528_utm10_belgium.geojson"

lepidoptera_df <- readr::read_tsv(lepidoptera_filepath)


## CHALLENGE 1

# 1
lepidoptera <- st_as_sf(lepidoptera_df,
                        coords = c("decimalLongitude", "decimalLatitude"),
                        crs = 4326)
lepidoptera


# 2
layers <- st_layers(pa_filepath)
layers

# The second and third layers have no geometry (geomtype = NA). This means that
# they are not spatial data.frames, but standard ones.
layers$geomtype


# 3
pa_layers <- sf::st_layers(pa_filepath)
pa_layers

pa <- sf::st_read(pa_filepath,
                     layer = "NaturaSite_polygon")

# If `layer` argument is not specified the first layer is used. The layer
# `NaturaSite_polygon` is the first one, so we can omit it. But notice the
# warning: it means that it's bad practice.
pa <- sf::st_read(pa_filepath)

# For visualization purposes, you can use the `mapview()` function. Same name as
# the package. Notice that `mapview()` shows the data using the WGS84 projection
# (transformation is performed behind the screen)
mapview::mapview(pa)


# 4

# Standard data.frames (= no spatial information included) can be added as
# layers of a geopackage. You must read them with sf as well.
pa_bioregion <- sf::st_read(pa_filepath, layer = "BIOREGION")
pa_habitats <- sf::st_read(pa_filepath, layer = "HABITATS")

class(pa_bioregion)
class(pa_habitats)


# 6

# Read polygons forming the 10x10km grid of BE. Notice the extension: geojson is
# a "geographic oriented" extension of json, another handy open format for
# spatial data.
utm_10 <- sf::st_read(utm_10_filepath)

mapview::mapview(utm_10)


# 7
st_crs(lepidoptera) == st_crs(pa)
st_crs(lepidoptera)
st_crs(pa)

st_crs(utm_10) == st_crs(pa)

# Notice the output of `st_crs`:
crs_utm_10 <- st_crs(utm_10)

# The output of `st_crs()` is of class "crs", not a suprise after all:
class(crs_utm_10)

# Actually it's a kind of list. You can check the names of the elements in the
# list
names(crs_utm_10)

# As a list, you can extract one element via `$`
crs_utm_10$input
crs_utm_10$wkt


# 8

# `dplyr::filter()` works nicely with sf spatial data.frames as well: handy!
pa_b <- pa %>%
  dplyr::filter(.data$SITETYPE == "B")
pa_b

mapview::mapview(pa_b)



## CHALLENGE 2

# 1
lepidoptera_3035 <- st_transform(lepidoptera, crs = 3035)

# Or via pipe
lepidoptera_3035 <- lepidoptera %>% st_transform(crs = 3035)


# 2

# Save layer with protected areas.
st_write(obj = pa,
         dsn = "./data/20240528/prot_areas_and_lepidoptera_3035.gpkg",
         layer = "prot_areas")

# Save layer with observations of Lepidoptera (you can use %>% as well).
lepidoptera_3035 %>%
  st_write(
    dsn = "./data/20240528/prot_areas_and_lepidoptera_3035.gpkg",
    layer = "lepidoptera_obs"
  )

# To save in other format, e.g. an ESRI shapefile, notice the different driver.
# Note that this works if the driver is installed on your machine.
st_write(
  obj = pa,
  dsn = "./data/20240528/prot_areas_and_lepidoptera_3035",
  layer = "prot_areas",
  driver = "ESRI Shapefile"
)

st_write(
  obj = lepidoptera_3035,
  dsn = "./data/20240528/prot_areas_and_lepidoptera_3035",
  layer = "lepidoptera_obs",
  driver = "ESRI Shapefile"
)

# You can use st_layers() to check what you did while writing
st_layers("./data/20240528/prot_areas_and_lepidoptera_3035.gpkg")
st_layers("./data/20240528/prot_areas_and_lepidoptera_3035")

# To overwrite a layer already existing, use APPEND = FALSE
st_write(obj = lepidoptera_3035,
         dsn = "./data/20240528/prot_areas_and_lepidoptera_3035.gpkg",
         layer = "lepidoptera_obs",
         append = FALSE)

# Delete all layers and write a new one using `delete_dsn` argument.
# This doesn't work on Windows for files with multiple layers, see
# https://github.com/r-spatial/sf/issues/1827
# Restart the session, rerun the code to create lepidoptera_3035 and
# then the overwriting commando here below will work.
st_write(obj = lepidoptera_3035,
         dsn = "./data/20240528/prot_areas_and_lepidoptera_3035.gpkg",
         layer = "lepidoptera_obs",
         delete_dsn = TRUE)

# one layer only
st_layers("./data/20240528/prot_areas_and_lepidoptera_3035.gpkg")


# 3
lepidoptera_3035_circles <- sf::st_buffer(
  lepidoptera_3035,
  dist = lepidoptera_3035$coordinateUncertaintyInMeters
)

# Optional: visual check of the circles. Notice that mapview authomatically
# converts your data to EPSG 4326 (WGS 84)
mapview::mapview(lepidoptera_3035_circles)

# By default 30 segments are used per quadrant to "simulate" a circle. To draw
# the circles even more accurate, increase the number of segments per quadrant.
# Example: 50 segments.
lepidoptera_3035_circles <- sf::st_buffer(
  lepidoptera_3035,
  dist = lepidoptera_3035$coordinateUncertaintyInMeters,
  nQuadSegs = 50
)



## CHALLENGE 3

# 1
lepidoptera_pts_in_prot_areas <- sf::st_contains(x = pa,
                                             y = lepidoptera_3035)
# Check the output
lepidoptera_pts_in_prot_areas
View(lepidoptera_pts_in_prot_areas)

# Notice that this output is an object of class "sgbp",
# which means "sparse geometry binary predicate list".
# More info via ?sgpb
class(lepidoptera_pts_in_prot_areas)

# You can use `sf::st_intersects()` as well: same result. However, st_contains
# gives more the idea of what you are doing
lepidoptera_pts_in_prot_areas <- sf::st_intersects(x = pa,
                                               y = lepidoptera_3035)
lepidoptera_pts_in_prot_areas

# You can opt for `sparse = FALSE` to obtain a matrix 310 x 945 with
# booleans (`TRUE` or `FALSE`). You can then transform to data.frame (tibble) if
# needed. IMPORTANT: this way to represent the result can become impractical if
# too many pts/polygons are involved.
lepidoptera_pts_in_prot_areas <- sf::st_intersects(x = pa,
                                               y = lepidoptera_3035,
                                               sparse = FALSE)
dim(lepidoptera_pts_in_prot_areas)
lepidoptera_pts_in_prot_areas
# Use gbifID (unique identifier of the GBIF occurrences) as column names
colnames(lepidoptera_pts_in_prot_areas) <- as.character(lepidoptera_3035$gbifID)
lepidoptera_pts_in_prot_areas_df <- dplyr::as_tibble(
  lepidoptera_pts_in_prot_areas,
  .name_repair = "minimal"
)
lepidoptera_pts_in_prot_areas_df


# 2
lepidoptera_circles_intersect_prot_areas <- sf::st_intersects(
  x = pa,
  y = lepidoptera_3035_circles
)
lepidoptera_circles_intersect_prot_areas

# Notice that you can get the protected area each observation belongs to by
# inverting x and y values
prot_areas_intersect_lepidoptera_circles <- sf::st_intersects(
  x = lepidoptera_3035_circles,
  y = pa
)
prot_areas_intersect_lepidoptera_circles


# 3
centroids_pa <- sf::st_centroid(pa)
# For some protected areas the centroid could be out the protected area. This is
# due to the fact that some protected areas are very scattered multipolygons.
mapview(pa) + mapview(centroids_pa)

areas_pa <- sf::st_area(pa)
areas_pa

# 4
lepidoptera_circles_totally_in_prot_areas <- st_covers(
  x = pa,
  y = lepidoptera_3035_circles
)
lepidoptera_circles_totally_in_prot_areas


# 5
pa_all <- sf::st_union(pa)

View(prot_areas_all)


# 6
cells_in_pa <- sf::st_intersects(utm_10, pa)

# Notice how a 10x10km cell can intersect more than one protected area.
View(cells_in_pa)


## BOUNS CHALLENGE

library(terra)

# Get the bounding box of `utm_10`
bbox <- sf::st_bbox(utm_10)
utm_10$values <- rnorm(nrow(utm_10))
mapview(utm_10, zcol = "values")

# To create a raster with terra, first we have to convert our sf object to a
# terra object of class SpatVector
utm_10_spat_vector <- terra::vect(utm_10 %>% dplyr::select(values, geometry))
utm_10_spat_vector

# Notice you can visualize SpatVector objects as well with mapview, handy!
mapview(utm_10_spat_vector, zcol = "values")

# Transform to raster now.
# First, make a template
utm_10_raster_template <- terra::rast(utm_10_spat_vector,
                             resolution = 10000,
                             xmin = bbox$xmin,
                             xmax = bbox$xmax,
                             ymin = bbox$ymin,
                             ymax = bbox$xmax)

# Second, use the template to apply the transformation
utm_10_raster <- terra::rasterize(x = utm_10_spat_vector,
                           y = utm_10_raster_template,
                           field = "values"
)

# Unfortunately mapview, which visualizes data in WG84 (EPSG code: 4326) only, doesn't transform correctly the raster. but this is a visualization issue only!
mapview(utm_10_raster, zcols = "values") +
  mapview(utm_10, zcols = "values")

# See what happen using ggplot.
# It is a two-step process. Inspired by:
# https://tmieno2.github.io/R-as-GIS-for-Economists/geom-raster.html#visualize-raster-with-geom_raster
# First, we need to transform the raster to a data.frame
utm_10_raster_df <-
  utm_10_raster %>%
  as.data.frame(xy = TRUE) %>%
  # Remove cells with NA
  na.omit()

# Second, we plot it using `geom_raster()`
ggplot() +
  geom_raster(data = utm_10_raster_df,
              aes(x = x , y = y, fill = values))

# Let's plot the raster on top of the spatial grid. To show it is done
# correctly, let's assign a uniform red color to the raster.  As you see the
# raster is correct. All borders are perfectly
ggplot() +
  geom_sf(data = utm_10, aes(fill = values)) +
  geom_raster(data = utm_10_raster_df, aes(x = x , y = y),
              fill = "red",
              alpha = 0.3)
