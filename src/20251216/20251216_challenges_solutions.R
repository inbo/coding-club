# Load the packages and install if needed
required_packages <- c(
  "readr",
  "dplyr",
  "tidyr",
  "jsonlite",
  "readxl",
  "googlesheets4",
  "arrow",
  "googledrive"
)

# Install packages not yet installed
installed_packages <- required_packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  # Install packages not yet installed
  install.packages(required_packages[!installed_packages])
}

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))



# Challenge 1 ####

## 1.1 ####
ref_data <- readr::read_csv(
  file = "https://zenodo.org/records/10054153/files/MH_ANTWERPEN-reference-data.csv?download=1",
  # specify the class of some columns
  col_types = readr::cols(
    .default = readr::col_character(), # Most of the columns are characters
    `deploy-on-date` = readr::col_datetime("%Y-%m-%d %H:%M:%OS"), # To use fractional seconds
    `deploy-off-date` = readr::col_datetime("%Y-%m-%d %H:%M:%OS"),
    `animal-mass` = readr::col_double(),
    `deploy-on-latitude` = readr::col_double(),
    `deploy-on-longitude` = readr::col_double(),
    `tag-mass` = readr::col_double()
  )
)
# Check the column specifications
readr::spec(ref_data)

## 1.2 #### 
gps_data <- readr::read_csv(
  file = "./data/20251216/20251216_MH_ANTWERPEN-gps-2018.csv.gz",
  # Specify the class of some columns
  col_types = readr::cols(
    .default = readr::col_double(), # Most of the columns are characters
    visible = readr::col_logical(),
    timestamp =  readr::col_datetime("%Y-%m-%d %H:%M:%OS"), # To use fractional seconds
    `gps:satellite-count` = readr::col_integer(),
    `import-marked-outlier` = readr::col_logical(),
    `manually-marked-outlier` = readr::col_logical(),
    `sensor-type` = readr::col_character(),
    `individual-taxon-canonical-name` = readr::col_character(),
    `tag-local-identifier` = readr::col_character(),
    `individual-local-identifier` = readr::col_character(),
    `study-name` = readr::col_character()
  )
)

# Check the column specifications
readr::spec(gps_data)

## 1.3 ####
gps_data <- readr::read_csv(
  file = "https://zenodo.org/records/10054153/files/MH_ANTWERPEN-gps-2018.csv.gz",
  # Specify the class of some columns
  col_types = readr::cols(
    .default = readr::col_double(), # Most of the columns are characters
    visible = readr::col_logical(),
    timestamp =  readr::col_datetime("%Y-%m-%d %H:%M:%OS"), # To use fractional seconds
    `gps:satellite-count` = readr::col_integer(),
    `import-marked-outlier` = readr::col_logical(),
    `manually-marked-outlier` = readr::col_logical(),
    `sensor-type` = readr::col_character(),
    `individual-taxon-canonical-name` = readr::col_character(),
    `tag-local-identifier` = readr::col_character(),
    `individual-local-identifier` = readr::col_character(),
    `study-name` = readr::col_character()
  )
)

## 1.4 ####

metadata <- jsonlite::fromJSON(
  txt = "https://zenodo.org/records/10054153/files/datapackage.json?download=1",
  simplifyVector = TRUE,
  simplifyDataFrame = TRUE
)

## 1.5 ####

inborutils::download_zenodo(
  doi = "10.5281/zenodo.10054153",
  path = "./data/20251216/mh_antwerpen_data"
)


# Challenge 2 ####

# If not yet done, please downloaded the directory from Google Drive containing the Parquet file(s):
# https://drive.google.com/drive/folders/19-wOEEu24zwXqbPxIU1bg_ChG-PFu_KF?usp=drive_link
# It can take a while...
# Unzip the folder and save it as `data/20251216/20251216_gbif_parquet_be_2022/`
# Open the Parquet file with the arrow package
gbif_df <- arrow::open_dataset("data/20251216/20251216_gbif_parquet_be_2022/")

