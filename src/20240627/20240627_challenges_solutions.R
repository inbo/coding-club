library(tidyverse)


## CHALLENGE 1

# 1.1
swiss
# Check class
class(swiss)
# Check structure
str(swiss)

purrr::map(swiss, mean, na.rm = TRUE)


# 1.2
iris
# Check class
class(iris)
# Check structure
str(iris)


purrr::map(iris, class)


# 1.3
list_with_dfs <- list(swiss = swiss, iris = iris)
# Check class
class(list_with_dfs)
# Check structure
str(list_with_dfs)


purrr::map(list_with_dfs, nrow)


# 1.4

map_dbl(swiss, mean, na.rm = TRUE)
map_chr(iris, class)
map_dbl(list_with_dfs, nrow)

map_df(swiss, mean, na.rm = TRUE)
map_df(iris, class)
map_df(list_with_dfs, nrow)


## Challenge 2

# 2.1

# Define the list with the sensor IDs
sensors <- list("A1", "G7", "H4")
names(sensors) <- sensors

#' Function to read a comma separated sensor data file.
#'
#' @param sensor character. A sensor ID.
#' @return A tibble data.frame as returned by `readr::read_csv()`.
#' @examples
#' # example code
#' library(readr)
#' read_sensor_data(sensor = "H4")
read_sensor_data <- function(
    sensor) {
  path <- paste0("./data/20240627/20240627_sensor_", sensor, ".txt")
  readr::read_csv(path,
                  na = "NA",
                  col_types = cols(
                    datetime = col_datetime(format = "%d/%m/%Y %H:%M:%S")
                  )
  )
}

# Apply function to one sensor ID as check.
sensor_df <- read_sensor_data(sensor = "A1")

# Do it for all. Notice that the output list has same names as the input list.
sensor_dfs <- map(sensors, read_sensor_data)
sensor_dfs

# Alternatives
sensor_dfs <- map(sensors, function(x) read_sensor_data(x))
sensor_dfs

sensor_dfs <- map(sensors, \(x) read_sensor_data(x))
sensor_dfs

sensor_dfs <- map(sensors, ~ read_sensor_data(.x))
sensor_dfs


# 2.2

#' Function to read a comma separated sensor data file.
#'
#' @param sensor character. A sensor ID.
#' @param path_pattern character. The path common to all sensor files.
#' @param extension character. The file extension starting with `.`.
#' @return A tibble data.frame as returned by `readr::read_csv()`.
#' @examples
#' path_pattern_datafiles <- "./data/20240627/20240627_sensor_"
#' file_extension <- ".txt"
#' read_sensor_data(sensor = "H4", path_pattern_datafiles, file_extension)
read_sensor_data <- function(
    sensor,
    path_pattern,
    extension) {
  path <- paste0(path_pattern, sensor, extension)
  readr::read_csv(path,
                  na = "NA",
                  col_types = cols(
                    datetime = col_datetime(format = "%d/%m/%Y %H:%M:%S")
                  )
  )
}

# If data files are setup where they should be, here the path_pattern and
# extension to use. Same as in @example above the function.
path_pattern_datafiles <- "./data/20240627/20240627_sensor_"
file_extension <- ".txt"

# Apply function to one sensor ID as check.
sensor_df <- read_sensor_data(sensor = "A1",
                              path_pattern = path_pattern_datafiles,
                              extension = file_extension
)

# Notice that the used `path_pattern value` and `file_extension` are constants for all sensor IDs.
# Constants can be defined after the function call.
sensor_dfs <- map(
  sensors,
  read_sensor_data,
  path_pattern = path_pattern_datafiles,
  extension = file_extension
)

# Without argument names is less readable but still works.
sensor_dfs <- map(
  sensors,
  read_sensor_data,
  path_pattern_datafiles,
  file_extension
)
sensor_dfs

# Notice you can use the pipe (%>%) as well.
sensor_dfs <- sensors %>%
  map(read_sensor_data,
      path_pattern = path_pattern_datafiles,
      extension = file_extension
)
sensor_dfs


# 2.3

# Define means and standard deviations
means <- c(-10, 0, 10, 20)
st_dev <- c(1, 3, 2, 1.5)

# Iterate over the two vectors via `map2()`.
map2(means, st_dev, ~ rnorm(n = 10))
# identical, but more verbose. Notice that . cannot be used anymore as we have two inputs.
map2(means, st_dev, ~rnorm(n = 10, mean = .x, sd = .y))


# 2.4

# Define function
get_max_min_datetime <- function(sensor_df) {
  sensor_df %>%
    summarize(min_datetime = min(datetime),
              max_datetime = max(datetime)
    )
}

# Apply function `get_max_min_datetime()` to all dataframes of the list
# `sensor_dfs`.
map_df(sensor_dfs, get_max_min_datetime)


## CHALLENGE 3A

