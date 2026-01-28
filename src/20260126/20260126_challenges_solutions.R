library(sf)
library(readr)
library(dplyr)
library(units) # for handling units (e.g., m^2, used in Challenge 3.7)
library(mapview) # for basic visualization

# Read occurrences
occs_df <- readr::read_tsv(
  "data/20260126/20260126_occurrences_raccoon_be.txt",
  na = "",
  guess_max = 1000000
)

# Read species occurrence cube
cube <- readr::read_tsv(
  "data/20260126/20260126_species_cube_raccoon_be.csv",
  na = ""
)

# Unzip municipalities shapefile
zip_file <- "data/20260126/20260126_communesgemeente-belgium.zip"
municipalities_folder <- "data/20260126/20260126_municipalities_belgium"
unzip(zip_file, exdir = municipalities_folder)

# Unzip EEA grid shapefile
zip_file <- "data/20260126/20260126_eea_grid_be.zip"
eea_grid_folder <- "data/20260126/20260126_eea_grid_be"
unzip(zip_file, exdir = eea_grid_folder)


# Challenge 1 ####

## Challenge 1.1 ####
occs <- st_as_sf(occs_df,
                 coords = c("decimalLongitude", "decimalLatitude"),
                 crs = 4326)
st_write(occs, "data/20260126/20260126_raccoon_occs_wgs84.gpkg", layer = "raccoon_occs_wgs84", delete_dsn = TRUE)
occs2 <- st_read("data/20260126/20260126_raccoon_occs_wgs84.gpkg", layer = "raccoon_occs_wgs84")
names(occs2)
View(occs)

## Challenge 1.2 ####
# 1st layer contains multipolygons with known CRS, the 2nd and 3rd layer are "just" data frames.
sf::st_layers("data/20260126/20260126_protected_areas_be.gpkg")
layers_names <- sf::st_layers("data/20260126/20260126_protected_areas_be.gpkg")
layers_names

## Challenge 1.3 ####
# Optional: use `as_tibble = TRUE` to read attributes as a tibble (data frame) instead of a regular data frame
pa <- st_read("data/20260126/20260126_protected_areas_be.gpkg", layer = "NaturaSite_polygon", as_tibble = TRUE)

# Notice the printed line: "Projected CRS: ETRS89-extended / LAEA Europe"
# This tells you that the CRS used is a projected CRS based on ETRS89 datum,
# specifically the LAEA (Lambert Azimuthal Equal Area) projection for Europe.
pa

## Challenge 1.4 ####
pa_bioregion <- st_read("data/20260126/20260126_protected_areas_be.gpkg", layer = "BIOREGION")
pa_habitats <- st_read("data/20260126/20260126_protected_areas_be.gpkg", layer = "HABITATS")

## Challenge 1.5 ####
st_layers(municipalities_folder)
municipalities <- st_read(municipalities_folder, layer = "georef-belgium-municipality-millesime")

# Notice the printed line: "Geodetic CRS:  WGS 84"
# This indicates that the CRS used is the WGS 84 geographic coordinate system. Geodetic (angles), not projected (x-y in meters)!
municipalities

## Challenge 1.6 ####
#unzipping the data put the files in another subfolder. I manually moved them out of the subfolder for this to work. Alternatively, we could have updated the aae_grid_folder:
eea_grid <- st_read(eea_grid_folder)

## Challenge 1.7 ####
# The most important part is the EPSG code, which is a unique identifier for coordinate reference systems. It's the very last
# part of the printed line after "EPSG:".
st_crs(eea_grid)
st_crs(pa)
st_crs(occs)
st_crs(municipalities)

# Same CRS? Some tests
st_crs(eea_grid) == st_crs(pa)

# Notice that eea_grid and pa have same EPSG code (3035), but different names.
# This is because they are using the same projected CRS (ETRS89 / LAEA Europe
# vs ETRS89-extended / LAEA Europe), but with slightly different definitions.
# In practice, they can be treated as the same CRS for most applications.
st_crs(eea_grid) == st_crs(pa)

#Challenge 1.8
pa_a <- pa %>%
  dplyr::filter(SITETYPE == "A")

# `pa_a` has less rows than `pa`
nrow(pa_a) < nrow(pa)

#  `pa_a` and `pa` have same CRS and columns
st_crs(pa_a) == st_crs(pa)
all(colnames(pa_a) == colnames(pa))


