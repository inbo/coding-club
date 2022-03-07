library(readr)
library(readxl)
library(googlesheets4)

## CHALLENGE 1

# read data file  `20220224_gent_groeiperwijk.txt` containing the demographic
# evolution of Ghent districts from 1999 to 2009
gent_demography_df <- read_csv2("./data/20220224/20220224_gent_groeiperwijk.txt",
                                quote = "'"
)

# read sheet `ALL DATA` from Excel datafile `20220224_manta_2014_2015.xlsx` with
# manta related data
manta_df <- read_xlsx("./data/20220224/20220224_manta_2014_2015.xlsx",
                      skip = 1,
                      sheet = "ALL DATA"
)

# Read butterfly related data file `20220224_butterflies_counts.txt` with
# semicolon (;) as delimiter, dot (.) as decimal mark and question mark (?) as
# NA. Read only the first 500 rows. Be sure column `Date` is parsed as
# datetime by using `format = "%d/%m/%Y %H:%M:%S"`.
butterflies_df <- read_delim(
  file = "./data/20220224/20220224_butterflies_counts.txt",
  delim = ";",
  na = "?",
  n_max = 500,
  col_types = cols(Date = col_datetime(format = "%d/%m/%Y %H:%M:%S"))
)

# as read_* imports a tibble, if number of columns is limited, you can inspect
# the column specifications just by printing the data.frame on screen
butterflies_df

# How to examine the column specifications for the dataframes you have just read?
spec(manta_df) #doesn't work because it wasn't read by readr, but readxl package
spec(butterflies_df) # works

## CHALLENGE 2: googlesheets

# 1. Read the sheet `HyaHoVrBl` from a googlesheet about [hyacint coverage in Ename](https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg)(https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg) paying attention to import all columns correctly
hyacint_cov_df <- read_sheet("https://docs.google.com/spreadsheets/d/1qHcx3eEhAv6LBI9R2kmV4IHgxdBw_Eq1ho6yuvi2xJM/edit?usp=sharing",
                             sheet = "HyaHoVrBl",
                             na = c("NA", "na", "NaN"))

# Extra: column names contain spaces, let's get rid of them with janitor package
hyacint_cov_df

if (!"googlesheets4" %in% installed.packages()) {
  install.packages("janitor")
}

hyacint_cov_df <- hyacint_cov_df %>%
  janitor::clean_names()
hyacint_cov_df # column names are cleaned

# Alternatively you can use the ID instead of the entire URL and sheet number
# instead of sheet name
hyacint_cov_df <- read_sheet("1qHcx3eEhAv6LBI9R2kmV4IHgxdBw_Eq1ho6yuvi2xJM",
                             sheet = 2,
                             na = c("NA", "na", "NaN")) %>%
  janitor::clean_names()
hyacint_cov_df

# 2. Get metadata of the Google Sheet file
gs4_get(ss = "1qHcx3eEhAv6LBI9R2kmV4IHgxdBw_Eq1ho6yuvi2xJM")

# Notice how the nominal extent in rows and columns is way higher than the
# dataframe dimensions: read_sheet() trims automatically all additional empty
# rows/columns

# 3. But what if you don't want to allow tidyverse API to get access to your INBO
# Google account? Well, you can publish the sheet to the web as csv and then
# import it via `read_delim()` or `read_csv()`. Note: This method is useful if you
# don't have to import a lot of Googlesheets and they can be publicly available.
# Read the csv generated in this way by using this link:
#
hyacint_cov_link <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vTpyMEyzb_M8vrSFUSzTegR4czallWdSUsDCuivdUIwdy7g8PIfrEJtgGBIXPV2UKKRaIZxN7o2O085/pub?gid=1007047746&single=true&output=csv"

hyacint_cov_df <- read_csv(file = hyacint_cov_link,
                           na = c("NA", "na", "NaN"))
hyacint_cov_df

## CHALLENGE 3: locale

