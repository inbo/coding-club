library(tidyverse)
library(rgbif)

# Load data ####

butterflies_eu <- readr::read_csv(
  file = "data/20250130/20250130_butterflies_eu.csv",
  na = ""
)

butterflies_eu_distr_all <- readr::read_csv(
  file = "data/20250130/20250130_butterflies_eu_distributions.csv",
  na = ""
)

butterflies_eu_vern_dutch <- readr::read_csv(
  file = "data/20250130/20250130_butterflies_eu_vernacularnames_dutch_all_GBIF.csv",
  guess_max = 1000
)

transect_counts <- readr::read_csv(
  "data/20250130/20250130_transect_counts.csv",
  na = ""
)

# CHALLENGE 1 - basics #####

## 1 ####
unique(butterflies_eu_distr_all$threatStatus)
dplyr::distinct(butterflies_eu_distr_all, threatStatus)

## 2 ####
butterflies_eu_distr <- dplyr::filter(
  butterflies_eu_distr_all,
  !is.na(country)
)

## 3 ####
dplyr::count(butterflies_eu_distr, threatStatus)

# Or via pipe
butterflies_eu_distr %>% dplyr::count(threatStatus)

# If you want to count the UNIQUE values of taxonKey
butterflies_eu_distr %>%
  group_by(threatStatus) %>%
  distinct(taxonKey) %>%
  count()


## 4 ####
butterflies_eu_distr %>%
  dplyr::count(country, threatStatus)


## 5 ####
dplyr::count(butterflies_eu_distr, threatStatus, country) %>%
  dplyr::arrange(country, desc(n))

## 6 ####
butterflies_eu_distr <- butterflies_eu_distr %>%
  dplyr::select(!c(source, remarks))

## 7 ####
butterflies_eu_distr <- butterflies_eu_distr %>%
  dplyr::relocate(country, .before = locality) %>%
  dplyr::relocate(threatStatus, .after = locationId)

## 8 ####
butterflies_eu_distr <- butterflies_eu_distr %>%
  dplyr::select(-dplyr::any_of(c("source", "remarks"))
)



# CHALLENGE 2 - To join or not to join 🦋  #####

## 1 ####

taxonKey_in_be <- butterflies_eu_distr %>%
  filter(country == "BE") %>%
  dplyr::distinct(taxonKey) %>%
  dplyr::pull(taxonKey)

butterflies_be <- butterflies_eu %>%
  filter(key %in% taxonKey_in_be)

## 2 ####

butterflies_eu_distr %>%
  dplyr::group_by(country) %>%
  dplyr::summarise(test = sum(!is.na(threatStatus))) %>%
  dplyr::filter(test == 0) %>%
  # remove helper column
  dplyr::distinct(country)

# Alternative solution via `add_count()`
butterflies_eu_distr %>%
  dplyr::distinct(country, threatStatus) %>%
  dplyr::add_count(country) %>%
  dplyr::filter(n == 1 & is.na(threatStatus)) %>%
  dplyr::distinct(country) %>%
  # Not mandatory step to get exactly same order as previous solution
  dplyr::arrange(country)


## 3 ####
transect_counts_with_scn <- transect_counts %>%
  dplyr::mutate(species_lower = stringr::str_to_lower(species)) %>%
  dplyr::left_join(
    butterflies_eu_vern_dutch %>%
      dplyr::mutate(vernacularName_lower = stringr::str_to_lower(vernacularName)) %>%
      dplyr::distinct(vernacularName_lower, taxonKey),
    by = c("species_lower" = "vernacularName_lower")) %>%
  dplyr::left_join(butterflies_be %>%
                     dplyr::select(scientificName, nubKey),
                   by = c("taxonKey" = "nubKey")) %>%
  dplyr::select(-species_lower)


## INTERMEZZO: rgbif + purrr = 💪

# It's almost impossible to do data wrangling with tidyverse without using purrr. purrr is a package from tidyverse ecosystem. It allows you to write code in a more functional style, which can be more readable and maintainable. rgbif is an R package to interface with the Global Biodiversity Information Facility (GBIF) API. It allows you to search for species, download occurrence data, and more. purrr and rgbif can be combined to make powerful and flexible workflows for working with biodiversity data. Here are some examples of how you can use purrr and rgbif together to get vernacular names.

# The "National checklists and red lists for European butterflies" dataset contains only vernacular names in English. Just check it via:

purrr::map(
  butterflies_eu$key, function(x) {
    rgbif::name_usage(key = x, data = "vernacularNames") %>%
      purrr::pluck("data")
  }) %>%
  purrr::list_rbind() %>%
  dplyr::distinct(language)

# We are interested in the Dutch vernacular names. How to get them? Let's do it by using the GBIF Taxonomic Backbone! The field `nubKey` in `butterflies_eu` contains the key of the taxon in the GBIF Taxonomic Backbone. We can use it to get the Dutch vernacular names of the Belgian butterflies:

