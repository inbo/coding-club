library(tidyverse)
library(sf)

impatiens_df <- read_tsv("./data/20211026/20211026_impatiens_glandulifera.txt")

#' Transform impatiens_df to a geospatial data.frame using sf package. Note that
#' GBIF data are stored using WGS 84. Hint: find which numeric code is
#' associated with WGS84 coordinate reference system.
spatial_impatiens_df <- st_as_sf(impatiens_df,
                                 coords = c("decimalLongitude",
                                            "decimalLatitude"),
                                 crs = 4326)

#' How many layers does the  geospatial file 20211026_protected_areas1.gpkg contain?
st_layers("./data/20211026/20211026_protected_areas.gpkg")

#' Read the layer `ps_hbtrl`: call it `prot_areas`
prot_areas <- st_read("./data/20211026/20211026_protected_areas.gpkg",
                      layer = "ps_hbtrl")

#' What is the coordinate reference system declared by user? Does it coincide
#' with the real Geographic Coordinate Reference System (GEOCRS)?
st_crs(prot_areas)

#' Check that the CRS of `prot_areas` and `spatial_impatiens_df` are the same
st_crs(prot_areas) == st_crs(spatial_impatiens_df)



## CHALLENGE 2

#' Transform both `prot_areas` and `spatial_impatiens_df` to [European
#' Terrestrial Reference System 1989](https://epsg.io/3035), the coordinate
#' reference system used at EU level
prot_areas_3035 <-
  prot_areas %>%
  st_transform(3035)

spatial_impatiens_df_3035 <-
  spatial_impatiens_df %>%
  st_transform(3035)

#' Write the transformed data as a geopackage file called
#' `prot_areas_and_impatiens_trs1989.gpkg` with two layers: the first called
#' `prot_areas`, containing the protected areas, the second layer,
#' `impatiens_obs`, containing the observations of Himalayan balsam

# save layer with protected areas
st_write(obj = prot_areas_3035,
         dsn = "./data/20211026/prot_areas_and_impatiens_trs1989.gpkg",
         layer = "prot_areas")

# save layer with observations of Himalayan balsam (you can use %>% as well)
spatial_impatiens_df_3035 %>%
  st_write(
    dsn = "./data/20211026/prot_areas_and_impatiens_trs1989.gpkg",
    layer = "impatiens_obs"
)

# to save in other format, e.g. an ESRI shapefile, notice the different driver
st_write(
  obj = prot_areas_3035,
  dsn = "./data/20211026/prot_areas_and_impatiens_trs1989.gdb",
  layer = "prot_areas",
  driver = "ESRI Shapefile"
)

st_write(
  obj = spatial_impatiens_df_3035,
  dsn = "./data/20211026/prot_areas_and_impatiens_trs1989.gdb",
  layer = "impatiens_obs",
  driver = "ESRI Shapefile"
)

#' you can use st_layers() to check what you did while writing
st_layers("./data/20211026/prot_areas_and_impatiens_trs1989.gpkg")
st_layers("./data/20211026/prot_areas_and_impatiens_trs1989.gdb")

# to overwrite a layer already existing, use APPEND = FALSE
st_write(obj = spatial_impatiens_df_3035,
         dsn = "./data/20211026/prot_areas_and_impatiens_trs1989.gpkg",
         layer = "impatiens_obs",
         append = FALSE)

# deleting a layer is not possible yet, but will be implemented soon
# See https://github.com/r-spatial/sf/issues/1828

# delete all layers and write a new one using delete_dsn argument
# this doesn't work on all laptops, follow issue here:
# https://github.com/r-spatial/sf/issues/1827
st_write(obj = spatial_impatiens_df_3035,
         dsn = "./data/20211026/prot_areas_and_impatiens_trs1989.gpkg",
         layer = "impatiens_obs",
         delete_dsn = TRUE)

st_layers("./data/20211026/prot_areas_and_impatiens_trs1989.gpkg")

#' 3. Due to spatial uncertainty (gridded data, GPS uncertainty, etc.) observations
#' should not be idealized as points in space, but as circles. Create such circles
#' using the values store in column `coordinateUncertaintyInMeters` for
#' `spatial_impatiens_df_3035`
circles_spatial_impatiens_3035 <-
  spatial_impatiens_df_3035 %>%
  st_buffer(
  dist = spatial_impatiens_df_3035$coordinateUncertaintyInMeters
)



#' INTERMEZZO - S2 geometry
#'
#' Notice that since last version of sf you can apply such spatial operations in
#' spherical CRSs (aka systems using lat-lon like WGS84)
circles_spatial_impatiens <-
  spatial_impatiens_df %>%
  st_buffer(
    dist = spatial_impatiens_df$coordinateUncertaintyInMeters
)



## CHALLENGE 3

#' Using data in CRS 3035:
#' 1. Find which observations, as points, are _contained_ in each protected area?
impatiens_pts_in_prot_areas <- st_contains(x = prot_areas_3035,
                                           y = spatial_impatiens_df_3035)

# You can use `st_intersects()` as well: same result. However, st_contains gives
# more the idea of what you are doing
impatiens_pts_in_prot_areas <- st_intersects(x = prot_areas_3035,
                                             y = spatial_impatiens_df_3035)


#' 2. But we should better check which observations, as circles (!), _intersect_
#' each protected area. How to do it?
impatiens_circles_intersect_prot_areas <- st_intersects(
  x = prot_areas_3035,
  y = circles_spatial_impatiens_3035
)

#' Notice that you can get the protected area each observation belongs to by
#' inverting x and y values
prot_areas_intersect_impatiens_circles <- st_intersects(
  x = circles_spatial_impatiens_3035,
  y = prot_areas_3035
)

#' 3. So, how many observations in the protected area "Bos- en heidegebieden ten
#' oosten van Antwerpen"?
names(impatiens_circles_intersect_prot_areas) <- prot_areas$GEBCODE
geb_code_bos_oost_antwerpen <- prot_areas %>%
  filter(NAAM == "Bos- en heidegebieden ten oosten van Antwerpen") %>%
  pull(GEBCODE)
length(impatiens_circles_intersect_prot_areas[[geb_code_bos_oost_antwerpen]])


#' 4. Sometimes it's interesting to calculate the centroid of a polygon, e.g. for
#' visualizations. Easy by using sf function `st_centroids()`. However, you get
#' an error while calculating the centroids of `prot_areas`. What does it mean?

st_centroid(prot_areas)

# it seems that two polygons are not valid (FALSE)
st_is_valid(prot_areas)
st_is_valid(prot_areas_3035)
# to know why they are not valid, add argument reason and notice that the reason
# for invalidity changes while changing CRS (spherical geometry with crs = 4326 vs
# planar geometry with crs = 3035)
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

#' 1. How to get only the observations, as circles, **totally** contained in
#' protected areas?
impatiens_circles_totally_in_prot_areas <- st_covered_by(
  x = prot_areas_3035,
  y = circles_spatial_impatiens_3035
)

map_dbl(
  impatiens_circles_totally_in_prot_areas,
  function(x) length(x)
)

#' 2. Not a sf question, but still nice to solve: based on the answer of 2 and 3,
#' how to add to `prot_areas_3035` a column called `n_impatiens` with the number
#' of observations for each protected area?
prot_areas_3035 <-
  prot_areas_3035 %>%
  mutate(n_impatiens = map_dbl(
    impatiens_circles_intersect_prot_areas,
    function(x) length(x)
  )
)
