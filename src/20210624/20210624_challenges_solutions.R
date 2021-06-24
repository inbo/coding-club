library(tidyverse)
library(tidylog)
library(sf)
library(leaflet)
library(htmltools)

## Do not forget to save the functions in a separate file in the same folder as the challenge. You can call it `20210624_functions.R`.

#'source it every time you update it with new functions

#' source("./src/20210624/20210624_functions.R")

#' function solutions are saved in `20210624_functions_solutions.R`
source("./src/20210624/20210624_functions_solutions.R")

## CHALLENGE 1.1

ha_2010 <- get_obs_2010(species = "Harmonia axyridis")
cb_2010 <- get_obs_2010(species = "Chorthippus biguttulus")


## CHALLENGE 1.2

ha_2011 <- get_obs(species = "Harmonia axyridis", year = 2011)
cb_2010 <- get_obs(species = "Chorthippus biguttulus", year = 2010)


#' A little extra: it could be wise to pass an extra argument for the root
#' folder to allow using some different directtories than "./data/20210624/"
ha_2011 <- get_obs_extra(species = "Harmonia axyridis",
                   year = 2011,
                   root_folder = "./data/20210624/")
cb_2010 <- get_obs_extra(species = "Chorthippus biguttulus",
                   year = 2010,
                   root_folder = "./data/20210624/")


## CHALLENGE 2 Part 1 - 1

ha_2011_cleaned <- clean_data(df = ha_2011)
cb_2010_cleaned <- clean_data(df = cb_2010) # all rows removed
# change the max coordinate uncertainty allowed
cb_2010_cleaned <- clean_data(df = cb_2010, max_coord_uncertain = 4000)


## CHALLENGE 2 Part 1 - 2

ha_2011_with_cellcode <- assign_eea_cell(ha_2011_cleaned,
                                         longitude_colname = "decimalLongitude",
                                         latitude_colname = "decimalLatitude")
cb_2010_with_cellcode <- assign_eea_cell(cb_2010_cleaned,
                                         longitude_colname = "longitude",
                                         latitude_colname = "latitude")


## CHALLENGE 2 Part 2 - 1

n_obs_cell_ha_2011 <- get_n_obs_per_cell(ha_2011_with_cellcode)
n_obs_cell_cb_2010 <- get_n_obs_per_cell(cb_2010_with_cellcode)


## CHALLENGE 2 Part 2 - 2

# Read EEA grid outside the function: it's more efficient. you don't need to constantly read the very same file again and again every time you run the function
be_grid <- st_read("./data/20210624/20210624_eea_1x1km_grid_BE.gpkg")

cells_with_obs_ha_2011 <- cells_with_obs(grid_cells = be_grid,
                                         n_obs_per_cell = n_obs_cell_ha_2011)
cells_with_obs_cb_2010 <- cells_with_obs(grid_cells = be_grid,
                                         n_obs_per_cell = n_obs_cell_cb_2010)


## CHALLENGE 3.1

visualize_obs_cells(sf_df = cells_with_obs_cb_2010,
                    species = "Harmonia axyridis",
                    year = 2011)

visualize_obs_cells(sf_df = cells_with_obs_cb_2010,
                    species = "Chorthippus biguttulus",
                    year = 2010)


## CHALLENGE 3.2

# report of 2011 in one click
make_report(species = "Harmonia axyridis",
            year = 2011,
            longitude_colname = "decimalLongitude",
            latitude_colname = "decimalLatitude",
            grid_cells = be_grid)

# report of 2012 in one click
make_report(species = "Harmonia axyridis",
            year = 2012,
            longitude_colname = "decimalLongitude",
            latitude_colname = "decimalLatitude",
            grid_cells = be_grid)

#' Notice how making big functions can arise some new challenges. For example,
#' the cleaning step in function `clean_data()` can remove all observations (no
#' rows left) and this arise an error in the next step, `assign_eea_cell()`.
#' Example:
make_report(species = "Chorthippus biguttulus",
            year = 2010,
            longitude_colname = "longitude",
            latitude_colname = "latitude",
            grid_cells = be_grid)

#' Crashes are never nice to see: you need to take care of these edge cases by
#' adding some checks, e.g. by adding an if-else structure. We choose for
#' example to return NULL and a warning message if no rows are left. Improved function is called `make_report_improved()`

make_report_improved(species = "Chorthippus biguttulus",
                     year = 2010,
                     longitude_colname = "longitude",
                     latitude_colname = "latitude",
                     grid_cells = be_grid)


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
file_name <- paste0(species, "_2010", ".txt")

## read file
ha_2010 <- read_tsv(paste0("./data/20210624/",
                           file_name))

#' STEP 2: data cleaning, remove imprecise or unverified observations, absences
#' Remove data with coordinate uncertainty higher than 1000 meters
ha_2010 <-
  ha_2010 %>%
  filter(coordinateUncertaintyInMeters < 1000 | is.na(coordinateUncertaintyInMeters))

#' Remove data with some issues
ha_2010 <-
  ha_2010 %>%
  filter(!issue %in% c(
    "ZERO_COORDINATE",
    "COORDINATE_OUT_OF_RANGE",
    "COORDINATE_INVALID",
    "COUNTRY_COORDINATE_MISMATCH"
  ))

#' Remove obs linked to absences or exclusions

ha_2010 <-
  ha_2010 %>%
  filter(!occurrenceStatus %in% c(
    "absent",
    "excluded"
  ))

#' STEP 3: get the 1x1km EAA grid cellcode each observation belongs to and add
#' it to the observation data.frame
#' Step 3a: reprojection
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

#' STEP 5: read the EEA grid and get number of observations for each cell. Cells
#' without observations are removed

# Read EEA grid
be_grid <- st_read("./data/20210624/eea_1x1km_grid_BE.geojson")

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
