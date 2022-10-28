library(tidyverse)
library(sf)

ludwigia_df <- read_tsv("./data/20221025/20221025_ludwigia_grandiflora.txt")

# 1. Create a geospatial data.frame called `spatial_ludwigia_df` starting from
# `ludwigia_df`. Note that GBIF data are stored using WGS 84. Hint: find first
# which numeric code is associated with WGS84 coordinate reference system and
# use the cheatsheet.
spatial_ludwigia_df <- st_as_sf(ludwigia_df,
                                 coords = c("decimalLongitude",
                                            "decimalLatitude"),
                                 crs = 4326)

# 2. How many layers does the  geospatial file 20221025_protected_areas1.gpkg
# contain?
st_layers("./data/20221025/20221025_protected_areas.gpkg")

# 3. Read the layer `ps_hbtrl`: call it `prot_areas`
prot_areas <- st_read("./data/20221025/20221025_protected_areas.gpkg",
                      layer = "ps_hbtrl")

# you can eventually use the alias function read_sf(), maybe easier to
# rememeber? Up to you!
prot_areas <- read_sf("./data/20221025/20221025_protected_areas.gpkg",
                      layer = "ps_hbtrl")


# 4. What is the coordinate reference system declared by user? Does it coincide
# with the real Geographic Coordinate Reference System (GEOCRS)?
st_crs(prot_areas)

# 5. Check that the CRS of `prot_areas` and `spatial_ludwigia_df` are the same
st_crs(prot_areas) == st_crs(spatial_ludwigia_df)

# 6. Read the Belgian provinces rds file as `20221025_be_provinces_sp` (the code
# is given!). What is the class of this variable? From which package? Transform
# it to a sf object. Is the CRS of the provinces the same as the CRS of the
# observations?
be_provinces_sp <- read_rds(
  file = "./data/20221025/20221025_be_provinces_sp.rds"
)

be_provinces <- st_as_sf(be_provinces_sp)

# notice that the source CRS (SOURCECRS) has GEOCRS label = "unknown". However,
# the other fields of the GEOCRS are enough for R to understand that the
# polygons are in WGS84
st_crs(be_provinces)

st_crs(prot_areas) == st_crs(be_provinces)

# 7. Extract the Flemish provinces
fl_provinces <- be_provinces %>% filter(TX_RGN_DESCR_NL == "Vlaams Gewest")

## CHALLENGE 2

# 1. Transform both `prot_areas` and `spatial_ludwigia_df` to [European
# Terrestrial Reference System 1989](https://epsg.io/3035), the coordinate
# reference system used at EU level
prot_areas_3035 <-
  prot_areas %>%
  st_transform(3035)

spatial_ludwigia_df_3035 <-
  spatial_ludwigia_df %>%
  st_transform(3035)

# 2. Write the transformed data as a geopackage file called
# `prot_areas_and_ludwigia_3035.gpkg` with two layers: the first called
# `prot_areas`, containing the protected areas, the second layer,
# `ludwigia_obs`, containing the observations of water primrose

# save layer with protected areas
st_write(obj = prot_areas_3035,
         dsn = "./data/20221025/prot_areas_and_ludwigia_3035.gpkg",
         layer = "prot_areas")

# save layer with observations of water primrose (you can use %>% as well)
spatial_ludwigia_df_3035 %>%
  st_write(
    dsn = "./data/20221025/prot_areas_and_ludwigia_3035.gpkg",
    layer = "ludwigia_obs"
)

# to save in other format, e.g. an ESRI shapefile, notice the different driver
st_write(
  obj = prot_areas_3035,
  dsn = "./data/20221025/prot_areas_and_ludwigia_3035.gdb",
  layer = "prot_areas",
  driver = "ESRI Shapefile"
)

st_write(
  obj = spatial_ludwigia_df_3035,
  dsn = "./data/20221025/prot_areas_and_ludwigia_3035.gdb",
  layer = "ludwigia_obs",
  driver = "ESRI Shapefile"
)

# you can use st_layers() to check what you did while writing
st_layers("./data/20221025/prot_areas_and_ludwigia_3035.gpkg")
st_layers("./data/20221025/prot_areas_and_ludwigia_3035.gdb")

