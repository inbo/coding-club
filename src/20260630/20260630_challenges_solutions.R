library(httr2)
library(tidyverse)
library(sf) # To open vector data files/requests saved/built via httr2
library(terra) # To open raster data saved via httr2
library(xml2) # Only for bonus challenge
library(mapview) # Optional. Only for fast visualization of raster/sf objects
library(wateRinfo)


# CHALLENGE 1 ####

## 1.1 ####
# Build the request
req1 <- request("https://api.gbif.org/v1/species/match") %>%
  req_url_query(
    name="Passer domesticus"
  )
# The request URL can be extracted as a string via slot `url`. Notice how the
# `?` is added by `req_url_query()`.
req1$url

# Check the request
req1 %>% req_dry_run()

resp1 <- req1 %>% req_perform()
# Notice how the response is printed as a list, with the status code, the content type and the type and size of the body.
resp1

result1 <- resp1 %>%
  resp_body_json()
result1

# Parse the result list as tibble (data frame)
result1 %>% tibble::as_tibble()

# EXTRA - Build the request in a formal way, by splitting the URL into a base
# URL, a API version, a API section and finally an API function
gbif_base <- "https://api.gbif.org/"
api_version <- "v1"
api_sec <- "species"
api_fn <- "match"

# EXTRA - Build the request via `req_url_path_append()` before using
# `req_url_query()` to add the query parameters
req1 <- httr2::request(gbif_base) %>%
  httr2::req_url_path_append(api_version, api_sec, api_fn) %>%
  httr2::req_url_query(name = "Passer domesticus")

# EXTRA - Typically it's better to retry the request a few times in case of
# temporary server issues and add a cache to avoid unnecessary repeated
# requests. The cache is stored in a temporary directory, and will be
# invalidated after 5 minutes, for example.
req1 <- req1 %>%
  httr2::req_retry(max_tries = 3) %>%
  httr2::req_cache(
    path = file.path(tempdir(), "httr2-cache"),
    # invalidate cache every 5 minutes
    max_age = 5 * 60
  )

# EXTRA - Performing and parsing steps are the same
req1 %>%
  # Perform the request
  httr2::req_perform() %>%
  # Parse the response
  httr2::resp_body_json() %>%
  tibble::as_tibble()


## 1.2 ####
req2 <- request("https://api.gbif.org/v1/species/search") %>%
  req_url_query(
    rank = "SPECIES",
    highertaxon_key = 212,
    limit = 1000
  )

# Notice how the query parameters are added as key-value pairs, separated by
# `&`.
req2$url


# Check the request
req2 %>% req_dry_run()

resp2 <- req2 %>% req_perform()
resp2
result2 <- resp2 %>%
  resp_body_json()
result2

names(result2)
# We are interested in the `results`
result2$results


## 1.3 ####
req3 <- request("https://api.gbif.org/v1/dataset/search") %>%
  req_url_query(id = "7888f666-f59e-4534-8478-3a10a3bfee45")
req3
response3 <- req_perform(req3)
response3
response3 %>%
  resp_body_json()

req3 <- request("https://api.gbif.org/v1/dataset/search") %>%
  req_url_query(publishingOrg = "1cd669d0-80ea-11de-a9d0-f1765f95f18b",
                type = "OCCURRENCE",
                limit = 200)
req3$url

response3 <- req_perform(req3)

result3<- response3  %>%
  httr2::resp_body_json()
result3



# CHALLENGE 2 ####

## 2.1 ####
# Build the URL properly with httr2
meteo_req1 <- request("https://opendata.meteo.be/service/aws/wfs") %>%
  req_url_query(
    service      = "WFS",
    version      = "2.0.0",
    request      = "GetFeature",
    typeNames    = "aws:aws_station",
    outputFormat = "application/json"
  )

# Pass the full URL to sf::st_read() directly
meteo_full_url1 <- meteo_req1$url

# Hand the finished URL to sf
meteo_stations_sf1 <- sf::st_read(meteo_full_url1) # or the equivalent `read_sf()`
# Create a map
mapview::mapview(meteo_stations_sf1)


## 2.2 ####
meteo_req2 <- request("https://opendata.meteo.be/service/aws/wfs") %>%
  req_url_query(
    service      = "WFS",
    version      = "2.0.0",
    request      = "GetFeature",
    typeNames    = "aws:aws_station",
    outputFormat = "csv"
  )

# Save directly to a file of your choice
meteo_resp2 <- req_perform(meteo_req2, path = "aws_stations.csv")
# The body is now `On disk`, not `In memory` anymore. Filename is mentioned and
# the size of the file is printed.
meteo_resp2

