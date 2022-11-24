library(tidyverse)
library(terra)
library(sf)
library(exactextractr)
library(geodata)

## CHALLENGE 1

#' read GeoTIFF `20221124_lu_nara_2016_100m.tif` as a terra SpatRaster
#' called `lu_nara_2016`
lu_nara_2016 <- rast("./data/20221124/20221124_lu_nara_2016_100m.tif")

#' Which layers (**names**) does it contain?
#' What is the **crs**? The **ext**ent? The **res**olution?
names(lu_nara_2016)
crs(lu_nara_2016)
ext(lu_nara_2016)
res(lu_nara_2016)

#' you can retrieve all this information at once as well
lu_nara_2016

#' What are the **minmax** values of the raster?
minmax(lu_nara_2016)
#' **plot** the raster. Note: if you get a bunch of errors:  `Error in
#' x$.self$finalize() : attempt to apply non-function`, just ignore them.
plot(lu_nara_2016)

#' Read `20221124_lu_nara_legend.txt` (code is provided!) so that you can set the
#' color table associated with `lu_nara_2016`.
legend <- read_csv(
  "./data/20221124/20221124_lu_nara_legend.txt",
  col_types = cols(
    id = col_double(),
    land_use = col_character(),
    color = col_character()
  ))
legend

# plot again with nice legend
plot(lu_nara_2016,
     type = "classes",
     col = legend$color,
     levels = legend$land_use)

#' Calculate the most and least occurring land use category in each of the
#' Natura2000 protected areas. Tip: use exactextractr::exact_extract() and find
#' the right [summary operations](https://isciences.gitlab.io/exactextractr/#summary-operations)
natura2000 <- sf::st_read("./data/20221124/20221124_protected_areas_Lambert72.gpkg",
                      layer = "ps_hbtrl")
min_max_lu <- exactextractr::exact_extract(
  x = lu_nara_2016,
  y = natura2000,
  fun = c("majority", "minority")
)

min_max_lu

# extra: add land_use classes via `left_join()`
min_max_lu %>%
  # add land use for the most occurring land use category
  left_join(legend %>% select(-color, land_use_majority = land_use),
            by = c("majority" = "id")) %>%
  # add land use for the least occurring land use category
  left_join(legend %>% select(-color,land_use_minority = land_use),
            by = c("minority" = "id"))


## CHALLENGE 2

tmin_max <- rast("./data/20221124/20221124_wc2.1_10m_tmin_tmax_01.tif")
names(tmin_max)
tmin_max

# Rename the layers to `tmin_01` `tmax_01` for minimum and maximum temperature
# respectively
names(tmin_max)[names(tmin_max) == "wc2.1_10m_tmin_01"] <- "tmin_01"
names(tmin_max)
names(tmin_max)[names(tmin_max) == "wc2.1_10m_tmax_01"] <- "tmax_01"
names(tmin_max)

# Calculate the difference tmax - tmin and store it as new raster called
# tdiff_tmax_tmin. How is called the layer? Rename it as "tdiff_01"

tdiff_tmax_tmin <- tmin_max$tmax_01 - tmin_max$tmin_01
tdiff_tmax_tmin
# using terra's function lapp() is recommended if rasters are big. See tutorial about raster calculations in resources slide
tdiff_tmax_tmin <- lapp(x = tmin_max, fun = function(x, y) {y-x}) # in rasters package: overlay()
tdiff_tmax_tmin

names(tdiff_tmax_tmin) <- "tdiff_01"
tdiff_tmax_tmin

# save the one layer raster tdiff_tmax_tmin as a tif file
terra::writeRaster(x = tdiff_tmax_tmin,
                   filename = "./data/20221124/20221124_tdiff_tmax_tmin_01.tif",
                   overwrite = TRUE) # if file doesn't exist, overwrite arg can be removed

# How to add minimum and maximum temperature as two extra layers to tdiff_tmax_tmin?
tdiff_tmax_tmin <- c(tdiff_tmax_tmin, tmin_max)
names(tdiff_tmax_tmin)

tdiff_tmax_tmin # notice what is mentioned in sources

# Save it again overwriting the previous tif file
terra::writeRaster(x = tdiff_tmax_tmin,
                   filename = "./data/20221124/20221124_tdiff_tmax_tmin_01.tif",
                   overwrite = TRUE,
                   gdal=c("COMPRESS=LZW", "TFW=YES") # TFW=YES allows compatibility with ESRI (e.g. ArcGIS)
)


