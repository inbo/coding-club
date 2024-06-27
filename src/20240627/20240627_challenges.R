library(tidyverse)


## CHALLENGE 1



# 1.3
list_with_dfs <- list(swiss = swiss, iris = iris)
names(list_with_dfs)




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
    sensor,
    path_pattern,
    extension) {
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




# 2.2

#' Function to read a comma separated sensor data file.
#'
#' @param sensor character. A sensor ID.
#' @param path_pattern character. The path common to all sensor files.
#' @param extension character. The file extension starting with `.`.
#' @return A tibble data.frame as returned by `readr::read_csv()`.
#' @examples
#' # example code
#' library(readr)
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

# If data files are where they should be, here the path_pattern and
# extension to use. Just copied from the @example above the function.
path_pattern_datafiles <- "./data/20240627/20240627_sensor_"
file_extension <- ".txt"

# Apply function to one sensor ID as check.
sensor_df <- read_sensor_data(sensor = "A1",
                              path_pattern = path_pattern_datafiles,
                              extension = file_extension
)



# 2.3

# Define means and standard deviations
means <- c(-10, 0, 10, 20)
st_dev <- c(1, 3, 2, 1.5)




# 2.4





## CHALLENGE 3A

# Load lepidoptera_in_prot_areas
lepidoptera_in_prot_areas <- readRDS("./data/20240627/20240627_lepidoptera_in_prot_areas.RData")
lepidoptera_in_prot_areas
# It's a kind of "special" list, but still a list! So, you can apply all purrr
# functions to it.
class(lepidoptera_in_prot_areas)


# 3.1




# 3.2

obs <- readr::read_tsv("./data/20240627/20240627_lepidoptera_2024.tsv", na = "")
str(obs)




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



# 3B.2



# 3B.3





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




# BC.2




