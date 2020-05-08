library(tidyverse)
library(INBOtheme)

# read survey data
survey <- read_csv("./data/20191219/20191219_survey_cleaned.csv")
# remove records without weight or hindfoot length
survey <- survey %>%
  filter(!is.na(weight) & !is.na(hindfoot_length) & !is.na(sex))

# read fit data
fit_results <- read_csv("./data/20191219/20191219_gam_fit_results.csv",
                        na = "")

## CHALLENGE 1



## CHALLENGE 2
# Hint: use egg or cowplot
# install.packages("egg")
# install.packages("cowplot")

fit_results_sum <-
  fit_results %>%
  group_by(year) %>%
  summarize(obs = sum(obs, na.rm = TRUE))

# Use fit_results_sum for new plot


## INTERMEZZO
# Play a little with dark themes
install.packages("ggdark")
library(ggdark)



## CHALLENGE 3
install.packages("lubridate")
install.packages("magick")
install.packages("gifski") # no need to load it, only needed for gganimate
install.packages("gganimate")

library(lubridate)
library(magick)
library(gganimate)

# Option 1
link <- "https://github.com/inbo/coding-club/raw/master/docs/assets/images/20191219/20191219_logo_gbif.png"



# Option 2

# Basic version to improve
ggplot(survey) +
  geom_point(aes(weight, hindfoot_length, color = sex),
             alpha = 0.3) +
  facet_wrap(~year)

# preparing survey data to follow the hint...
survey_timestamp <-
  survey %>%
  mutate(timestamp = ymd(paste(year, month, day, sep = "-")))

static_plot <-
  ggplot(survey_timestamp) +
  geom_point(aes(weight, hindfoot_length, color = sex),
             alpha = 0.3)
# now it's up to you to add animation with gganimate!
