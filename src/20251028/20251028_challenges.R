## CHALLENGE 1

# Convert the code below to a Rmd document called `visualize_n_occs.Rmd` and
# make an html version of it.


# Title : "Read and visualize ABV occurrence data"


# # Setup

# Load libraries:
library(tidyverse)    # to do datascience
library(INBOtheme)    # to apply INBO style to graphs
library(sf)           # to work with geospatial vector data
library(plotly)       # to make dynamic plots
library(leaflet)      # to make dynamic maps


# # Introduction
#
# In this document we will:
#
# 1. read occurrence cube data
# 2. explore data
# 3. visualize data
#
#
# # Read data
#
# Read **ABV** data from the occurrence cube file `20251028_abv_cube.csv`:
abv_cube <- readr::read_csv(
  file = "./data/20251028/20251028_abv_cube.csv"
)

# Read the Flemish grid from the geopackage file `20251028_utm_grid.gpkg`:
vl_grid <- sf::st_read("./data/20251028/20251028_utm_grid.gpkg")


# # Explore data

# This dataset contains data from min(abv_cube$year) to max(abv_cube$year)
# related to length(unique(abv_cube$specieskey)) species from the
# unique(abv_cube$family) family and their distribution in Flanders
# based on a grid of 1 km x 1 km.


# Preview of the first 30 rows of the dataset:
head(abv_cube, n = 30)


# ## Taxonomic information

# Species present in the dataset:
abv_cube %>% distinct(specieskey, species)


# ## Temporal information

# The data are temporally defined at year level. Years present:
abv_cube %>% dplyr::distinct(year) %>% arrange(year)



# ## Geographical information

# The geographical information is represented by the `mgrscode` column,
# which contains the identifiers of the grid cells containing at least one
# occurrence of the species.

# The dataset contains `length(unique(abv_cube$mgrscode))` unique grid cells.


# # Preprocess data
#
# Add geometrical information to the occurrence cube via `mgrscode`, which contains the identifiers of the grid cells containing at least one occurrence of the species.
cells_in_cube <- vl_grid %>%
  dplyr::filter(mgrscode %in% unique(abv_cube$mgrscode)) %>%
  dplyr::select(-c(TAG, Shape_Leng, Shape_Area))
sf_abv_cube <- cells_in_cube %>%
  dplyr::left_join(abv_cube, by = "mgrscode")

# Final (spatial) dataset:
sf_abv_cube %>% head(n = 30)



## End CHALLENGE 1



## CHALLENGE 2



# Data visualization

# In this section we will show how the number of occurrences and the number of occupied grid cells vary by year and species. Both static plots and dynamic maps are generated.
#
# # Static plots
#
# # Show number of occurrences and number of occupied grid cells (make a tabbed section out of it)
#
# ### per species (1st tab)

n_per_species <- sf_abv_cube %>%
  dplyr::group_by(species) %>%
  dplyr::summarize(occurrences = sum(n),
                   grid_cells = n_distinct(mgrscode),
                   .groups = "drop") %>%
  tidyr::pivot_longer(cols = c(occurrences, grid_cells),
                      names_to = "variable",
                      values_to = "n")

ggplot(n_per_species, aes(x = species, y = n)) +
  geom_bar(stat = 'identity') +
  facet_grid(.~variable, scales = "free_y") +
  ggplot2::theme(axis.text.x = element_text(angle = 60, hjust = 1))

# ### per year (2nd tab)

n_per_year <- sf_abv_cube %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(occurrences = sum(n),
                   grid_cells = n_distinct(mgrscode),
                   .groups = "drop") %>%
  tidyr::pivot_longer(cols = c(occurrences, grid_cells),
                      names_to = "variable",
                      values_to = "n")

ggplot(n_per_year,aes(x = year, y = n)) +
  geom_bar(stat = 'identity') +
  facet_grid(.~variable, scales = "free_y") +
  ggplot2::theme(axis.text.x = element_text(angle = 60, hjust = 1))


# ### per year and species (3rd tab)

n_occs_per_year_species <-
  sf_abv_cube %>%
  dplyr::group_by(year, species) %>%
  dplyr::summarize(occurrences = sum(n),
                   grid_cells = n_distinct(mgrscode),
                   .groups = "drop") %>%
  tidyr::pivot_longer(cols = c(occurrences, grid_cells),
                      names_to = "variable",
                      values_to = "n")

ggplot(n_occs_per_year_species,
       aes(x = year, y = n, fill = species)) +
  geom_bar(stat = 'identity') +
  facet_grid(.~variable) +
  ggplot2::theme(axis.text.x = element_text(angle = 60, hjust = 1))

# # Dynamic plots
#
# ## Leaflet dynamic map
#
# We show a map with the distribution of _Anemone_ in Belgium. We show the total number of occurrences per grid cell. The color of the grid cells is based on the number of occurrences. The legend shows the color scale and the number of occurrences per grid cell.
n_occs_per_cell <- sf_abv_cube %>%
  dplyr::group_by(mgrscode) %>%
  dplyr::summarize(
    occurrences = sum(n),
    min_coordinateuncertaintyinmeters = min(mincoordinateuncertaintyinmeters),
    .groups = "drop")

map_abv <- mapview::mapview(n_occs_per_cell,
                            zcol = "occurrences",
                            legend = TRUE
)

map_abv


# ## Plotly yearly abundance
n_occs_per_year <- n_occs_per_year_species |>
  dplyr::filter(variable == "occurrences") |>
  st_drop_geometry()

fig <- plot_ly(n_occs_per_year,
               x = ~year,
               y = ~n,
               split = ~species,
               stroke = ~species,
               type = "scatter",
               mode = "lines+markers")

fig