## 2.3 ####
meteo_req3 <- request("https://opendata.meteo.be/service/aws/wfs") %>%
  req_url_query(
    service      = "WFS",
    version      = "2.0.0",
    request      = "GetFeature",
    typeNames    = "aws:aws_1day",
    outputFormat = "csv",
    cql_filter = "code = 6418 AND timestamp > 2026-01-01T00:00:00Z"
  )
req_perform(meteo_req3, path = "zeebrugge_1day_20260101.csv")


## 2.4 ####
# You can use `CQL_FILTER` argument to filter the data on the server side instead of `cql_filter`. The difference is that `CQL_FILTER` is case-sensitive and `cql_filter` is not. So, this works:
meteo_req4 <- request("https://opendata.meteo.be/service/aws/wfs") %>%
  req_url_query(
    service      = "WFS",
    version      = "2.0.0",
    request      = "GetFeature",
    typeNames    = "aws:aws_1day",
    outputFormat = "csv",
    CQL_FILTER = "code = 6477 AND timestamp during 2026-01-15T00:00:00Z/P8D"
  )
meteo_req4
meteo_resp4 <- req_perform(meteo_req4)
diepenbeek_aws_hourly <- meteo_resp4 %>%
  resp_body_string() %>%
  readr::read_csv()
diepenbeek_aws_hourly

# This doesn't work when performing the request:a "bad request" error returned!
request("https://opendata.meteo.be/service/aws/wfs") %>%
  req_url_query(
    service      = "WFS",
    version      = "2.0.0",
    request      = "GetFeature",
    typeNames    = "aws:aws_1day",
    outputFormat = "csv",
    # Use `TIMESTAMP` instead of `timestamp` in CQL_FILTER value
    CQL_FILTER = "code = 6477 AND TIMESTAMP during 2026-01-15T00:00:00Z/P8D"
    ) %>%
  req_perform()

# CHALLENGE 3 ####

## 3A.1 ####

wateRinfo::supported_variables("en")
stations_ep <- wateRinfo::get_stations("evaporation_penman")

## 3A.2 ####
waregem_ts_id <- stations_ep %>%
  dplyr::filter(station_name == "Waregem_ME") %>%
  dplyr::pull(ts_id)

## 3A.3 ####
waregem_ep <- wateRinfo::get_timeseries_tsid(
  waregem_ts_id,
  from = "2025-01-01",
  to = "2026-01-01") %>%
  dplyr::as_tibble()
# Alternative with `period` argument
waregem_ep <- wateRinfo::get_timeseries_tsid(
  waregem_ts_id,
  from = "2025-01-01",
  period = "P1Y") %>%
  dplyr::as_tibble()

## 3B.1 ####
req_b1 <- request("https://hydro.vmm.be/grid/kiwis/KiWIS") %>%
  req_url_query(
    datasource = 10,
    service = "kisters",
    type = "queryServices",
    request = "getRasterfile",
    ts_id = 911010,
    format = "geotiff",
    date = "2026-06-25T23:00:00.000+02:00"
  )

# Save it on disk
req_b1 %>%
  req_perform(path = "rainfall_intensity.tiff")

rainfall <- terra::rast("rainfall_intensity.tiff")
terra::plot(rainfall)

## 3B.2 ####
req_b2 <- request("https://hydro.vmm.be/grid/kiwis/KiWIS") %>%
  req_url_query(
    datasource = 10,
    service = "kisters",
    type = "queryServices",
    request = "getRasterfile",
    ts_id = 6604010,
    format = "geotiff",
    date = "2026-06-28T12:00:00.000+02:00"
  )
req_b2 %>%
  req_perform(path = "rainfall_intensity_24h.tiff")

rainfall_24h <- terra::rast("rainfall_intensity_24h.tiff")
terra::plot(rainfall_24h)

# 3B.3 ####
full_url_b2 <- req_b2$url
rainfall_24h_b3 <- terra::rast(full_url_b2)
terra::plot(rainfall_24h_b3)

# BONUS CHALLENGE ####

req <- request("https://opendata.meteo.be/service/ows") %>%
  req_url_query(
    service = "wfs",
    version = "2.0.0",
    request = "GetCapabilities",
    outputFormat  = "application/xml"
  )

resp <- req %>% req_perform()
caps <- resp %>%
  resp_body_xml()

xml_find_all(caps, "//wfs:WFS_Capabilities//FeatureTypeList//FeatureType//Name")

xml_find_all(caps, ".//d1:FeatureType/d1:Name", xml_ns(caps)) %>% xml_text()
