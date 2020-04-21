#install.packages("tidyverse")
library(tidyverse)
#install.packages("here")
library(here)
#install.packages("janitor")
library(janitor)

########################################
## Challenge 1: files and directories ##
########################################

source(here("src", "20200225_create_messy_project.R"))
create_messy_project()
# this will create a folder "messy_project", open the Rstudio project
# (messy_project.Rproj) in that folder to start the challenge
# when done, come back to this coding-club Rstudio project

#############################################################
##  Challenge 2: improve the column names (using R syntax) ##
#############################################################

urban_gaia <- read_delim(here("data", "20200225_urban_gaia_policy.txt"),
                         delim = "\t")

##########################################
##  Challenge 3: improve the code style ##
##########################################

# tip 1: use CTRL + I for automatic code alignment
# tip 2: use lintr::lint() to check this file for faults against style

# the below code is copy-pasted from a previous coding club (and messed up a bit)


library(tidyverse)
library(here)

# Read something
my.df<-read_csv(here('data','20191024_species.csv'),na="")

# Do something

my.df$species_id <- str_to_lower(
  my.df$species_id
)
my.df$taxa = str_to_lower( my.df$taxa )


### Do something 2

species.id_label<-str_sort(my.df$species_id)


### extract species_id labels longer than 2 letters
species_id_long = my.df$species_id[ str_length(my.df$species_id) > 2]

### tidyverse version
species_id_long <-my.df %>%filter(str_length(species_id) > 2) %>%pull(species_id)

# Add canonicalName as genus + species
my.df2<-my.df %>% mutate(canonicalName = str_c(genus, species, sep = " "))

# Remove something from a column
Species.my.dfTaxaClean <-
  my.df %>%
  # str_remove or str_remove_all, in this case no differences
  mutate(taxa = str_remove(taxa, "-not censused" )
  )

Speciesmy.df.Clean <-
  my.df %>%
  # remove tabs
  mutate(new_col = str_remove_all(authorship,
                                           pattern = "\\t")) %>%
  # remove only NAs that are preceded by | or followed by |
  mutate(new_col = str_remove_all(new_col, pattern = "((?<=\\|)NA)|(NA(?=\\|))")) %>%
  # remove vertical pipes
  mutate(new_col = str_remove_all(new_col,
                                           pattern = "\\|")) %>%

  # remove spaces at the end
  mutate(new_col = str_remove_all(new_col,
                                           pattern = "[:space:]+$")) %>%
  # remove punctuation at the end
  mutate(new_col = str_remove_all(new_col,
                                           pattern = "[:punct:]$"))

View(Speciesmy.df.Clean)

if (nrow(my.df)<=nrow(my.df2)) print(paste("Number of rows:",nrow(my.df))) else print(paste("Number of rows:", nrow(my.df2)))
