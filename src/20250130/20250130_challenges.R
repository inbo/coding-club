library(tidyverse)
library(rgbif)

# Load data

butterflies_eu <- readr::read_csv(
  file = "data/20250130/20250130_butterflies_eu.csv",
  na = ""
)

butterflies_eu_distr_all <- readr::read_csv(
  file = "data/20250130/20250130_butterflies_eu_distributions.csv",
  na = ""
)

butterflies_eu_vern_dutch <- readr::read_csv(
  file = "data/20250130/20250130_butterflies_eu_vernacularnames_dutch_all_GBIF.csv",
  guess_max = 1000
)

transect_counts <- readr::read_csv(
  "data/20250130/20250130_transect_counts.csv",
  na = ""
)


## CHALLENGE 1 - basics




## CHALLENGE 2 - To join or not to join 🦋



## INTERMEZZO: rgbif + purrr = 💪

# It's almost impossible to do data wrangling with tidyverse without using purrr. purrr is a package from tidyverse ecosystem. It allows you to write code in a more functional style, which can be more readable and maintainable. rgbif is an R package to interface with the Global Biodiversity Information Facility (GBIF) API. It allows you to search for species, download occurrence data, and more. purrr and rgbif can be combined to make powerful and flexible workflows for working with biodiversity data. Here are some examples of how you can use purrr and rgbif together to get vernacular names.

# The "National checklists and red lists for European butterflies" dataset contains only vernacular names in English. Just check it via:

purrr::map(
  butterflies_eu$key, function(x) {
    rgbif::name_usage(key = x, data = "vernacularNames") %>%
      purrr::pluck("data")
  }) %>%
  purrr::list_rbind() %>%
  dplyr::distinct(language)

# We are interested in the Dutch vernacular names. How to get them? Let's do it by using the GBIF Taxonomic Backbone! The field `nubKey` in `butterflies_eu` contains the key of the taxon in the GBIF Taxonomic Backbone. We can use it to get the Dutch vernacular names of the Belgian butterflies:

butterflies_eu_vern_dutch <- purrr::map(
  butterflies_eu$nubKey, function(x) {
    rgbif::name_usage(key = x, data = "vernacularNames") %>%
      purrr::pluck("data")
  }) %>%
  purrr::list_rbind() %>%
  dplyr::filter(language == "nld")


## CHALLENGE 3 - So many names, so little time 🦋







## BONUS CHALLENGE 1 - Choices 🤷






## BONUS CHALLENGE 2 - Tidying up your data 🧹

library(readxl)

counts_raw <- read_excel(
  path = "data/20250130/20250130_butterfly_transect_counts_raw.xls",
  skip = 4,
  .name_repair = "universal"
)
