
library(tidyverse)

# ------------------------------
#  Survey_data
# ------------------------------
survey <- readr::read_csv2("../data/20180222_survey_data_spreadsheet_tidy.csv")

# Show min, max, mean weight per sex
survey %>%
    group_by(species, sex) %>%
    filter(!is.na(weight_in_g)) %>%
    summarise(mean = mean(weight_in_g),
              min = min(weight_in_g),
              max = max(weight_in_g)) -> weight_per_species_sex

# mutate/rename exercise
data_kg_US <- survey %>%
    rename(weight = weight_in_g) %>%
    mutate(weight = weight/1000.) %>%
    mutate(country = 'US')

# ------------------------------
#  Brandganzen
# ------------------------------
library(readxl)
library(janitor)
brandganzen <- read_excel("../data/20180123_brandganzen.xlsx")
brandganzen <- brandganzen %>%
    remove_empty_rows() %>%
    clean_names()

# column 'Ringnummer' for the adult male geese from Destelbergen
brandganzen %>%
    filter(locatie_vangst == "DESTELBERGEN",
           geslacht == "Man",
           leeftijdscategorie == "Adult") %>%
    select(ringnummer)

# How many adult geese per sex can you count?
brandganzen %>%
    filter(leeftijdscategorie == "Adult") %>%
    filter(!is.na(geslacht)) %>%
    group_by(geslacht) %>%
    count()

# How many different catching methods were used in each location?
brandganzen %>%
    group_by(locatie_vangst) %>%
    summarise(n_methods = n_distinct(vangtype))

# ------------------------------
#  Bevolkingsevolutie Gent
# ------------------------------

bevolking <- readr::read_delim("./data/20180123_gent_groeiperwijk.csv",
                               delim = ";")
tidy_bevolking <- bevolking %>%
    gather(key = "year", value = "growth", -wijk) %>%
    separate(year, into = c("dummy", "year")) %>%
    mutate(year = parse_integer(year)) %>%
    select(-dummy)

# ------------------------------
#  Surveys/species
# ------------------------------

surveys <- read_csv("./data/20180222_surveys.csv")
species <- read_csv("./data/20180222_species.csv")

surveys_joined <- left_join(surveys, species, by = "species_id")

# ------------------------------
# cameratrap images
# ------------------------------
cameratrap <- read_csv("./data/20180123_observations_NPHK_cameratrapping.csv")

# human observations in each month
cameratrap %>%
    filter(animalVernacularName == "Human") %>%
    group_by(sequenceMonth) %>%
    summarize(humans_observed = sum(animalCount))

# add an additional column wih the counts per animal/sampling point combination
cameratrap %>%
    select(sequenceDay, sequenceMonth, sequenceYear, deploymentSamplingPoint,
           animalVernacularName, animalCount) %>%
    group_by(deploymentSamplingPoint, animalVernacularName) %>%
    mutate(point_animal_counts = sum(animalCount)) %>%
    arrange(animalVernacularName)

# ------------------------------
# Stierkikker
# ------------------------------

stierkikker <- read_csv("./data/20180123_stierkikker_formulieren_reacties.csv")
animal <- "blankvoorn"
stierkikker %>%
    select(contains(animal, ignore.case = TRUE)) %>%
    filter(rowMeans(is.na(.)) < 1)

# ------------------------------
# yearly rainfall sum
# ------------------------------

klemskerke <- read_csv("./data/20180123_rainfall_klemskerke_clean.csv")

year_sum <- klemskerke %>%
    filter(datetime >= as.Date("2012-01-01") &
               datetime < as.Date("2017-01-01")) %>%
    group_by(year = lubridate::floor_date(datetime, "year")) %>%
    summarize(value = sum(value))



