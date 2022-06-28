library(tidyverse)   # to do datascience
library(sf)          # to work with spatial data
library(leaflet)     # to create maps
library(htmltools)   # to generate custom HTML code in R

#' Do not forget to save the functions in a separate file in the same folder as
#' the challenge. You can call it `20220630_functions.R`.

#' Source it everytime you update it with new functions by:
#' source("./src/20220630/20220630_functions.R")


#######################################
## CODE TO BE CONVERTED TO FUNCTIONS ##
#######################################

# STEP 1: read observations

## define species
species <- "Harmonia axyridis"
## set scientific name to lowercase
species <- tolower(species)
## replace spaces with underscores
species <- str_replace_all(
  species,
  pattern = " ",
  replacement = "_"
)

## compose filename
file_name <- paste0("20220630_", species, "_2010", ".txt")

## read file
ha_2010 <- read_tsv(paste0("./data/20220630/",
                           file_name))

# STEP 2: data cleaning, remove imprecise or unverified observations, absences
# Remove data with coordinate uncertainty higher than 1000 meters
ha_2010 <-
  ha_2010 %>%
  filter(coordinateUncertaintyInMeters < 1000 | is.na(coordinateUncertaintyInMeters))

## Remove data with some issues
ha_2010 <-
  ha_2010 %>%
  filter(!issue %in% c(
    "ZERO_COORDINATE",
    "COORDINATE_OUT_OF_RANGE",
    "COORDINATE_INVALID",
    "COUNTRY_COORDINATE_MISMATCH"
  ))

## Remove obs linked to absences or exclusions

ha_2010 <-
  ha_2010 %>%
  filter(!occurrenceStatus %in% c(
    "absent",
    "excluded"
  ))

# STEP 3: get the 1x1km EAA grid cellcode each observation belongs to and add
# it to the observation data.frame

## Step 3a: reprojection
ha_2010 <- ha_2010 %>%
  mutate(x = decimalLongitude,
         y = decimalLatitude)
ha_2010 <- st_as_sf(ha_2010, coords = c("x", "y"), crs = 4326)
ha_2010 <-  st_transform(ha_2010, crs = 3035)
coords <- st_coordinates(ha_2010) %>%
  as_tibble() %>%
  rename(x_3035 = X,
         y_3035= Y)
ha_2010 <-
  ha_2010 %>%
  bind_cols(coords)

## Step 3b: get the EAA grid cell code each observation belongs to and add it to
## the data.frame
ha_2010 <-
  ha_2010 %>%
    mutate(eea_cell_code = paste0(
      "1km",
      "E", floor(x_3035/1000),
      "N", floor(y_3035/1000))) %>%
  select(-c(x_3035, y_3035))

## Step 4: calculate number of observations of Harmonia axyridis in each grid cell
n_obs_ha_2010 <-
  ha_2010 %>%
  as_tibble() %>%
  group_by(eea_cell_code) %>%
  count()

# STEP 5: read the EEA grid and get number of observations for each cell. Cells
# without observations are removed

## Read EEA grid
be_grid <- st_read("./data/20220630/20220630_eea_1x1km_grid_BE.gpkg")

## add number of observations via inner_join (cells with no obs automatically
## excluded)
be_grid_n_obs_ha_2010 <-
  be_grid %>%
  inner_join(n_obs_ha_2010,
             by = c("CELLCODE" = "eea_cell_code")
  )

## STEP 6: make a leaflet heatmap
pal <- colorBin(palette = "YlOrRd",
                domain = be_grid_n_obs_ha_2010$n)
labels <- sprintf(
  "EEA cell: %s<br/>Species: Harmonia axyridis<br/>Number of observations: %g",
  be_grid_n_obs_ha_2010$CELLCODE,
  be_grid_n_obs_ha_2010$n) %>%
  lapply(HTML)
leaflet(st_transform(be_grid_n_obs_ha_2010, crs = 4326)) %>%
  addTiles() %>%
  addPolygons(
  fillColor = ~pal(n),
  weight = 1,
  opacity = 1,
  color = "purple",
  fillOpacity = 0.7,
  highlightOptions = highlightOptions(weight = 2,
    color = "black",
    fillOpacity = 1,
    bringToFront = TRUE),
  label =  labels,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto")) %>%
  addLegend(title = "Harmonia axyridis (2010)<br>Number of observations",
            pal = pal,
            values = ~n)
