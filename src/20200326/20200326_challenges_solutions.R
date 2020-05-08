library(tidyverse)
library(sf)


# CHALLENGE 1

butterfly_df <- read_csv("data/20200326/20200326_butterflies.txt", na = "")

# View first 10 rows for inspection
butterfly_df %>% head(n = 10) %>% View

# transform data.frame to data.frame of geospatial points
spatial_butterfly_df <- st_as_sf(butterfly_df,
                                 coords = c("decimal_longitude",
                                            "decimal_latitude"),
                                 crs = 4326)

# check class: a data.frame, a tibble dataframe but also of type sf
class(spatial_butterfly_df)

# check CRS
st_crs(spatial_butterfly_df)

# View first 10 rows for inspection
# Note how the columns decimal_longitude and decimal_latitude
# have been used to create the geometry column
spatial_butterfly_df %>% head(n = 10) %>% View

# Only observations of species Atalanta
spatial_atalanta_df <-
spatial_butterfly_df %>%
  filter(species == "Atalanta")

# Import reference grid of Belgium at 10km resolution
utm10_belgium <- st_read("./data/20200326/20200326_utm10_bel.gpkg")

# check CRS
st_crs(utm10_belgium)

# the proj4string is the most important thing. If you google it you will see
# that it refers to EPSG 3035. So you can add it just to know it for future use
# If you assign it without getting a warningn it means it's the right code.
# Otherwise, use st_transform()
st_crs(utm10_belgium) <- 3035


municipalities_layers <- st_layers("./data/20200326/20200326_Belgian_municipalities")
municipalities <- st_read("./data/20200326/20200326_Belgian_municipalities")

# import municipalities: geojson data are always in WGS84, i.e. EPSG code 4326
st_crs(municipalities)

# both observations and municipalities are in WGS84 (EPSG code: 4326)
st_crs(spatial_atalanta_df) == st_crs(municipalities)

## CHALLENGE 2
## Get cell each obs of Atalanta belongs to and count

# Transfomr the points to same CRS as the grid. You get an error if you try to
# intersect without doing it. Just try it.
spatial_atalanta_df_3035 <-
  spatial_atalanta_df %>%
  st_transform(crs = 3035)

# Columns of the grids are added, but only one geometry is allowed.
# The geometry of the points are maintained as they are the first argument.
spatial_atalanta_df_cells_3035 <-
  spatial_atalanta_df_3035 %>%
  st_intersection(utm10_belgium)


# Count obs in each cell. Note that result is still a sf data.frame with a
# geomtry column
counts_per_cell <-
  spatial_atalanta_df_cells_3035 %>%
  group_by(CELLCODE) %>%
  count()

counts_per_cell

# Transform municipalities in CRS 3035.
# Another projection can be used as well but it has to be in meters, not lat/lng
municipalities_3035 <-
  municipalities %>%
  st_transform(3035)

# 3. Atalanta obs in municipalities
spatial_atalanta_df_municipalities_3035 <-
  spatial_atalanta_df_3035 %>%
  st_intersection(municipalities_3035)

# Which warning do you get if you intersect spatial objects with epsg 4326?
# This can give right results but is conceptually wrong. So, better not doing it
# Check this link:
# https://r-spatial.github.io/sf/articles/sf6.html#although-coordinates-are-longitudelatitude-xxx-assumes-that-they-are-planar
spatial_atalanta_df_municipalities <-
  spatial_atalanta_df %>%
  st_intersection(municipalities)

# Count per municipality
counts_per_municipality_3035 <-
  spatial_atalanta_df_municipalities_3035 %>%
  group_by(NISCode, NameGer, NameFre, NameDut) %>%
  count()

## CHALLENGE 3

# Get information on the layers of the Flemish protected area
prot_areas_layers <- st_layers("data/20200326/20200326_protected_areas.gpkg")
prot_areas_layers

# Import layer ps_hbtrl with habitat of Flanders areas
prot_areas <- st_read("./data/20190226/20190226_ps_hbtrl",
                        layer = prot_areas_layers$name[1])

# Again no explicit EPSG code (actually it is 103300 by googling the entire
# proj4string) 103300 is very similar to the classic "Belgium Lambert 72"
# projection 31370
st_crs(prot_areas)

# Transform to 31370 (Lambert 72)
prot_areas_31370 <-
  prot_areas %>%
  st_transform(31370)

