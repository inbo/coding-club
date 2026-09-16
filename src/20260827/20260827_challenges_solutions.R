library(DBI)
library(RSQLite)
library(tidyverse)

# CHALLENGE 1 ####

## 1.1 ####
con <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  "data/20260827/20260827_portal_mammals.sqlite"
)

## 1.2 ####
dbListTables(con)

## 1.3 ####
dbListFields(con, name = "species")

## 1.4 ####
dbReadTable(con, name = "species")

## 1.5 ####
res <- dbSendQuery(con, "SELECT * FROM species WHERE taxa = 'Reptile'")
dbFetch(res)
dbClearResult(res)

# Notice that you can perform all the three steps before using `dbGetQuery()`.
res <- dbGetQuery(con, "SELECT * FROM species WHERE taxa = 'Reptile'")

# Still, it's always nice to remember what the typical steps are when working
# with databases. Sending a query without fetching can help you debug your SQL
# query. And it can save you crashes if the query is too big and you don't want
# to fetch all the results at once. You can fetch results in chunks, for
# example, using `dbFetch(res, n = 100)` to fetch 100 rows at a time.
res <- dbSendQuery(con, "SELECT * FROM species WHERE taxa = 'Reptile'")
dbFetch(res, n = 1)
dbClearResult(res)

## 1.6 ####
res <- dbSendQuery(
  con,
  "SELECT species_id, genus and species FROM species WHERE taxa = 'Reptile'"
)
dbFetch(res)
dbClearResult(res)

# Notice that the result is a plain data frame. Do you want a tibble, i.e. a nicely displayed data frame? Just calls the function `tbl()` from dplyr package in combination with the dplyr function `sql()`.
reptiles <- tbl(src = con, sql("SELECT * FROM species WHERE taxa = \"Reptile\""))
reptiles

## 1.7 ####
dbDisconnect(con)


## EXTRA - How to work with SQL in Quarto

# Give a look to https://hackmd.io/dzthDR3CTHy0g4BWir0VRw?view#Bonus-Alternative


# CHALLENGE 2 ####

con <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  "data/20260827/20260827_portal_mammals.sqlite"
)

## 2.1 ####
res <- dbSendQuery(con, "SELECT DISTINCT year FROM surveys;")
dbFetch(res)
dbClearResult(res)

## 2.2 ####
res <- dbSendQuery(con, "SELECT DISTINCT year, species_id FROM surveys;")
dbFetch(res)
dbClearResult(res)

## 2.3 ####
res <- dbSendQuery(
  con,
  "SELECT DISTINCT year, species_id FROM surveys WHERE species_id is NOT NULL;"
)
dbFetch(res)
dbClearResult(res)

## 2.4 ####
res <- dbSendQuery(
  con,
  "SELECT record_id, month, day, year, plot_id, species_id, sex, hindfoot_length, weight/1000 FROM surveys LIMIT 100;"
)
dbFetch(res)
dbClearResult(res)

## 2.5 ####
res <- dbSendQuery(
  con,
  "SELECT * FROM surveys WHERE hindfoot_length IS NOT NULL ORDER BY hindfoot_length, year LIMIT 100;"
)
dbFetch(res)
dbClearResult(res)

# Variant with ordering in descending order
res <- dbSendQuery(
  con,
  "SELECT * FROM surveys
    WHERE hindfoot_length IS NOT NULL
    ORDER BY hindfoot_length DESC, year DESC
    LIMIT 100;
  "
)
dbFetch(res)
dbClearResult(res)


## 2.6 ####

# Get the needed species_id
res <- dbSendQuery(
  con,
  "SELECT species_id FROM species WHERE genus = 'Dipodomys';"
)
dbFetch(res)
dbClearResult(res)

# Retrieve surveys for those species and the specified year
res <- dbSendQuery(
  con,
  "SELECT * FROM surveys WHERE species_id IN ('DM', 'DO', 'DS', 'DX') AND year = 1989;"
)
dbFetch(res)
dbClearResult(res)

# Alternative solutions encapsulating the first query within the second query,
# maybe difficult to read, but effective
query <- "
SELECT *
FROM surveys
WHERE species_id IN
(SELECT DISTINCT species_id FROM species WHERE genus = 'Dipodomys')
"
dbGetQuery(con, query)

# Extra - ALternative solution without hardcoding and more future-proof,
# inspired by intermezzo example
species_ids <- dbGetQuery(
  con,
  "SELECT species_id FROM species WHERE genus = 'Dipodomys';"
) %>% dplyr::pull(species_id)
species_ids

query <- glue::glue_sql(
  "SELECT * FROM surveys WHERE species_id IN ({species_ids*}) AND year = 1989;",
  .con = con
)
# You can "print" the query to check if it's what you expect.
print(query)

