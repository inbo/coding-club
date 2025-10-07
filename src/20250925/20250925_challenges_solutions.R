library(tidyverse) # purrr is part of tidyverse core packages installed
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
data_nl <- purrr::set_names(data_nl, species_df$species)

## 1.2 ####
purrr::map(data_nl, \(x) nrow(x$data))

## 1.3 ####
# I use here the ~ .x notation
purrr::map_int(data_nl, ~ nrow(.x$data))

# Or using the more traditional function(x) notation
purrr::map_int(data_nl, function(x) nrow(x$data))

## 1.4 ####
data_nl_df <- purrr::map_dfr(data_nl, purrr::pluck("data"))
# It can even shorter
data_nl_df <- purrr::map_dfr(data_nl, "data")

## 1.5 ####
countries <- c("NL", "AT", "ES", "DK")

get_gbif_data <- function(country_code) {
  rgbif::occ_search(
    taxonKey = species_df$taxonKey,
    country = country_code,
    year = "1950,2025",
    hasCoordinate = TRUE,
    occurrenceStatus = "PRESENT",
    limit = 100000 # High enough
  )
}

# Use purrr::map to apply the function to each country code
data_countries <- purrr::map(countries, get_gbif_data)
# The data are returned in a nested structure, as expected
data_countries[[1]]$`5218786`$data

## 1.6 ####
data_countries <- purrr::set_names(data_countries, countries)
names(data_countries)
data_countries[["NL"]]$`5218786`$data

data_countries <- purrr::map(
  data_countries,
  ~ purrr::set_names(.x, species_df$species)
)

# Or using the more modern \x instead of ~ .x
data_countries <- purrr::map(
  data_countries, \(x) purrr::set_names(x, species_df$species)
)

# Now we can access the data slot like this
data_countries$NL$`Procyon lotor`$data

# CHALLENGE 2 ####

## 2.1 ####

# This fails because for some country/species combination data is `NULL` and so
# `nrow(NULL)` is NULL and NULL cannot be part of an integer vector.
nrows_list <- purrr::map(
  data_countries,
  function(x) {
    purrr::map_int(x, \(x) nrow(x$data))
  }
)

# The improved version that returns 0 for NULL data slots
nrows_list <- purrr::map(
  data_countries,
  function(dfs) {
    purrr::map_int(dfs, function(x) {
      if (is.null(x$data)) 0 else nrow(x$data)
    }
    )
  }
)
nrows_list

## 2.2 ####
tot_nrecords <- sum(purrr::map_int(nrows_list, sum))
tot_nrecords


## 2.3 ####
# Code to generate a bar plot for Procyon lotor in NL showing the number of
# records per year
ggplot2::ggplot(
  data = data_countries$NL$`Procyon lotor`$data
) +
  ggplot2::geom_bar(ggplot2::aes(x = year)) +
  ggplot2::xlab("Year") +
  ggplot2::ylab("Number of records") +
  ggplot2::ggtitle("Procyon lotor - NL")

purrr::iwalk(
  data_countries,
  function(x, country_code) {
    purrr::iwalk(
      x,
      function(y, species_name) {
        if (!is.null(y$data) > 0) {
          p <- ggplot2::ggplot(
            data = y$data
          ) +
            ggplot2::geom_bar(ggplot2::aes(x = year)) +
            ggplot2::xlab("Year") +
            ggplot2::ylab("Number of records") +
            ggplot2::ggtitle(sprintf("%s - %s", species_name, country_code))
          print(p)
        }
      }
    )
  }
)

## 2.4 ####
purrr::iwalk(
  data_countries,
  function(x, country_code) {
    purrr::iwalk(
      x,
      function(y, species_name) {
        taxon_key <- species_df$taxonKey[species_df$species == species_name]
        file_name <- sprintf(
          "./data/20250925/20250925_gbif_%s_%s_%s.csv",
          taxon_key,
          gsub(" ", "_", species_name),
          country_code
        )
        if (!is.null(y$data)) {
          readr::write_csv(
            x = y$data,
            file = file_name,
            na = ""
          )
        }
      }
    )
  }
)

## 2.5 ####
data_countries_df <- purrr::map_dfr(
  data_countries,
  function(x) {
    purrr::map_dfr(x, "data")
  }
)
nrow(data_countries_df) == tot_nrecords



readr::write_csv(
  x = data_countries_df,
  file = "./data/20250925/20250925_gbif_occs.csv",
  na = ""
)

# INTERMEZZO ####

# purrr has also a very nice set of tools to work with lists (and vectors
# too).
#
# Example: how to remove NULL slots from a list?
a <- list(z = 1, b = NULL, c = 3)
purrr::compact(a)

# How to bind a list in a vector?
purrr::list_c(a)

purrr::list_flatten(data_countries)



# CHALLENGE 3 ####

# If everything went well, `data_countries_df` should be a data.frame similar to
# the one saved as "./data/20250925/20250925_gbif_occs.csv". In any case, load
# it with the provided code:
data_countries_df <- readr::read_csv(
  "./data/20250925/20250925_gbif_occs.csv",
  na = ""
)

# Group occurrences by `species` and nest it
data_nested <- data_countries_df %>%
  dplyr::group_by(species) %>%
  tidyr::nest()
data_nested

## 3.1 ####

# Provided ggplot2 code
ggplot2::geom_bar(ggplot2::aes(x = year, fill = country)) +
  ggplot2::xlab("Year") +
  ggplot2::ylab("Number of records")

data_nested <- data_nested %>%
  dplyr::mutate(
    bar_plot = purrr::map2(
      data, species,
      function(df, species_name) {
        ggplot2::ggplot(
          data = df
        ) +
          ggplot2::geom_bar(ggplot2::aes(x = year, fill = country)) +
          ggplot2::xlab("Year") +
          ggplot2::ylab("Number of records") +
          ggplot2::ggtitle(species_name)
      }
    )
  )
data_nested$bar_plot[[1]]
data_nested$bar_plot[[2]]
data_nested$bar_plot[[3]]


##3.2 ####
purrr::walk2(
  data_nested$bar_plot, data_nested$species,
  function(p, species_name) {
    file_name <- sprintf(
      "./data/20250925/20250925_gbif_%s_barplot.png",
      gsub(" ", "_", species_name)
    )
    ggplot2::ggsave(
      filename = file_name,
      plot = p$bar_plot[[1]],
      width = 8,
      height = 6
    )
  }
)
