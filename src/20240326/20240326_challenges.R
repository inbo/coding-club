library(tidyverse)
library(plotly)
library(scales)
library(patchwork)
library(ggforce)
library(gganimate)
library(magick)

# Read data
rodents <- readr::read_tsv(file = "./data/20240326/20240326_rodents.txt")

# Create basic plots we will work with

plot1 <- ggplot(rodents) +
  geom_bar(aes(x = year, fill = institutionCode)) +
  labs(y = "observations")
plot1

plot2 <- ggplot(rodents) +
  geom_bar(mapping = aes(x = month, fill = species)) +
  facet_wrap(~species, scales = "free") +
  labs(y = "observations")
plot2


rodents_n_2000 <- rodents %>%
  dplyr::filter(year >= 2000) %>%
  dplyr::group_by(species,year, month) %>%
  dplyr::count() %>%
  mutate(date = make_date(year, month, 1))

plot3 <- ggplot(data = rodents_n_2000,
                mapping = aes(x = date, y = n, color = species)) +
  geom_line() +
  facet_wrap(~species, scales = "free") +
  labs(y = "observations")
plot3

plot4 <- ggplot(rodents %>%
                  filter(!is.na(decimalLatitude),
                         !is.na(decimalLongitude))) +
  geom_point(mapping = aes(x = decimalLongitude,
                           y = decimalLatitude,
                           color = species)) +
  labs(x = "latitude",
       y = "longitude")
plot4


## CHALLENGE 1: interactivity and scales




## CHALLENGE 2: patchwork and ggforce




## CHALLENGE 3: animations



## BONUS CHALLENGE: add logo to plot

logo_file <- "./data/20240326/coding_club_logo_1.png"

