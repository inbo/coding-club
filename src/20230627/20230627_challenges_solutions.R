library(sf)
library(tidyverse)
library(mapview) # optional; only needed to map spatial data on a map quickly

## CHALLENGE 1

lepidoptera_df <- readr::read_tsv("./data/20230627/20230627_lepidoptera_iNaturalist_2023.csv")

# 1

lepidoptera <- st_as_sf(lepidoptera_df,
                           coords = c("decimalLongitude", "decimalLatitude"),
                           crs = 4326)


# 2
layers <- st_layers("./data/20230627/20230627_protected_areas.gpkg")
layers


# 3
prot_areas <- st_read("./data/20230627/20230627_protected_areas.gpkg",
                           layer = "ps_hbtrl")
prot_areas

# you can eventually use the alias function `read_sf()`, maybe easier to
# remember as it is similar to readr functions, e.g. `read_csv()`,
# `read_tsv()`, `read_delim()` ? Up to you!
prot_areas <- read_sf("./data/20230627/20230627_protected_areas.gpkg",
                      layer = "ps_hbtrl")

# OPTIONAL: have a visual check by plotting the protected areas on a map
mapview::mapview(prot_areas)


# 4
st_crs(prot_areas)


# 5
st_crs(lepidoptera) == st_crs(prot_areas)

## notice that the user's provided string is different, but that's just a label
waldo::compare(
  st_crs(prot_areas),
  st_crs(lepidoptera)
)

# 6
provinces_be <- readRDS(file = "./data/20230627/20230627_provinces_be.rds")
class(provinces_be)

provinces_be <- st_as_sf(provinces_be)

# 7
# dplyr's filter works nicely with sf spatial data.frames as well: handy!
provinces_fl <- provinces_be %>%
  dplyr::filter(.data$TX_RGN_DESCR_NL == "Vlaams Gewest")

# 5 provinces in Flanders, indeed
nrow(provinces_fl)



## CHALLENGE 2

# 1
prot_areas_3035 <- st_transform(prot_areas, crs = 3035)
lepidoptera_3035 <- st_transform(lepidoptera, crs = 3035)


# 2

# save layer with protected areas
st_write(obj = prot_areas_3035,
         dsn = "./data/20230627/prot_areas_and_lepidoptera_3035.gpkg",
         layer = "prot_areas")

# save layer with observations of lepidoptera (you can use %>% as well)
lepidoptera_3035 %>%
  st_write(
    dsn = "./data/20230627/prot_areas_and_lepidoptera_3035.gpkg",
    layer = "lepidoptera_obs"
  )

# to save in other format, e.g. an ESRI shapefile, notice the different driver
st_write(
  obj = prot_areas_3035,
  dsn = "./data/20230627/prot_areas_and_lepidoptera_3035",
  layer = "prot_areas",
  driver = "ESRI Shapefile"
)

st_write(
  obj = lepidoptera_3035,
  dsn = "./data/20230627/prot_areas_and_lepidoptera_3035",
  layer = "lepidoptera_obs",
  driver = "ESRI Shapefile"
)

# you can use st_layers() to check what you did while writing
st_layers("./data/20230627/prot_areas_and_lepidoptera_3035.gpkg")
st_layers("./data/20230627/prot_areas_and_lepidoptera_3035")

# to overwrite a layer already existing, use APPEND = FALSE
st_write(obj = lepidoptera_3035,
         dsn = "./data/20230627/prot_areas_and_lepidoptera_3035.gpkg",
         layer = "lepidoptera_obs",
         append = FALSE)

# delete all layers and write a new one using delete_dsn argument
# this doesn't work on Windows for files with multiple layers, see
# https://github.com/r-spatial/sf/issues/1827
# restart the session, rerun the code to create lepidoptera_3035 and
# then the overwriting commando here below will work
st_write(obj = lepidoptera_3035,
         dsn = "./data/20230627/prot_areas_and_lepidoptera_3035.gpkg",
         layer = "lepidoptera_obs",
         delete_dsn = TRUE)

# one layer only
st_layers("./data/20230627/prot_areas_and_lepidoptera_3035.gpkg")


# 3
lepidoptera_3035_circles <- st_buffer(
  lepidoptera_3035,
  dist = lepidoptera_3035$coordinateUncertaintyInMeters
)

# to make the circles even more accurate, increase the number of segments per
# quadrant
lepidoptera_3035_circles <- st_buffer(
  lepidoptera_3035,
  dist = lepidoptera_3035$coordinateUncertaintyInMeters,
  nQuadSegs = 100
)


# optional: visual check of the circles. Notice that mapview authomatically
# converts your data to EPSG 4326 (WGS 84)
mapview(lepidoptera_3035_circles)


# CHALLENGE 3

# 1
lepidoptera_pts_in_prot_areas <- st_contains(x = prot_areas_3035,
                                             y = lepidoptera_3035)
lepidoptera_pts_in_prot_areas
View(lepidoptera_pts_in_prot_areas)

