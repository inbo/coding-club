## Computer says no

## function 'sum' ----
wont_work <- c('a', 'b', 'c')
sum(wont_work)

will_work <- 1:10
sum(will_work)


## function 'multiply' ----
wont_work <- 'a'
wont_work * 2

will_work <- 5
will_work * 2


## functions to change columns inside dplyr ----

library(readr)
library(tidyverse)

rainfall <- read_csv("../data/20180123/20180123_rainfall_klemskerke_clean.csv")

rainfall %>%
    mutate(take_half_wont_work = datetime/2.)
rainfall %>%
    mutate(take_half_will_work = value/2.)

rainfall %>%
    mutate(take_year_wont_work = lubridate::year(value))
rainfall %>%
    mutate(take_year_wont_work = lubridate::year(datetime))


## predictions ----

wont_work <- predict(cars)

linearMod <- lm(dist ~ speed, data = cars)
will_work <- predict(linearMod)


