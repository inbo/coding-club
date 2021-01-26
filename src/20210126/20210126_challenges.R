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




#' b. select locations from watina database with `area_codes` "KAL", "WES" or "ZAB" and depth range between 2 and 4 meters



#' 2. Using inbodb and florabank database and still being lazy:
#' get observations of taxon Erigeron from florabank db:



#' 3. Using inbodb and inboveg connection and still being lazy:
#' search information about survey "ABS-LIM2011":


#' How to collect the data queried above?





#' Challenge 3.

#' 1. Using florabank and its table tblTaxon:
#'   a. get the first 10 rows

# SQL

#  tidyverse syntax


#'   b. get the scientific name (`NaamWetenschappelijk`) of Dutch name
#' (`NaamNederlands`) Slank snavelmos

# SQL



# tidyverse


#'   c. get the scientific names (`NaamWetenschappelijk`) and Dutch names
#' (`NaamNederlands`) of taxa with Dutch name starting with  `Slank`. [Tip for SQL query](https://www.w3schools.com/SQL/sql_like.asp); [tip for tidyverse](https://github.com/tidyverse/dbplyr/issues/295)

# SQL



# tidyverse



#' 2. Using INBOVEG database and its table ivRecording: a. retrieve the 10
#' locations (LocationCode) with the highest number of recordings with
#' `Latitude` between 50.9 and 51.1 and `Longitude` between 3.9 and 3.5

# SQL


# tidyverse



#''3. How to get the column names of table `ivRecording` from `INBOVEG`?

# SQL


# tidyverse syntax



#' Bonus Challenge 1

require(glue)

inboveg_locs_most_recs <- function(con, n_locations, lat, lng){


}

# test your function
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
