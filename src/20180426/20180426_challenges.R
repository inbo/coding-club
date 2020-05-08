
library(tidyverse)
library(lubridate)

# Intro/recap

surveys <- read_csv("../data/20180222/20180222_surveys.csv") %>%
    slice(1:10)
species <- read_csv("../data/20180222/20180222_species.csv")

# left join - "adding information from other table"
surveys_joined <- left_join(surveys, species, by = "species_id")

# left vs right join
left_join(surveys, species, by = "species_id")
right_join(species, surveys, by = "species_id")

# left join in one direction is not the same as in the other
left_join(species, surveys, by = "species_id")
left_join(surveys, species, by = "species_id")

# inner join - only were info of both is available
inner_join(surveys, species, by = "species_id")
# cfr with left_join(surveys, species, by = "species_id") %>% drop_na(genus, species, taxa)

# show result full join in View()
temp <- full_join(surveys, species, by = "species_id")

# 'what can not be merged/matched?' -> ANTI-join
anti_join(surveys, species, by = "species_id")

# specialleke -  wat matcht van x, zonder y eraan te plakken
# aka 'wat zou ik kunnen matchen?'
semi_join(species, surveys, by = "species_id")
# cfr with inner_join(species, surveys, by = "species_id") # entry per match

# ------------------------------
#  Read and write datetimes
# ------------------------------

# which day of the week is August 2nd, 2018 14:00?

my_date <- "August 2nd, 2018 14:00"
wday(mdy_hm(my_date), label = TRUE)

# From three separate colums to a date column
surveys <- read_csv("../data/20180222/20180222_surveys.csv")

surveys %>%
    mutate(date = str_c(year, month, day, sep = "-")) %>%
    mutate(date = ymd(date))

# ------------------------------
#  Fish data
# ------------------------------

fish <- read_csv("../data/20180426/20180426_visdata_cleaned.csv")

fish %>%
    mutate(meetpuntomschrijving = str_to_lower(meetpuntomschrijving)) %>%
    filter(str_detect(soort, "garnaal|krab|kreeft")) %>%
    mutate(soort = str_replace_all(soort, "_", " ")) %>%
    mutate(description = glue::glue("{totaal_gewicht} g {soort} bij {meetpuntomschrijving} op {datum}"))


# ------------------------------
#  Survey_data
# ------------------------------

grofwild_logs <- read_delim("../data/20180316/20180316_grofwild_logs.csv", delim = " ")

# number of visits for each hour of the day
hour_counts <- grofwild_logs %>%
    filter(type == "AppStart") %>%
    mutate(hour = lubridate::hour(time)) %>%
    group_by(hour) %>%
    count()

# make sure we have hours for each day
hour_counts <- tibble(hour = 0:23) %>%
    left_join(hour_counts) %>%
    replace_na(list(n = 0))

ggplot(hour_counts, aes(factor(hour), n)) +
    geom_bar(stat = 'identity') +
    ylab("visitors") +
    xlab("Hour of the day")


# Note about date_breaks
# ---------------------

# daily number of app starts - the lubridate::pretty_dates TIP!

ggplot(grofwild_logs, aes(lubridate::floor_date(time, "day"))) +
    geom_line(stat = 'count') +
    ylab("visitors") + xlab("") +
    scale_x_datetime(date_labels = "%y-%m-%d",
                     date_breaks = "3 days")

ggplot(grofwild_logs, aes(lubridate::floor_date(time, "day"))) +
    geom_line(stat = 'count') +
    ylab("visitors") + xlab("") +
    scale_x_datetime(breaks = lubridate::pretty_dates(grofwild_logs$time,
                                                      n = 3))
# pretty_dates docs: ...to provide approximately n breaks!

