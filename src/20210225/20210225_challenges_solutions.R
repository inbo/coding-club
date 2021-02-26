library(readr)
library(readxl)
library(googlesheets4)

## CHALLENGE 1

#' read a set of research grade observations from text file
#' `20210125_occurrence_iNaturalist_researchgrade_obs.txt`
inat_df <- read_tsv(
  "./data/20210225/20210125_occurrence_iNaturalist_researchgrade_obs.txt"
)

#' read data file  `20210225_gent_groeiperwijk.csv` containing the demographic evolution of Ghent districts from 1999 to 2009
gent_demography_df <- read_csv2("./data/20210225/20210225_gent_groeiperwijk.csv",
                                quote = "'"
)

#' read sheet `ALL DATA` from Excel datafile `20210225_manta_2014_2015.xlsx` with
#' manta related data.
manta_df <- read_xlsx("./data/20210225/20210225_manta_2014_2015.xlsx",
                      skip = 1,
                      sheet = "ALL DATA"
)

#' Read butterfly related data file `20210225_butterflies_counts.txt` with
#' semicolon (;) as delimiter, dot (.) as decimal mark and question mark (?) as
#' NA. Read only the first 500 rows. Be sure column `Date` is parsed as
#' datetime by using `format = "%d/%m/%Y %H:%M:%S"`.
butterflies_df <- read_delim(file = "./data/20210225/20210225_butterflies_counts.txt",
                             delim = ";",
                             na = "?",
                             n_max = 500,
                             col_types = cols(
                               Date = col_datetime(format = "%d/%m/%Y %H:%M:%S"))
)

#' as read_* imports a tibble, if number of columns is limited, you can inspect
#' the column specifications just by printing the data.frame on screen
butterflies_df

#' How to examine the column specifications for the dataframes you have just read?
spec(manta_df) #doesn't work because it wasn't read by readr, but readxl package
spec(butterflies_df) # works

## CHALLENGE 2: googlesheets

#' 1. Read the sheet `HyaHoVrBl` from a googlesheet about [hyacint coverage in Ename](https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg)(https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg) paying attention to import all columns correctly
hyacint_cov_df <- read_sheet("https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg",
                             sheet = "HyaHoVrBl",
                             na = c("NA", "na", "NaN"))

hyacint_cov_df # the column names contain spaces, let's get rid of them with janitor package

if (!"googlesheets4" %in% installed.packages()) {
  install.packages("janitor")
}

hyacint_cov_df <- hyacint_cov_df %>%
  janitor::clean_names()
hyacint_cov_df # clean names!

#' or the ID only instead of URL and sheet number instead of sheet name
hyacint_cov_df <- read_sheet("1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg",
                                  sheet = 2,
                                  na = c("NA", "na", "NaN")) %>%
  janitor::clean_names()
hyacint_cov_df

#' 2. Get metadata of the googlesheet in 1
gs4_get(ss = "1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg")

#' Notice how the nominal extent in rows and columns is way higher than the
#' dataframe dimensions: read_sheet() trims automatically all additional empty
#' rows/columns

#' 3. But what if you don't want to allow tidyverse API to get access to your INBO
#' Google account? Well, you can publish the sheet to the web as csv and then
#' import it via `read_delim()` or `read_csv()`. Note: This method is useful if you
#' don't have to import a lot of Googlesheets and they can be publicly available.
#' Read the csv generated in this way by using this link:
#'
hyacint_cov_link <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRFAWYrZmgBRPXQnw3Io5T_29ZrGkH-Ds4yulFd02MIPcalGPtzyQ3cujgAdwzfnRNYIWQFf1oKjgM3/pub?gid=1007047746&single=true&output=csv"

hyacint_cov_df <- read_csv(file = hyacint_cov_link,
                           na = c("NA", "na", "NaN"))
hyacint_cov_df

## CHALLENGE 3

#' You  get meteorological data from Wallonia (Waterloo) in Walloon! 1. Parse
#' column `Hour` as a column containing number (by default read as a character
#' column) 2. Parse column `AV Quality Code` as a column containing numbers, not
#' as logicals 3. Parse the column `Date` as a date column. Hint: give a look to
#' the readr's [`locale`
#' vignette](https://readr.tidyverse.org/articles/locales.html) and check the
#' structure of a typical date names locale, e.g. nl <- locale("nl")$date_names.
#' This is a nice datetime [format specifications
#' compendium](https://www.stat.berkeley.edu/~s133/dates.html)

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
  encoding = "UTF-8", # important to rightly decode special characters (Windows)
  decimal_mark = ".",
  grouping_mark = "'",
)

walloon

rainfall_waterloo_df <- read_csv(
  "./data/20210225/20210225_rainfall_waterloo.csv",
  skip = 6,
  col_types = cols(
    Hour = col_double(),
    `AV Quality Code` = col_number(),
    Date = col_date(format = "%a %d %B %Y")),
  locale = walloon
)

# Even better, you can store the date format in the locale as well
walloon_with_date_format <- locale(date_names(
  day= days_walloon,
  mon = months_walloon,
  day_ab = days_abbr_walloon,
  mon_ab = months_abbr_walloon),
  encoding = "UTF-8", # important to rightly decode special characters (Windows)
  decimal_mark = ".",
  grouping_mark = "'",
  date_format = "%a %d %B %Y"
)

walloon_with_date_format

rainfall_waterloo_df <- read_csv(
  "./data/20210225/20210225_rainfall_waterloo.csv",
  skip = 6,
  # no need to specify the col_date format anymore in col_types()
  col_types = cols(
    Hour = col_double(),
    `AV Quality Code` = col_number()),
  locale = walloon_with_date_format
)

rainfall_waterloo_df

#' Notice the col_number() instead of col_double() for columns containing
#' numbers with grouping mark, i.e. `Absoulte Value`, `AV Quality Code`
spec(rainfall_waterloo_df)

#' you can change the guess_max default so that readr takes more rows to guess
#' the type of each column. In this way you don't need to specify the type for
#' column `AV Quality Code`
rainfall_waterloo_df <- read_csv(
  "./data/20210225/20210225_rainfall_waterloo.csv",
  skip = 6,
  col_types = cols(
    Hour = col_double(),
    Date = col_date(format = "%a %d %B %Y")),
  guess_max = 2000,
  locale = walloon
)

spec(rainfall_waterloo_df)


#' Notice how col_double() will not allow you to use grouping marks at all as it
#' reads IEEE doubles only, e.g. it doesn't support grouping marks.
#' https://github.com/tidyverse/readr/issues/1119
rainfall_witparsing_failures <-
  read_csv(
  "./data/20210225/20210225_rainfall_waterloo.csv",
  skip = 6,
  col_types = cols(
    Hour = col_double(),
    `AV Quality Code` = col_double(), # this is not allowed and returns parsing failures!
    Date = col_date(format = "%a %d %B %Y")),
  locale = walloon
)
