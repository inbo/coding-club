library(tidyverse)
library(lubridate)
library(suncalc)

# CHALLENGE 1.1

# parse these character columns with lubridate
datetimes_to_parse <- tibble(
  datetime1 = c("2020-10-24 01:01:45", "2020-10-27 14:23:50"),
  datetime2 = c("2020/24/10 01;01;45am", "2020/27/10 02;23;50pm"),
  datetime3 = c("24?10?99 1-1am", "27&10&20 14:23")
)

datetimes_to_parse <-
  datetimes_to_parse %>%
  mutate(
    datetime1 = ymd_hms(datetime1),
    datetime2 = ydm_hms(datetime2),
    datetime3 = dmy_hm(datetime3))
datetimes_to_parse

#' Give a look also to the very useful guess_formats() function
#' https://lubridate.tidyverse.org/reference/guess_formats.html


#' It's always good to know which parsing lubridate uses. You get to know it by
#' settting options(lubridate.verbose = TRUE).
#' A list of with all parsing formulas (%Y, %y, %d, ...) can be found here:
#' https://lubridate.tidyverse.org/reference/parse_date_time.html#details
options(lubridate.verbose = TRUE)

#' You can use as_datetime() function but then you have to specify the format
#' yourself if the datetime is not in ISO format
as_datetime("2020-10-01 12:23:34") # this works
as_datetime("01-2020-10 02:23:34am") # this doesn't work, format needed
as_datetime("01-10-2020 02:23:34am",
            format = "%d-%m-%Y %H:%M:%S%p") # format needed


# CHALLENGE 1.2

# one date
inbo_string <- "2006-04-01"
inbo_date <- ymd(inbo_string)
# or as_date(inbo_string) because date is written in standard way yyyy-mm-dd
wday(inbo_string, label = TRUE, abbr = FALSE)
wday(inbo_string)

# wday() works with multiple dates as well (vector). Handy!
institutes_string <- c(`in` = "1985-07-17", # `in` because in is a reserved name
                       ibw = "1991-03-13",
                       inbo = "2006-04-01")
institutes_date <- ymd(institutes_string)
# Just number of the weekday
wday(institutes_date)
# Abbreviated weekday
wday(institutes_date, label = TRUE)
# Not abbreviated weekday
wday(institutes_date, label = TRUE, abbr = FALSE)

# Change locale to get week day in other language
wday(institutes_date, label = TRUE, abbr = FALSE, locale = "French")
wday(institutes_date, label = TRUE, abbr = FALSE, locale = "Italian")
wday(institutes_date, label = TRUE, abbr = FALSE, locale = "Polish")
wday(institutes_date, label = TRUE, abbr = FALSE, locale = "German")

# with dfs
institutes_df <- tibble(institute = c("in", "ibw", "inbo"),
                      date = ymd(institutes_string))
institutes_df <-
  institutes_df %>%
  mutate(week_day = wday(date, label = TRUE, abbr = FALSE))
institutes_df


# CHALLENGE 1.3

#' Stamp these dates as in this example:
#' "The institute has been founded on Saturday, Apr 1st, 2006"
foundation_stamp <- stamp_date("The institute has been founded on Monday, Apr 1, 1900")
foundation_stamp(institutes_df$date)


# CHALLENGE 1.4

# difftime of IN and IBW
difftime_in <- institutes_date[3] - institutes_date[1]
difftime_in
class(difftime_in)

difftime_ibw <- institutes_date[3] - institutes_date[2]
difftime_ibw

#' duration is a class from lubridate
#' difftime is base R
duration_ibw <- as.duration(difftime_ibw)
duration_ibw
class(duration_ibw)
duration_in <- as.duration(difftime_in)
duration_in

#' duration is compatible with difftime (i.e. you can sum or subtract)
difftime_in + duration_ibw
class(difftime_in + duration_ibw)


# INTERMEZZO

#' UTC is the time standard and it is therefore used by default when defining a
#' datetime
time_in_utc <- ymd_hms("2020-10-27 10:00:00")
time_in_utc

#' Show how to setup a time zone. Continent/City works most of the time
ymd_hms("2020-08-01 09:00:00", tz = "Asia/Tehran")
ymd_hms("2020-08-01 09:00:00", tz = "Europe/Brussels")

#' But in case of US West Coast not
ymd_hms("2020-08-01 09:00:00", tz = "US/Sacramento")
#' This works
ymd_hms("2020-08-01 09:00:00", tz = "US/Pacific")

#' Some time zones abbreviations work
as_datetime("2020-08-01 09:00:00", tz = "CET")
as_datetime("2020-08-01 09:00:00", tz = "EET")

#' But others not
ymd_hms("2020-08-01 09:00:00", tz = "PT") # Pacific Time

#' Note the automatic conversion to CEST (Central Europe Summer Time) or
#' EEST (European Eastern Summer Time) if the daytime falls in daylight saving
#' time period of the year.
#' However, if you pass CEST/EEST as tz argument, it will not work and you will
#' get the GMT version:
as_datetime("2020-08-01 09:00:00", tz = "CEST")
as_datetime("2020-08-01 09:00:00", tz = "EEST")