municipalities_31370 <-
  municipalities %>%
  st_transform(31370)

# Get municipalities in each protected area.
# Short solution via st_intersection
hab_in_mun_31370 <-
  prot_areas_31370 %>%
  st_intersection(municipalities_31370)

hab_in_mun_31370 %>% filter(NAAM == "Kalmthoutse Heide")

hab_in_mun_31370 %>% filter(NAAM == "Voerstreek")

# Long solution via st_overlaps()!
# Overlap municipalities and protected areas
municipalities_in_prot_areas_31370 <-
  municipalities_31370 %>%
  st_overlaps(prot_areas_31370, sparse = FALSE) %>%
  as_tibble()

# the result is a normal tibble (data.frame), no spatial info anymore!
class(municipalities_in_prot_areas_31370)

# numbere of rows = number of Belgian municipalities (581)
# number of columns = number of Flemish protected areas (38)
dim(municipalities_in_prot_areas_31370)

# each column is a protected area. Assign GEBCODE as column names
colnames(municipalities_in_prot_areas_31370) <-
  prot_areas$GEBCODE

# Add extra columns:
# NISCode (identifier municipality)
# NameGer, NameFre, NameDut: names in German, French, Dutch
municipalities_in_prot_areas_31370 <-
  municipalities_in_prot_areas_31370 %>%
  bind_cols(municipalities_31370 %>%
              select(NISCode, NameGer, NameFre, NameDut))

# Get GEBCODE of Kalmthoutse Heide
geb_code_kalmthoutse_heide <-
  prot_areas %>%
  filter(NAAM == "Kalmthoutse Heide") %>%
  pull(GEBCODE) %>%
  as.character()
geb_code_kalmthoutse_heide # which is BE2100015

municipalities_in_prot_areas_31370 %>%
  filter(BE2100015 == TRUE) %>%
  select(NISCode, starts_with("Name"))

# You can avoid hardcoding the GEBCode, BE2100015, by using
# `geb_code_kalmthoutse_heide`, but then you need something more complex using
# package rlang (from tidyverse galaxy)
library(rlang)
municipalities_in_prot_areas_31370 %>%
  filter(!!sym(geb_code_kalmthoutse_heide)  == TRUE) %>%
  select(NISCode, starts_with("Name"))

# Get GEBCODE of Voerstreek
geb_code_voerstreek <-
  prot_areas %>%
  filter(NAAM == "Voerstreek") %>%
  pull(GEBCODE) %>%
  as.character()
geb_code_voerstreek

municipalities_in_prot_areas_31370 %>%
  filter(BE2200039 == TRUE) %>%
  select(NISCode, starts_with("Name"))

# or again geb_code_voerstreek and using !!sym( ) syntax
municipalities_in_prot_areas_31370 %>%
  filter(!!sym(geb_code_voerstreek)  == TRUE) %>%
  select(NISCode, starts_with("Name"))

## BONUS CHALLENGE

# via st_read you can read shape files as well. First download them and unzip
# them as explained in the body of the challenge. Shape files are always a
# fodler containing multiple files with different extensions. You need to call
# the map containing them.
prot_areas_shp <- st_layers("data/20190226/20190226_ps_hbtrl")

# Note how it fails reading them if we add a / in the path. So, be careful.
prot_areas_shp <- st_layers("data/20190226/20190226_ps_hbtrl/")

# Calculate centroids municipalities
centroids_municipalities_3035 <- st_centroid(municipalities_3035)

# Again, what if you try to calculate centroids using original CRS 4326?
# See https://r-spatial.github.io/sf/articles/sf6.html#st_centroid-does-not-give-correct-centroids-for-longitudelatitude-data
centroids_municipalities <- st_centroid(municipalities)

# Calculate distance of ALL observations to the centroids of ALL municipalities
dist_butterfly_to_centre_3035 <-
  st_distance(spatial_atalanta_df_3035,
              centroids_municipalities_3035)

# it contains data with units (meters)
class(dist_butterfly_to_centre_3035)

# number of rows: number of observations
# number of columns: number of municipalities
dim(dist_butterfly_to_centre_3035)

# We can maybe improve the result by assigning column names based on NISCode
names(dist_butterfly_to_centre_3035) <- municipalities$NISCode