# ADVANCED: not requested but you could do this by using purrr package and add
# an help column,`in_prot_area`:
lepidoptera_3035 %>%
  mutate(in_prot_area =
           purrr::map_dbl(
             st_within(lepidoptera_3035,prot_areas_3035),
             ~ifelse(is.null(.x),NA,.x)
           )
  ) %>%
  filter(!is.na(in_prot_area))

# You can use `st_intersects()` as well: same result. However, st_contains gives
# more the idea of what you are doing
lepidoptera_pts_in_prot_areas <- st_intersects(x = prot_areas_3035,
                                             y = lepidoptera_3035)

lepidoptera_pts_in_prot_areas


# 2
lepidoptera_circles_intersect_prot_areas <- st_intersects(
  x = prot_areas_3035,
  y = lepidoptera_3035_circles
)


# Notice that you can get the protected area each observation belongs to by
# inverting x and y values
prot_areas_intersect_lepidoptera_circles <- st_intersects(
  x = lepidoptera_3035_circles,
  y = prot_areas_3035
)

# ADVANCED: via purrr and rlang you can get the answer as well:
lepidoptera_3035[
  !purrr::map_lgl(
    st_intersects(lepidoptera_3035_circles, prot_areas_3035),
    rlang::is_empty),]


# 3
names(lepidoptera_circles_intersect_prot_areas) <- prot_areas$GEBCODE
geb_code_sonian <- prot_areas %>%
  filter(NAAM == "Zoniënwoud") %>%
  pull(GEBCODE)
length(lepidoptera_circles_intersect_prot_areas[[geb_code_sonian]])


# 4
st_centroid(prot_areas)

# it seems that two polygons are not valid (FALSE)
st_is_valid(prot_areas)
st_is_valid(prot_areas_3035)
# to know why they are not valid, add argument reason and notice that the reason
# for invalidity changes while changing CRS (spherical geometry with crs = 4326
# vs planar geometry with crs = 3035)
st_is_valid(prot_areas, reason = TRUE)
st_is_valid(prot_areas_3035, reason = TRUE)

# validate the polygons
prot_areas_valid <- st_make_valid(prot_areas)
prot_areas_3035_valid <- st_make_valid(prot_areas_3035)

# calculate centroids of the valid polygons
cts_prot_areas <- st_centroid(prot_areas_valid)
cts_prot_areas_3035 <- st_centroid(prot_areas_3035_valid)

# 5
prov_antwerpen <- provinces %>%
  filter(TX_PROV_DESCR_NL == "Provincie Antwerpen")

prot_areas_antwerpen <- st_intersection(x = prot_areas_valid,
                                        y = prov_antwerpen)

# Notice how st_intersection adds all columns of y to x
prot_areas_antwerpen

# Optional: visual check with mapview()
mapview::mapview(prot_areas_antwerpen)


# 6

prot_areas_all <- st_union(prot_areas_valid)

View(prot_areas_all)


# BONUS CHALLENGE

# 1. How to get only the observations, as circles, **totally** contained in
# protected areas?
lepidoptera_circles_totally_in_prot_areas <- st_covers(
  x = prot_areas_3035,
  y = lepidoptera_3035_circles,
  sparse = TRUE)

View(lepidoptera_circles_totally_in_prot_areas)
mapview(prot_areas_3035, color = "magenta") + lepidoptera_3035_circles


# 2

# purrr::map_dbl() can help us to get the number of obs in each protected area
map_dbl(
  lepidoptera_pts_in_prot_areas,
  function(x) length(x)
)

# add the three new columns. Notice that by definition:
# `n_lepidoptera_all_in` >= `n_lepidoptera_pts` >= `lepidoptera_circles_totally_in_prot_areas`
prot_areas_3035_extra <-
  prot_areas_3035 %>%
  mutate(n_lepidoptera_pts = map_dbl(
    lepidoptera_pts_in_prot_areas,
    function(x) length(x)
    ),
    n_lepidoptera_intersect = map_dbl(
      lepidoptera_circles_intersect_prot_areas,
      function(x) length(x)
    ),
    n_lepidoptera_all_in = map_dbl(
      lepidoptera_circles_totally_in_prot_areas,
      function(x) length(x)
    )
  )

View(prot_areas_3035_extra)


# 3
library(qgisprocess)

#Notice you need to have QGIS installed
has_qgis()

# Search which algorithms could help us to create random points in polygons
qgisprocess::qgis_search_algorithms(algorithm = "points.*polygon")


# Apply the chosen algorithm after getting some info about the args needed
specs_algorithm <- qgis_get_argument_specs("qgis:randompointsinsidepolygons")
View(specs_algorithm)
result <- qgisprocess::qgis_run_algorithm(
  "qgis:randompointsinsidepolygons",
  STRATEGY = "Points count",
  VALUE = 50,
  INPUT  = prot_areas,
  MAX_TRIES_PER_POINT = 100)

# specify a file path as OUTPUT to write result in a file,
# e.g. OUTPUT  = "./data/20230627/random_points_in_provinces.gpkg"

#check result
result

# get the points out of the result object
random_pts_in_protected_areas <- st_read(result$OUTPUT)

#visualize points and protectred areas as a check
mapview(prot_areas) + random_pts_in_protected_areas