# You  get meteorological data from Wallonia (Waterloo) in Walloon! 1. Parse
# column `Hour` as a column containing number (by default read as a character
# column) 2. Parse column `AV Quality Code` as a column containing numbers, not
# as logicals 3. Parse the column `Date` as a date column. Hint: give a look to
# the readr's [`locale`
# vignette](https://readr.tidyverse.org/articles/locales.html) and check the
# structure of a typical date names locale, e.g. nl <- locale("nl")$date_names.
# This is a nice datetime [format specifications
# compendium](https://www.stat.berkeley.edu/~s133/dates.html)

days_walloon <- c("londi", "mårdi", "mierkidi", "djudi", "vénrdi",
  "semdi", "dimegne")
months_walloon <- c("djanvî","fevrî", "måss", "avri", "may", "djun", "djulete",
                    "awousse","setimbre", "octôbe", "nôvimbe", "decimbe")
days_abbr_walloon <- c("lon", "mår", "mie", "dju", "vén", "sem", "dim")
months_abbr_walloon <- c("djan","fev", "mås", "avr", "may", "djun", "djul",
                         "awou","set", "oct", "nôv", "dec")

walloon <- locale(date_names(
  day= days_walloon,
  mon = months_walloon,
  day_ab = days_abbr_walloon,
  mon_ab = months_abbr_walloon),
  encoding = "UTF-8",
  decimal_mark = ".",
  grouping_mark = "'",
  date_format = "%a %d %B %Y"
)

walloon

rainfall_waterloo_df <- read_csv(
  "./data/20220224/20220224_rainfall_waterloo.txt",
  skip = 6,
  col_types = cols(
    Date = col_date(format = walloon$date_format),
    Hour = col_double(),
    `AV Quality Code` = col_number()),
  locale = walloon
)

rainfall_waterloo_df

# why two dates (vén 3 djun 2016 and vén 1 djulete 2016) are not parsed (run
# problems(rainfall_waterloo_df)) is still
# a mistery. Reported to readr in issue:
# https://github.com/tidyverse/readr/issues/1383


# Notice the col_number() instead of col_double() for columns containing
# numbers with grouping mark, i.e. `Absoulte Value`, `AV Quality Code`
spec(rainfall_waterloo_df)

# you can change the guess_max default so that readr takes more rows to guess
# the type of each column. In this way you don't need to specify the type for
# column `AV Quality Code`
rainfall_waterloo_df <- read_csv(
  "./data/20220224/20220224_rainfall_waterloo.txt",
  skip = 6,
  col_types = cols(
    Date = col_date(format = walloon$date_format),
    Hour = col_double()
    ),
  guess_max = 2000,
  locale = walloon
)

spec(rainfall_waterloo_df)


# Notice how col_double() will NOT allow you to use grouping marks at all as it
# reads IEEE doubles only, e.g. it doesn't support grouping marks.
# https://github.com/tidyverse/readr/issues/1119
rainfall_with_parsing_failures <-
  read_csv(
  "./data/20220224/20220224_rainfall_waterloo.txt",
  skip = 6,
  col_types = cols(
    Date = col_date(format = walloon$date_format),
    Hour = col_double(),
    `AV Quality Code` = col_double(), # this is not allowed and returns parsing failures!
    ),
  locale = walloon
)


## CHALLENGE 3: encoding

# Read file 20220224_latin-1_character_set.txt

latin1_chrs <- read_tsv("./data/20220224/20220224_latin-1_character_set.txt",
                        locale = locale(encoding = "iso8859-1")
)
latin1_chrs


# Read file 20220224_turkish_iso8859-9_encoding.txt. Use View() to open the data.frame.
# Do you get the same while printing the data.frame on Console? Why?

turkish_chrs <- read_tsv(
  "./data/20220224/20220224_turkish_iso8859-9_encoding.txt",
  locale = locale(encoding = "iso8859-9")
)
View(turkish_chrs)
turkish_chrs
