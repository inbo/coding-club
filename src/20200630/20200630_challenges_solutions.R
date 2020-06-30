## Challenge 1

# Compute the mean of every column in swiss
swiss
class(swiss)
str(swiss)

map(swiss, mean, na.rm = TRUE)

# Determine the type of each column in  iris
iris
class(iris)
str(iris)

map(iris, class)

# Set swiss and iris as a named list of two data.frames and get the number of
# rows of each data.frame
dfs <- list(swiss = swiss, iris = iris)
class(dfs)
str(dfs)

map(dfs, nrow)


# map() returns ALWAYS a list, ALWAYS. Apply the right map_*() variants to
# the previous exercises to return a numeric vector (1, 3) a character vector
# (2) or a data.frame (1, 2, 3)

map_dbl(swiss, mean, na.rm = TRUE)
map_chr(iris, class)
map_dbl(dfs, nrow)

map_dfr(swiss, mean, na.rm = TRUE)
map_dfr(iris, class)
map_dfr(dfs, nrow)


## Challenge 2

# Get 10 random numbers from a normal distribution (`rnorm(n = 10)`) for each of
# the mean values and return it as a list of 4:
means <- c(-10, 0, 10, 20)

map(means, ~rnorm(n = 10, mean = .x))
# OR longer but without ~ and .x pronoun
get_rnom_values <- function(mean_value) rnorm(n = 10, mean = mean_value)
map(means, get_rnom_values)

# Read sensor data

sensors <- list("A1" = "A1", "G7" = "G7", "H4" = "H4")
sensors

read_sensor_data <- function(sensor) {
  path <- paste0("./data/20200630/20200630_sensor_", sensor, ".txt")
  read_csv(path,
           na = "NA",
           col_types = cols(
             datetime = col_datetime(format = "%d/%m/%Y %H:%M:%S")
             )
  )
}

## SOLUTION
# Do it for one
sensor_df <- read_sensor_data("A1")
# Do it for all
sensor_dfs <- map(sensors, read_sensor_data)


# Get max and min datetime for all sensor data data.frame and return them as
# data.frame


## SOLUTION

# Define function
get_max_min_datetime <- function(sensor_df) {
  sensor_df %>%
    summarize(min_datetime = min(datetime),
              max_datetime = max(datetime)
    )
}

# Apply function
map_df(sensor_dfs, ~get_max_min_datetime(.x))


# Get 10 random numbers from normal distributions with these combinations of
# mean and standard deviations and returned it as a list of 4
means <- c(-10, 0, 10, 20)
st_dev <- c(1, 3, 2, 1.5)

## SOLUTION
# iterate over two vectors and use .y as second pronoun
map2(means, st_dev, ~rnorm(n = 10, mean = .x, sd = .y))
# or even easier
map2(means, st_dev, ~rnorm(n = 10))


## CHALLENGE 3

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

## SOLUTION

# define the plot function
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
  mutate(plot = map2(.x = data,
                     .y = species,
                     .f = ~plot_function(df = .x,
                                         species_name = .y)))

pd$plot

# Alternative: define the plot function on the fly. Less readable
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


## BONUS CHALLENGE

# Save the plots created in challenge 3 using species name and extension png.

## SOLUTION

walk2(.x = pd$plot,
      .y = pd$species,
      .f = function(x, y) {
        ggsave(filename = paste0(y, ".png"),
               plot = x,
               path = tempdir() # you can personalize the path
        )
      })

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

# Definitely not DRY and prone to errors! Try to do it DRY by using lists and
# purrr

## SOLUTION

# Make a list containing the 3 data.frames with species
species_list <- list(species_1, species_2, species_3)

# Use reduce function to apply full_join to all of them
species_df <- reduce(species_list, full_join)
# or spcifying the column to join by
species_df <- reduce(species_list, full_join, by = "species")
# or
species_df <- reduce(species_list, ~full_join(.x, .y, by = "species"))