# Challenge 2 ####

## 2.1 ####
occs_3035 <- st_transform(occs, crs = 3035)
st_crs(occs_3035)

## 2.2 ####

# Start with protected area layer.
st_write(pa, layer = "NaturaSite", "data/20260126/pa_occs_3035.gpkg")
st_write(occs_3035, layer = "raccoon_occs", "data/20260126/pa_occs_3035.gpkg")

# Check layers after writing
st_layers("data/20260126/pa_occs_3035.gpkg")

# Read back and compare to originals
waldo::compare(
  st_read("data/20260126/pa_occs_3035.gpkg", layer = "NaturaSite", as_tibble = TRUE),
  pa
)

# The geometry column is now called `"geom"` instead of `"geometry"` because
# `st_write()` defaults to `"geom"` for the geometry column name.
waldo::compare(
  st_read("data/20260126/pa_occs_3035.gpkg", layer = "raccoon_occs", as_tibble = TRUE),
  occs_3035
)


## 2.3 ####

municipalities_3035 <- st_transform(municipalities, 3035)
st_crs(municipalities)
st_crs(municipalities_3035)

## 2.4 ####

municipalities_3035_centroids <- st_centroid(municipalities_3035)

# Centroids should have same CRS as original
st_crs(municipalities_3035_centroids) == st_crs(municipalities_3035)

# Centroids are points
all(st_geometry_type(municipalities_3035_centroids) == "POINT")


# Challenge 3 ####

## 3.1 ####
# 1. Let's work with `cube`. How can you make a sf data frame of it? Call the new
# sf data frame `cube_sf`.
# Hint: `eea_grid` and `cube` both have a column called `CELLCODE`.
cube_sf <- cube %>%
  dplyr::left_join(eea_grid, by = "CELLCODE") %>%
  st_as_sf()
# Check that `cube_sf` is indeed an sf data frame
class(cube_sf)
# Same number of rows as `cube`
nrow(cube_sf) == nrow(cube)

## 3.2 ####
# Use sf::st_intersects() to find which protected areas intersect with the municipalities.
# Then, for each municipality, count how many protected areas intersect with it.
municipalities_3035 <- municipalities_3035 %>%
  dplyr::mutate(
    n_pa = lengths(
      st_intersects(municipalities_3035, pa)
    )
  )

# Check that `n_pa` column was added
"n_pa" %in% colnames(municipalities_3035)
# Check that `n_pa` is numeric
is.numeric(municipalities_3035$n_pa)
# Check that `n_pa` has non-negative values
all(municipalities_3035$n_pa >= 0)

# Do a visual check with mapview
mapview::mapview(pa, col.regions = "green", alpha.regions = 0.3) +
  mapview::mapview(municipalities_3035, zcol = "n_pa")

## 3.3 ####
no_pa_municipalities_3035 <- municipalities_3035 %>%
  dplyr::filter(n_pa == 0)

## 3.4 ####
# Get the 10 largest municipalities among no_pa_municipalities_3035.
# Hint: measure the **area**.
no_pa_municipalities_3035 <- no_pa_municipalities_3035 %>%
  dplyr::mutate(
    area = st_area(geometry)
  ) %>%
  dplyr::arrange(
    dplyr::desc(area)
  )

dplyr::slice_head(no_pa_municipalities_3035, n = 10)

# Visual check with mapview
mapview::mapview(
  dplyr::slice_head(no_pa_municipalities_3035, n = 10),
  col.regions = "red",
  alpha.regions = 0.5) +
  mapview::mapview(pa, col.regions = "green", alpha.regions = 0.3)

## 3.5 ####
# Get the number of raccoon occurrences per municipality. Add it as a new
# column `n_occs` to `municipalities_3035`.
municipalities_3035 <- municipalities_3035 %>%
  dplyr::mutate(
    n_occs = lengths(
      st_intersects(municipalities_3035, occs_3035)
    )
  )

# Check that `n_occs` column was added
"n_occs" %in% colnames(municipalities_3035_1)
# Check that `n_occs` is numeric
is.numeric(municipalities_3035_1$n_occs)
# Check that `n_occs` has non-negative values
all(municipalities_3035_1$n_occs >= 0)

# Do a visual check with mapview
mapview::mapview(municipalities_3035, zcol = "n_occs") +
  mapview::mapview(occs_3035, col.regions = "blue", alpha.regions = 0.5)

