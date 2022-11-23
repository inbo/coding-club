library(tidyverse)
library(terra)
library(sf)
library(exactextractr)


## CHALLENGE 1

#' 1. Read `20211125_lu_nara_2016_100m.tif` as a SpatRaster (terra) and call it
#' `lu_nara_2016`



#' 2. Which layers (**names**) does it contain? What is the **crs**? The
#' **ext**ent? The **res**olution? What are the **minmax** values of the raster?



#' 3. **plot** the raster. Note: if you get a bunch of errors:  `Error in
#' x$.self$finalize() : attempt to apply non-function`, just ignore them.




#' 4. Read `20211125_lu_nara_legend.csv` (code is provided!) so that you can set
#' the color table associated with `lu_nara_2016`.
legend <- read_csv(
  "./data/20211125/20211125_lu_nara_legend.csv",
  col_types = cols(
    id = col_double(),
    land_use = col_character(),
    color = col_character()
  ))
legend


#' 5. Calculate the most and least occurring land use category in each of the
#' Natura2000 protected areas (read these areas using the provided code). Tip: use exactextractr::exact_extract() and find
#' the right [summary operations](https://isciences.gitlab.io/exactextractr/#summary-operations)
natura2000 <- st_read("./data/20211125/20211125_protected_areas_Lambert72.gpkg",
                      layer = "ps_hbtrl")



## challenge 2

#' 1. Read the color-infrared image `20211125_cir_ename.tif` (read more about
#' [false colour infrared composites](https://eo.belspo.be/en/colour-composites))


#' 2. How many layers does it contain? What are their **names**?
#' What is the raster's **crs**? The **ext**ent? The **res**olution?



#' 3. Rename layer names
#' fill_1 -> nir
#' fill_2 -> red
#' fill_3 -> green



#' 4. Calculate the [Normalized difference vegetation
#' index](https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index)
#' (NDVI) based on near infrared (nir) and red layers of the raster NDVI = (near
#' infra rood - red)/(nir+red)



#' 5. Notice how the calculated `ndvi` is a raster
#' itself. Assign name  `ndvi` to the raster layer you have just created



#' 6. Plot `ndvi` and write it as a new GeoTIFF (*.tif) file: `ndvi_ename.tif`




## CHALLENGE 3

#' Calculate a canopy height raster from a digital **terrain** model (DTM) and a
#' digital **surface** model (DSM). In other words: `dtm` is the height of the
#' terrain in meters while `dsm` is the height of the top of the vegetation
#' canopy in meters. Both heights are measured using mean sea level as reference
#' zero.
#' Read `20211125_dtm_ename.tif` and `20211125_dsm_ename.tif` as `dtm` and
#' `dsm` respectively.
#' This doesn't work!
#' dsm - dtm
#' How to fix it?




## BONUS CHALLENGES

### Extension to challenge 1

#' 1. Calculate the areal proportion of land cover classes in each of the
#' Natura2000 protected areas. Note: exact_extract() should be combined with a
#' function. It requires data manipulation knowledge (dplyr) as well.



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

