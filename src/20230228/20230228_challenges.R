library(tidyverse)

## Read data

partridge <- read_csv("./data/20230228/20230228_partridge.txt", na = "")

# Preview of the data.frame structure
str(partridge)

## CHALLENGE 1





## CHALLENGE 2 - Summaries




## CHALLENGE 3 - Two-table verbs

# read the game management units details
WBE <- read_csv("./data/20230228/20230228_wbe_info.txt", na = "")



## BONUS CHALLENGE - Create tidy data with tidyr

ias <- read_csv("./data/20230228/20230228_ias_plants.txt", na = "")
head(ias)

