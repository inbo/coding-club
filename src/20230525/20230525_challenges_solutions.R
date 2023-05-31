library(tidyverse)

## CHALLENGE 1

# Use debug techniques to find the bug in the function evenOdd()

#' Function evenOdd() takes an integer n and returns a list containing two integers
#' that respectively indicate how many even and odd digits occur in n
#'
#' @examples
#' evenOdd(398473234) # should return (4, 5)
#' evenOdd(459) # should return (1, 2)
evenOdd <- function(n) {
  char_n <- as.character(n)
  counter_even <- 0
  counter_odd <- 0
  for (i in seq_len(nchar(char_n))) {
    digit <- as.integer(substr(char_n, i, i))
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

# Using debug techniques find what is going wrong in functions step() and steps()

#' Function step() takes a positive integer:
#' 886328712442992
#'
#' Write down a positive integer:
#' 398473234
#' Count up the number of even and odd digits, and the total number of digits:
#' 4 5 9
#' String the digits of those three numbers together to make a new number:
#' 459
#' Return it as a number
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
  n_odd_even_total <- paste0(n_odd_even_total, collapse = "")
  n_odd_even_total <- as.integer(n_odd_even_total)
  return(n_odd_even_total)
}


#'Function `steps` takes an integer and return how
#' many steps you need before the number 123 is reached.
#' @examples
#' steps(398473234)
#' 2
#' steps(1)
#' 5
#' steps(2)
#' 2
steps <- function(n) {
  n_steps <- 0
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


# improve version with assertion

#' Customized `min()` function for numeric vectors to avoid warning while
#' calculating minimum of empty vectors
#'
#' `custom_min()` should fail if a not numeric vector is passed
#'
#' @examples
#' custom_min(c(8, 4, 2, 5)) # this works
#' custom_min(c("e", "r", "a")) # this should return an error
custom_min <- function(x) {
  # check x argument (assertion)
  assertthat::assert_that(
    is.numeric(x),
    msg = "Invalid type of input: only numeric vectors allowed."
  )
  # function core follows
  if (length(x)>0) min(x) else NA
}

## CHALLENGE 3

# Based on defensive programming principle, add some checks to `get_migrations()`
# function defined here below. You can test the function using the examples
# defined under the function. Notice also how documenting your own functions is
# more than a nice-to-have.

#' Core function to find migration periods of a tagged eel
#' @examples
#' library(readr)
#' library(dplyr)
#' library(lubridate)
#' library(ggplot2)
#'
#' ## Example 1
#'
#' # read eel tagging data
#' eel_anna <- read_csv("./data/20230525/20230525_eel_Anna.txt", na = "")
#' # define thresholds
#' distance_threshold <- 5000 # threshold in meter
#' migration_speed_threshold <- 0.1 # speed threshold in m/s
#' # run migration detection
#' eel_anna_migration_info <- get_migrations(
#'   eel_anna,
#'   dist_threshold = distance_threshold,
#'   speed_threshold = migration_speed_threshold
#' )
#' # plot result (this chunk is not included in following examples)
#' ggplot(eel_anna_migration_info, aes(x = arrival, y = totaldistance_m)) +
#'   geom_point(aes(color = downstream_migration)) +
#'   geom_line() +
#'   scale_y_reverse()
#'
#' ## Example 2
#' eel_lisa <- read_csv("./data/20230525/20230525_eel_Lisa.txt", na = "")
#' # define thresholds
#' dist_thresh <- "5000" # threshold in meter
#' speed_thresh <- 0.1 # speed threshold in m/s
#' # run migration detection
#' get_migrations(eel_lisa,
#'                dist_threshold = dist_thresh,
#'                speed_threshold = speed_thresh)
#' ## Example 3
#' eel_amber <- read_csv("./data/20230525/20230525_eel_Amber.txt", na = "")
#' # define thresholds
#' dist_thresh <- 5000 # threshold in meter
#' speed_thresh <- 0.1 # speed threshold in m/s
#' # run migration detection
#' get_migrations(eel_amber,
#'                dist_threshold = dist_thresh,
#'                speed_threshold = speed_thresh)
get_migrations <- function(df,
                           dist_threshold,
                           speed_threshold) {

  ## check inputs
  # df is a data.frame. Notice that msg argument with your own error message is
  # optional
  assertthat::assert_that(is.data.frame(df))
  # dist_threshold is a number
  assertthat::assert_that(is.numeric(dist_threshold))
  # speed_threshold is a number
  assertthat::assert_that(is.numeric(speed_threshold))
  # we make use of some columns in df. So, they need to be present in df
  assertthat::assert_that("totaldistance_m" %in% names(df),
                          msg = "Column `totaldistance_m` not found in df."
  )
  assertthat::assert_that("arrival" %in% names(df),
                          msg = "Column `arrival` not found in df."
  )
  assertthat::assert_that("departure" %in% names(df),
                          msg = "Column `departure` not found in df."
  )

  ## core function follows
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

## BONUS CHALLENGE

# notice the order of the assertions to fail as fastest as possible and
# precisely detect the bug
evenOdd_bonus <- function(n) {
  assertthat::assert_that(length(n) == 1,
                          msg = "n must be of length 1."
  )
  assertthat::assert_that(n >= 0,
                          msg = "n must be a non-negative number."
  )
  assertthat::assert_that(
    is.integer(n),
    msg = "n must be integer and <= `.Machine$integer.max`."
  )
  char_n <- as.character(n)
  counter_even <- 0
  counter_odd <- 0
  for (i in seq_len(nchar(char_n))) {
    digit <- as.integer(substr(char_n, i, i))
    if (digit %% 2 == 0) {
      counter_even <- counter_even + 1
    } else {
      counter_odd <- counter_odd + 1
    }
  }
  return(list(n_even = counter_even,
              n_odd = counter_odd))
}
