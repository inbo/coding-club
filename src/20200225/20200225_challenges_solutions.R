#install.packages("tidyverse")
library(tidyverse)
#install.packages("here")
library(here)
#install.packages("janitor")
library(janitor)

########################################
## Challenge 1: files and directories ##
########################################

source(here("src", "20200225", "20200225_create_messy_project.R"))
create_messy_project()
# this will create a folder "messy_project", open the Rstudio project
# (messy_project.Rproj) in that folder to start the challenge
# when done, come back to this coding-club Rstudio project

# possible restructured project

# Data structure Ming:
# .
# ├── README.md
# ├── data
# │   └── raw
# │       ├── 2017-06-21_bird-observation.csv
# │       └── 2020-01_bird-ringing-in-belgium.csv
# ├── messy_project.Rproj
# ├── reports
# │   └── figures
# │       └── 01_plot-bird-obs.jpg
# └── src
# ├── analysis
# │   ├── 01_data-analysis.R
# │   └── 02_revised-data-analysis.R
# ├── data
# │   └── 01_data-preparation.R
# ├── global
# │   └── 01_helpers.R
# ├── plots
# │   └── 01_plot-bird-obs.R
# └── tmp
# └── 2018-07_analysis-test.R

# or

# Data structure Emma:
# 1             data/20170621_bird_obs.csv
# 2        data/202001_birdringing_raw.csv
# 3                    messy_project.Rproj
# 4 output/figure01_count_per_gemeente.jpg
# 5                         src/analysis.R
# 6                        src/data_prep.R
# 7                          src/helpers.R
# 8                   src/visualisations.R

# or


# Data structure Nicolas:
#   1                 data/2017-06-21_birds-observations.csv
# 2                            data/2020-01_dirty-data.csv
# 3                                    messy_project.Rproj
# 4                            reports/figures/figure1.jpg
# 5                              src/01_data-preparation.R
# 6                                src/02_analysis-final.R
# 7  src/02_analysis-finalfinal-i-should-use-git-instead.R
# 8                        src/02_analysis-test-july2018.R
# 9                           src/03_data-visualizations.R
# 10                                         src/helpers.R

# or


# Data structure Britt:
#   1  data/20170621_birdobservations.csv
# 2   data/20200100_birdringing_bel.csv
# 3                 messy_project.Rproj
# 4     output/birdspermunicipality.jpg
# 5        src/20180700_analysis_test.R
# 6                src/analysis_paper.R
# 7  src/analysis_paper_afterrevision.R
# 8                   src/createimage.R
# 9             ""  src/datapreparation.R
# 10              src/helperfunctions.R

# possible solution to figure problem

birds <- read_csv(here("data/2017-06-21_bird-obs.csv"))
fig1 <- ggplot(birds, aes(x = PlaatsGemeente)) +
  geom_bar()
ggsave(here("output/fig1_nr-birds-gemeente.jpg"),
       fig1)

# or if you want a nicer looking figure
fig1 <- ggplot(birds, aes(x = PlaatsGemeente)) +
  geom_bar(fill = "darkgreen") +
  xlab("Locality") +
  ylab("Number of birds") +
  scale_y_continuous(breaks = c(2, 4, 6, 8)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 15, face = "bold"),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 15),
        panel.background = element_rect(fill = "white",
                                        colour = "grey",
                                        size = 1,
                                        linetype = "solid"),
        panel.grid.major = element_line(size = 0.5,
                                        linetype = "solid",
                                        colour = "grey"))





#############################################################
##  Challenge 2: improve the column names (using R syntax) ##
#############################################################

urban_gaia <- read_delim(here("data", "20200225", "20200225_urban_gaia_policy.txt"),
                         delim = "\t")

names(urban_gaia)

urban_gaia <- urban_gaia %>%
  clean_names() %>%
  rename(ugbi_mentioned = ugbi_directly_or_indirectly_mentioned,
         ugbi_central = ugbi_central_to_approach)

names(urban_gaia)



##########################################
##  Challenge 3: improve the code style ##
##########################################

# tip 1: use CTRL + I for automatic code alignment
# tip 2: use lintr::lint() to check this file for faults against style

# the below code is copy-pasted from a previous coding club (and messed up a bit)


library(tidyverse)
library(here)

# Read something
bird_obs <- read_csv(here("data", "20191024", "20191024_species.csv"), na = "")

# ALT + -: inserts an assignment, including spaces " <- "
# CTRL + SHIFT + M: inserts a pipe, including spaces " %>% "

# Do something

bird_obs <- bird_obs %>%
  mutate(species_id = str_to_lower(species_id),
         taxa = str_to_lower(taxa))


### Do something 2

species_id_label <- str_sort(bird_obs$species_id)


### extract species_id labels longer than 2 letters
species_id_long <- bird_obs$species_id[str_length(bird_obs$species_id) > 2]

### tidyverse version
species_id_long <- bird_obs %>%
  filter(str_length(species_id) > 2) %>%
  pull(species_id)

# Add canonicalName as genus + species
bird_obs2 <- bird_obs %>%
  mutate(canonicalName = str_c(genus, species, sep = " "))

# Remove something from a column
species_bird_obs_taxa_clean <-
  bird_obs %>%
  # str_remove or str_remove_all, in this case no differences
  mutate(taxa = str_remove(taxa, "-not censused" )
  )

species_bird_obs_clean <-
  bird_obs %>%
  # remove tabs
  mutate(new_col = str_remove_all(authorship,
                                  pattern = "\\t"),
         # remove only NAs that are preceded by | or followed by |
         new_col = str_remove_all(new_col,
                                  pattern = "((?<=\\|)NA)|(NA(?=\\|))"),
         # remove vertical pipes
         new_col = str_remove_all(new_col,
                                  pattern = "\\|"),

         # remove spaces at the end
         new_col = str_remove_all(new_col,
                                  pattern = "[:space:]+$"),
         # remove punctuation at the end
         new_col = str_remove_all(new_col,
                                  pattern = "[:punct:]$"))

View(species_bird_obs_clean)

if (nrow(bird_obs) <= nrow(bird_obs2)) {
  print(
    paste("Number of rows:",
          nrow(bird_obs)
    )
  )
} else {
  print(
    paste("Number of rows:",
          nrow(bird_obs2)
    )
  )
}