# Load lepidoptera_in_prot_areas
lepidoptera_in_prot_areas <- readRDS("./data/20240627/20240627_lepidoptera_in_prot_areas.RData")
lepidoptera_in_prot_areas
# It's a kind of "special" list, but still a list! So, you can apply all purrr
# functions to it.
class(lepidoptera_in_prot_areas)


# 3.1

# purrr::map_dbl() can help us to get the number of obs in each protected area
purrr::map_dbl(
  lepidoptera_in_prot_areas,
  function(x) length(x)
)

# Again you can opt for alternative "styles", for example using ~ and .
purrr::map_dbl(lepidoptera_in_prot_areas, ~ length(.))

# Or ~ and .x
purrr::map_dbl(lepidoptera_in_prot_areas, ~ length(.x))

# Or the "new" way of writing anonymous functions (R 4.0 or higher)
purrr::map_dbl(lepidoptera_in_prot_areas, \(x) length(x))


# 3.2

obs <- readr::read_tsv("./data/20240627/20240627_lepidoptera_2024.tsv", na = "")
str(obs)

obs_in_prot_areas <- map_df(lepidoptera_in_prot_areas, function(x) dplyr::slice(obs, x))
obs_in_prot_areas

# 3.3

# Species data.frames
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



# Make a list containing the 3 data.frames with species
species_list <- list(species_1, species_2, species_3)

# Use reduce function to apply full_join to all of them
species_df <- reduce(species_list, full_join)
# Or specifying the column to join by
species_df <- reduce(species_list, full_join, by = "species")
# Use "alternative" style with ~ and .x, .y
species_df <- reduce(species_list, ~full_join(.x, .y, by = "species"))
# Use "new" way (R 4.0 or higher)
species_df <- reduce(species_list, \(x, y) full_join(x, y, by = "species"))


## Challenge 3B

# Height of 5 giraffes
height_giraffe <- runif(n = 6, min = 4.3, max = 5.7)
# Weight of 5 giraffes
weight_giraffe <- rnorm(n = 6, mean = 1192, sd = 300)
# GPS tracker ID
gps_tracker_giraffe <- c("A31", "E4T", "RT4", "YU7", "3G1", "ON9")
# Data.frame with weight, height and GPS tracker IDs.
df <- tibble::tibble(
  "weight" = weight_giraffe,
  "height" = height_giraffe,
  "gpsID" = gps_tracker_giraffe
)


# 3B.1

df %>%
  mutate(across(where(is.numeric), floor))


# 3B.2

df %>%
  mutate(across(ends_with("ight"), floor))


# 3B.3

df %>%
  mutate(across(where(is.numeric),
                .fns = list(floored = floor),
                .names = "{.col}_floored"))


df %>%
  mutate(across(ends_with("ight"),
                .fns = list(floored = floor),
                .names = "{.col}_floored"))



## BONUS CHALLENGE

library(palmerpenguins) # Install it first if not yet done.
# Load `penguins` dataset
data(package = 'palmerpenguins')

# Group `penguins` data.frame by species and nest it as shown below:
penguins %>%
  group_by(species) %>%
  nest()

# Notice the column `data` containing data.frames (a "list" column)

# Add a column called  `plot` containing ggplot objects based on the geometry
# and aesthetics below:
geom_point(aes(x = bill_length_mm ,
               y = bill_depth_mm,
               colour = sex))


# BC.1

#' Define the plot function
#'
#' @param df Data.frame containing the data
#' @param species_name Character. Name of the species.
#' @return ggplot object
#' @examples
#' adelie <- penguins %>% filter(species == "Adelie")
#' plot_function(adelie, "Adelie")
plot_function <- function(df, species_name){
  df %>%
    ggplot() +
    geom_point(aes(x = bill_length_mm ,
                   y = bill_depth_mm,
                   colour = sex)) +
    ggtitle(label = species_name)
}

# Apply the plot function to all groups
pd <- penguins %>%
  group_by(species) %>%
  nest() %>%
  mutate(plot = map2(
    .x = data,
    .y = species,
    .f = function(df, sp) plot_function(df = df, species_name = sp)
    )
  )

# 3 plots generated
pd$plot[[1]]
pd$plot[[2]]
pd$plot[[3]]

# Alternative: without mutate() and using alternative syntax with shortcuts
pd$plot <- map2(.x = pd$data,
                .y = pd$species,
                \(df, sp) plot_function(df = df, species_name = sp))



# Alternative: define the plot function "on the fly". Less readable
pd <- penguins %>%
  group_by(species) %>%
  nest() %>%
  mutate(plot = map2(.x = data,
                     .y = species,
                     .f = function(df, species_name){
                       df %>%
                         ggplot() +
                         geom_point(aes(x = bill_length_mm ,
                                        y = bill_depth_mm,
                                        colour = sex)) +
                         ggtitle(label = species_name)
                     }))



# BC.2

walk2(.x = pd$plot,
      .y = pd$species,
      .f = function(x, y) {
        ggsave(filename = paste0(y, ".png"),
               plot = x,
               path = tempdir() # You can personalize the path
        )
      })
