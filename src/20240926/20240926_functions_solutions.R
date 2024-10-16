library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
library(tidyr)
library(assertthat)


# CHALLENGE 0 functions

make_bread <- function(grains, yeast, water, salt) {
  # Code to generate `bread`
  bread <- grains + yeast + water + salt
  return(bread)
}

make_focaccia <- function(grains, yeast, water, salt) {
  # Code to generate `focaccia`
  focaccia <- grains + 1.5 * yeast + 0.7 * water + 2 * salt
  return(focaccia)
}

make_doughs <- function(grains, yeast, water, salt) {
  # Function to generate `bread`
  bread <- make_bread(grains, yeast, water, salt)
  # Function to generate `bread`
  focaccia <- make_focaccia(grains, yeast, water, salt)
  doughs <- list(bread = bread, focaccia = focaccia)
  return(doughs)
}

# CHALLENGE 1 functions

get_obs_2010 <- function(species) {
  # Set scientific name to lowercase
  species <- tolower(species)
  # Replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  # Compose filename
  file_name <- paste0("20240926_", species, "_2010", ".txt")

  # Read file
  obs_2010 <- read_tsv(paste0("./data/20240926/",
                              file_name))
  return(obs_2010)
}

get_obs <- function(species, year) {
  # Set scientific name to lowercase
  species <- tolower(species)
  # Replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  # Compose filename
  file_name <- paste0("20240926_", species, "_", year, ".txt")

  # Read file
  obs <- read_tsv(paste0("./data/20240926/", file_name))
  return(obs)
}

# Extra 1:
# use `require()` within a function to be sure you load all packages you need.
# Extra 2: use assertthat package to check the passed arguments.
# Extra 3: in case you would like to specify a different root folder, you can
# add an extra argument to the function, e.g. `root_folder`.
get_obs_extra <- function(species, year, root_folder) {

  stopifnot(require(assertthat), require(readr))
  # Apply defensive programming principles and check the input arguments as soon
  # as you have them See "fail fast principle"
  # (https://en.wikipedia.org/wiki/Fail-fast_system).
  # We spoke about defensive programming at the INBO coding club of August 27:
  # https://inbo.github.io/coding-club/sessions/20240827_the_art_of_debugging.html#32
  # `species` is a scalar (1 value) and a character
  assertthat::assert_that(is.string(species))
  # `species` is not `NA_character_` (missing value of type character)
  assertthat::assert_that(noNA(species))
  # `year` is a scalar (1 value) and a positive integer
  assertthat::assert_that(is.count(year))
  # `root_folder` is a scalar (1 value) and a directory ("-d")
  assertthat::assert_that(file_test("-d", root_folder))

  # We won't always add similar checks in other functions for sake of
  # simplicity, but it's always good to have them in your functions.

  # Set scientific name to lowercase
  species <- tolower(species)
  # Replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  # Compose filename
  file_name <- paste0("20240926_", species, "_", year, ".txt")

  # Read file using the specified root folder
  obs <- read_tsv(paste0(root_folder, file_name))
  return(obs)
}

## CHALLENGE 2 functions

clean_data <- function(
  df,
  max_coord_uncertain = 1000,
  issues_to_discard = c("ZERO_COORDINATE",
                        "COORDINATE_OUT_OF_RANGE",
                        "COORDINATE_INVALID",
                        "COUNTRY_COORDINATE_MISMATCH"),
  occurrenceStatus_to_discard = c("absent","excluded")) {
  cleaned_df <-
    df %>%
    filter(coordinateUncertaintyInMeters < max_coord_uncertain |
             is.na(coordinateUncertaintyInMeters)) %>%
    filter(!issue %in% issues_to_discard) %>%
    filter(!occurrenceStatus %in% occurrenceStatus_to_discard)
  return(cleaned_df)
}

calc_grid_cell <- function(df,
                           name_lon = "decimalLongitude",
                           name_lat = "decimalLatitude",
                           x_size = 0.1,
                           y_size = 0.05) {
  df <-
    df %>%
    mutate(cell_code = paste0(
      stringr::str_remove(as.character(x_size), pattern = "\\."),
      "x",
      stringr::str_remove(as.character(y_size), pattern = "\\."),
      "E", floor(get(name_lon) / x_size), # or get(name_lon) equivalent to .data[[name_lon]]
      "N", floor(get(name_lat) / y_size)
      )
    )
  return(df)
}

calc_n_obs_ind  <- function(df) {

  # for basic checks you can use `stopifnot()` R base function.
  stopifnot("cell_code" %in% colnames(df))
  stopifnot("individualCount" %in% colnames(df))

  df <-
    df %>%
    dplyr::group_by(cell_code) %>%
    dplyr::summarise(n_observations = n(), # number of observations (rows)
                     n_individuals = sum(individualCount) # number of individuals
    )

  return(df)
}

plot_distr_cells <- function(df, bin_width = 5) {

  # Assertions using assertthat package are more customizable
  assertthat::assert_that(
    "n_observations" %in% names(df),
    msg = "Column `n_observations` not found."
  )
  assertthat::assert_that(
    "n_individuals" %in% names(df),
    msg = "Column `n_individuals` not found."
  )

  df <-
    df %>%
    tidyr::pivot_longer(cols = c(n_observations, n_individuals),
                        values_to = "n",
                        names_to = "indicator",
                        names_pattern = "n_?(.*)"
    )

  p <- ggplot2::ggplot(df) +
    ggplot2::geom_histogram(aes(x = n, fill = indicator),
                            position = "dodge",
                            binwidth = bin_width) +
    ggplot2::xlab(sprintf("n (binwidth: %s)", bin_width)) +
    ggplot2::ggtitle(
      label = "Grid cells distribution"
    )
  return(p)
}


## CHALLENGE 3 function

#' Automatize the entire workflow by creating a macrofunction called analyse_obs() embedding all steps developed in the previous challenges. Think about which arguments you need as input. Return a named list containing:
#' - The data.frame as returned by calc_n_obs_ind()
#' - The ggplot object as returned by plot_distr_cells()

analyse_obs <- function(species,
                        year,
                        root_folder,
                        max_coord_uncertain = 1000,
                        issues_to_discard = c("ZERO_COORDINATE",
                                              "COORDINATE_OUT_OF_RANGE",
                                              "COORDINATE_INVALID",
                                              "COUNTRY_COORDINATE_MISMATCH"),
                        occurrenceStatus_to_discard = c("absent","excluded"),
                        name_lon = "decimalLongitude",
                        name_lat = "decimalLatitude",
                        x_size = 0.1,
                        y_size = 0.05,
                        bin_width = 5) {
  obs <- get_obs_extra(species, year, root_folder)
  cleaned_obs <- clean_data(obs,
                            max_coord_uncertain,
                            issues_to_discard,
                            occurrenceStatus_to_discard)
  grid_obs <- calc_grid_cell(cleaned_obs, name_lon, name_lat, x_size, y_size)
  n_obs_ind <- calc_n_obs_ind(grid_obs)
  p <- plot_distr_cells(n_obs_ind, bin_width)
  return(list(n_obs_ind = n_obs_ind, plot = p))
}