# check
x <- rast("./data/20221124/20221124_tdiff_tmax_tmin_01.tif")
names(x)
x
plot(x) # ignore errors


# Pull country boundaries and save them as spatial polygons (sf package)
w <- sf::st_as_sf(geodata::world(resolution = 5, level = 0, path = tempdir()))
w
plot(w)

# Calculate the minimum and maximum values of all layers in tdiff_tmax_tmin for
# each country. Tip: use exactextractr::exact_extract() and find
#' the right [summary operations](https://isciences.gitlab.io/exactextractr/#summary-operations)
min_max_countries <- exactextractr::exact_extract(
  x = tdiff_tmax_tmin,
  y = w,
  fun = c('min', 'max'),
  append_cols = c("GID_0", "NAME_0")
)

min_max_countries


# We load the average solar radiation tif file `20221124_20221124_wc2.1_5m_srad_01.tif` as  `srad`
# We want to calculate the spatial correlation between average solar radiation and average maximum
# temperature of January. We can do it by using terra's function `focalCor()`.
# However, we get the error below. Why? Try to solve this.

srad <- rast("./data/20221124/20221124_wc2.1_5m_srad_01.tif")
srad

# ```
# > focalCor(c(srad, tmin_max$tmax_01), w = 3, function(x, y) cor(x, y))
# Error in h(simpleError(msg, call)) :
#   error in evaluating the argument 'x' in selecting a method for function 'focalCor':
#   [rast] number of rows and/or columns do not match
# ```

srad <- terra::resample(x = srad, tmin_max)

# check the two rasters have same resolution and extent
res(srad) == res(tmin_max)
dim(srad) == dim(tmin_max)

# The error disappears but the computation takes a lot of time, isn't?
# line below takes some time...
srad_tmax_corr_01 <- focalCor(c(srad, tmin_max$tmax_01), w = 3, function(x, y) cor(x, y))

# How to downsample the rasters by factor 5? Rerun the correlation and plot it
srad_lowres <- terra::aggregate(srad, 5)
tmin_max_lowres <- terra::aggregate(tmin_max, 5)

dim(tmin_max_lowres)[1:2] == dim(srad_lowres)[1:2] # check dimension x and y

srad_tmax_corr_01 <- focalCor(c(srad_lowres, tmin_max_lowres$tmax_01), w = 3, function(x, y) cor(x, y))
srad_tmax_corr_01
plot(srad_tmax_corr_01)

## Histogram of the correlation values
hist(srad_tmax_corr_01,
     main="Histogram of spatial correlation between maximum temperature and solar radiation",
     ylab="Number of Pixels",
     xlab="correlation")

## BONUS CHALLENGE 1

### Extension to challenge 1

#' Calculate the areal proportion of land cover classes in each of the
#' Natura2000 protected areas. Note: exact_extract() should be combined with a
#' function. It requires data manipulation knowledge (dplyr) as well.

# Notice that variable `value` is created by extract_exact() internally and refers to the land use
landcoverfraction <- function(df) {
  print(names(df))
  df %>%
    mutate(frac_total = coverage_fraction / sum(coverage_fraction)) %>%
    group_by(NAAM, value) %>%
    summarize(prop_landuse = sum(frac_total), .groups = "drop_last")
}

lu_prot_areas <- exactextractr::exact_extract(
  x = lu_nara_2016,
  y = natura2000,
  fun = landcoverfraction,
  summarize_df = TRUE,
  include_cols = "NAAM")

lu_prot_areas

# Viisualize it
lu_prot_areas %>%
  ggplot() +
  geom_bar(aes(x = value, y = prop_landuse), stat = "identity") +
  facet_wrap(~NAAM)


## BONUS CHALLENGE 2

## Wind - water vapor pressur correlation

# By using files `wc2.1_10m_wind_01.tif` and `wc2.1_10m_vapr_01.tif`, calculate
# the correlation between wind speed and water vapor pressure. Plot it.

wind <- rast("./data/20221124/20221124_wc2.1_10m_wind_01.tif")
vapr <- rast("./data/20221124/20221124_wc2.1_10m_vapr_01.tif")

wind_lowres <- terra::aggregate(wind, 5)
vapr_lowres <- terra::aggregate(vapr, 5)

wind_vapr_corr <- focalCor(c(wind_lowres, vapr_lowres), w = 3, function(x, y) cor(x, y))
wind_vapr_corr
plot(wind_vapr_corr)

