library(sf)
library(readr)
library(dplyr)
library(mapview) # Optional

heracleum_df <- readr::read_tsv(
  "data/20250424/20250424_heracleum_BE.tsv"
)

# Challenge 1 ####

## 1.1 ####
municipalities <- sf::st_read(
  dsn = "data/20250424/20250424_communesgemeente-belgium/georef-belgium-municipality-millesime.shp"
)
View(municipalities)
mapview::mapview(municipalities)

## 1.2 ####
heracleum <- sf::st_as_sf(
  heracleum_df,
  coords = c("decimalLongitude", "decimalLatitude"),
  crs = 4326
)

mapview::mapview(list(heracleum, pa_a, municipalities))

## 1.3 ####
sf::st_layers("data/20250424/20250424_protected_areas_BE.gpkg")

## 1.4 ####
pa <- sf::st_read(
  dsn = "data/20250424/20250424_protected_areas_BE.gpkg",
  layer = "NaturaSite_polygon")
pa
mapview::mapview(pa)

## 1.5 ####
pa_bioregion <- sf::st_read(
  dsn = "data/20250424/20250424_protected_areas_BE.gpkg",
  layer = "BIOREGION")
# Transform the returned data.frame to a tibble data.frame (better printing)
pa_bioregion <- pa_bioregion %>% dplyr::tibble()
pa_bioregion

pa_habitats <- sf::st_read(
  dsn = "data/20250424/20250424_protected_areas_BE.gpkg",
  layer = "HABITATS")
# Transform the returned data.frame to a tibble data.frame (better printing)
pa_habitats <- pa_habitats %>% dplyr::tibble()
pa_habitats


## 1.6 ####
sf::st_crs(pa)
sf::st_crs(heracleum)
sf::st_crs(municipalities)


## 1.7 ####
sf::st_crs(pa) == sf::st_crs(heracleum)
sf::st_crs(heracleum) == sf::st_crs(municipalities)

## 1.8 ####
pa_a <- pa %>%
  dplyr::filter(SITETYPE == "A")


# Check if the coordinate reference systems (CRS) of the created sf objects are the same
sf::st_crs(municipalities) == sf::st_crs(heracleum)
sf::st_crs(municipalities) == sf::st_crs(pa_a)


# Challenge 2 ####

## 2.1 ####
pa_a_wgs84 <- sf::st_transform(
  x = pa_a,
  crs = 4326
)

## 2.2 ####

# Add layer with protected areas of type A (`SITETYPE`: `"A"`)
pa_a_heracleum_4326.gpkg <- sf::st_write(
  obj = pa_a_wgs84,
  dsn = "data/20250424/pa_a_heracleum_4326.gpkg",
  layer = "NaturaSite_A",
  delete_dsn = TRUE, # delete the file if it exists
  delete_layer = TRUE # delete the layer if it exists
)

# Add layer with Heracleum occurrences
pa_a_heracleum_4326.gpkg <- sf::st_write(
  obj = heracleum,
  dsn = "data/20250424/pa_a_heracleum_4326.gpkg",
  layer = "heracleum_occs",
  delete_layer = TRUE # delete the layer if it exists
)

# Check if the file is created with the correct layers
sf::st_layers("data/20250424/pa_a_heracleum_4326.gpkg")


## 2.3 ####

# Default number of segments per quadrant is 30 = 120 segments in total, which
# is a very good approximation of a circle. However, you will pay for it in
# a longer processing time.
heracleum_circles <- sf::st_buffer(
  x = heracleum,
  dist = heracleum$coordinateUncertaintyInMeters
)

# If you want to speed up the process, you can reduce the number of segments by using
# `nQuadSegs` argument. The number of segments per quadrant.
# However, notice that the number of segments per quadrant seems to be ignored while using points in WGS84 and it will take therefore the same processing time. See "Details" section of function documentation (`?sf::st_buffer()`).
#
# """
# The `nQuadSegs`, `endCapsStyle`, `joinStyle`, `mitreLimit` and `singleSide`
# parameters only work if the GEOS engine is used (i.e. projected coordinates
# or when `sf_use_s2()` is set to `FALSE`).
# """
#
# If you transform your points to a projected CRS, e.g. Lambert 72, the circles
# are generated much faster and with the right number of segments (in our case:
# 2x4 = 8)
heracleum_31370 <- sf::st_transform(
  x = heracleum,
  crs = 31370
)

