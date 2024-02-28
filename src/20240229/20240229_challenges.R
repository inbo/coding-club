library(tidyverse)

rodentia <- readr::read_tsv(
  file = "./data/20240229/20240229_rodentia.txt",
  na = "",
  guess_max = 136300)


## CHALLENGE 1






## Challenge 2A






## Challenge 2B

rodentia_selection <- rodentia %>%
  dplyr::filter(species %in% c("Ondatra zibethicus",
                        "Rattus norvegicus"))

rodentia_selection_n <- rodentia_selection %>%
  group_by(species,year) %>%
  count()






## Challenge 3





