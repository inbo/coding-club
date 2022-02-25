# install readr if not already installed
if (!"readr" %in% installed.packages()) {
  install.packages("readr")
}
# install readxl if not already installed
if (!"readxl" %in% installed.packages()) {
  install.packages("readxl")
}
if (!"googlesheets4" %in% installed.packages()) {
  install.packages("googlesheets4")
}
library(readr)
library(readxl)
library(googlesheets4)

## CHALLENGE 1

# read data file  `20220224_gent_groeiperwijk.txt` containing the demographic
# evolution of Ghent districts from 1999 to 2009


# read sheet `ALL DATA` from Excel datafile `20220224_manta_2014_2015.xlsx` with
# manta related data


# Read butterfly related data file `20220224_butterflies_counts.txt` with
# semicolon (;) as delimiter, dot (.) as decimal mark and question mark (?) as
# NA. Read only the first 500 rows. Be sure column `Date` is parsed as
# datetime by using `format = "%d/%m/%Y %H:%M:%S"`.



## CHALLENGE 2: googlesheets

# 1. Read the sheet `HyaHoVrBl` from a googlesheet about [hyacint coverage in Ename](https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg)(https://docs.google.com/spreadsheets/d/1Tc8U-ud4dEcxgOojS80w7gdQQ-Ac85A4dN-u47NSmYg) paying attention to import all columns correctly


# Extra: column names contain spaces, let's get rid of them with janitor package
if (!"janitor" %in% installed.packages()) {
  install.packages("janitor")
}


# 2. Get metadata of the Google Sheet file



# 3. But what if you don't want to allow tidyverse API to get access to your INBO
# Google account? Well, you can publish the sheet to the web as csv and then
# import it via `read_delim()` or `read_csv()`. Note: This method is useful if you
# don't have to import a lot of Googlesheets and they can be publicly available.
# Read the csv generated in this way by using this link:




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



## CHALLENGE 3: encoding
# Read file 20220224_latin-1_character_set.txt


# Read file 20220224_turkish_iso8859-9_encoding.txt. Use View() to open the data.frame.
# Do you get the same while printing the data.frame on Console? Why?
