library(tidyverse)
library(lubridate)

# read data
persian_hogweed <- read_tsv("./data/20230126/20230126_persian_hogweed_2022_scandinavia.txt")


## CHALLENGE 1




## CHALLENGE 2

# Read deployments. ISO datetimes are immediately interpreted as datetimes
deployments <- readr::read_csv(
  "./data/20230126/20230126_deployments.txt",
  na = ""
)
deployments$start
deployments$end





## CHALLENGE 3





## BONUS CHALLENGES - strings





## BONUS CHALLENGES - dates