dbGetQuery(con, query)

dbDisconnect(con)

# CHALLENGE 3 ####

con <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  "data/20260827/20260827_portal_mammals.sqlite"
)

## 3.1 ####
query <- "SELECT genus, COUNT(species_id) FROM species GROUP BY genus;"
res <- dbSendQuery(
  con,
  query
)
dbFetch(res)
dbClearResult(res)

query <- "SELECT species_id, COUNT(record_id) FROM surveys GROUP BY species_id;"
res <- dbGetQuery(
  con,
  query
)
tibble(res)

## 3.2 ####
# SELECT * returns every column from every table in the join. SQL doesn't
# deduplicate columns just because they hold identical values or share a name.
query <- "
  SELECT * FROM surveys
  LEFT JOIN species ON surveys.species_id = species.species_id;
"
res <- dbGetQuery(con, query)

# Alternative with the very handy verb `USING`
query <- "
  SELECT *
  FROM surveys
  JOIN species USING (species_id);
"
res <- dbGetQuery(con, query)
tibble(res)

# SELECT * is actually good for exploration, but prone to errors for data
# analysis. It's always better (future proof) to specify the fields
query <- "
  SELECT
    record_id,
    month, day,
    year,
    plot_id,
    taxa,
    genus,
    species,
    surveys.species_id,
    sex,
    hindfoot_length,
    weight
  FROM surveys
  LEFT JOIN species ON surveys.species_id = species.species_id;
"
res <- dbGetQuery(con, query)

## 3.3 ####
query <- "
  SELECT
    record_id, month, day, year, plot_id, surveys.species_id, species,
    sex, hindfoot_length, weight
  FROM surveys
  LEFT JOIN species ON surveys.species_id = species.species_id;
"
res <- dbGetQuery(con, query)


## 3.4 ####
dwc_occurrence_sql <- glue::glue_sql(
  readr::read_file("src/20260827/20260827_sql_query_intermezzo.sql"),
  .con = con
)
res <- dbSendQuery(con, dwc_occurrence_sql)
dbFetch(res)
dbClearResult(res)

## 3.5 ####
surveys <- tbl(con, "surveys")
specific_surveys <- surveys %>%
  dplyr::filter(
    year >= 2000,
    species_id %in% c("DM", "DO", "DS")
  )
# Lazy evaluation, it doesn't know how many rows, it just shows the first ones
specific_surveys
# See the SQL query
specific_surveys %>% show_query()
# Execute query and retrieve results
specific_surveys %>% collect()


# BONUS CHALLENGE

counts <- readr::read_csv(
  file = "data/20260827/20260827_counts.csv",
  na = ""
)

events <- readr::read_csv(
  file = "data/20260827/20260827_events.csv",
  na = ""
)

counters <- readr::read_csv(
  file = "data/20260827/20260827_counters.csv",
  na = ""
)

# Create an ephemeral in-memory RSQLite database
con_bonus <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")

# 1. Enable foreign key enforcement for this connection
DBI::dbExecute(con_bonus, "PRAGMA foreign_keys = ON;")

# 2. Define schema explicitly with primary/foreign keys
dbExecute(con_bonus, "
  CREATE TABLE counts (
    count_id INTEGER PRIMARY KEY,
    species TEXT,
    section TEXT,
    n  INTEGER,
    event_id TEXT,
    counters_id TEXT
  );
")

dbExecute(con_bonus, "
  CREATE TABLE events (
    event_id  PRIMARY KEY,
    location_id TEXT,
    start  INTEGER,
    end TEXT,
    cloudiness REAL,
    cloudiness_unit TEXT,
    wind_speed REAL,
    wind_speed_unit TEXT,
    temperature REAL,
    temperature_unit TEXT
  );
")

# Empty, no tables yet
dbListTables(con_bonus)

# Add counts table
RSQLite::dbAppendTable(con_bonus, "counts", counts)
dbListFields(con_bonus, "counts")
# Check that counts tables has all the columns of counts data frame
all(dbListFields(con_bonus, "counts") == names(counts))

# Add events table
RSQLite::dbAppendTable(con_bonus, "events", events)
dbListFields(con_bonus, "events")
# Check that events tables has all the columns of events data frame
all(dbListFields(con_bonus, "events") == names(events))

# Get all data from counts (example using `dbReadTable()`)
counts_from_db <- dbReadTable(conn = con_bonus, name = "counts")
tibble(counts_from_db)

# Get all data from events (example using SQL query)
events_from_db <- dbGetQuery(
  conn = con_bonus,
  "SELECT * FROM events;"
)
tibble(events_from_db)

dbDisconnect(con_bonus)
