library(tidyverse)

# # Read in the cube (https://doi.org/10.15468/dl.furjrq)
# data <- readr::read_tsv(
#   "data/20260429/0072635-260226173443078.csv",
#   na = ""
# )
# cube <- data %>%
#   filter(phylum == "Marchantiophyta") # liverworts, levermossen
# cube %>%
#   write_tsv("data/20260429/cube_marchantiophyta_flanders.tsv", na = "")

cube <- readr::read_tsv(
  "data/20260429/20260429_cube_marchantiophyta_flanders.tsv",
  na = ""
)

# CHALLENGE 1 ####

## 1.1 ####
species <- cube_minimal %>%
  pull(specieskey) %>%
  unique()
# Alternative
species <- unique(cube_minimal$specieskey)

species_df <- cube_minimal %>%
  distinct(specieskey)


## 1.2 ####
cube_occurrences_gt_1_precise <- cube %>%
  filter(occurrences > 1, mincoordinateuncertaintyinmeters < 1000)


## 1.3 ####
all(cube_occurrences_gt_1$specieskey %in% species)


## 1.4 ####
cube_minimal <- cube %>%
  dplyr::select(eeacellcode, year, specieskey, occurrences)


## 1.5 ####
cube <- cube %>%
  dplyr::relocate(species, specieskey, year, eeacellcode, .before = 1) %>%
  dplyr::relocate(occurrences, mincoordinateuncertaintyinmeters, mintemporaluncertainty, .after = eeacellcode)
names(cube)


# CHALLENGE 2 ####

## 2A.1 ####
cube <- cube %>%
  dplyr::rename(
    cell_code = eeacellcode,
    min_coord_unc = mincoordinateuncertaintyinmeters,
    min_temp_unc = mintemporaluncertainty
  )
names(cube)


## 2A.2 ####
cube %>%
  group_by(species, specieskey) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(desc(n), species)

# Shortcut using `count()`
cube %>%
  count(species, specieskey) %>%
  arrange(desc(n), species)


## 2A.3 ####
cube %>%
  group_by(species) %>%
  distinct(min_coord_unc) %>%
  ungroup() %>%
  arrange(species, min_coord_unc)


## 2A.4 ####
species_name_key <- cube %>%
  group_by(species) %>%
  summarise(n_species = n_distinct(specieskey), .groups = "drop") %>%
  arrange(desc(n_species), species)


## 2B.1 ####
species_richness_year <- cube %>%
  group_by(year) %>%
  summarise(n_species = n_distinct(specieskey), .groups = "drop") %>%
  arrange(desc(n_species), year)


## 2B.2 ####
species_richness_year <- species_richness_year %>%
  mutate(
    richness_category = case_when(
      n_species <= 10 ~ "low",
      n_species > 10 & n_species <= 20 ~ "medium",
      n_species > 20 ~ "high",
      .unmatched = "error"
    )
  )


## 2B.3 ####
species_year_occupancy <- cube %>%
  group_by(species, specieskey, year) %>%
  summarise(
    n_cells = n_distinct(cell_code),
    n_occurrences = sum(occurrences),
    .groups = "drop"
  ) %>%
  arrange(specieskey, year)
species_year_occupancy


# CHALLENGE 3 ####

vernacular_names <- readr::read_tsv("data/20260429/20260429_vernacular_names_marchantiophyta_flanders.tsv", na = "")

## 3.1 ####
vernacular_names_wide_lists <- vernacular_names %>%
  filter(language %in% c("eng", "nld", "deu")) %>%
  select(taxonKey, vernacularName, language) %>%
  tidyr::pivot_wider(
    names_from = language,
    values_from = vernacularName,
    names_prefix = "vernacular_name_",
    values_fn = list
  )

## 3.2 ####
vernacular_names_wide <- vernacular_names %>%
  filter(language %in% c("eng", "nld", "deu"), !is.na(vernacularName)) %>%
  select(taxonKey, vernacularName, language) %>%
  distinct() %>%
  tidyr::pivot_wider(
    names_from = language,
    values_from = vernacularName,
    names_prefix = "vernacular_name_",
    values_fn = ~ paste(., collapse = ", ")
  )

## 3.3 ####
cube_vernacular <- cube %>%
  left_join(vernacular_names_wide, by = c("specieskey" = "taxonKey"))
# Or, using the join_by() function
cube_vernacular <- cube %>%
  left_join(vernacular_names_wide, join_by(specieskey == taxonKey))


# BONUS CHALLENGE ####

## BC.1 ####
cube_extra <- cube %>%
  dplyr::rename_with(
     ~ stringr::str_replace_all(
      .,
      pattern = "(count|key)",
      replacement = "_\\1"
    ),
    .cols = ends_with(c("count", "key"))
  )

## BC.2 ####
library(rgbif)
vernacular_name <- function(key) {
  rgbif::name_usage(key = key, data = "vernacularNames") %>%
    purrr::pluck("data")
}

vernacular_names <- purrr::map(unique(cube$specieskey), vernacular_name) %>%
  purrr::list_rbind()