butterflies_eu_vern_dutch <- purrr::map(
  butterflies_eu$nubKey, function(x) {
    rgbif::name_usage(key = x, data = "vernacularNames") %>%
      purrr::pluck("data")
  }) %>%
  purrr::list_rbind() %>%
  dplyr::filter(language == "nld")

# `butterflies_eu_vern_dutch` is actually the data.frame in `20250130_butterflies_eu_vern_dutch.csv`.

# Curious about purrr? Check the INBO coding club session of [Jun 27, 2024](https://coding-club.inbo.be/sessions/20240627_functional_programming_in_r.html#1).


# CHALLENGE 3 - So many names, so little time 🦋

## 1 ####
butterflies_eu_vern_dutch %>%
  dplyr::count(taxonKey, vernacularName) %>%
  dplyr::count(taxonKey)

## 2 ####
butterflies_eu_vern_dutch %>%
  dplyr::mutate(vernacularName_lower = stringr::str_to_lower(vernacularName)) %>%
  dplyr::count(taxonKey, vernacularName_lower) %>%
  dplyr::count(taxonKey) %>%
  dplyr::arrange(desc(n))

## 3 ####
butterflies_eu_vern_dutch %>%
  dplyr::mutate(vernacularName_lower = stringr::str_to_lower(vernacularName)) %>%
  dplyr::count(taxonKey, vernacularName_lower) %>%
  dplyr::add_count(taxonKey) %>%
  dplyr::select(-n) %>%
  dplyr::rename(n_names = nn) %>%
  dplyr::arrange(desc(n_names))



# BONUS CHALLENGE 1 ####

# Step 1: the preferred vernacular names
preferred_vns <- butterflies_eu_vern_dutch %>%
  dplyr::filter(preferred == TRUE) %>%
  dplyr::distinct(taxonKey, vernacularName)
# Step 2: select the first vernacular name if there is no preferred one
no_preferred_vns <- butterflies_eu_vern_dutch %>%
  dplyr::filter(!taxonKey %in% preferred_vns$taxonKey) %>%
  dplyr::group_by(taxonKey) %>%
  dplyr::slice(1)
# Step 3: bind the results
butterflies_eu_vern_dutch_preferred <- dplyr::bind_rows(
  preferred_vns, no_preferred_vns) %>%
  dplyr::arrange(taxonKey)

# Check we did everything correctly by comparing the number of rows in `butterflies_eu_vern_dutch_preferred` and the number of unique taxonKeys in `butterflies_eu_vern_dutch`
nrow(butterflies_eu_vern_dutch_preferred) ==
  length(unique(butterflies_eu_vern_dutch$taxonKey))


## BONUS CHALLENGE 2

library(readxl)

counts_raw <- readxl::read_excel(
  path = "data/20250130/20250130_butterfly_transect_counts_raw.xls",
  skip = 4,
  .name_repair = "universal"
)
head(counts_raw)

counts_raw <- counts_raw %>%
  dplyr::rename(species = NAAM...1) %>%
  dplyr::select(species:O27)
head(counts_raw)

counts <- counts_raw %>%
  tidyr::pivot_longer(cols = !species,
               names_to = "section",
               values_to = "n") %>%
  dplyr::filter(!is.na(n)) %>%
  dplyr::filter(!is.na(species))

# Create an event data.frame with info about:
# - location
# - start and end of the count
# - wind
# - temperature
# - cloudiness

# First, we need to extract the location from the Excel file
location_raw <- names(
  readxl::read_excel(
  path = "data/20250130/20250130_butterfly_transect_counts_raw.xls",
  range = "H4"
  )
)

location <- dplyr::tibble(
  location_id = as.numeric(stringr::str_extract(location_raw, "\\d+")),
  name = stringr::str_extract(location_raw, "\\D+")) %>%
  dplyr::mutate(name = stringr::str_remove(name,
                                           pattern = "SECTIES")) %>%
  dplyr::mutate(name = stringr::str_remove(name,
                                           pattern = "-")) %>%
  dplyr::mutate(name = stringr::str_trim(name))
location


# Extract day
day <- readxl::read_excel("data/20250130/20250130_butterfly_transect_counts_raw.xls",
                                range = "C1:C2")
class(day)

# Extract month
month <- readxl::read_excel("data/20250130/20250130_butterfly_transect_counts_raw.xls",
                                  range = "E1:E2")
month

# Extract year
year <- readxl::read_excel("data/20250130/20250130_butterfly_transect_counts_raw.xls",
                                 range = "G1:G2")
year

# Extract start time
start_count <- readxl::read_excel("data/20250130/20250130_butterfly_transect_counts_raw.xls",
                                  range = "J1:J2")
