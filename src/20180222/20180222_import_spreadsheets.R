
# All load functions expect the R project in a main folder, with `./data` as a
# subfolder in the project!
library(tidyverse)

# import survey_data_spreadsheet_tidy.csv
data <- read_delim("./data/20180222/20180222_survey_data_spreadsheet_tidy.csv", ";",
                   escape_double = FALSE,
                   trim_ws = TRUE)

# import brandganzen
library(readxl)
brandganzen <- read_excel("./data/20180123/20180123_brandganzen.xlsx")

#  import bevolkingsevolutie Gent
bevolking <- read_delim("./data/20180123/20180123_gent_groeiperwijk.csv", delim = ";")

# import surveys and species
surveys <- read_csv("./data/20180222/20180222_surveys.csv")
species <- read_csv("./data/20180222/20180222_species.csv")

#-------------------------------------

# import data cameratraps
cameratrap <- read_csv("./data/20180123/20180123_observations_NPHK_cameratrapping.csv")

# stierkikker response data
stierkikker <- read_csv("./data/20180123/20180123_stierkikker_formulieren_reacties.csv")

# import code klemskerke rainfall
klemskerke <- read_csv("./data/20180123/20180123_rainfall_klemskerke_clean.csv")
