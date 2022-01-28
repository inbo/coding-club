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


#' b. select locations from watina database with `area_codes`
#' `"MAY"` or `"LIN"` and depth range between 2 and 3 meters.
#' How to return only the latest observation well per location?

info_locs <- get_locs(watina,
                      area_codes = c("MAY", "LIN"),
                      filterdepth_range = c(2, 3),
                      obswell_aggr = "latest")

#' 2. Using inbodb and florabank database and still being lazy:
#' get observations of invasive species _Impatiens glandulifera_ and  _Hydrocotyle
#' ranunculoides_ from florabank db:

obs_ias <- get_florabank_observations(
  florabank,
  names = c("Impatiens glandulifera", "Hydrocotyle ranunculoides"))
obs_ias

#' 3. Using inbodb and still being lazy, search recordings collected during survey
#' `"ABS-LIM2011"` in `inboveg` database
recordings <- get_inboveg_recording(inboveg, survey_name = "ABS-LIM2011")

recordings

#' How to collect the data queried above?
info_locs_df <-
  info_locs %>%
  collect()

# is info_locs_df a dataframe?
is.data.frame(info_locs_df)

obs_ias_df <-
  obs_ias %>%
  collect()

# is obs_ias_df a dataframe?
is.data.frame(obs_ias_df)

recordings_info_df <-
  recordings %>%
  collect()

# is recordings_info_df a dataframe?
is.data.frame(recordings_info_df)

#' Challenge 3.

#' 1. Using florabank and its table tblTaxon:
#'   a. get the first 10 rows

# SQL
tbl(florabank, sql("SELECT TOP 10 *
                   FROM tblTaxon"))

#  tidyverse syntax
tbl(florabank, "tblTaxon") %>%
  head(10)

# looks the same as
tbl(florabank, "tblTaxon")

# but is a different query (a lazy tbl just shows 10 rows when printed):
tbl(florabank, "tblTaxon") %>%
  head(10) %>%
  show_query()

tbl(florabank, "tblTaxon") %>%
  show_query()

# very useful alternative: to view the first n records use view()

view(tbl(florabank, "tblTaxon")) #default first 1000
view(tbl(florabank, "tblTaxon"), n = 100) #first 100

#'   b. get the scientific name (`NaamWetenschappelijk`) of Dutch name
#' (`NaamNederlands`) Rotsvorkje

# SQL

rotsvorkje_query <- "SELECT NaamWetenschappelijk
                   FROM tblTaxon
                   WHERE NaamNederlands = 'Rotsvorkje'"


tbl(florabank, sql(rotsvorkje_query))


# tidyverse
tbl(florabank, "tblTaxon") %>%
  filter(NaamNederlands == "Rotsvorkje") %>%
  select(NaamWetenschappelijk)

#' c. get the scientific names (`NaamWetenschappelijk`) and Dutch names
#' (`NaamNederlands`) of taxa with Dutch name starting with  `Slank`. [Tip for
#' SQL query](https://www.w3schools.com/SQL/sql_like.asp); [tip for
#' tidyverse](https://github.com/tidyverse/dbplyr/issues/295)

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
#' `Latitude` between 50.9 and 51.1 and `Longitude` between 3.5 and 3.9. Show
#' the locations and the number of recordings and order them by decreasing order
#' (location with highest number of recordings first)

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

# see https://db.rstudio.com/best-practices/run-queries-safely/#using-glue_sql

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
  crs = 31370)  %>%
  st_cast("GEOMETRYCOLLECTION") %>%
  st_collection_extract(type = "POLYGON")

# starting from code for get_inboveg_header

get_inboveg_header_sf <- function(connection,
         survey_name,
         rec_type,
         sf_poly, # new argument
         multiple = FALSE,
         collect = FALSE) {
  require(assertthat)
  require(glue)
  require(sf)

  assert_that(inherits(connection, what = "Microsoft SQL Server"),
              msg = "Not a connection object to database.")

  if (missing(survey_name) & !multiple) {
    survey_name <- "%"
  }

  if (missing(survey_name) & multiple) {
    stop("Please provide one or more survey names to survey_name when multiple
         = TRUE")
  }

  if (!missing(survey_name)) {
    if (!multiple) {
      assert_that(is.character(survey_name))
    } else {
      assert_that(is.vector(survey_name, mode = "character"))
    }
  }


  if (missing(rec_type)) {
    rec_type <- "%"
  } else {
    assert_that(is.character(rec_type))
  }

  common_part <- "SELECT
      ivR.RecordingGivid
      , ivS.Name
      , ivR.UserReference
      , ivR.Observer
      , ivR.LocationCode
      , ivR.Latitude
      , ivR.Longitude
      , COALESCE(ivR.Length * ivR.Width / 10000, try_convert(decimal, ivR.Area)) AS Area
      , ivR.Length
      , ivR.Width
      , ivR.VagueDateType
      , ivR.VagueDateBegin
      , ivR.VagueDateEnd
      , ivR.SurveyId
      , ivR.RecTypeID
      FROM [dbo].[ivRecording] ivR
      INNER JOIN [dbo].[ivSurvey] ivS on ivS.Id = ivR.SurveyId
      INNER JOIN [dbo].[ivRecTypeD] ivRec on ivRec.ID = ivR.RecTypeID
      where ivR.NeedsWork = 0"

  if (!multiple) {
      sql_statement <- glue_sql(common_part,
                                "AND ivS.Name LIKE {survey_name}
                              AND ivREc.Name LIKE {rec_type}",
                                survey_name = survey_name,
                                rec_type = rec_type,
                                .con = connection)
  } else {
    sql_statement <- glue_sql(common_part,
                              "AND ivS.Name IN ({survey_name*})
                              AND ivREc.Name LIKE {rec_type}",
                              survey_name = survey_name,
                              rec_type = rec_type,
                              .con = connection)
  }


  query_result <- tbl(connection, sql(sql_statement))

  if (!missing(sf_poly)) {
    query_result <- query_result %>%
      collect() %>%
      filter(Latitude > 49, Latitude < 53, Longitude >2, Longitude<8) %>%
      st_as_sf(coords = c("Longitude", "Latitude"),
            crs = 4326) %>%
      st_transform(crs = 31370) %>%
      st_make_valid() %>%
      st_filter(sf_poly)

    return(query_result)
  }

  if (!isTRUE(collect)) {
    return(query_result)
  } else {
    query_result <- collect(query_result)
    return(query_result)
  }
}

#debugonce(get_inboveg_header_sf) # for finding errors (debugging)
testfunctie <- get_inboveg_header_sf(
  connection = inboveg,
  sf_poly = west_vlaanderen)

# the plot could take a little of time...
testfunctie %>%
  ggplot() +
  geom_sf(data = west_vlaanderen) +
  geom_sf()

#' Disconnect
dbDisconnect(watina)
dbDisconnect(inboveg)
dbDisconnect(florabank)
