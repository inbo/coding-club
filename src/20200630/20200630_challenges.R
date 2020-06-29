## Challenge 1

# Compute the mean of every column in swiss
swiss
class(swiss)
str(swiss)



# Determine the type of each column in  iris
iris
class(iris)
str(iris)



# Set swiss and iris as a named list of two data.frames and get the number of
# rows of each data.frame
dfs <- list(swiss = swiss, iris = iris)
class(dfs)
str(dfs)



# map() returns ALWAYS a list, ALWAYS. Apply the right map_*() variants to
# the previous exercises to return a numeric vector (1, 3) a character vector
# (2) or a data.frame (1, 2, 3)



## Challenge 2

# Get 10 random numbers from a normal distribution (`rnorm(n = 10)`) for each of
# the mean values and return it as a list of 4:
means <- c(-10, 0, 10, 20)



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



# Get max and min datetime for all sensor data data.frame and return them as
# data.frame. Hint: write a function containing
# summarize(df, minimum = min(datetime), maximum = max(datetime))



# Get 10 random numbers from normal distributions with these combinations of
# mean and standard deviations and returned it as a list of 4
means <- c(-10, 0, 10, 20)
st_dev <- c(1, 3, 2, 1.5)



## CHALLENGE 3

# Group `penguins` data.frame by species and nest it as shown below:

penguins %>%
  group_by(species) %>%
  nest()

# Add a column called  `plot` containing ggplot objects based on the geometry
# and aesthetics below:

geom_point(aes(x = bill_length_mm ,
               y = bill_depth_mm,
               colour = sex))



## BONUS CHALLENGE

# 1. Save the plots created in challenge 3 using species name and extension png.




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


