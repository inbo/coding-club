library(tidyverse)
library(lubridate)
library(suncalc)

# CHALLENGE 1.1

# parse these character columns with lubridate
datetimes_to_parse <- tibble(
  datetime1 = c("2020-10-24 01:01:45", "2020-10-27 14:23:50"),
  datetime2 = c("10-24-2020 1:1:45", "10-27-2020 14:23:50"),
  datetime3 = c("2020/24/10 01;01;45am", "2020/27/10 02;23;50pm"),
  datetime4 = c("2020:24:10 1-1am", "2020:27:10 2-23pm"),
  datetime5 = c("24?10?99", "27&10&20"),
  datetime6 = c("2020-10,24 1-1?45", "2020:Oct:27 2-23-50pm")
)



# CHALLENGE 1.2



# CHALLENGE 1.3



# CHALLENGE 1.4



# CHALLENGE 2

#' Read file 20201027_cameratrap_df.txt
data_cameratrap <- read_tsv("./data/20201027/20201027_cameratrap_df.txt")

# CHALLENGE 2.1

#' Datetimes in column image_sequence are in UTC. Get correspondent clock times



# CHALLENGE 2.2

#' Contrarily to image_sequence_datetime, the datetimes in
#' camera_deployment_start and camera_deployment_end  are already in clock time.
#' Add the timezone information to these columns



# CHALLENGE 3

# CHALLENGE 3.1

#' Extract hour and day information as extra columns



# CHALLENGE 3.2

#' Use suncalc package to get for each observation whether it happened during dawn (between dawn and sunriseEnd), day (between sunriseEnd and sunset), evening (between sunset and nightStart) or night (before nightEnd or after nightStart)

