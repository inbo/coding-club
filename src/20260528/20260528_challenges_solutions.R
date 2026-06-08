library(inbospatial)
library(terra)
library(sf)
library(exactextractr)
library(tidyverse)

## CHALLENGE 1 ####

## 1.1 ####
lu_nara_2016 <- terra::rast("./data/20260528/20260528_lu_nara_2016_100m.tif")

## 1.2 ####
names(lu_nara_2016)
terra::crs(lu_nara_2016)
terra::ext(lu_nara_2016)
terra::res(lu_nara_2016)
terra::minmax(lu_nara_2016)

# You can retrieve all this information at once as well
lu_nara_2016


## 1.3 ####
terra::plot(lu_nara_2016)

## 1.4 ####
legend <- readr::read_csv(
  "./data/20260528/20260528_lu_nara_legend.txt",
  col_types = readr::cols(
    id = col_double(),
    land_use = col_character(),
    color = col_character()
  ))
legend

# Plot with nice legend
plot(lu_nara_2016,
     type = "classes",
     col = legend$color,
     levels = legend$land_use)

# Or you can use the function legend()` to add a legend to the plot with a lot
# of customization options, e.g. position, background color, etc.
plot(lu_nara_2016,
     type = "classes")
legend(
  legend = legend$land_use,
  fill = legend$color,
  "topright",
  bg = "orange")

# CHALLENGE 2 ####

municipalities_fl <- sf::st_read(
  dsn = "./data/20260528/20260528_municipalities_flanders.gpkg",
  crs = 31370
)
# Get the bounding box of the municipalities, and add a buffer of 1000 meters to it.
bbox <- sf::st_bbox(municipalities_fl)
bbox[c("xmax", "ymax")] <- bbox[c("xmax", "ymax")] + 1000

# Light emission in 2024
light_2024 <- inbospatial::get_coverage_wcs(
  wcs = "mercatornet",
  bbox = bbox,
  layername = "hh:hh_licht_2024_v3",
  resolution = 100,
  wcs_crs = "EPSG:31370"
)

# You can use terra::plot() function for visualizing both rasters (light emission) and polygons (municipalities)
terra::plot(light_2024)
terra::plot(sf::st_geometry(municipalities_fl)) # To visualize only the borders

# To visualize them as two layers on the same plot, you can use the `add = TRUE` argument in the second plot
# First plot the raster, then add the polygons on top of it
# Note that the order matters, if you plot the polygons first, they will be hidden by the raster.
terra::plot(light_2024)
terra::plot(sf::st_geometry(municipalities_fl), add = TRUE)

# Do you know that leaflet() supports both rasters and vector data? You can create an interactive map with both layers using the `leaflet` package. Here is an example of how to do it:
library(leaflet)
leaflet() %>%
  leaflet::addTiles() %>%
  leaflet::addRasterImage(light_2024, colors = colorNumeric("viridis", values(light_2024), na.color = "transparent"), opacity = 0.8) %>%
  leaflet::addPolygons(
    data = sf::st_transform(municipalities_fl, crs = 4326),
    fill = FALSE,
    color = "red",
    weight = 1
  )

## 2.1 ####
light_2012 <- get_coverage_wcs(
  "mercatornet",
  bbox = bbox,
  layername = "hh:hh_licht_2012_v3",
  resolution = 100,
  wcs_crs = "EPSG:31370"
)

## 2.2 ####
municipalities_antwerpen <- municipalities_fl %>%
  dplyr::filter(prov_name_n == "['Provincie Antwerpen']")
light_2024_antwerp <- terra::crop(
  light_2024,
  y = municipalities_antwerpen
)
terra::plot(light_2024_antwerp)

## 2.3 ####
diff_light <- light_2024 - light_2012
terra::plot(diff_light)

## 2.4 ####
municipalities_fl$median_light <- exactextractr::exact_extract(
  light_2024,
  municipalities_fl,
  "median"
)
terra::plot(municipalities_fl$median_light)

## 2.5 ####
municipalities_fl$mean_diff_light <-
  exactextractr::exact_extract(
    diff_light,
    municipalities_fl,
    "mean"
  )
terra::plot(municipalities_fl["mean_diff_light"])

## 2.6 ####
light_summary <- c(
  light_2024,
  light_2012,
  diff_light
)
names(light_summary)
names(light_summary) <- c(
  "light_2024",
  "light_2012",
  "diff_light"
)
# Check the new names
names(light_summary)

## 2.7 ####
terra::writeRaster(
  light_summary,
  "data/20260528/20260528_light_summary.tif",
  overwrite = TRUE,
  gdal = c(
    "COMPRESS=LZW",
    "TFW=YES" # TFW=YES allows compatibility with ESRI (ArcGIS)
  )
)

## 2.8 ####
# With `terra::rasterize()` you can create a raster with the right extent and
# values as another one used as reference, e.g. `light_2024`.
municipalities_fl_spat <- terra::rasterize(
  municipalities_fl,
  light_2024,
  field = municipalities_fl$median_light
)
# Check it
ext(municipalities_fl_spat) == ext(light_2024)
minmax(municipalities_fl_spat)
# Plot it
terra::plot(municipalities_fl_spat)


# CHALLENGE 3 ####

## 3.1 ####
max_temp <- terra::rast("data/20260528/20260528_wc2.1_10m_tmax_May.tif")
terra::plot(max_temp)

## 3.2 ####
srad <- terra::rast("data/20260528/20260528_wc2.1_5m_srad_May.tif")
terra::plot(srad)

## 3.3 ####
# Resample the solar radiation to have the same resolution of `max_temp`
srad <- terra::resample(x = srad, max_temp)

# Check the two rasters have same resolution and extent
res(srad) == res(max_temp)
dim(srad) == dim(max_temp)

# Downsample, e.g. with factor 5
srad_lowres <- terra::aggregate(srad, 5)
max_temp_lowres <- terra::aggregate(max_temp, 5)

res(srad_lowres)
res(max_temp_lowres)

# Calculate the focal spatial correlation
max_temp_srad_corr <- terra::focalPairs(
  c(max_temp_lowres, srad_lowres),
  w = 3, # it must be an odd number or a matrix (3 is the default value)
  fun = "pearson",
  na.rm=TRUE
)
terra::plot(max_temp_srad_corr)

## 3.4 ####
hist(max_temp_srad_corr,
     main="Correlation between maximum temperature and solar radiation",
     ylab="Number of Pixels",
     xlab="correlation")
