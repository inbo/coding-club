library(tidyverse)


# CHALLENGE 1 ####

file_name <- "20250626_moth_obs_2022.csv"
path <- file.path("data", "20250626", file_name)
obs <- readr::read_csv(path)


# Add `year` column based on `eventDate`
obs <- obs %>%
  dplyr::mutate(year = lubridate::year(.data$eventDate))

# Calculate the total yearly effort for each `locationID` as the total number of
# trap days over all deploymentIDs linked to each `locationID`
effort_year <- obs %>%
  dplyr::group_by(year, locationID, deploymentID) %>%
  dplyr::summarise(
    trap_nights = dplyr::n_distinct(eventDate), .groups = "drop_last"
  ) %>%
  dplyr::summarise(
    effort = sum(trap_nights),
    .groups = "drop"
  )
effort_year


# Calculate yearly abundance as the sum of individual counts per species and
# `locationID`
abundance_year <- obs %>%
  dplyr::group_by(year, locationID, species) %>%
  dplyr::summarise(
    abundance = sum(individualCount), .groups = "drop"
  )
abundance_year

# Calculate species richness per `locationID` as number of unique species
# observed
richness_year <- obs %>%
  dplyr::group_by(year, locationID) %>%
  dplyr::summarise(
    richness = n_distinct(species), .groups = "drop"
  )
richness_year


# CHALLENGE 2 ####

# Add effort categories
# Low: 0-9 trap nights
# Medium: 10-19 trap nights
# High: 20+ trap nights
effort_year <- effort_year %>%
  dplyr::mutate(categoric_effort = cut(effort,
                                       breaks = c(-Inf, 9, 19, Inf),
                                       labels = c("low", "medium", "high")
                                       )
  )
effort_year

# Add abundance categories
# Low: 0-9
# Medium: 10-49
# High: 50+
abundance_year <- abundance_year %>%
  dplyr::mutate(categoric_abundance = cut(abundance,
                                          breaks = c(-Inf, 9, 49, Inf),
                                          labels = c("low", "medium", "high")
  )
  )
abundance_year

# Add richness categories
# Low: 0-5
# Medium: 6-10
# High: 11+
richness_year <- richness_year %>%
  dplyr::mutate(categories_richness = cut(richness,
      breaks = c(-Inf, 5, 10, Inf),
      labels = c("low", "medium", "high")
    )
  )
richness_year

# Plot abundance of Cossus cossus by location
plot_abundance_year_cossus_cossus <- abundance_year %>%
  dplyr::filter(species == "Cossus cossus") %>%
  ggplot2::ggplot(
    ggplot2::aes(x = locationID,
                 y = total_abundance,
                 fill = categoric_abundance)) +
  geom_col() +
  labs(title = "Abundance of Cossus cossus by Location",
       x = "Location",
       y = "Abundance")
plot_abundance_year_cossus_cossus

# Same plot with text in Dutch
plot_abundance_year_cossus_cossus_nl <- abundance_year %>%
  dplyr::filter(species == "Cossus cossus") %>%
  ggplot2::ggplot(
    ggplot2::aes(x = locationID,
                 y = total_abundance,
                 fill = categoric_abundance)) +
  geom_col() +
  labs(title = "Abundantie van Cossus cossus per Locatie",
       x = "Locatie",
       y = "Abundantie")
plot_abundance_year_cossus_cossus


# CHALLENGE 3 ####

# Plot effort by location
plot_effort_year <- ggplot(effort_year,
                           aes(x = locationID,
                               y = effort,
                               fill = categoric_effort)) +
  geom_col() +
  labs(title = "Effort by Location",
       x = "Location",
       y = "Effort")
plot_effort_year

# Plot richness by location
plot_richness_year <- ggplot(richness_year,
                             aes(x = locationID,
                                 y = richness,
                                 fill = categories_richness)) +
  geom_col() +
  labs(title = "Species Richness by Location",
       x = "Location",
       y = "Species Richness")
plot_richness_year


# Combine effort, abundance, and richness into a list
indicators <- list(effort_year = effort_year,
                   abundance_year = abundance_year,
                   richness_year = richness_year)
indicators
