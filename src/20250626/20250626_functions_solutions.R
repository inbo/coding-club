library(tidyverse)
library(docstring) # Install first if needed (used in Challenge 3)

# CHALLENGE 0 ####
make_bread <- function(grains, yeast, water, salt) {
  return(grains + yeast + water + salt)
}

make_focaccia <- function(grains,yeast,water,salt) {
  return(grains + 1.5 * yeast + 0.7 * water + 2 * salt)
}

make_doughs <- function(grains, yeast, water, salt) {
  # Code to generate `bread` and `focaccia`
  bread <- make_bread(grains = grains,
                      yeast = yeast,
                      water = water,
                      salt = salt)
  focaccia <- make_focaccia(grains = grains,
                            yeast = yeast,
                            water = water,
                            salt = salt)
  # Combine bread and focaccia as a list of doughs
  doughs <- list(bread = bread, focaccia = focaccia)
  return(doughs)
}

# CHALLENGE 1 ####

## 1.1 ####
read_moth <- function(year) {
  # Create file name and path based on the year
  file_name <- sprintf("20250626_moth_obs_%s.csv", year)
  path <- file.path("data", "20250626", file_name)

  # Read the CSV file into a data frame
  moth_data <- readr::read_csv(path)
  return(moth_data)
}

# Extra: add a path argument for more flexibility.
read_moth_with_path <- function(path, year) {
  # Create file name and path based on the year
  file_name <- sprintf("20250626_moth_obs_%s.csv", year)

  # Read the CSV file into a data frame
  moth_data <- readr::read_csv(file.path(path, file_name))
  return(moth_data)
}

# For the pipe lovers: alternative with pipes!
read_moth_with_path_pipes <- function(path,year) {
  moth_data <- year %>%
    sprintf(fmt="20250626_moth_obs_%i.csv") %>%
    file.path(path, .) %>%
    readr::read_csv()
  return(moth_data)
}

## 1.2 ####
read_moth <- function(year) {
  # Create file name and path based on the year
  file_name <- sprintf("20250626_moth_obs_%s.csv", year)
  path <- file.path("data", "20250626", file_name)

  # Read the CSV file into a data frame
  moth_data <- readr::read_csv(path) %>%
    # Add a new column for the year
    dplyr::mutate(year = lubridate::year(.data$eventDate))
  return(moth_data)
}

# Same for the two other alternatives
# Extra: add a path argument for more flexibility.
read_moth_with_path <- function(path, year) {
  # Create file name and path based on the year
  file_name <- sprintf("20250626_moth_obs_%s.csv", year)

  # Read the CSV file into a data frame
  moth_data <- readr::read_csv(file.path(path, file_name)) %>%
    # Add a new column for the year
    dplyr::mutate(year = lubridate::year(.data$eventDate))
  return(moth_data)
}

# For the pipe lovers: alternative with pipes!
read_moth_with_path_pipes <- function(path,year) {
  moth_data <- year %>%
    sprintf(fmt="20250626_moth_obs_%i.csv") %>%
    file.path(path, .) %>%
    readr::read_csv() %>%
    # Add a new column for the year
    dplyr::mutate(year = lubridate::year(.data$eventDate))
  return(moth_data)
}


## 1.3 ####
get_effort <- function(df) {
  df %>%
    dplyr::group_by(year, locationID, deploymentID) %>%
    dplyr::summarise(
      trap_nights = dplyr::n_distinct(eventDate), .groups = "drop_last"
    ) %>%
    dplyr::summarise(
      effort = sum(trap_nights),
      .groups = "drop"
    )
}

get_abundance <- function(df) {
  df %>%
    dplyr::group_by(year, locationID, species) %>%
    dplyr::summarise(
      abundance = sum(individualCount), .groups = "drop"
    )
}

get_richness <- function(df) {
  df %>%
    dplyr::group_by(year, locationID) %>%
    dplyr::summarise(
      richness = n_distinct(species), .groups = "drop"
    )
}


# CHALLENGE 2 ####

## 2.1 ####
get_effort <- function(df,
                       breaks = c(-Inf, 9, 19, Inf),
                       labels = c("low", "medium", "high")) {
  df %>%
    dplyr::group_by(year, locationID, deploymentID) %>%
    dplyr::summarise(
      trap_nights = dplyr::n_distinct(eventDate), .groups = "drop_last"
    ) %>%
    dplyr::summarise(
      effort = sum(trap_nights),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      categoric_effort = cut(effort, breaks = breaks, labels = labels)
    )
}

