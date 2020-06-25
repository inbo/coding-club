library(tidyverse)
library(lubridate)

## Challenge 1

# Compute the mean of every column in swiss
swiss


# Determine the type of each column in  iris
iris


# Set swiss and iris as a named list of two data.frames and get the number of
# rows of each data.frame
dfs <- list(swiss = swiss, iris = iris)


# map() returns ALWAYS a list, ALWAYS. Apply the right map_*() variants to
# the previous exercises to return a numeric vector (1, 3) a character vector
# (2) or a data.frame



## Challenge 2

# Compute the number of unique values in each column of iris and return it as a
# a list



# Get 10 random numbers from a normal distribution (`rnorm(n = 10)`) for each of
# the mean values and return it as a list of 4:
means <- c(-10, 0, 10, 20)



# Read sensor data
sensors <- list("A1" = "A1", "G7" = "G7", "H4" = "H4")
sensors

read_sensor_data <- function(sensor) {
  path <- paste0("./data/20200630/data_sensor_", sensor, ".txt")
  read_csv(path,
           na = "NA",
           col_types = cols(
             datetime = col_datetime(format = "%d/%m/%Y %H:%M:%S")
             )
  )
}


# Get max and min datetime for all sensor data data.frame and return them as
# data.frame
# Use this code to DO IT for ONE. Generalize it to DO IT for ALL
sensor_df %>%
  summarize(min_datetime = min(datetime),
            max_datetime = max(datetime)
  )

## CHALLENGE 3

# Get 10 random numbers from normal distributions with these combinations of
# mean and standard deviations and returned it as a list of 4
means <- c(-10, 0, 10, 20)
st_dev <- c(1, 3, 2, 1.5)


# The datetime of the sensors don't contain the time zone information. Apply the
# following time zones by using lubridate function force_tz():
time_zones <- list("A1" = "EST", "G7" = "EET", "H4" = "MST")


# The sensors have been calibrated so you should apply these offsets to `pressure`:
offset <- list("A1" = -0.3, "G7" = 0.08, "H4" = 0.6)



## BONUS CHALLENGE

species_1 <- tibble(
  species = c("Balanus tintinnabulum",
              "Callinectes sapidus",
              "Mnemiopsis leidyi"),
  is_marine = c(TRUE, TRUE, TRUE)
)

species_2 <- tibble(
  species = c("Leuciscus aspius",
              "Rhithropanopeus harrisii",
              "Mnemiopsis leidyi"),
  genus = c("Leuciscus",
            "Rhithropanopeus",
            "Mnemiopsis leidyi")
)

species_3 <- tibble(
  species = c("Rhithropanopeus harrisii","Potamopyrgus antipodarum"),
  informal_group = c("mollusca", "mollusca")
)

# Not DRY solution (hardcoded)
full_join(species_1, species_2, by = "species") %>%
  full_join(species_3, by = "species")


# Definitely not DRY and prone to errors! Try to do it DRY by using lists and
# purrr.

