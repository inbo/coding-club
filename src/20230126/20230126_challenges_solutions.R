library(tidyverse)
library(lubridate)

# read data
persian_hogweed <- read_tsv("./data/20230126/20230126_persian_hogweed_2022_scandinavia.txt")


## CHALLENGE 1

# via ymd
persian_hogweed$date <- lubridate::ymd(
  paste(persian_hogweed$year,
        persian_hogweed$month,
        persian_hogweed$day)
)

# via make_date
persian_hogweed$date <- lubridate::make_date(year = persian_hogweed$year,
                                            month = persian_hogweed$month,
                                            day = persian_hogweed$day)

persian_hogweed

# week day in your own locale (in my case week days returned in Dutch)
persian_hogweed$weekday <- lubridate::wday(persian_hogweed$date,
                                           label = TRUE,
                                           abbr = FALSE)

# in other languages via locale, e.g. English
persian_hogweed$weekday <- lubridate::wday(persian_hogweed$date,
                                           label = TRUE,
                                           abbr = FALSE,
                                           locale = "English")

# create the "stamp" (it's a function!)
persian_hogweed_stamp <- stamp_date(
  x = "Occurrence recorded on Monday, Jan 23, 2023",
  locale = "English"
)

# use it
persian_hogweed$date_stamp <- persian_hogweed_stamp(persian_hogweed$date)

View(persian_hogweed)

# Create column label
# First, make a new stamp
stamp_for_label <- stamp(" on Fri, 25-9-22.", locale = "English", orders = "admy")
persian_hogweed$label <- stringr::str_c(
  "Occurrence of ",
  persian_hogweed$species,
  " found in ",
  persian_hogweed$countryCode,
  stamp_for_label(persian_hogweed$date),
  sep = ""
)

persian_hogweed$label[1:10] # first 10 labels for check


## INTERMEZZO

as_datetime("2020-08-01 09:00:00", tz = "Asia/Tehran")
as_datetime("2020-08-01 09:00:00", tz = "America/Chicago")

as_datetime("2020-08-01 09:00:00", tz = "CET")
as_datetime("2020-08-01 09:00:00", tz = "CEST")


## CHALLENGE 2

# Read deployments. ISO datetimes are immediately interpreted as datetimes
deployments <- readr::read_csv(
  "./data/20230126/20230126_deployments.txt",
  na = ""
)
deployments$start


# Add a column called local_start and local_end with local time showing the
# timezone. The deployments are all in Belgium. Tip: read the
# [time-zones][https://lubridate.tidyverse.org/reference/lubridate-package.html#time-zones)
# section of the "Get started".
deployments$start_local <- lubridate::with_tz(deployments$start,
                                              tzone = "Europe/Brussels")
deployments$start_local
deployments$start

deployments$end_local <- lubridate::with_tz(deployments$end,
                                            tzone = "Europe/Brussels")
deployments$end_local
deployments$end


# Solve the "bug": recalculate local times
deployments$start_local <- lubridate::force_tz(deployments$start,
                                               tzone = "Europe/Brussels")
deployments$start_local
deployments$start

deployments$end_local <- lubridate::force_tz(deployments$end,
                                             tzone = "Europe/Brussels")
deployments$end_local
deployments$end

# Correct start and end columns.
# Notice that UTC is not a timezone, but you can use it as value for tzone
# argument
deployments$start <- lubridate::with_tz(deployments$start_local, tzone = "UTC")
deployments$end <- lubridate::with_tz(deployments$end_local, tzone = "UTC")

deployments$end
deployments$end_local


# Calculate the duration of each deployment and
# store it in column `duration`
deployments$duration <- deployments$end - deployments$start
# Notice the class "difftime" of the new column
class(deployments$duration)
deployments$duration

# You can convert them to class "duration"
deployments$duration <- as.duration(deployments$duration)
class(deployments$duration)
# duration is always in seconds and it shows the largest time unit, e.g. weeks
# in this case
deployments$duration
# What are the differences between difftime and duration? Not so many. Check
# https://lubridate.tidyverse.org/reference/make_difftime.html#details


# Get hour and day of start deployments
deployments$day_start <- lubridate::day(deployments$start)
deployments$hour_start <- lubridate::hour(deployments$start)


## CHALLENGE 3

# Select the occurrences of persian hogweed coming from the [Finnish
# Biodiversity Information Facility](https://laji.fi/en) (FinBIF), i.e. the
# occurrences with occurrenceID starting with `http://tun.fi/`. Store them in a
# new data.frame, `finbif_occs`.
finbif_occs <- persian_hogweed %>%
  filter(stringr::str_starts(occurrenceID, pattern = "http://tun.fi/"))
str(finbif_occs)
head(finbif_occs)
finbif_occs

# Retrieve the authorship from column `scientificName`, i.e. the string after the value in column `species`. Store it in a new column called `authorship`.
persian_hogweed$authorship <- stringr::str_trim(
  stringr::str_remove(persian_hogweed$scientificName,
                      pattern = persian_hogweed$species)
)