get_abundance <- function(df,
                          breaks = c(-Inf, 9, 49, Inf),
                          labels = c("low", "medium", "high")) {
  df %>%
    dplyr::group_by(year, locationID, species) %>%
    dplyr::summarise(
      abundance = sum(individualCount), .groups = "drop"
    ) %>%
    dplyr::mutate(categoric_abundance = cut(abundance,
                                            breaks = breaks,
                                            labels = labels)
    )
}

get_richness <- function(df,
                         breaks = c(-Inf, 5, 10, Inf),
                         labels = c("low", "medium", "high")) {
  df %>%
    dplyr::group_by(year, locationID) %>%
    dplyr::summarise(
      richness = n_distinct(species), .groups = "drop"
    ) %>%
    dplyr::mutate(categoric_richness = cut(richness,
                                           breaks = breaks,
                                           labels = labels)
    )
}

## 2.2 ####
plot_abundance <- function(df, scientific_name) {
  df %>%
    dplyr::filter(species == scientific_name) %>%
    ggplot2::ggplot(
      ggplot2::aes(x = locationID,
                   y = abundance,
                   fill = categoric_abundance)) +
    geom_col() +
    labs(title = sprintf("Abundance of %s by Location", scientific_name),
         x = "Location",
         y = "Abundance")
}


## 2.3 ####
plot_abundance <- function(df,
                           scientific_name,
                           language = "en") {

  # `language` must be either "en" or "nl". Uppercase input allowed for
  # convenience
  try(
    if (!language %in% c("en", "nl")) {
      stop("Language must be either 'en' or 'nl'.")
    }
  )
  language <- tolower(language)


  p <- df %>%
    dplyr::filter(species == scientific_name) %>%
    ggplot2::ggplot(
      ggplot2::aes(x = locationID,
                   y = abundance,
                   fill = categoric_abundance)) +
    geom_col()
  if (language == "en") {
    p + labs(title = sprintf("Abundance of %s by Location", scientific_name),
             x = "Location",
             y = "Abundance")
  } else {
    if (language == "nl") {
      p +
        labs(title = sprintf("Abundantie van %s per Locatie", scientific_name),
             x = "Locatie",
             y = "Abundantie")
    }
  }
}


# CHALLENGE 3 ####

## 3.1 ####
# We should avoid to repeat the language check in all three functions! We
# learned that if you repeat a piece code, then you should create a function for
# it. Let's try!

check_language <- function(language) {
  #' Help function to check if the given `language` is supported
  #'
  #' @param language Character string, either "en" or "nl".
  #' @return The `language` in lowercase.

  try(
    if (!language %in% c("en", "nl")) {
      stop("Language must be either 'en' or 'nl'.")
    }
  )
  language <- tolower(language)

  return(language)
}

plot_effort <- function(df, language = "en") {
  #' Plot effort by location in the specified language
  #'
  #' @param df Data frame containing effort data
  #' @param language Language for labels ("en" for English, "nl" for Dutch).
  #'   Default: "en".
  #' @return A ggplot object
  #' @examples
  #' library(tidyverse)
  #' df <- read_moth(2022) %>% get_effort()
  #' plot_effort(df, language = "en")
  #' plot_effort(df, language = "nl")

  language <- check_language(language)
  p <- ggplot(effort_year,
              aes(x = locationID,
                  y = effort,
                  fill = categoric_effort)) +
    geom_col()
  if (language == "en") {
    p + labs(title = "Effort by Location",
         x = "Location",
         y = "Effort")
  } else {
    if (language == "nl") {
      p + labs(title = "Inspanning per Locatie",
         x = "Locatie",
         y = "Inspanning")
    }
  }
}


plot_richness <- function(df, language = "en") {
  #' Plot richness by location in the specified language
  #'
  #' @param df Data frame containing richness data
  #' @param language Language for labels ("en" for English, "nl" for Dutch).
  #'   Default: "en".
  #' @return A ggplot object
  #' @examples
  #' library(tidyverse)
  #' richness_df <- read_moth(2022) %>% get_richness()
  #' plot_effort(richness_df, language = "en")
  #' plot_effort(richness_df, language = "nl")

  language <- check_language(language)
  p <- ggplot(richness_year,
              aes(x = locationID,
                  y = richness,
                  fill = categoric_richness)) +
    geom_col()
  if (language == "en") {
    p + labs(title = "Species Richness by Location",
         x = "Location",
         y = "Richness")
  } else {
    if (language == "nl") {
      p + labs(title = "Soorten Rijkdom per Locatie",
         x = "Locatie",
         y = "Rijkdom")
    }
  }
}