start_count <- start_count %>%
  dplyr::rename(start = `Tijd begin`)

start_count <- start_count %>%
  dplyr::mutate(start = as_datetime(start)) %>%
  # Extract the time
  dplyr::mutate(time = format(start, "%H:%M:%S")) %>%
  # Hour
  dplyr::mutate(start_hour = hour(start)) %>%
  # Minute
  dplyr::mutate(start_minute = minute(start)) %>%
  # Second
  dplyr::mutate(start_second = second(start)) %>%
  # Remove help columns
  dplyr::select(-c(start, time))

# Repeat for end time
end_count <- readxl::read_excel("data/20250130/20250130_butterfly_transect_counts_raw.xls",
                                  range = "L1:L2")
end_count <- end_count %>%
  dplyr::rename(end = `Tijd einde`)
end_count <- end_count %>%
  dplyr::mutate(end = as_datetime(end)) %>%
  dplyr::mutate(time = format(end, "%H:%M:%S")) %>%
  dplyr::mutate(end_hour = hour(end)) %>%
  dplyr::mutate(end_minute = minute(end)) %>%
  dplyr::mutate(end_second = second(end)) %>%
  dplyr::select(-c(end, time))

# Merge all info in a temporal data.frame
datetime_df <- dplyr::tibble(
  day = day$Dag,
  month = month$Maand,
  year = year$Jaar) %>%
  dplyr::bind_cols(start_count, end_count)
# Add datetime objects for start and end as two new columns
datetime_df$start <- lubridate::make_datetime(
  datetime_df$year, datetime_df$month, datetime_df$day,
  datetime_df$start_hour, datetime_df$start_minute, datetime_df$start_second
)
datetime_df$end <- lubridate::make_datetime(
  datetime_df$year, datetime_df$month, datetime_df$day,
  datetime_df$end_hour, datetime_df$end_minute, datetime_df$end_second
)
# Also, add a unique identifier for the start and end based on their numeric representation
datetime_df <- datetime_df %>%
  dplyr::mutate(
    start_id = as.numeric(start),
    end_id = as.numeric(end)
  )

# Better to relocate the columns to have `start_id`, `start`, `end_id` and `end` at the beginning
datetime_df <- datetime_df %>% dplyr::relocate(
  start_id, start, end_id, end, .before = day
)
datetime_df

# Extract temperature
temperature <- readxl::read_excel(
  "data/20250130/20250130_butterfly_transect_counts_raw.xls",
  range = "O1:O2"
)
temperature <- temperature %>%
  dplyr::rename(temperatuur = `T°`)

cloudiness <- readxl::read_excel(
  "data/20250130/20250130_butterfly_transect_counts_raw.xls",
  range = "Q1:Q2"
)

cloudiness <- cloudiness %>%
  dplyr::rename(cloudiness = Bewolking) %>%
  dplyr::mutate(cloudiness_unit = "okta")

# Extract wind speed level
wind <- read_excel("data/20250130/20250130_butterfly_transect_counts_raw.xls",
                                       range = "T1:AB2")

# Get column containing wind speed level (Beaufort)
speed <- wind[names(wind) == wind[1,]]

wind <- dplyr::tibble(
  wind_speed = speed,
  wind_speed_unit = "Beaufort"
)

# Merge all info in an event data.frame
event <- dplyr::bind_cols(
  location,
  datetime_df,
  temperature,
  cloudiness,
  wind
)

# Add unique identifier (`event_id `) based on location_id, start_id and end_id
event <- event %>%
  dplyr::mutate(
    event_id = stringr::str_c(location_id, start_id, end_id, sep = "-")) %>%
  # Move the `event_id` to the beginning
  dplyr::relocate(event_id, .before = location_id) %>%
  # Move `start_id` and `end_id` to after `location_id`
  dplyr::relocate(start_id, end_id, .after = location_id)

# Counters
counters <- as.data.frame(read_excel("data/20250130/20250130_butterfly_transect_counts_raw.xls",
                                    range = "A1:A3"))
counters

counter1 <- counters[1,]
counter2 <- counters[2,]

counters <- dplyr::tibble(
  counter1 = counter1,
  counter2=  counter2)

# Add a unique identifier for the counter based on initials of the counters
get_initials <- function(names) {
  names %>%
    stringr::str_extract_all("\\b[A-Z]") %>%
    purrr::map_chr(paste, collapse = "")
}

counters <- counters %>%
  dplyr::mutate(counters_id = stringr::str_c(
    get_initials(counter1),
    get_initials(counter2)
  )
)

counters

# Add event_id and counters_id to the transect counts
counts <- counts %>%
  dplyr::mutate(
    event_id = event$event_id,
    counters_id = counters$counters_id)

counts

# Up to you to save the three data.frames: `counts`, `event` and `counters` to CSV files :-)
