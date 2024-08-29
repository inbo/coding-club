library(tidyverse)

## CHALLENGE 1

#' Function evenOdd() takes an integer n and returns a list containing two integers
#' that respectively indicate how many even and odd digits occur in n
#'
#' @examples
#' evenOdd(398473234) -> (4, 5)
#' evenOdd(459) -> (1, 2)
evenOdd <- function(n) {
  char_n <- as.character(n)
  counter_even <- 0
  counter_odd <- 0
  for (i in char_n) {
    digit <- as.integer(i)
    if (digit %% 2 == 0) {
      counter_even <- counter_even + 1
    } else {
      counter_odd <- counter_odd + 1
    }
  }
  return(list(n_even = counter_even,
              n_odd = counter_odd))
}


## CHALLENGE 2

#' Function step() takes a positive integer, count up the number of even and
#' odd digits, and the total number of digits and return it as a number.
#'
#' @examples
#' step(398473234)
#' 459
#' step(459)
#' 123
step <- function(n) {
  n_odd_even <- evenOdd(n)
  total_digits <- nchar(n)
  n_odd_even_total <- n_odd_even
  n_odd_even_total$n_total <- total_digits
  return(n_odd_even_total)
}


#' Function `steps` takes an integer and return how
#' many steps you need before the number 123 is reached.
#' @examples
#' steps(398473234)
#' 2
#' steps(1)
#' 5
#' steps(2)
#' 2
steps <- function(n) {
  while (n != 123) {
    n <- step(n)
    n_steps <- n_steps + 1
  }
  return(n_steps)
}


## INTERMEZZO

#' Customized `min()` function for numeric vectors to avoid warning while
#' calculating minimum of empty vectors
#'
#' `custom_min()` should fail if a not numeric vector is passed
#'
#' @examples
#' custom_min(c(8, 4, 2, 5)) # this works
#' custom_min(c("e", "r", "a")) # this should return an error
custom_min <- function(x) {
  if (length(x)>0) min(x) else NA
}


# Improve version with assertion

#' Customized `min()` function for numeric vectors to avoid warning while
#' calculating minimum of empty vectors
#'
#' `custom_min()` should fail if a not numeric vector is passed
#'
#' @examples
#' custom_min(c(8, 4, 2, 5)) # this works
#' custom_min(c("e", "r", "a")) # this should return an error
custom_min <- function(x) {
  # Check x argument (assertion)
  assertthat::assert_that(
    is.numeric(x),
    msg = "Invalid type of input: only numeric vectors allowed."
  )
  # Function core follows
  if (length(x)>0) min(x) else NA
}



## CHALLENGE 3


#' Core function to find migration periods of a tagged eel
#' @examples
#' library(readr)
#' library(dplyr)
#' library(lubridate)
#' library(ggplot2)
#'
#' ## Example 1
#'
#' # Read eel tagging data
#' eel_emma <- read_csv("./data/20240827/20240827_eel_Emma.txt", na = "")
#' # Define thresholds
#' distance_threshold <- 5000 # Threshold in meter
#' migration_speed_threshold <- 0.1 # Speed threshold in m/s
#' # Run migration detection
#' eel_emma_migration_info <- get_migrations(
#'   eel_emma,
#'   dist_threshold = distance_threshold,
#'   speed_threshold = migration_speed_threshold
#' )
#' # Plot result (this chunk is not included in following examples)
#' ggplot(eel_emma_migration_info, aes(x = arrival, y = totaldistance_m)) +
#'   geom_point(aes(color = downstream_migration)) +
#'   geom_line() +
#'   scale_y_reverse()
#'
#' ## Example 2
#' eel_rhea <- read_csv("./data/20240827/20240827_eel_Rhea.txt", na = "")
#' # Define thresholds
#' dist_thresh <- "5000" # Threshold in meter
#' speed_thresh <- 0.1 # Speed threshold in m/s
#' # Run migration detection
#' get_migrations(eel_rhea,
#'                dist_threshold = dist_thresh,
#'                speed_threshold = speed_thresh)
#'
#' ## Example 3
#' eel_amber <- read_csv("./data/20240827/20240827_eel_Amber.txt", na = "")
#' # Define thresholds
#' dist_thresh <- 5000 # Threshold in meter
#' speed_thresh <- 0.1 # Speed threshold in m/s
#' # Run migration detection
#' get_migrations(eel_amber,
#'                dist_threshold = dist_thresh,
#'                speed_threshold = speed_thresh)
get_migrations <- function(df,
                           dist_threshold,
                           speed_threshold) {
  df %>%
    mutate(dist_threshold = totaldistance_m + dist_threshold) %>%
    rowwise() %>%
    mutate(first_dist_to_use = custom_min(
      df$totaldistance_m[df$totaldistance_m >= dist_threshold])) %>%
    mutate(row_first_dist_to_use = if_else(
      !is.na(first_dist_to_use),
      which(df$totaldistance_m == first_dist_to_use)[1],
      NA)) %>%
    ungroup() %>%
    mutate(time_first_dist_to_use = if_else(!is.na(row_first_dist_to_use),
                                            df$arrival[row_first_dist_to_use],
                                            NA)) %>%
    mutate(delta_totdist = first_dist_to_use - totaldistance_m) %>%
    mutate(delta_t = as.numeric(as.duration(time_first_dist_to_use - departure))) %>%
    mutate(migration_speed = (delta_totdist / delta_t)) %>%
    mutate(downstream_migration = migration_speed >= speed_threshold)
}