# to overwrite a layer already existing, use APPEND = FALSE
st_write(obj = spatial_ludwigia_df_3035,
         dsn = "./data/20221025/prot_areas_and_ludwigia_3035.gpkg",
         layer = "ludwigia_obs",
         append = FALSE)

# delete all layers and write a new one using delete_dsn argument
# this doesn't work on Windows for files with multiple layers, see
# https://github.com/r-spatial/sf/issues/1827
# restart the session, rerun the code to create spatial_ludwigia_df_3035 and
# then the overwriting commando here below will work
st_write(obj = spatial_ludwigia_df_3035,
         dsn = "./data/20221025/prot_areas_and_ludwigia_3035.gpkg",
         layer = "ludwigia_obs",
         delete_dsn = TRUE)

# one layer only
st_layers("./data/20221025/prot_areas_and_ludwigia_3035.gpkg")

# 3. Due to spatial uncertainty (gridded data, GPS uncertainty, etc.)
# observations should not be idealized as points in space, but as circles.
# Create such circles using the values store in column
# `coordinateUncertaintyInMeters` of `spatial_ludwigia_df_3035`
circles_spatial_ludwigia_3035 <-
  spatial_ludwigia_df_3035 %>%
  st_buffer(
  dist = spatial_ludwigia_df_3035$coordinateUncertaintyInMeters
)


# INTERMEZZO - S2 geometry
#
# Notice that since last version of sf you can apply such spatial operations in
# spherical CRSs (aka systems using lat-lon like WGS84)
circles_spatial_ludwigia <-
  spatial_ludwigia_df %>%
  st_buffer(
    dist = spatial_ludwigia_df$coordinateUncertaintyInMeters
)



## CHALLENGE 3

# Using data in CRS 3035:
# 1. Find which observations, as points, are _contained_ in each protected area?
ludwigia_pts_in_prot_areas <- st_contains(x = prot_areas_3035,
                                           y = spatial_ludwigia_df_3035)

# You can use `st_intersects()` as well: same result. However, st_contains gives
# more the idea of what you are doing
ludwigia_pts_in_prot_areas <- st_intersects(x = prot_areas_3035,
                                             y = spatial_ludwigia_df_3035)


# 2. But we should better check which observations, as circles (!), _intersect_
# each protected area. How to do it?
ludwigia_circles_intersect_prot_areas <- st_intersects(
  x = prot_areas_3035,
  y = circles_spatial_ludwigia_3035
)

# Notice that you can get the protected area each observation belongs to by
# inverting x and y values
prot_areas_intersect_ludwigia_circles <- st_intersects(
  x = circles_spatial_ludwigia_3035,
  y = prot_areas_3035
)

# 3. So, how many observations in the protected area called `"Demervallei"`?
names(ludwigia_circles_intersect_prot_areas) <- prot_areas$GEBCODE
geb_code_demervallei <- prot_areas %>%
  filter(NAAM == "Demervallei") %>%
  pull(GEBCODE)
length(ludwigia_circles_intersect_prot_areas[[geb_code_demervallei]])


# 4. Sometimes it's interesting to calculate the centroid of a polygon, e.g. for
# visualizations. Easy by using sf function `st_centroids()`. However, you get
# an error while calculating the centroids of `prot_areas`. What does it mean?
# How to solve the problem?

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
cts_prot_areas_3035 <- st_centroid(prot_areas_valid_3035)

# notice how not all reasons for invalidity affect the computation of centroids
# https://github.com/r-spatial/sf/issues/1829#issuecomment-953763358
# Actually you don't need to validate the polygons in crs 3035 to calculate
# the centroids
cts_prot_areas_3035 <- st_centroid(prot_areas_3035)


## BONUS CHALLENGE

# 1. How to get only the observations, as circles, **totally** contained in
# protected areas?
ludwigia_circles_totally_in_prot_areas <- st_covered_by(
  x = prot_areas_3035,
  y = circles_spatial_ludwigia_3035
)

map_dbl(
  ludwigia_circles_totally_in_prot_areas,
  function(x) length(x)
)

# 2. Not a sf question, but still nice to solve: how to add to `prot_areas_3035`
# a column called `n_ludwigia` with the number of observations for each
# protected area?
prot_areas_3035 <-
  prot_areas_3035 %>%
  mutate(n_ludwigia = map_dbl(
    ludwigia_circles_intersect_prot_areas,
    function(x) length(x)
  )
)