#' Showing differences between intervals and periods
#' while daylight saving occurs
start_datetime <- as_datetime("2020-10-25 01:00:00", tz = "CET")
# add a period (periods track changes in clock times)
start_datetime + hours(2)
#' add a duration (durations track the passage of physical time which deviates
#' from clock time when irregularities occur)
start_datetime + dhours(2)

end_datetime <- as_datetime("2020-10-25 03:00:00", tz = "CET")
end_datetime - start_datetime # difftime are durations


# CHALLENGE 2

# INTRO
#' We need to get a better insight of the behavior of the mammals of the
#' Red Forest (Ucraine), one of the most contaminated areas in the world today.
#' To do so, the brave Jim, Emma and Sander (FIS team) went there and installed
#' a camera trap deployment. Read file 20201027_cameratrap_df.txt
data_cameratrap <- read_tsv("./data/20201027/20201027_cameratrap_df.txt")

# CHALLENGE 2.1

#' datetimes in column image_sequence are in UTC. Get correspondent clock times
data_cameratrap <-
  data_cameratrap %>%
  mutate(image_sequence_datetime_tz = with_tz(image_sequence_datetime, tzone = "EET"))
# check results
data_cameratrap %>%
  select(image_sequence_datetime, image_sequence_datetime_tz)
data_cameratrap$image_sequence_datetime_tz[1]

#' with_tz() works not only to convert from UTC, but it can be used to switch
#' between time zones. For example, add clock time info at Brussels time
data_cameratrap <-
  data_cameratrap %>%
  mutate(image_sequence_datetime_tz_bxl = with_tz(image_sequence_datetime_tz,
                                                  tzone = "Europe/Brussels"))
#' Add time zone info at pacific time US/Pacific
data_cameratrap <-
  data_cameratrap %>%
  mutate(image_sequence_datetime_tz_pacific = with_tz(image_sequence_datetime_tz,
                                                      "US/Pacific"))

# Notice that dataframes don't show timezone,
#' neither on console nor via View()
data_cameratrap %>% select(starts_with("image_sequence"))

# Printing (part of) the column as vector does the job
data_cameratrap$image_sequence_datetime[1:2]
data_cameratrap$image_sequence_datetime_tz[1:2]
data_cameratrap$image_sequence_datetime_tz_bxl[1:2]
data_cameratrap$image_sequence_datetime_tz_pacific[1:2]

# CHALLENGE 2.2

#' Contrarily to image_sequence_datetime, the datetimes in
#' camera_deployment_start and camera_deployment_end  are already in clock time.
#' Add the timezone information to these columns
data_cameratrap <-
  data_cameratrap %>%
  mutate(camera_deployment_start_tz = force_tz(camera_deployment_start,
                                               tzone = "EET"),
         camera_deployment_end_tz = force_tz(camera_deployment_end,
                                             tzone = "EET"))
# check results
data_cameratrap$camera_deployment_start[1]
data_cameratrap$camera_deployment_start_tz[1]
data_cameratrap$camera_deployment_end[1]
data_cameratrap$camera_deployment_end_tz[1]

#' Again, notice that dataframes don't show timezone,
#' neither on console nor via View()
data_cameratrap %>% select(starts_with("camera_deployment"))



# CHALLENGE 3.1


# Extract hour and day information as extra columns
data_cameratrap <-
  data_cameratrap %>%
  mutate(image_sequence_day_tz = day(image_sequence_datetime_tz),
         image_sequence_hour_tz = hour(image_sequence_datetime_tz))

#' if you did it using image_sequence_datetime instead of
#' image_sequence_datetime_tz you get wrong day/hour as you are not
#' synchronized to time zone!


# CHALLENGE 3.2

#' Use suncalc package to get for each observation whether it happened during
#' dawn (between dawn and sunriseEnd), day (between sunriseEnd and sunset),
#' evening (between sunset and nauticalDusk) or night (before dawn or after
#' nauticalDusk)

prep_df <- tibble(date = as_date(data_cameratrap$image_sequence_datetime),
                  lat = data_cameratrap$lat,
                  lon = data_cameratrap$lng)
sun_datetimes <- getSunlightTimes(
  data = prep_df,
  keep = c("dawn", "sunriseEnd", "sunset", "nauticalDusk")) %>%
  as_tibble()

data_cameratrap <-
  data_cameratrap %>%
  mutate(image_sequence_date = as_date(
    image_sequence_datetime)
  ) %>%
  bind_cols(sun_datetimes %>% select(-c(date, lat, lon)))

data_cameratrap <-
  data_cameratrap %>%
  mutate(moment_of_the_day = case_when(
    image_sequence_datetime < dawn |
      image_sequence_datetime > nauticalDusk ~ "night",
    image_sequence_datetime > dawn &
      image_sequence_datetime < sunriseEnd ~ "dawn",
    image_sequence_datetime > sunriseEnd &
      image_sequence_datetime < sunset ~ "day",
    image_sequence_datetime > sunset &
      image_sequence_datetime < nauticalDusk ~ "evening"
  ))

data_cameratrap %>% group_by(moment_of_the_day) %>% count()
