library(tidyverse)
library(sf)

ludwigia_df <- read_tsv("./data/20221025/20221025_ludwigia_grandiflora.txt")

# 1. Transform both `prot_areas` and `spatial_ludwigia_df` to [European
# Terrestrial Reference System 1989](https://epsg.io/3035) (EPSG: 3035), the
# coordinate reference system used at EU level



# 2. How many layers does the  geospatial file `20221025_protected_areas.gpkg`
# contain?



# 3. Import the layer `ps_hbtrl`: call it `prot_areas`



# 4. What is the CRS declared by user? Does it coincide with the real Geographic
# Coordinate Reference System (GEOCRS)?



# 5. Do `prot_areas` and `spatial_ludwigia_df` have the same CRS?



# 6. Read the Belgian provinces rds file as `be_provinces_sp` (the code is
# given!). What is the class of this variable? From which package? How to
# transform it to a sf object?

be_provinces_sp <- read_rds(
  file = "./data/20221025/20221025_be_provinces_sp.rds"
)





# 7. Extract the Flemish provinces.




## CHALLENGE 2

# 1. Transform both `prot_areas` and `spatial_ludwigia_df` to [European
# Terrestrial Reference System 1989](https://epsg.io/3035), the coordinate
# reference system used at EU level



# 2. Write the transformed data as a geopackage file called
# `prot_areas_and_ludwigia_3035.gpkg` with two layers: the first called
# `prot_areas`, containing the protected areas, the second layer,
# `ludwigia_obs`, containing the observations of water primrose






# 3. Due to spatial uncertainty (gridded data, GPS uncertainty, etc.) GBIF
# observations should not be idealized as points in space, but as circles.
# Create such circles using the values store in column
# `coordinateUncertaintyInMeters` of `spatial_ludwigia_df_3035`




# INTERMEZZO - S2 geometry
#
# Notice that since last version of sf you can apply such spatial operations in
# spherical CRSs (aka systems using lat-lon like WGS84)




## CHALLENGE 3

# Using data in CRS 3035:
# 1. Find which observations, as points, are _contained_ in each protected area?




# You can use `st_intersects()` as well: same result. However, st_contains gives
# more the idea of what you are doing




# 2. But we should better check which observations, as circles (!), _intersect_
# each protected area. How to do it?




# 3. So, how many observations in the protected area called `"Demervallei"`?


# 4. Sometimes it's interesting to calculate the centroid of a polygon, e.g. for
# visualizations. Easy by using sf function `st_centroids()`. However, you get
# an error while calculating the centroids of `prot_areas`. What does it mean? How to solve the problem?

st_centroid(prot_areas)




## BONUS CHALLENGE

# 1. How to get only the observations, as circles, **totally** contained in
# protected areas?




# 2. Not a sf question, but still nice to solve: how to add to `prot_areas_3035`
# a column called `n_ludwigia` with the number of observations for each
# protected area?



