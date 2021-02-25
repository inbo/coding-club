library(readr)
library(readxl)
library(googlesheets4)

## CHALLENGE 1

#' read a set of research grade observations from text file
#' `20210125_occurrence_iNaturalist_researchgrade_obs.txt`



#' read data file  `20210225_gent_groeiperwijk.csv` containing the demographic evolution of Ghent districts from 1999 to 2009



#' read sheet `ALL DATA` from Excel datafile `20210225_manta_2014_2015.xlsx` with
#' manta related data.



#' Read butterfly related data file `20210225_butterflies_counts.txt` with
#' semicolon (;) as delimiter, dot (.) as decimal mark and question mark (?) as
#' NA. Read only the first 500 rows. Be sure column `Date` is parsed as
#' datetime by using `format = "%d/%m/%Y %H:%M:%S"`.



#' How to examine the column specifications for the dataframes you have just read?




## CHALLENGE 2: googlesheets

#' 1. Read the sheet `HyaHoVrBl` from a googlesheet about [hyacint coverage in Ename](https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg)(https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg) paying attention to import all columns correctly



#' 2. Get metadata of the googlesheet in 1



#' 3. But what if you don't want to allow tidyverse API to get access to your INBO
#' Google account? Well, you can publish the sheet to the web as csv and then
#' import it via `read_delim()` or `read_csv()`. Note: This method is useful if you
#' don't have to import a lot of Googlesheets and they can be publicly available.
#' Read the csv generated in this way by using this link:
#'
hyacint_cov_link <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRFAWYrZmgBRPXQnw3Io5T_29ZrGkH-Ds4yulFd02MIPcalGPtzyQ3cujgAdwzfnRNYIWQFf1oKjgM3/pub?gid=1007047746&single=true&output=csv"




## CHALLENGE 3

#' You  get the data file `20210225_rainfall_waterloo.csv` containing
#' meteorological data from Wallonia (Waterloo) in Walloon and using apex as
#' grouping mark (e.g. 1000 -> 1'000)
#'
#' Be aware of these three aspects:
#'
#' 1. Parse column `Hour` as a column containing number (by default read as a
#' character column) 2. Parse both columns `Absolute Value` and `AV Quality
#' Code` as numeric columns paying attention to define the right
#' `grouping_mark`. Hint: check the structure of a typical locale, e.g. nl <-
#' locale("nl") 3. Parse the column `Date` as a date column. Hint: look at the
#' readr's [`locale`
#' vignette](https://readr.tidyverse.org/articles/locales.html) and again check
#' the structure of a typical _locale_. For finding the right datetime parsing,
#' this is a nice datetime [format specifications
#' compendium](https://www.stat.berkeley.edu/~s133/dates.html) These are the
#' days, months and correspondent abbreviations in Walloon:

days_walloon <- c("londi", "mårdi", "mierkidi", "djudi", "vénrdi",
  "semdi", "dimegne")
months_walloon <- c("djanvî","fevrî", "måss", "avri", "may", "djun", "djulete",
                    "awousse","setimbre", "octôbe", "nôvimbe", "decimbe")
days_abbr_walloon <- c("lon", "mår", "mie", "dju", "vén", "sem", "dim")
months_abbr_walloon <- c("djan","fev", "mås", "avr", "may", "djun", "djul",
                         "awou","set", "oct", "nôv", "dec")


