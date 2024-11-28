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
  if (!"https://inbo.r-universe.dev" %in% getOption("repos")) {
    # Install inbospatial via GitHub
    devtools::install_github("inbo/inbospatial")
    # Remove inbospatial from the list of packages to install
    required_packages <- required_packages[required_packages != "inbospatial"]
  }
  # Install packages not yet installed
  install.packages(required_packages[!installed_packages])
}

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))



## CHALLENGE 1 - Plots

# Load the number of alien species in protected areas
ias_in_pa <- sf::st_read(
  dsn = "./data/20241128/20241128_ias_union_concern_Natura2000_B.gpkg"
)





## CHALLENGE 2 - Maps

# Take just 10 Natura200 protected areas
ias_in_pa_sample <- ias_in_pa[1:10,]



## CHALLENGE 3 - Interactive maps

# Read geopackage file with Flemish municipalities
flanders <- sf::st_read("./data/20241128/20241128_flemish_municipalities.gpkg")


