library(tidyverse)

## CHALLENGE 1 & 2

#' no R needed



## CHALLENGE 3

#' note you cannot use tidyverse function read_csv(), as fill argument is not
#' provided. Use standard read.csv() instead
camtrap_data <- read.csv("./data/20210330/20210330_camtrap_data.csv",
                         header = FALSE,
                         fill = TRUE,
                         col.names = paste0("V",seq_len(21)),
                         stringsAsFactors = FALSE)

# make camtrap_data a tibble  (= read-friendly data.frame)
camtrap_data <- as_tibble(camtrap_data )

camtrap_data




## BONUS CHALLENGE

rings <- read_csv("./data/20210330/20210330_bird_rings_untidy.csv")

rings


