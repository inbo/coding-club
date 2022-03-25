library(tidyverse)

## CHALLENGE 1 & 2

#' no R needed


## CHALLENGE 3.1

# read data
habitats_raw <- read_csv("./data/20220329/20220329_habitat_types.txt")



## CHALLENGE 3.2

# read data
habitats2_raw <- read_csv("./data/20220329/20220329_habitat_types_2.txt")



## CHALLENGE 3.3

#' Do you get warnings?
#' Sure, the number of columns is not constant: data are NOT TIDY!
camtrap_data <- read_csv("./data/20220329/20220329_camtrap_data.txt",
                         col_names = paste0("V",seq_len(21)))

camtrap_data




## BONUS CHALLENGE

rings <- read_csv("./data/20220329/20220329_bird_rings_untidy.txt")

rings
