library(tidyverse)


## CHALLENGE 1

# Read dataset about year of first observation of IAS in Belgium from 1950.
ias_be <- read_tsv(
  file = "./data/20230330/20230330_ias_first_observed_BE.txt",
  na = ""
)







## Challenge 2

# IAS data at regional level
ias_regions <- read_tsv(
  "./data/20230330/20230330_ias_first_observed_regions.txt",
  na = ""
)







## CHALLENGE 3: Categorical variables

ias_path <- read_tsv("./data/20230330/20230330_ias_pathways.txt", na = "")



# code for the 2nd exercise
bin <- 10
ias_path <-
  ias_path %>%
  mutate(
    bins_first_observed_label =
      floor(.data$first_observed / bin) * bin
  ) %>%
  mutate(bins_first_observed_label = paste(
    as.character(.data$bins_first_observed_label),
    "-",
    as.character(.data$bins_first_observed_label + bin - 1)
  ))





