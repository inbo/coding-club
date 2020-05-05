library(tidyverse) # to do datascience
library(readxl) # to read Excel files

### IMPORT DATASETS ###

## 20200121_overzicht_resistentie_2013_2015.xlsx

# this doesn't work: more than 1000 empty rows (1047) in last 6 columns:
# they are set as logicals and therefore you get error message
resistentie_df <- read_xlsx(path = "./data/20200121/20200121_overzicht_resistentie_2013_2015.xlsx")
# this works: set a sufficient higher rows as guess_max to guess the type of the column:
resistentie_df <- read_xlsx(path = "./data/20200121/20200121_overzicht_resistentie_2013_2015.xlsx",
                    guess_max = 2000) # Still, you loose colors: colors are not tidy data :-(


## 20200121_manta_master_database_2014_2015.xlsx

# this will not work: columns are grouped.
# Group names in first column.Column names in second column.
manta_df <- read_xlsx("./data/20200121/20200121_manta_master_database_2014_2015.xlsx")
# this will work: skip first row
manta_df <- read_xlsx("./data/20200121/20200121_manta_master_database_2014_2015.xlsx",
                      skip = 1)


## 20200121_ecosysteem_areaal_clc.csv

# it's a semicolon separated file and Wouter let me know that comma is the
# decimal mark!
ecosysteem_clc_df <- read_delim(
  file = "./data/20200121/20200121_ecosysteem_areaal_clc.csv",
  delim = ";",
  locale = locale(decimal_mark = ","))
# via read_csv2() you obtain a message about interpretation of comma and dot.
# The comma is interpreted as decimal mark, the dot as grouping mark.
# This behavior is well documented. Type ?read_csv2 and read the very first
# section (Description) ;-)
# So this will work fine:
ecosysteem_clc_df <- read_csv2("./data/20200121/20200121_ecosysteem_areaal_clc.csv")


## 20200121_derep_mincount80_cleaned_tagged.txt

# Open txt files first to see how they look like and get right delimiter
derep_df <- read_delim(
  file = "./data/20200121/20200121_derep_mincount80_cleaned_tagged.txt",
  delim = "\t"
)
# a lot of columns, you can check specifications of all cols by typing
# spec(derep_df)
# tab separated files can be opened by read_tsv(). No need to specify delimiter.
derep_df <- read_tsv("./data/20200121/20200121_derep_mincount80_cleaned_tagged.txt")


## 20200121_occurrence_iNaturalist_researchgrade_obs.txt
gbif_inat_df <- read_delim(
  file = "./data/20200121/20200121_occurrence_iNaturalist_researchgrade_obs.txt",
  delim = "\t"
)
# of via read_tsv()
gbif_inat_df <- read_tsv(
  file = "./data/20200121/20200121_occurrence_iNaturalist_researchgrade_obs.txt"
)


## 20200121_dataVlinders.csv
# this is a file with semicolon as delimiter (separator),
# and dot (.) as decimal mark.
vlinders_df <- read_delim(file = "./data/20200121/20200121_dataVlinders.csv",
                          delim = ";")
# Maybe via read_csv2()? No, the dot is in read_csv2 ALWAYS interpreted as
# grouping mark, the comma ALWAYS as decimal mark. Providing your own locale to
# read_csv2() doesn't work. This behavior is not a bug. See
# https://github.com/tidyverse/readr/issues/1061. So this will not work:
# vlinders_df <- read_csv2("./data/20200121/20200121_dataVlinders.csv", locale =
# locale(decimal_mark = "."))

## 20200121_hyacint_ename_2008_2018.xlsx
# multiple sheets? Multiple variables
# First sheet
hyacint1_df <- read_excel("./data/20200121/20200121_hyacint_ename_2008_2018.xlsx")
# Second sheet
hyacint2_df <- read_excel("./data/20200121/20200121_hyacint_ename_2008_2018.xlsx",
                          sheet = 2, na = "NA")

## 20200121_meff_lu_soorten.csv
meff_soorten_df <- read_delim("./data/20200121/20200121_meff_lu_soorten.csv",
                              delim = ",")


## 20200121_osmerus_rclubevdb.xlsx
osmerus_df <- read_excel("./data/20200121/20200121_osmerus_rclubevdb.xlsx")


## 20200121_qry_abiotiek_all.xlsx
abiotiek_df <- read_excel(path = "./data/20200121/20200121_qry_abiotiek_all.xlsx")


## 20200121_urban_gaia_policy.xlsx
urban_gaia_df <- read_excel("./data/20200121/20200121_urban_gaia_policy.xlsx")


## 20200121_191007_WUP_SGBP_Bio_2018.xlsx Skip first row with names of groups of
#columns: nice for humans, bad for computers
# You can select sheet by number (1 for first sheet, 2 for second sheet etc. )
# You can select sheet by name as below
wup_sgbf_bio_df <- read_excel("./data/20200121/20200121_191007_WUP_SGBP_Bio_2018.xlsx",
                          skip = 1,
                          sheet = "Bio")

