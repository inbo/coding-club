## Challenge 0

# Install packages

# see instructions from links in slides

# Load packages

library(tidyverse)
library(inbodb)
library(watina)

# Connect

watina <- connect_watina()
inboveg <- connect_inbo_dbase("D0010_00_Cydonia")
florabank <- connect_inbo_dbase("D0021_00_userFlora")

## Challenge 1

#' no real coding for challenge 1...

## Challenge 2

#' 1. Using watina package and always in lazy mode:
#' a. How many area codes exist in watina database?

area_codes <-
  get_locs(watina) %>%
  distinct(area_code) %>%
  count()


#' b. select locations from watina database with `area_codes` "KAL", "WES" or "ZAB" and depth range between 2 and 4 meters

info_locs <- get_locs(watina,
                      area_codes = c("KAL", "WES", "ZAB"),
                      filterdepth_range = c(2, 4))


#' 2. Using inbodb and florabank database and still being lazy:
#' get observations of taxon Erigeron from florabank db:

obs_erigeron <- get_florabank_observations(florabank,
                                           names = c("Erigeron"))
obs_erigeron

#' 3. Using inbodb and inboveg connection and still being lazy:
#' search information about survey "ABS-LIM2011":
survey_info <- get_inboveg_survey(inboveg,
                                  survey_name = "ABS-LIM2011")

survey_info

#' How to collect the data queried above?
info_locs_df <-
  info_locs %>%
  collect()

# is info_locs_df a dataframe?
is.data.frame(info_locs_df)

obs_erigeron_df <-
  obs_erigeron %>%
  collect()

# is obs_erigeron_df a dataframe?
is.data.frame(obs_erigeron_df)

survey_info_df <-
  survey_info %>%
  collect()

# is survey_info_df a dataframe?
is.data.frame(survey_info_df)

#' Challenge 3.

#' 1. Using florabank and its table tblTaxon:
#'   a. get the first 10 rows

# SQL
tbl(florabank, sql("SELECT TOP 10 * FROM tblTaxon"))

#  tidyverse syntax
tbl(florabank, "tblTaxon") %>%
  head(10)


#'   b. get the scientific name (`NaamWetenschappelijk`) of Dutch name
#' (`NaamNederlands`) Slank snavelmos

# SQL

slank_snavelmos_query <- "SELECT NaamWetenschappelijk
                   FROM tblTaxon
                   WHERE NaamNederlands = 'Slank snavelmos'"


tbl(florabank, sql(slank_snavelmos_query))


# tidyverse
tbl(florabank, "tblTaxon") %>%
  filter(NaamNederlands == "Slank snavelmos") %>%
  select(NaamWetenschappelijk)

#'   c. get the scientific names (`NaamWetenschappelijk`) and Dutch names
#' (`NaamNederlands`) of taxa with Dutch name starting with  `Slank`. [Tip for SQL query](https://www.w3schools.com/SQL/sql_like.asp); [tip for tidyverse](https://github.com/tidyverse/dbplyr/issues/295)

# SQL
start_with_slank_query <- "SELECT NaamWetenschappelijk, NaamNederlands
                   FROM tblTaxon
                   WHERE NaamNederlands LIKE 'Slank%'"
tbl(florabank, sql(start_with_slank_query))

# tidyverse
tbl(florabank, "tblTaxon") %>%
  filter(NaamNederlands %like% "Slank%") %>%
  select(NaamNederlands, NaamWetenschappelijk)

#' 2. Using INBOVEG database and its table ivRecording: a. retrieve the 10
#' locations (LocationCode) with the highest number of recordings with
#' `Latitude` between 50.9 and 51.1 and `Longitude` between 3.9 and 3.5

# SQL
locs_most_recs_query <- 'SELECT TOP 10 LocationCode, COUNT(*) AS n
FROM ivRecording
WHERE (Latitude > 50.9 AND Latitude < 51.1 AND Longitude > 3.5 AND Longitude < 3.9)
GROUP BY LocationCode
ORDER BY n DESC'

tbl(inboveg, sql(locs_most_recs_query))

# tidyverse
loc_recordings <-
  tbl(inboveg, "ivRecording") %>%
  filter(Latitude > 50.9 & Latitude < 51.1 & Longitude > 3.5 & Longitude < 3.9) %>%
  group_by(LocationCode) %>%
  count() %>%
  arrange(desc(n)) %>%
  head(10)

loc_recordings

#''3. How to get the column names of table `ivRecording` from `INBOVEG`?

# SQL
colnames_query <- "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'ivRecording'"
tbl(inboveg, sql(colnames_query))

# tidyverse syntax
tbl(florabank, "tblTaxon") %>%
  colnames()


#' Bonus Challenge 1

# SQL
require(glue)

inboveg_locs_most_recs <- function(con, n_locations, lat, lng){
  locs_highest_n_recs_query <- glue_sql(
    'SELECT TOP {n_locs} LocationCode, COUNT(*) AS n
    FROM ivRecording
    WHERE (Latitude > { lat_min } AND Latitude < { lat_max } AND
    Longitude > { lng_min } AND Longitude < { lng_max })
    GROUP BY LocationCode
    ORDER BY n DESC',
    n_locs = n_locations,
    lat_min = lat[1],
    lat_max = lat[2],
    lng_min = lng[1],
    lng_max = lng[2]
  )
  print(locs_highest_n_recs_query)
  tbl(inboveg, sql(locs_highest_n_recs_query)) %>%
    collect()
}

inboveg_locs_most_recs(inboveg,
                       n_locations = 8,
                       lat = c(50.1, 50.3),
                       lng = c(4.2, 4.9))

# Tidyverse

inboveg_locs_most_recs <- function(con, n_locations, lat, lng){
  # explicit min and max otherwise filter() fails
  lat_min <- lat[1]
  lat_max <- lat[2]
  lng_min <- lng[1]
  lng_max <- lng[2]
  tbl(con, "ivRecording") %>%
    filter(Latitude > lat_min & Latitude < lat_max &
             Longitude > lng_min & Longitude < lng_max) %>%
    group_by(LocationCode) %>%
    count() %>%
    arrange(desc(n)) %>%
    head(n_locations) %>%
    collect() # or add collect as arg to function
}

inboveg_locs_most_recs(inboveg,
                       n_locations = 8,
                       lat = c(50.1, 50.3),
                       lng = c(4.2, 4.9))

#' Bonus challenge 2

#' Here is an sf polygon you can use to test your function
library(sf)
west_vlaanderen <- read_sf(
  "https://geoservices.informatievlaanderen.be/overdrachtdiensten/VRBG/wfs?service=wfs&request=GetFeature&typeName=VRBG%3ARefprv&srsName=EPSG%3A31370&cql_filter=NAAM%3D%27West-Vlaanderen%27&outputFormat=text%2Fxml%3B%20subtype%3Dgml%2F3.1.1",
  crs = 31370
) %>%
  st_transform(crs = 4326)



#' Disconnect
dbDisconnect(watina)
dbDisconnect(inboveg)
dbDisconnect(florabank)