# We can also refactor `plot_abundance()` written for Challenge 2 to use the
# `check_language` function.
plot_abundance <- function(df,
                           scientific_name,
                           language = "en") {
  #' Plot abundance by location for a specific species in the specified language
  #'
  #' @param df Data frame containing abnundance data.
  #' @param scientific_name Character string, the scientific name of the
  #'   species.
  #' @param language Language for labels ("en" for English, "nl" for Dutch).
  #'   Default: "en".
  #' @return A ggplot object
  #' @examples
  #' library(tidyverse)
  #' abundance_df <- read_moth(2022) %>% get_abundance()
  #' plot_abundance(abundance_df, "Cossus cossus", language = "en")
  #' plot_abundance(abundance_df, "Cossus cossus", language = "nl")

  language <- check_language(language)
  p <- df %>%
    dplyr::filter(species == scientific_name) %>%
    ggplot2::ggplot(
      ggplot2::aes(x = locationID,
                   y = abundance,
                   fill = categoric_abundance)) +
    geom_col()
  if (language == "en") {
    p + labs(title = sprintf("Abundance of %s by Location", scientific_name),
             x = "Location",
             y = "Abundance")
  } else {
    if (language == "nl") {
      p +
        labs(title = sprintf("Abundantie van %s per Locatie", scientific_name),
             x = "Locatie",
             y = "Abundantie")
    }
  }
}

## 3.2 ####
get_indicators <- function(year,
                           breaks_effort = c(-Inf, 9, 19, Inf),
                           labels_effort = c("low", "medium", "high"),
                           breaks_abundance = c(-Inf, 9, 49, Inf),
                           labels_abundance = c("low", "medium", "high"),
                           breaks_richness = c(-Inf, 5, 10, Inf),
                           labels_richness = c("low", "medium", "high")) {
  #' Get indicators for a given year
  #' @param year Integer, the year for which to get the indicators.
  #' @param breaks_effort Numeric vector, breaks for effort categorization.
  #'   Default: `c(-Inf, 9, 19, Inf)`.
  #' @param labels_effort Character vector, labels for effort categories.
  #'  Default: `c("low", "medium", "high")`.
  #' @param breaks_abundance Numeric vector, breaks for abundance
  #'   categorization. Default: `c(-Inf, 9, 49, Inf)`.
  #' @param labels_abundance Character vector, labels for abundance categories.
  #'   Default: `c("low", "medium", "high")`.
  #' @param breaks_richness Numeric vector, breaks for richness categorization.
  #'   Default: `c(-Inf, 5, 10, Inf)`.
  #' @param labels_richness Character vector, labels for richness categories.
  #'   Default: `c("low", "medium", "high")`.
  #' @return A list containing effort, abundance, and richness indicators for the
  #' specified year.
  #' @examples
  #' get_indicators(2022)
  #' get_indicators(2022,
  #'                breaks_effort = c(-Inf, 10, 20, Inf),
  #'                labels_effort = c("very low", "medium", "very high"),
  #'                breaks_abundance = c(-Inf, 10, 50, Inf),
  #'                labels_abundance = c("L", "M", "H"),
  #'                breaks_richness = c(-Inf, 6, 12, Inf),
  #'                labels_richness = c("LOW", "MEDIUM", "HIGH"))

  df <- read_moth(year)
  effort_year <- get_effort(df, breaks = breaks_effort, labels = labels_effort)
  abundance_year <- get_abundance(df,
                                  breaks = breaks_abundance,
                                  labels = labels_abundance)
  richness_year <- get_richness(df,
                                breaks = breaks_richness,
                                labels = labels_richness)
  list(
    effort = effort_year,
    abundance = abundance_year,
    richness = richness_year
  )
}

# BONUS CHALLENGE ####

plot_indicators <- function(indicators, scientific_name, language = "en") {
  #' Plot indicators in the specified language
  #'
  #' @param indicators List containing effort, abundance, and richness data
  #'   frames.
  #' @param scientific_name Character string, the scientific name of the
  #'  species for abundance plot.
  #' @param language Language for labels ("en" for English, "nl" for Dutch).
  #'   Default: "en".
  #' @return A list of ggplot objects for effort, abundance, and richness.
  #' @examples
  #' library(tidyverse)
  #' indicators <- get_indicators(2022)
  #' plot_indicators(
  #'   indicators,
  #'   scientific_name = "Cossus cossus",
  #'   language = "en"
  #' )
  #' plot_indicators(
  #'   indicators,
  #'   scientific_name = "Cossus cossus",
  #'   language = "nl"
  #' )

  # Check if the `language` is supported
  language <- check_language(language)

  list(
    effort = plot_effort(indicators$effort, language),
    abundance = plot_abundance(indicators$abundance,
                               scientific_name = scientific_name,
                               language),
    richness = plot_richness(indicators$richness, language)
  )
}


# Extra for you: Based on `check_language()`, write a `check_scientific_name()`
# and use it in `plot_abundance()`.