## 2.1 ####
names(gbif_df)

## 2.2 ####
gbif_df %>%
  dplyr::count() %>%
  dplyr::collect()

## 2.3 ####
gbif_df %>%
  dplyr::distinct(species) %>%
  dplyr::count() %>%
  dplyr::collect()

## 2.4 ####
gbif_df %>%
  dplyr::filter(!is.na(species)) %>%
  dplyr::group_by(species) %>%
  dplyr::summarise(n = dplyr::n()) %>%
  dplyr::arrange(dplyr::desc(n)) %>%
  dplyr::slice_head(n = 10) %>%
  dplyr::collect()

## 2.5 ####
gbif_df %>%
  dplyr::summarise(
    min_date = min(eventdate, na.rm = TRUE),
    max_date = max(eventdate, na.rm = TRUE)
  ) %>%
  dplyr::collect()

## 2.6 ####
gbif_df %>%
  # Get only eventdate with yyyy-mm-dd format
  dplyr::filter(stringr::str_detect(
    eventdate,
    pattern = "^\\d{4}-\\d{2}-\\d{2}$"
  )) %>%
  dplyr::summarise(
    min_date = min(eventdate, na.rm = TRUE),
    max_date = max(eventdate, na.rm = TRUE)
  ) %>%
  dplyr::collect()

## 2.7 ####
gbif_df %>%
  dplyr::group_by(occurrencestatus) %>%
  dplyr::summarise(n = dplyr::n()) %>%
  dplyr::collect()
  

# Challenge 3A ####

# We don't need any authentication. So, avoid authentication phase via `gs4_deauth()`
googlesheets4::gs4_deauth()
butterflies_2025 <- googlesheets4::read_sheet(
  ss = "https://docs.google.com/spreadsheets/d/1hUd_qWIQ5Lg1g1cfxKyBkD56iUU9lcVeKV6bkN02Ing/edit?usp=sharing",
  sheet = "butterflies 2025"
)

# Challenge 3B ####

counts_raw <- readxl::read_excel(
  path = "data/20251216/20251216_butterfly_transect_counts_raw.xls",
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
  path = "data/20251216/20251216_butterfly_transect_counts_raw.xls",
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
day <- readxl::read_excel("data/20251216/20251216_butterfly_transect_counts_raw.xls",
                                range = "C1:C2")
class(day)

# Extract month
month <- readxl::read_excel("data/20251216/20251216_butterfly_transect_counts_raw.xls",
                                  range = "E1:E2")
month

# Extract year
year <- readxl::read_excel("data/20251216/20251216_butterfly_transect_counts_raw.xls",
                                 range = "G1:G2")
year

# Extract start time
start_count <- readxl::read_excel("data/20251216/20251216_butterfly_transect_counts_raw.xls",
                                  range = "J1:J2")
start_count <- start_count %>%
  dplyr::rename(start = `Tijd begin`)

start_count <- start_count %>%
  dplyr::mutate(start = lubridate::as_datetime(start)) %>%
  # Extract the time
  dplyr::mutate(time = format(start, "%H:%M:%S")) %>%
  # Hour
  dplyr::mutate(start_hour = lubridate::hour(start)) %>%
  # Minute
  dplyr::mutate(start_minute = lubridate::minute(start)) %>%
  # Second
  dplyr::mutate(start_second = lubridate::second(start)) %>%
  # Remove help columns
  dplyr::select(-c(start, time))

# Repeat for end time
end_count <- readxl::read_excel(
  "data/20251216/20251216_butterfly_transect_counts_raw.xls",
  range = "L1:L2"
)
end_count <- end_count %>%
  dplyr::rename(end = `Tijd einde`)

end_count <- end_count %>%
  dplyr::mutate(end = lubridate::as_datetime(.data$end)) %>%
  dplyr::mutate(time = format(end, "%H:%M:%S")) %>%
  dplyr::mutate(end_hour = lubridate::hour(end)) %>%
  dplyr::mutate(end_minute = lubridate::minute(end)) %>%
  dplyr::mutate(end_second = lubridate::second(end)) %>%
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
  "data/20251216/20251216_butterfly_transect_counts_raw.xls",
  range = "O1:O2"
)
temperature <- temperature %>%
  dplyr::rename(temperatuur = `T°`)