wup_sgbf_vl_df <- read_excel("./data/20200121/20200121_191007_WUP_SGBP_Bio_2018.xlsx",
                              skip = 1,
                              sheet = "Vlaanderen")

# head of your data.frame, some examples
head(wup_sgbf_bio_df)
head(hyacint2_df)
# Notice how it adapts based on the width of your console pane. Try to make it
# wider and repeat the commando :-)

# structure of your data.frame:
str(wup_sgbf_bio_df)
str(hyacint2_df)

# are you interested in the class of one column only? Use class()
class(wup_sgbf_bio_df$`Waterlichaam code`)
class(wup_sgbf_bio_df$`Beoordeling eco`)
class(hyacint2_df$plot)

# basic summary statistics of each column with summary()
summary(wup_sgbf_bio_df)

# number of rows and number of columns?
nrow(wup_sgbf_bio_df)
ncol(wup_sgbf_bio_df)
nrow(hyacint2_df)
ncol(hyacint2_df)

### Challenge 2

# return distinct rows (remove duplicated rows, if present)
distinct(wup_sgbf_bio_df)
distinct(hyacint2_df)

# count() how many NAs you have in a column
filter(hyacint2_df, !is.na(`stem height 2018`))


# assign the filtered data.frame to a new variable
filtered_hyacint2_df <- filter(hyacint2_df, !is.na(`stem height 2018`))

filtered_wup_sgbf_vl_df <- filter(wup_sgbf_vl_df, !is.na(`Aantal Vlaamse waterlichamen`))

# select columns via select()
select(hyacint2_df, `stem height 2018`, `stem height 2008`)
select(wup_sgbf_vl_df, `Aantal Vlaamse waterlichamen`, `fysico-chemie (n=311)`)

## Intermezzo

# How to combine these kind of operations without saving all intermediate steps?

# Basic R syntax: quite unreadable :-(
hacint2_df_mini <- select(filter(hyacint2_df, !is.na(`stem height 2018`)), `stem height 2018`, `stem height 2008`)
# splitting on multiple rows can help, but still difficult to read
select(filter(wup_sgbf_vl_df, !is.na(`Aantal Vlaamse waterlichamen`)),
       `Aantal Vlaamse waterlichamen`, `fysico-chemie (n=311)`)

# using %>% operator (one of the main reasons to use tidyverse) both readability
# and writability is improved
hacint2_df_mini <-
  hyacint2_df %>%
  filter(!is.na(`stem height 2018`)) %>%
  select(`stem height 2018`, `stem height 2008`)
hacint2_df_mini

wup_sgbf_vl_df_mini <-
  wup_sgbf_vl_df %>%
  filter(!is.na(`Aantal Vlaamse waterlichamen`)) %>%
  select(`Aantal Vlaamse waterlichamen`, `fysico-chemie (n=311)`)
wup_sgbf_vl_df_mini

# INTERMEZZO 2 and Challenge 3: ggplot recipe

# data
ggplot(urban_gaia_df)

# data + mapping
ggplot(urban_gaia_df, mapping = aes(x = Year))

# data + mapping + geometry
ggplot(urban_gaia_df, mapping = aes(x = Year)) +
  geom_bar()
ggplot(urban_gaia_df, mapping = aes(x = `Area of interest`, y = Year)) +
  geom_boxplot()

# Another example

# data
ggplot(abiotiek_df)
# data and mapping.
ggplot(abiotiek_df, mapping = aes(x = AfstandBron, y = Cl))
# data, mapping and geometry
ggplot(abiotiek_df, mapping = aes(x = AfstandBron, y = Cl)) + geom_point()

# maybe better with boxplot?
ggplot(abiotiek_df, mapping = aes(x = AfstandBron, y = Cl)) + geom_boxplot()

# How Cl vs EC_veld_25grC?
ggplot(abiotiek_df, mapping = aes(x = EC_veld_25grC, y = Cl)) + geom_point()
# Get the trend (basic smoother)
ggplot(abiotiek_df, mapping = aes(x = EC_veld_25grC, y = Cl)) + geom_smooth()

# You can put the mapping (aesthetics) in the geometry
ggplot(abiotiek_df) +
  geom_point(aes(x = EC_veld_25grC, y = Cl))
# You can also add other parameters, such as transparency (alpha)
ggplot(abiotiek_df) +
  geom_point(aes(x = EC_veld_25grC, y = Cl), alpha = 0.2)
# You can add (+) titles, write your own x- or y-labels, etc.
ggplot(abiotiek_df) +
  geom_point(aes(x = EC_veld_25grC, y = Cl), alpha = 0.2) +
  labs(title = "My great plot",
       subtitle = "I can add a subtitle, wow!",
       x = "No idea what I have on the x-axis",
       y = "Chlorine")
