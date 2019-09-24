library(tidyverse)
library(here)
library(INBOtheme)


## CHALLENGE 1

# file path
area_districts_f <- here("data", "oppervlakte_straat_wijken_Brugge.csv")
area_districts_brugge <- read_delim(area_districts_f, delim = ";")

# minimum area
min_area <- min(area_districts_brugge$OPPERVLAKTE, na.rm = TRUE) # min
# district with smallest area
smallest_district <- area_districts_brugge$NAAM[which.min(area_districts_brugge$OPPERVLAKTE)]

# maximum area
max_area <- max(area_districts_brugge$OPPERVLAKTE, na.rm = TRUE) # max
# district with biggest area
biggest_district <- area_districts_brugge$NAAM[which.max(area_districts_brugge$OPPERVLAKTE)]

# average area
average_area <- mean(area_districts_brugge$OPPERVLAKTE, na.rm = TRUE) # mean
# the district with area most similar to average
average_district <- area_districts_brugge$NAAM[which.min(abs(area_districts_brugge$OPPERVLAKTE - average_area))]

# summarize these info in data frame (output)
info_districts <- tibble(min_area = min_area,
                         smallest_district = smallest_district,
                         max_area = max_area,
                         biggest_district = biggest_district,
                         average_area = average_area,
                         average_district = average_district)

# WRITE YOUR FUNCTION HERE! ###
get_info_districts <- function(area_districts) {
  # minimum area
  min_area <- min(area_districts$OPPERVLAKTE, na.rm = TRUE) # min
  # distict with smallest area
  smallest_district <- area_districts$NAAM[which.min(area_districts$OPPERVLAKTE)]

  # maximum area
  max_area <- max(area_districts$OPPERVLAKTE, na.rm = TRUE) # max
  # district with biggest area
  biggest_district <- area_districts$NAAM[which.max(area_districts$OPPERVLAKTE)]

  # average area
  average_area <- mean(area_districts$OPPERVLAKTE, na.rm = TRUE) # mean
  # the district with area most similar to average
  average_district <- area_districts$NAAM[which.min(abs(area_districts$OPPERVLAKTE - average_area))]

  # summarize these info in data frame (output)
  info_districts <- tibble(min_area = min_area,
                           smallest_district = smallest_district,
                           max_area = max_area,
                           biggest_district = biggest_district,
                           average_area = average_area,
                           average_district = average_district)
  return(info_districts)
}

get_info_districts(area_districts = area_districts_brugge)

################################################################################

## CHALLENGE 2

# Adapt the function get_info_districts so that you can reuse your function to
# tackle also "oppervlakte_straat_wijken_Antwerpen.csv" without
# altering the data itself

area_districts_f_antwerpen <- here("data", "oppervlakte_straat_wijken_Antwerpen.csv")
area_districts_antwerpen <- read_delim(area_districts_f_antwerpen, delim = ";")

get_info_districts2 <- function(area_districts, col_district, col_area) {
  # minimum area
  min_area <- min(area_districts[[col_area]], na.rm = TRUE) # min
  # distict with smallest area
  smallest_district <- area_districts[[col_district]][which.min(area_districts[[col_area]])]

  # maximum area
  max_area <- max(area_districts[[col_area]], na.rm = TRUE) # max
  # district with biggest area
  biggest_district <- area_districts[[col_district]][which.max(area_districts[[col_area]])]

  # average area
  average_area <- mean(area_districts[[col_area]], na.rm = TRUE) # mean
  # the district with area most similar to average
  average_district <- area_districts[[col_district]][which.min(abs(area_districts[[col_area]] - average_area))]

  # summarize these info in data frame (output)
  info_districts <- tibble(min_area = min_area,
                           smallest_district = smallest_district,
                           max_area = max_area,
                           biggest_district = biggest_district,
                           average_area = average_area,
                           average_district = average_district)
  return(info_districts)
}

get_info_districts2(area_districts = area_districts_antwerpen,
                   col_district = "Wijken",
                   col_area = "Oppervlakte straat|2019")

get_info_districts2(area_districts = area_districts_brugge,
                   col_district = "NAAM",
                   col_area = "OPPERVLAKTE")

################################################################################

## CHALLENGE 3

# read data
goose_counts <-
  read_csv(here("data", "20190829_goose_counts_2018.csv"))

# remove Dutch neighboring provinces in case present
goose_counts <-
  goose_counts %>%
  filter(province != "NL_Noord-Brabant" & province != "NL_Zeeland")

# counts geese per year
goose_counts_summary_plot <-
  goose_counts %>%
  group_by(year) %>%
  summarize(total_counts_year = sum(counts, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(total_counts_year)) %>%
  ggplot(aes(x = year, y = total_counts_year)) +
  geom_point()  +
  theme(axis.text.x = element_text(angle = 90)) +
  ggtitle("Total counts by year")
goose_counts_summary_plot

# counts geese per province
goose_counts_summary_plot <-
  goose_counts %>%
  group_by(province) %>%
  summarize(total_counts_province = sum(counts, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(total_counts_province)) %>%
  ggplot(aes(x = province, y = total_counts_province)) +
  geom_point()  +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Total counts by province")

goose_counts_summary_plot

# counts geese per species (commonName)
goose_counts_summary_plot <-
  goose_counts %>%
  group_by(commonName) %>%
  summarize(total_counts_species = sum(counts, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(total_counts_species)) %>%
  ggplot(aes(x = commonName, y = total_counts_species)) +
  geom_point()  +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Total counts by species")
goose_counts_summary_plot

## Let's do it without repeating ourselves by writing a function!

# WRITE YOUR FUNCTION HERE! ###
counts_summary <- function(df, col_to_group) {
  df %>%
    group_by(!!sym(col_to_group)) %>%
    summarize(total_counts = sum(counts, na.rm = TRUE)) %>%
    ungroup() %>%
    arrange(desc(total_counts)) %>%
    ggplot(aes(x = !!sym(col_to_group), y = total_counts)) +
    geom_point() +
    ylab("total counts") +
    xlab(col_to_group) +
    ggtitle(paste("Total counts by", col_to_group)) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# columns for summary
cols_for_summary_plots <- c("year", "province", "commonName")

# initalize list of summary plots
goose_counts_summary_plots <-
  list()
# for loop to make plots
for (parameter in cols_for_summary_plots) {
  goose_counts_summary_plot <-
    goose_counts %>%
    counts_summary(col_to_group = parameter)
  goose_counts_summary_plots[[parameter]] <- goose_counts_summary_plot
}

goose_counts_summary_plots$year
goose_counts_summary_plots$province
goose_counts_summary_plots$commonName