# Get the "internal" ID for each occurrence of `persian_hogweed` dataframe. Such ID is the number after the very last colon (`:`), dot (`.`) or slash (`/`), e.g. `105853683` for `urn:lsid:artportalen.se:sighting:105853683` or `36631219` for `http://tun.fi/MKC.36631219` or `63a587a8d5de65595547a609#Unit1` for `http://tun.fi/KE.176/63a587a8d5de65595547a609#Unit1`. Tip: one of [these functions](https://stringr.tidyverse.org/reference/str_split.html) and a simple regex can help you a lot!
persian_hogweed$internalID <- stringr::str_split_i(
  string = persian_hogweed$occurrenceID,
  pattern = "[:|.|/]",
  i = -1)

persian_hogweed$internalID


## BONUS CHALLENGES - strings

# Regex is very powerful but also complex. Fortunately, we have the cheat sheet, regex101 and the web is full of regex questions/answers :-) The occurrences in `finbif_occs` are coming from different projects. They can be identified by the letters following the prefix `"http://tun.fi/"` and preceding the dot, e.g.  `MKC` for `http://tun.fi/MKC.36631219`,  `JX` for `http://tun.fi/JX.1443935#3`.

# Extract the project acronyms from the `occurrenceID` of `finbif_occs` and
# store them in column `project`. Tip: check the cheatsheet and use
# [regex101](https://regex101.com) website.
finbif_occs$project <- stringr::str_replace(
  string = finbif_occs$occurrenceID,
  pattern = ".*[http://tun.fi/]([^.]+)[.].*",
  replacement = "\\1"
)

# Metal rings, typically applied to animals such as birds, should be expressed
# as a letter followed by a sequence of 10 digits. If less than 10 digits are
# present on the ring, dots should be added between the letter and the digits.
# Example: `E123456` should become `E.....123456`.
metal_rings <- c("A1234567890", "B123456789", "C12345678", "D1234567", "E123456")
metal_rings_improved <- str_c(
  stringr::str_extract(metal_rings, "[A-Z]"),
  stringr::str_dup(
    string = ".",
    times = 10 - stringr::str_length(stringr::str_extract(metal_rings, "[0-9]+"))
  ),
  stringr::str_extract(metal_rings, "[0-9]+"),
  sep = ""
)
metal_rings_improved

## BONUS CHALLENGES - dates

# The provided code in 20230126_challenges.R analyzes produces a plot where data
# are grouped by week. How to leave the plot as it is but putting breaks and
# ticks at month level? Tip: use scale_x_continuous() and define the right
# values for `breaks` and `labels`.

# read data of Phlogophora meticulosa
pheno_phlogo <- readr::read_delim(
  file = "./data/20230126/20230126_pheno_phlogo.txt",
  delim = ";"
)
head(pheno_phlogo)

# add year and week number
pheno_phlogo$year <- lubridate::year(pheno_phlogo$datum)
pheno_phlogo$week <- lubridate::week(pheno_phlogo$datum)
head(pheno_phlogo)

# define periods
pheno_phlogo <- pheno_phlogo %>%
  mutate(Period = case_when(year >= 1980 & year <= 2012 ~ "2003_2012",
                            year >= 2013 & year <= 2022 ~ "2013_2022"))
head(pheno_phlogo)

df_pheno_plot <- pheno_phlogo %>%
  dplyr::group_by(species_nl, Period, week) %>%
  dplyr::summarise(nObs = n())
head(df_pheno_plot)

df_sum_species <- df_pheno_plot %>%
  dplyr::group_by(species_nl, Period) %>%
  dplyr::summarise(sum = sum(nObs))
head(df_sum_species)

df_pheno_plot <- dplyr::inner_join(df_pheno_plot,
                                   df_sum_species,
                                   by = c("species_nl", "Period")) %>%
  dplyr::select(species_nl,
                Period,
                week,
                nObs,
                sum)

head(df_pheno_plot)

df_pheno_plot <- df_pheno_plot %>%
  dplyr::mutate(pObs = 100*nObs/sum)
df_pheno_plot

month <- seq(lubridate::ymd("2020-01-01"),
             lubridate::ymd("2020-12-01"),
             by = "1 month")

## this is the first part of the solution!! ##
month_breaks <- lubridate::yday(month) / 365 * 53 + 1
month_label <- lubridate::month(month, label = TRUE)
##

cbbPalette <- c("#000000", "#E69F00")


## plot

p <- ggplot(df_pheno_plot,
            aes(x = week,
                y = pObs,
                fill = Period)) +
  geom_bar(stat = "identity",
           position = position_dodge(width = 0.9)) +
  xlab("Month") +
  ylab("observations (%)") +
  scale_fill_manual(values = cbbPalette) +
  ## this is second part of the solution ##
  scale_x_continuous(breaks = month_breaks,
                     labels = month_label,
                     limits = c(min(month_breaks), max(month_breaks)))
p
