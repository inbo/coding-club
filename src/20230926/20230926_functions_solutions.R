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

## INTERMEZZO 3

#' Creating a package using `checklist` is possible, but at the moment of
#' writing the solutions the package `docstring` stops working as wished. So, we
#' make a package without following the INBO specifications via checklist, but
#' we use the generic `usethis` package. Here below some comments with a list of
#' commando to execute to create the entomolist package:
#'
#' 1. Run:
#' `usethis::create_package(path = "../entomologist", rstudio = TRUE, roxygen = TRUE, open = TRUE)`
#' Notice that you can change the path where to create the
#' package. In my case, I have a folder with all packages and projects I work
#' on and this is the parent directory of the INBO coding club folder.
#'
#' 2. A project called `entomologist.Rprj` has been created and opened
#' automatically in a new RStudio session. Notice also what you get on your
#' console before you are redirected to the new project.
#'
#' 3. Start by editing the `DESCRIPTION` file which you can find in
#' the root folder. Provide the title for your package as in slides:
#' `Analyze insect related GBIF occurrences`. Provide also the description as in slides:
#' `A collection of functions used to analyze insects data for the project of my life.`.
#' Notice that this file is not a R file: you don't need to insert `"` around these two strings!
#'
#' 4. Still in `DESCRIPTION`, provide the person details of the package creator,
#' that's you! :-)
#'
#' 5. Run `usethis::use_mit_license()` to add a MIT license to your package. The
#' choice of the license is personal or explicitly defined within the project
#' the package is intended. Still, MIT license is in most of the time a good
#' option for R packages. Notice that now the line with license has changed on
#' the fly: `License: MIT + file LICENSE` and two files has been added:
#' `LICENSE` and `LICENSE.md`.
#'
#' 6. Add a line with `Language: en-GB` to specify that your package is written
#' in British English. You can put it more or less wherever you want, but
#' typically it is placed under the `Encoding` line.

## CHALLENGE 3

#' 1. Add a R file called `get_obs.R` in `./R` subdirectory.
#'
#' 2. Place the `get_obs()` function in it. Notice you need to add the
#' `get_obs()` function with the root folder argument as described in the
#' extra's of challenge 1. The package otherwise cannot find your files.
#'
#' 3. All needed packages must be "imported" to be available for the functions
#' in your package. To do so, you need a section in `DESCRIPTION` called
#' `Imports:`. Something like this based on `get_obs()` (to be extended):
#' Imports:
#'   assertthat,
#'   readr,
#'   stringr
#'
#' If you prefer, you can run:
#' `usethis::use_package("dplyr")`
#' `usethis::use_package("assertthat")`
#' `usethis::use_package("ggplot2")`
#' `usethis::use_package()` function will add automatically the packages for you
#' in `Imports` section of `DESCRIPTION`: package is not added if already
#' present.