## 3.6 ####
#Get the 10 municipalities with the highest number of raccoon occurrences.
# Hint: do it as you would do with a standard data.frame.
municipalities_3035 <- municipalities_3035 %>%
  dplyr::arrange(
    dplyr::desc(n_occs)
  )
dplyr::slice_head(municipalities_3035, n = 10)

## 3.7 ####
# Add a column `protected_area_m2` to `municipalities_3035`, containing the total
# area of protected areas per municipality. You can eventually show it on a map
# using `mapview(municipalities_3035, zcol = "protected_area_m2")`.

# Dissolve all protected areas into one (union) to avoid that overlapping protected areas
# are counted multiple times in the intersections.
pa_union <- sf::st_union(pa)

intersections <- st_intersection(municipalities_3035, pa_union)
intersections <- intersections %>%
  dplyr::mutate(area_pa = st_area(geometry))

protected_area_per_municipality <- intersections %>%
  dplyr::group_by(mun_code) %>%
  dplyr::summarise(
    protected_area_m2 = sum(area_pa)
  )
View(protected_area_per_municipality)

# The number of rows in `protected_area_per_municipality` is equal to the number of municipalities
# less those without protected areas
nrow(protected_area_per_municipality) == nrow(municipalities_3035) - nrow(no_pa_municipalities_3035)

# The intersections areas are exactly equal to the protected areas except the ones in the sea:
# no municipality offshore :-)
mapview(protected_area_per_municipality, zcol = "protected_area_m2") + 
  mapview(pa)

# Now join the `protected_area_per_municipality` to `municipalities_3035`
# Drop geometry from `protected_area_per_municipality` as we only need the attributes and the 
# geometry is already in `municipalities_3035`. Joining with geometry would return error as it means you 
# want to do a "spatial join", which is not what we want here.
municipalities_3035 <- municipalities_3035 %>%
  dplyr::left_join(
    protected_area_per_municipality %>%
      dplyr::select(mun_code, protected_area_m2) %>%
      sf::st_drop_geometry(),
    by = "mun_code"
  )
  # Replace NAs with 0 m^2 for municipalities without protected areas
municipalities_3035 <- municipalities_3035 %>%
  dplyr::mutate(
    protected_area_m2 = dplyr::if_else(
      is.na(protected_area_m2),
      # If you don't want to use units, remove `units::as_units()` and just use `0`
      units::as_units(0, "m^2"),
      # If you don't want to use units, use `as.double(protected_area_m2)` instead
      protected_area_m2
    )
  )

# Check that `protected_area_m2` column was added
"protected_area_m2" %in% colnames(municipalities_3035)
# Check that `protected_area_m2` is numeric
is.numeric(municipalities_3035$protected_area_m2)
# Check that `protected_area_m2` has non-negative values
all(municipalities_3035$protected_area_m2 >= units::as_units(0, "m^2"))

# Do a visual check with mapview
mapview::mapview(municipalities_3035, zcol = "protected_area_m2") +
  mapview::mapview(pa, col.regions = "green", alpha.regions = 0.3)

## 3.8 ####
# Add a column `protected_percentage` to `municipalities_3035`, containing
# the percentage of municipality area that is protected. Which municipality has the
# highest percentage of protected area?
municipalities_3035 <- municipalities_3035 %>%
  dplyr::mutate(
    area = st_area(geometry),
    # Use as.double() to convert from units to numeric as a percentage has no units
    protected_percentage = as.double(protected_area_m2 / area) * 100
  )

# Check that `protected_percentage` column was added
"protected_percentage" %in% colnames(municipalities_3035)
# Check that `protected_percentage` is numeric
is.numeric(municipalities_3035$protected_percentage)
# Check that `protected_percentage` has values between 0 and 100
all(municipalities_3035$protected_percentage >= 0 & municipalities_3035$protected_percentage <= 100)

# Do a visual check with mapview
mapview::mapview(municipalities_3035, zcol = "protected_percentage") +
  mapview::mapview(pa, col.regions = "green", alpha.regions = 0.3)

# Extra: maybe you are curious as me to know which municipality has the highest percentage of protected areas?
municipalities_3035 %>%
  dplyr::arrange(
    dplyr::desc(protected_percentage)
  ) %>%
  dplyr::slice_head(n = 1)
# It is Peer with a stunning 77.8% of its area protected!
