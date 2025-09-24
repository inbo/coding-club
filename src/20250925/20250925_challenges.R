library(tidyverse)
library(rgbif)

# CHALLENGE 1 ####

species_df <- dplyr::tibble(
  species = c("Procyon lotor", "Nasua narica", "Muntiacus reevesis"),
  taxonKey = c(5218786, 2433536, 2440946)
)

# Get occurrence data for the given species in the
# Netherlands (country code "NL")
data_nl <- rgbif::occ_search(
  taxonKey = species_df$taxonKey,
  country = "NL",
  year = "1950,2025",
  hasCoordinate = TRUE,
  occurrenceStatus = "PRESENT",
  limit = 100000 # High enough
)
data_nl$`5218786`$data
data_nl$`2433536`$data
data_nl$`2440946`$data

## 1.1 ####


## 1.2 ####


## 1.3 ####


## 1.4 ####


## 1.5 ####
countries <- c("NL", "AT", "ES", "DK")


## 1.6 ####



# CHALLENGE 2 ####

## 2.1 ####


## 2.2 ####


## 2.3 ####
ggplot2::ggplot(
  data = data_countries$NL$`Procyon lotor`$data
) +
  ggplot2::geom_bar(ggplot2::aes(x = year)) +
  ggplot2::xlab("Year") +
  ggplot2::ylab("Number of records") +
  ggplot2::ggtitle("Procyon lotor - NL")


## 2.4 ####


## 2.5 ####



# INTERMEZZO ####


a <- list(z = 1, b = NULL, c = 3)
purrr::compact(a)

purrr::list_c(a)



# CHALLENGE 3 ####

data_countries_df <- readr::read_csv(
  "./data/20250925/20250925_gbif_occs.csv",
  na = ""
)

data_nested <- data_countries_df %>%
  dplyr::group_by(species) %>%
  tidyr::nest()
data_nested

## 3.1 ####
ggplot2::ggplot(data_nested$data[[1]]) +
ggplot2::geom_bar(ggplot2::aes(x = year, fill = country)) +
  ggplot2::xlab("Year") +
  ggplot2::ylab("Number of records")


##3.2 ####


