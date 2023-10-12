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
  file_name <- paste0("20230926_", species, "_2010", ".txt")

  # Read file
  obs_2010 <- read_tsv(paste0("./data/20230926/",
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
  file_name <- paste0("20230926_", species, "_", year, ".txt")

  # Read file
  obs <- read_tsv(paste0("./data/20230926/", file_name))
  return(obs)
}

# Extra 1:
# use require() within a function to be sure you load all packages you need
get_obs <- function(species, year) {
  require(readr)
  require(stringr)

  ## set scientific name to lowercase
  species <- tolower(species)
  ## replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  ## compose filename
  file_name <- paste0("20230926_", species, "_", year, ".txt")

  ## read file
  obs <- read_tsv(paste0("./data/20230926/",
                                  file_name))

  return(obs)
}

# Extra 2: use assertthat package to check the passed arguments
get_obs <- function(species,year) {
  require(readr)
  require(stringr)
  require(assertthat)

  # species and year MUST be unique and of right type, otherwise arise error
  assertthat::is.string(species)
  assertthat::is.number(year)

  # Set scientific name to lowercase
  species <- tolower(species)
  # Replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  # Compose filename
  file_name <- paste0("20230926_", species, "_", year, ".txt")

  # Read file
  obs <- read_tsv(paste0("./data/20230926/",
                         file_name))

  return(obs)
}


# Extra 3: in case you would like to specify a different root folder for your
# input data (this solution is needed in challenge 3 when we will put the
# function in a package)
get_obs_extra <- function(species, year, root_folder) {

  # species and year MUST be unique and of right type, otherwise arise error
  assertthat::is.string(species)
  assertthat::is.number(year)

  # Set scientific name to lowercase
  species <- tolower(species)
  # Replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  # Compose filename
  file_name <- paste0("20230926_", species, "_", year, ".txt")

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
                           x_size = 0.1,
                           y_size = 0.05) {
  df <-
    df %>%
    mutate(cell_code = paste0(
      stringr::str_remove(as.character(x_size), pattern = "\\."),
      "x",
      stringr::str_remove(as.character(y_size), pattern = "\\."),
      "E", floor(decimalLongitude / x_size),
      "N", floor(decimalLatitude / y_size)
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
    group_by(cell_code) %>%
    summarise(n_observations = n(), # number of observations (rows)
              n_individuals = sum(individualCount) # number of individuals
    )

  return(df)
}

plot_distr_cells <- function(df, bin_width = 5) {

  #assertions using assertthat package are more customizable
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

  p <- ggplot(df) +
    geom_histogram(aes(x = n, fill = indicator),
                   position = "dodge",
                   binwidth = bin_width) +
    xlab(sprintf("n (binwidth: %s)", bin_width)) +
    ggtitle(
      label = "Grid cells distribution"
    )
  return(p)
}