heracleum_31370_circles <- sf::st_buffer(
  x = heracleum_31370,
  dist = heracleum$coordinateUncertaintyInMeters,
  nQuadSegs = 2
)
mapview(heracleum_31370_circles)

## 2.4 ####

municipalities_centroids <- sf::st_centroid(municipalities)
mapview(list(municipalities, municipalities_centroids))


# CHALLENGE 3 ####

## 3.1 ####
nearest_municipality <- sf::st_nearest_feature(
  x = heracleum,
  y = municipalities_centroids
)

## 3.2 ####
nearest_municipality_polygon <- sf::st_nearest_feature(
  x = heracleum,
  y = municipalities
)

# You can use the `waldo` package to compare the two results.
waldo::compare(nearest_municipality, nearest_municipality_polygon)
# Example of the first difference occurring already in the first occurrence
mapview::mapview(list(municipalities[c(468, 519),],
                      municipalities_centroids[c(468, 519),],
                      heracleum[1, ]))

## 3.3 ####

# The sf objects MUST have same CRS to apply some geometric
municipalities_pa <- sf::st_intersects(
  x = pa_a_wgs84,
  y = municipalities,
  sparse = TRUE
)
View(municipalities_pa)

# Set `sparse` = `FALSE` to return a matrix. The
# matrix has as many rows as the number of protected areas of type A and as many
# columns as the number of municipalities. The value is `TRUE` if the protected area
# intersects with the municipality, `FALSE` otherwise.
municipalities_pa_matrix <- sf::st_intersects(
  x = pa_a_wgs84,
  y = municipalities,
  sparse = FALSE
)
dim(municipalities_pa_matrix)


## 3.4 ####
municipality_kruibeke <- municipalities %>%
  dplyr::filter(mun_name_up == "KRUIBEKE")
pa_durme_wgs84 <- pa_a_wgs84 %>%
  dplyr::filter(SITECODE == "BE2301235")
pa_durme_kruibeke <- sf::st_intersection(
  x = pa_durme_wgs84,
  y = municipality_kruibeke
)
mapview::mapview(list(pa_durme_kruibeke, municipality_kruibeke))

## 3.5 ####

dist_municipalities_pa_a <- st_distance(
  municipalities,
  pa_a_wgs84
)
dist_municipalities_pa_a

municipalities_lambert <- sf::st_transform(
  x = municipalities,
  crs = 31370
)
pa_a_lambert <- sf::st_transform(
  x = pa_a_wgs84,
  crs = 31370
)
dist_municipalities_pa_a_lambert <- sf::st_distance(
  municipalities_lambert,
  pa_a_lambert
)
dist_municipalities_pa_a_lambert

dist_municipalities_pa_a_lambert[1, 1] == dist_municipalities_pa_a[1, 1]
dist_municipalities_pa_a_lambert[1, 1] - dist_municipalities_pa_a[1, 1]

## 3.6 ####

heracleum_circles_intersects_pa_a <- sf::st_intersects(
  heracleum_circles,
  pa_a_wgs84
)

# `st_within()` or `covered_by()`: same results
heracleum_circles_in_pa_a <- sf::st_within(heracleum_circles, pa_a_wgs84)
heracleum_circles_covered_pa_a <- st_covered_by(heracleum_circles, pa_a_wgs84)
# Compare with waldo: same result, only the "predicate" is different
waldo::compare(
  heracleum_circles_in_pa_a,
  heracleum_circles_covered_pa_a
)
# Another way is using `st_covers()`
pa_a_covers_heracleaum_circles <- sf::st_covers(pa_a_wgs84, heracleum_circles)
View(pa_a_covers_heracleaum_circles)

# Compare the results
waldo::compare(
  heracleum_circles_intersects_pa_a,
  heracleum_circles_in_pa_a
)

# Example: the 7th circle intersects a protected area in Doel, but is not
# totally covered by it
mapview(list(heracleum_circles[7, ], pa_a_wgs84))
mapview(heracleum_circles[7, ])


## 3.7 ####
municipalities_projected <- sf::st_transform(
  x = municipalities,
  crs = 31370
)
grid_municipalities <- sf::st_make_grid(
  x = municipalities_projected,
  cellsize = 5000,
  square = TRUE
)
# Transform `grid_municipalities` to a sf data.frame
grid_municipalities <- sf::st_as_sf(grid_municipalities)
mapview::mapview(grid_municipalities)

