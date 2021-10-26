library(tidyverse)
library(sf)

impatiens_df <- read_tsv("./data/20211026/20211026_impatiens_glandulifera.txt")


#' Transform impatiens_df to a geospatial data.frame using sf package. Note that
#' GBIF data are stored using WGS 84. Hint: find which numeric code is
#' associated with WGS84 coordinate reference system.



#' How many layers does the  geospatial file 20211026_protected_areas1.gpkg contain?



#' Read the layer `ps_hbtrl`: call it `prot_areas`



#' What is the coordinate reference system declared by user? Does it coincide
#' with the real Geographic Coordinate Reference System (GEOCRS)?



#' Check that the CRS of `prot_areas` and `spatial_impatiens_df` are the same




## CHALLENGE 2

#' Transform both `prot_areas` and `spatial_impatiens_df` to [European
#' Terrestrial Reference System 1989](https://epsg.io/3035), the coordinate
#' reference system used at EU level



#' Write the transformed data as a geopackage file called
#' `prot_areas_and_impatiens_trs1989.gpkg` with two layers: the first called
#' `prot_areas`, containing the protected areas, the second layer,
#' `impatiens_obs`, containing the observations of Himalayan balsam



#' Due to spatial uncertainty (gridded data, GPS uncertainty, etc.) observations
#' should not be idealized as points in space, but as circles. Create such circles
#' using the values store in column `coordinateUncertaintyInMeters` for
#' `spatial_impatiens_df_3035`




## CHALLENGE 3

#' Using data in CRS 3035:
#' 1. Find which observations, as points, are _contained_ in each protected area?



#' But we should better check which observations, as circles (!), _intersect_
#' each protected area. How to do it?



#' So, how many observations in the protected area "Bos- en heidegebieden ten
#' oosten van Antwerpen"?



#' Sometimes it's interesting to calculate the centroid of a polygon, e.g. for
#' visualizations. Easy by using sf function `st_centroids()`.
#' However, you get an error while calculating the centroids of `prot_areas`.
#' What does it mean? How to solve the issue?




## BONUS CHALLENGE

#' 1. Not a sf question, but still nice to solve: based on the answer of 2 and 3,
#' how to add to `prot_areas_3035` a column called `n_impatiens` with the number
#' of observations for each protected area?



#' 2. How to get only the observations, as circles, **totally** contained in
#' protected areas? Hint: check the cheat sheet


