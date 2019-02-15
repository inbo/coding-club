# load packages
library(tidyverse)
library(lubridate)
library(purrr)

# read csv file and preprocessing
vis_data <- read_csv(file = "../data/20180426_visdata_cleaned.csv")
vis_data <- vis_data %>%
  filter(!is.na(lengte) & !is.na(gewicht)) %>%
  mutate(year = lubridate::year(datum))

#' Function to calculate the fish spherical density distribution
#'
#' The spherical density distribution doesn't take into account the abundance of
#' each species. For this reason the mean of the spherical density for each fish
#' species is calculated at first. The means are then used to calculate the
#' quantiles (0%, 25%, 50%; 75%; 100%) of the spherical density distribution.
#' @param df A data.frame containing at least the columns "soort", "gewicht" and
#'   "lengte".
#' @return A named vector
#' @examples
#' library(tidyverse)
#' library(lubridate)
#' library(purrr)
#' vis_data <- read_csv(file = "../data/20180426_visdata_cleaned.csv")
#' vis_data %>%
#'   mutate(year = lubridate::year(datum)) %>%
#'   spherical_density_distribution()
#'
spherical_density_distribution <- function(df) {
  q_index <- df %>%
    group_by(soort) %>%
    summarize(density = mean(gewicht/(4/3*pi*(lengte/2)^3)), na.rm = TRUE) %>%
    pull(density) %>%
    quantile(na.rm = TRUE)
  return(q_index)
}
