library(tidyverse)

## CHALLENGE 1 & 2

#' no R needed



## CHALLENGE 3

#' Do you get warnings?
#' Sure, the number of columns is not constant: data are NOT TIDY!
camtrap_data <- read_csv("./data/20210330/20210330_camtrap_data.csv",
                         col_names = paste0("V",seq_len(21)))

camtrap_data




## BONUS CHALLENGE

rings <- read_csv("./data/20210330/20210330_bird_rings_untidy.csv")

rings


