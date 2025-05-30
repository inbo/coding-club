library(tidyverse)
library(digest)
library(rgbif)

# Read dataset `counts` ####
counts <- readr::read_tsv(
  file = "data/20250527/20250527_partridge_counts.tsv",
  na = ""
)

## Get an overview of `counts` ####
dplyr::glimpse(counts)


# CHALLENGE 1 ####

## 1.1 ####

## 1.2 ####

## 1.3 ####

## 1.4 ####

# CHALLENGE 2 ####

# INTERMEZZO ####

digest::digest(object = "Damiano Oldoni", algo = "sha256")

digest::digest(object = "Damiano Oldoni", algo = "blake3")


# CHALLENGE 3A ####

## 3A.1 ####

## 3A.2 ####

# CHALLENGE 3B ####
library(rgbif)

taxa_ad_hoc <- rgbif::name_usage(
  datasetKey = "1f3505cd-5d98-4e23-bd3b-ffe59d05d7c2",
  limit = 1000 # Enough high to get all taxa
) %>%
  purrr::pluck("data") %>% # Similar to use $data, but nice for piping
  dplyr::filter(origin == "SOURCE") # Remove any higher taxonomy provided by checklist authors

# Extract GBIF Backbone taxon keys
backbone_taxa <- taxa_ad_hoc %>%
  # Filter out taxa with not match with the GBIF Backbone
  dplyr::filter(!is.na(nubKey)) %>%
  dplyr::pull(nubKey)

# Get vernacular names of one taxon as example (set max to 1000 names)
backbone_taxon <- backbone_taxa[1]
vernacular_names_example <- rgbif::name_usage(
  key = backbone_taxon,
  data = "vernacularNames",
  limit = 1000
) %>%
  purrr::pluck("data")

## 3B.1 ####

##3B.2 ####

## 3B.3 ####

## 3B.4 ####
