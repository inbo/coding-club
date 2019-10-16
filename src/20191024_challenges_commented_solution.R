library(tidyverse)
library(here)

## Challlenge 1

species_df <- read_csv(here("data", "20191024_species.csv"), na = "")

### Set columns `species_id` and `taxa` lowercase

species_df$species_id <- str_to_lower(species_df$species_id)
species_df$taxa <- str_to_lower(species_df$taxa)

# or using tidyverse functions (dplyr)
species_df <-
  species_df %>%
  mutate(species_id = str_to_lower(species_id),
         taxa = str_to_lower(taxa))

### sort vector of species_id label alphabetically

species_id_label <- str_sort(species_df$species_id)

### extract species_id labels longer than 2 letters
species_id_long <- species_df$species_id[which(str_count(species_df$species_id) > 2)]

### tidyverse version
species_id_long <-
  species_df %>%
  filter(str_count(species_id) > 2) %>%
  pull(species_id)


## CHALLENGE 2

### genus + species

# tidyverse style
df_complete <-
  df %>%
  mutate(canonicalName = str_c(genus, species, sep = " "))

# or in old style R
df_complete <- df
df_complete[["canonicalName"]] <- str_c(df$genus, df$species, sep =  " ")

# Remove census related label from taxa column

species_df_taxa_clean <-
  species_df %>%
  # str_remove or str_remove_all, in this case no differences
  mutate(taxa = str_remove(taxa, "-not censused"))

## INTERMEZZO

example_string <- "I. love. the. 2019(!!) INBO. Coding. Club! Session. of. 24/10/2019...."

# How to detect/remove/extract:

#   - any digit? (maybe first show all three function (str_detect, ...), but
#   then choose one of it. I would choose str_remove as it is useful for
#   challenge 3, for everyday use, and you see the original string changing.
str_detect(example_string, pattern = "[:digit]") # or "[\\d]"
str_remove(example_string, pattern = "[:digit:]") # or "[\\d]"
str_remove_all(example_string, pattern = "[:digit:]") # or "[\\d]"
str_extract(example_string, pattern = "[:digit:]") # or "[\\d]"
str_extract(example_string, pattern = "[:digit:]") # or "[\\d]"

# any "." (nice to show the need of \\ before the "." as "." is a special
# character. See in cheatsheet: every character except a new line) SHOW THE DIFFERENCE.
str_remove_all(example_string, pattern = ".") # Oh no, everything is gone
str_remove_all(example_string, pattern = "\\.") # this is correct

# the last .
str_remove_all(example_string, pattern = "\\.$") # show anchor "$"

# All . at the end
str_remove_all(example_string, pattern = "\\.+$") # show quantifier "+"

#   - any extra "." , i.e. any . preceded by .
str_remove_all(example_string, pattern = "(?<=\\.)\\.") # show look around (?<=)



## Challenge 3

species_df_clean <-
  species_df %>%
  # remove tabs
  mutate(authorship_clean = str_remove_all(authorship,
                                           pattern = "\\t")) %>%
  # remove vertical pipes
  mutate(authorship_clean = str_remove_all(authorship_clean,
                                           pattern = "\\|")) %>%
  # remove NAs
  mutate(authorship_clean = str_remove_all(authorship_clean,
                                           pattern = "NA")) %>%
  # remove spaces at the end
  mutate(authorship_clean = str_remove_all(authorship_clean,
                                           pattern = "[:space:]$")) %>%
  # remove punctuation at the end
  mutate(authorship_clean = str_remove_all(authorship_clean,
                                           pattern = "[:punct:]$"))

View(species_df_clean)

## Bonus challenge

### bird observation (easy)
bird_obs <- read_csv(here("data", "20191024_bird_observations.csv"), na = "")

bird_obs[["observation_location"]] <- str_c(
  str_c(bird_obs$PlaatsGemeente, bird_obs$PlaatsToponym,
        sep = ","),
  bird_obs$PlaatsToponymDetail,
  sep = ":"
)

# tidyverse style
bird_obs <-
  bird_obs %>%
  mutate(observation_location = str_c(
    str_c(PlaatsGemeente, PlaatsToponym,
          sep = ","),
    PlaatsToponymDetail, sep = ":")
)

### bird observation (slightly more difficult) It's something I wrote for a
### project about ring data. I think it is very useful to mention it as it
### provides the right feeling to participants: we are not showing theoretical,
### strange problems: we discuss REAL problems! Never forget it. This is one of
### the principles of Coding Club...
bird_obs2 <- read_csv(here("data", "20191024_bird_observations_with_na.csv"),
                      na = "")

bird_obs2 <-
  bird_obs2 %>%
  mutate(observation_location = if_else(!is.na(PlaatsToponym),
                                        str_c(PlaatsGemeente, PlaatsToponym,
                                              sep = ","),
                                        PlaatsGemeente)) %>%
  mutate(observation_location = if_else(!is.na(PlaatsToponymDetail),
                                        str_c(observation_location,
                                              PlaatsToponymDetail,
                                              sep = ":"),
                                        observation_location))

View(bird_obs2)
