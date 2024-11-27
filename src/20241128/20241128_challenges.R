# Load the packages and install if needed
required_packages <- c(
  "sf",
  "ggplot2",
  "ggrepel", # For avoiding label overlapping
  "ggspatial",
  "prettymapr", # For using map tiles with ggspatial
  "raster", # For using map tiles with ggspatial
  "mapview",
  "leafem", # For providing extensions to leaflet maps
  "leafpop", # For including tables, images and graphs in leaflet pop-ups
  "inbospatial" # For sharing useful R functions for dealing with spatial raster or vector data
)

# Install packages not yet installed
installed_packages <- required_packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(required_packages[!installed_packages])
}

# Packages loading
invisible(lapply(required_packages, library, character.only = TRUE))



## CHALLENGE 1 - Plots

# Load the data
ias_in_pa <- sf::st_read("./data/20241128/20241128_ias_union_concern_Natura2000_B.gpkg")





## CHALLENGE 2 - Maps

# Take just 10 Natura200 protected areas
ias_in_pa_sample <- ias_in_pa[1:10,]



## CHALLENGE 3 - Interactive maps

# Read geopackage file with Flemish municipalities
flanders <- sf::st_read("./data/20241128/20241128_flemish_municipalities.gpkg")


