## CHALLENGE 1

# Convert the code below to a Rmd document called `visualize_n_occs.Rmd` and
# make an html version of it.


# Title : "Read and visualize Anemone occurrence data"


# # Setup

# Load libraries:
library(tidyverse)    # to do datascience
library(INBOtheme)    # to apply INBO style to graphs
library(sf)           # to work with geospatial vector data
library(mapview)      # to make dynamic leaflet maps


# # Introduction
#
# In this document we will:
#
# 1. read occurrence cube data
# 2. explore data
# 3. preprocess data
#
#
# # Read data
#
# Read _Anemone_ data from the occurrence cube file `20241217_occurrence_cube_anemone.tsv`:
anemone_cube <- readr::read_tsv(
  file = "./data/20241217/20241217_occurrence_cube_anemone.tsv",
  na = ""
)

# Read the Belgian grid from the geopackage file `20241217_utm1_be.gpkg`:
be_grid <- sf::st_read("./data/20241217/20241217_utm1_be.gpkg")


# # Explore data

# This dataset contain data from min(anemone_cube$year) to max(anemone_cube$year)
# related to length(unique(anemone_cube$specieskey)) species and their distribution
# in Belgium based on a grid of 1 km x 1 km.


# Preview with the first 30 rows of the dataset:
head(anemone_cube, n = 30)


# ## Taxonomic information

# Species present in the dataset:
anemone_cube %>% distinct(specieskey, species)


# ## Temporal information

# The data are temporally defined at year level. Years present:
anemone_cube %>% dplyr::distinct(year)



# ## Geographical information

# The geographical information is represented by the `eeacellcode` column,
# which contains the identifiers of the grid cells containing at least one
# occurrence of the species.

# The dataset contains `length(unique(anemone_cube$eeacellcode))` unique grid cells.


# # Preprocess data
#
# Add geometrical information to the occurrence cube via `eeacellcode`, which contains the identifiers of the grid cells containing at least one occurrence of the species.
cells_in_cube <- be_grid %>%
  dplyr::filter(CELLCODE %in% unique(anemone_cube$eeacellcode)) %>%
  dplyr::select(-c(EOFORIGIN, NOFORIGIN))
sf_anemone_cube <- cells_in_cube %>%
  dplyr::left_join(anemone_cube, by = c("CELLCODE" = "eeacellcode")) %>%
  dplyr::rename("eeacellcode" = "CELLCODE")

# Final (spatial) dataset:
sf_anemone_cube %>% head(n = 30)



## End CHALLENGE 1



## CHALLENGE 2



# Data visualization

# In this section we will show how the number of occurrences and the number of occupied grid cells vary by year and species. Both static plots and dynamic maps are generated.
#
# # Static plots
#
# # Show number of occurrences  and number of occupied grid cells (make a tabbed section out of it)
#
# ### per species (1st tab)

n_per_species <- sf_anemone_cube %>%
  dplyr::group_by(species) %>%
  dplyr::summarize(occurrences = sum(occurrences),
                   grid_cells = n_distinct(eeacellcode),
                   .groups = "drop") %>%
  tidyr::pivot_longer(cols = c(occurrences, grid_cells),
                      names_to = "variable",
                      values_to = "n")

ggplot(n_per_species, aes(x = species, y = n)) +
  geom_bar(stat = 'identity') +
  facet_grid(.~variable, scales = "free_y") +
  ggplot2::theme(axis.text.x = element_text(angle = 60, hjust = 1))

# ### per year (2nd tab)

n_per_year <- sf_anemone_cube %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(occurrences = sum(occurrences),
                   grid_cells = n_distinct(eeacellcode),
                   .groups = "drop") %>%
  tidyr::pivot_longer(cols = c(occurrences, grid_cells),
                      names_to = "variable",
                      values_to = "n")

ggplot(n_per_year,aes(x = year, y = n)) +
  geom_bar(stat = 'identity') +
  facet_grid(.~variable, scales = "free_y") +
  ggplot2::theme(axis.text.x = element_text(angle = 60, hjust = 1))


# ### per year and province (3rd tab)

n_occs_per_year_species <-
  sf_anemone_cube %>%
  dplyr::group_by(year, species) %>%
  dplyr::summarize(occurrences = sum(occurrences),
                   grid_cells = n_distinct(eeacellcode),
                   .groups = "drop") %>%
  tidyr::pivot_longer(cols = c(occurrences, grid_cells),
                      names_to = "variable",
                      values_to = "n")

ggplot(n_occs_per_year_species,
       aes(x = year, y = n, fill = species)) +
  geom_bar(stat = 'identity') +
  facet_grid(.~variable) +
  ggplot2::theme(axis.text.x = element_text(angle = 60, hjust = 1))

# # Dynamic maps
#
# ## Leaflet maps
#
# We show a map with the distribution of _Anemone_ in Belgium. We show the total number of occurrences per grid cell. The color of the grid cells is based on the number of occurrences. The legend shows the color scale and the number of occurrences per grid cell.
n_occs_per_cell <- sf_anemone_cube %>%
  dplyr::group_by(eeacellcode) %>%
  dplyr::summarize(
    occurrences = sum(occurrences),
    min_coordinateuncertaintyinmeters = min(mincoordinateuncertaintyinmeters),
    min_mintemporaluncertainty = min(mintemporaluncertainty),
    .groups = "drop")
map_anemone <- mapview::mapview(n_occs_per_cell,
                                zcol = "occurrences",
                                legend = TRUE
)
map_anemone
