# 1. Open  a file:
library(readr)
bird_rings <- read_csv("./data/20181217_bird_rings.csv")

# 2. Preview of bird_rings
bird_rings %>% head()

# 3. Make a df with vernacular names in English and Dutch
vernacular_names <- date.frame(
  species = c(
  "Larus fuscus",
  "Larus argentatus",
  "Circus aeruginosus",
  "Haematopus ostralegus")
  vernacular_name_en = c(
    "Lesser Black-backed Gull",
    "Herring Gull",
    "Western Marsh Harrier",
    "Eurasian Oystercatcher"),
  vernacular_name_nl <- c(
    "Kleine mantelmeeuw",
    "Zilvermeeuw",
    "Bruine kiekendief",
    "Scholekster"
  ))

# 4. Add vernacular names to bird_rings df
bird_rings_with_names <-
  bird_rings %>%
  left_join(vernacular_name,
            by = species)

# Preview of bird_rings_with_names
bird_rings_with_names %>% head

# 5. Select birds with L in ring number
birds_with_L <-
  bird_rings_with_names %>%
  filter(str_detect(ring_number, pattern = "L"))
