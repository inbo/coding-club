library(tidyverse)

# read data
survey <- read_csv("./data/20180222_surveys.csv")
# remove records without weight or hindfoot length
survey <- survey %>%
  filter(!is.na(weight) & !is.na(hindfoot_length) & !is.na(sex))

## CHALLENGE 1


# Plot the hindfoot_length as function of weight using points


# Plot the weight as function of species using boxplot


# Replace the box plot with a violin plot


# How many surveys per gender? Show it as bar plot


# How many surveys per year? Show it as bar plot


### CHALLENGE 2

# First plot
# - Use `sex` as color
# - Adjust the transparency (alpha) of the points to 0.5
# - Change the y label to "hindfoot length"
# - Add a title to the graph, e.g. "hindfoot length vs weight"
# - Use a logarithmic scale for the x-axis
# - Set points' colors to "red" for females and "yellow" for males

ggplot(data = survey, mapping = aes(x = weight,
                                    y = hindfoot_length)) +
  geom_point()


# Second plot
# - Split bars into `sex`
# - Arrange bars for `F` and `M` side by side
# - Adjust the transparency of the bar to 0.5
# - Change the y label to "number of surveys"
# - Add a title to the graph, e.g. "Number of surveys per year"
# - Flip x and y-axis

ggplot(data = survey, mapping = aes(x = year)) +
  geom_bar()


## CHALLENGE 3

# Read iNaturalist obseration in and around Brussels from 2019
inat_bxl <- read_tsv("./data/20191126_BXL_iNaturalist_top20.csv",
                     na =  "")

# Plot the number of observations per species and year.
# Make the best plot ever!