cloudiness <- readxl::read_excel(
  "data/20251216/20251216_butterfly_transect_counts_raw.xls",
  range = "Q1:Q2"
)

cloudiness <- cloudiness %>%
  dplyr::rename(cloudiness = Bewolking) %>%
  dplyr::mutate(cloudiness_unit = "okta")

# Extract wind speed level
wind <- readxl::read_excel("data/20251216/20251216_butterfly_transect_counts_raw.xls",
                                       range = "T1:AB2")

# Get column containing wind speed level (Beaufort)
speed <- wind[names(wind) == wind[1,]]

wind <- dplyr::tibble(
  wind_speed = speed,
  wind_speed_unit = "Beaufort"
)

# Merge all info in an event data.frame
events <- dplyr::bind_cols(
  location,
  datetime_df,
  temperature,
  cloudiness,
  wind
)

# Add unique identifier (`event_id `) based on location_id, start_id and end_id
events <- events %>%
  dplyr::mutate(
    event_id = stringr::str_c(location_id, start_id, end_id, sep = "-")) %>%
  # Move the `event_id` to the beginning
  dplyr::relocate(event_id, .before = location_id) %>%
  # Move `start_id` and `end_id` to after `location_id`
  dplyr::relocate(start_id, end_id, .after = location_id)

# Counters
counters <- as.data.frame(
  readxl::read_excel(
    "data/20251216/20251216_butterfly_transect_counts_raw.xls",
    range = "A1:A3"
  )
)
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
    event_id = events$event_id,
    counters_id = counters$counters_id)

counts

# Up to you to save the data.frames `counts`, `events` and `counters` to CSV files :-)


# BONUS Challenges ####

## BC.1 ####

library(frictionless)
mh_antwerpen_zenodo <- frictionless::read_package("https://zenodo.org/records/10054153/files/datapackage.json")

ref_data_via_frictionless <- frictionless::read_resource(mh_antwerpen_zenodo, "reference-data")
gps_via_frictionless <- frictionless::read_resource(mh_antwerpen_zenodo, "gps")

library(googledrive)

# Set the folder URL
folder_url <- "https://drive.google.com/drive/folders/19-wOEEu24zwXqbPxIU1bg_ChG-PFu_KF"

# Get the folder ID from the URL
folder_id <- googledrive::as_id(folder_url)

# List all files in the folder
files_in_folder <- googledrive::drive_ls(folder_id)

# Create the destination folder if it doesn't exist
dest_folder <- "./data/20251216/20251216_parquet_from_gdrive"
if (!dir.exists(dest_folder)) {
  dir.create(dest_folder)
}

## BC.2 ####
# Download all files from the Google Drive folder (it takes a lot of time, but you can stop the process whenever you want)
purrr::walk2(
  files_in_folder$id,
  files_in_folder$name,
  ~ googledrive::drive_download(
      googledrive::as_id(.x),
      path = file.path("./data/20251216/20251216_parquet_from_gdrive", .y),
      overwrite = TRUE
    )
)

## BC.3 ####
# Open the Parquet file from Amazon Web Service "s3://gbif-open-data-eu-central-1/occurrence/2021-11-01/occurrence.parquet"
# using arrow
gbif_s3 <- arrow::open_dataset("s3://gbif-open-data-eu-central-1/occurrence/2021-11-01/occurrence.parquet")

# Trying some queries as in Challenge 2
# This one took a lot of time to execute. As mentioned in the blogpost (https://data-blog.gbif.org/post/apache-arrow-and-parquet/):
# "A local copy will always run faster than a copy on AWS."
gbif_s3 %>%
  dplyr::count() %>%
  dplyr::collect()

