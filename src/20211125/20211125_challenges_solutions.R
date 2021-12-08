library(tidyverse)
library(terra)
library(sf)
library(exactextractr)

## CHALLENGE 1

#' read GeoTIFF `20211125_lu_nara_2016_100m.tif` as a terra SpatRaster
#' called `lu_nara_2016`
lu_nara_2016 <- rast("./data/20211125/20211125_lu_nara_2016_100m.tif")

#' Which layers (**names**) does it contain?
#' What is the **crs**? The **ext**ent? The **res**olution?
names(lu_nara_2016)
crs(lu_nara_2016)
ext(lu_nara_2016)
res(lu_nara_2016)

#' What are the **minmax** values of the raster?
minmax(lu_nara_2016)
#' **plot** the raster. Note: if you get a bunch of errors:  `Error in
#' x$.self$finalize() : attempt to apply non-function`, just ignore them.
plot(lu_nara_2016)

#' Read `20211125_lu_nara_legend.csv` (code is provided!) so that you can set the
#' color table associated with `lu_nara_2016`.
legend <- read_csv(
  "./data/20211125/20211125_lu_nara_legend.txt",
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
natura2000 <- st_read("./data/20211125/20211125_protected_areas_Lambert72.gpkg",
                      layer = "ps_hbtrl")
min_max_lu <- exactextractr::exact_extract(
  x = lu_nara_2016,
  y = natura2000,
  fun = c("majority", "minority")
)

min_max_lu

# extra: via `left_join()` add land_use classes
min_max_lu %>%
  # add land use for the most occurring land use category
  left_join(legend %>% select(-color, land_use_majority = land_use),
            by = c("majority" = "id")) %>%
  # add land use for the least occurring land use category
  left_join(legend %>% select(-color,land_use_minority = land_use),
            by = c("minority" = "id"))


## challenge 2

#' Read the color-infrared image `20211125_cir_ename.tif` (read more about
#' [false colour infrared composites](https://eo.belspo.be/en/colour-composites))
cir_ename <- rast("./data/20211125/20211125_cir_ename.tif")

#' How many layers does it contain? What are their **names**?
#' What is the raster's **crs**? The **ext**ent? The **res**olution?
names(cir_ename)
terra::crs(cir_ename)
terra::ext(cir_ename)
terra::res(cir_ename)

plot(cir_ename)

#' Rename layer names
#' fill_1 -> nir
#' fill_2 -> red
#' fill_3 -> green

# fastest way (uncomment it to use)
# names(cir_ename) <- c("nir", "red", "green")
cir_ename

# safest way (e.g. in case order of layers change)
names(cir_ename)[names(cir_ename) == "fil_1"] <- "nir"
names(cir_ename)[names(cir_ename) == "fil_2"] <- "red"
names(cir_ename)[names(cir_ename) == "fil_3"] <- "green"

cir_ename

#' Plot the raster
plot(cir_ename)

#' Calculate the [Normalized difference vegetation
#' index](https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index)
#' (NDVI) based on near infrared (nir) and red layers of the raster
#' NDVI = (near infra rood - red)/(nir+red)
ndvi <- (cir_ename$nir - cir_ename$red) / (cir_ename$nir + cir_ename$red)
#' 5. Assign name  `ndvi` to the raster layer just created
names(ndvi) <- "ndvi"
ndvi

ndvi_fun <- function(nir, red) {
  result <- (nir - red) / (nir + red)
  names(result) <- "ndvi"
  result
}


ndvi_ename <- lapp(
  cir_ename,
  fun = ndvi_fun,
  usenames = TRUE,
  overwrite = TRUE,
  filename = "data/20211125/ndvi_ename.tif")


#' Plot `ndvi` and write it to a new GeoTIFF (*.tif) file: `ndvi_ename.tif`
plot(ndvi)

terra::writeRaster(x = ndvi,
                   filename = file.path("data/20211125", "ndvi_ename.tif"),
                   overwrite = TRUE)
#' by deafult gdal = "COMPRESS=LZW" is used on my Windows laptop.
#' To allow compatibility with ESRI (e.g. ArcGIS), you can add
#' "TFW=YES" to gdal
terra::writeRaster(x = ndvi,
                   filename = file.path("data/20211125",
                                        "ndvi.tif"),
                   gdal=c("COMPRESS=LZW", "TFW=YES"),
                   overwrite= TRUE)

## CHALLENGE 3

#' Calculate a canopy height raster from a digital **terrain** model (dtm) and a digital
#' **surface** model (dsm). In other words:
# DTM = height of the terrain in meters (height above mean sea level, HAMSL)
# DSM = height of the top of the vegetation canopy in meters

dsm <- rast("./data/20211125/20211125_dsm_ename.tif")
dsm
plot(dsm)

dtm <- rast("./data/20211125/20211125_dtm_ename.tif")
dtm
plot(dtm)

#' This doesn't work! Why? How to fix it?
dsm - dtm

#' Resample dsm so it has same raster as dtm.
#' Notice that the method used for estimating the new cell values is chosen
#' automatically based on the type of input layers. If you want to force a
#' specific method, specify it with arg  `method`.
dsm <- terra::resample(dsm, dtm)
dsm

# calculate CHM
chm <- dsm - dtm
chm
plot(chm)


## BONUS CHALLENGES

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

# visualize (not part of the challenge but nice to know)
lu_prot_areas %>%
  ggplot() +
  geom_bar(aes(x = value, y = prop_landuse), stat = "identity") +
  facet_wrap(~NAAM)

#' 2. Let's do something similar working with continuous rasters. Calculate
#dataframe with min max and mean altitude for each Belgian province using
#`exact_extract()`. How to include the province name in the output? (code to get
#the data is provided in R script!). Tip:
#https://isciences.gitlab.io/exactextractr/#basic-usage

# Pull province boundaries for Belgium
belgium <- st_as_sf(raster::getData('GADM', country='BE', level=2))

# Pull gridded altitude world data
alt <- raster::getData('worldclim', var='alt', res=10)
plot(alt)

belgium_mean_prec <- exact_extract(alt, belgium, c('min', 'max', 'mean'),
                                   append_cols = "NAME_2")
belgium_mean_prec

### Extension to challenge 2

#' Add layers `nir` and `red` from `cir_ename` to GeoTIFF "ndvi.tif"
ndvi_ename_extended <- c(ndvi, cir_ename$nir, cir_ename$red)
ndvi_ename_extended
raster::writeRaster(x = ndvi_ename_extended,
                    filename = file.path("data/20211125",
                                         "ndvi.tif"),
                    gdal=c("COMPRESS=LZW", "TFW=YES"),
                    overwrite= TRUE)
#' Check we did it correctly: read "ndvi.tif" again and plot
ndvi <- rast(file.path("data/20211125",
                        "ndvi.tif"))
ndvi
plot(ndvi)


