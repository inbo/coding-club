library(tidyverse)

## Challenge 1: files and directories

##  Challenge 2: improve the column names

urban_gaia <- read_delim(here::here("data", "20200225_urban_gaia_policy.txt"),
                         delim = "\t")


##########################################
##  Challenge 3: improve the code style ##
##########################################

# tip 1: use CTRL + I for automatic code alignment
# tip 2: use lintr::lint() to check this file for faults against style


library(tidyverse)
library(here)

# Read something
df <- read_csv(here('data', '20191024_species.csv'), na = "")

# Do something

df$species_id <- str_to_lower(
  df$species_id
)
df$taxa <- str_to_lower( df$taxa )


### Do something 2

species_id_label <- str_sort(df$species_id)

## beware!! str_sort within mutate will sort a specific column without sorting the other columns in the dataframe

df %>%
  mutate(species_id = str_sort(species_id))

# to sort a dataframe by a column use arrange(colname). To sort a dataframe by multiple columns use arrange(colname1, colname2, colname3, ...)
df %>%
  arrange(species_id)


### extract species_id labels longer than 2 letters
species_id_long <- df$species_id[
  str_length(df$species_id) > 2
  ]

### tidyverse version
species_id_long <-
  df %>%
    filter(str_length(species_id) > 2) %>%
      pull(species_id)

# Add canonicalName as genus + species
df2 <-
  df %>%
  mutate(canonicalName = str_c(genus, species, sep = " "))


# Remove something from a column
Species.dfTaxaClean <-
  df %>%
  # str_remove or str_remove_all, in this case no differences
  mutate(taxa = str_remove(taxa, "-not censused" )
  )

SpeciesDf.Clean <-
  df %>%
  # remove tabs
  mutate(new_col = str_remove_all(authorship,
                                           pattern = "\\t")) %>%
  # remove only NAs that are preceded by | or followed by |
  mutate(new_col = str_remove_all(new_col,
                                           pattern = "((?<=\\|)NA)|(NA(?=\\|))")) %>%
  # remove vertical pipes
  mutate(new_col = str_remove_all(new_col,
                                           pattern = "\\|")) %>%

  # remove spaces at the end
  mutate(new_col = str_remove_all(new_col,
                                           pattern = "[:space:]+$")) %>%
  # remove punctuation at the end
  mutate(new_col = str_remove_all(new_col,
                                           pattern = "[:punct:]$"))

View(SpeciesDf.Clean)

if (nrow(df) <= nrow(df2)) print(paste("Number of rows:", nrow(df))) else print(paste("Number of rows:", nrow(df2)))
