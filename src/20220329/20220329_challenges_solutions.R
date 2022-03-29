library(tidyverse)

## CHALLENGE 1 & 2

#' no R needed


## CHALLENGE 3.1

# read data
habitats_raw <- read_csv("./data/20220329/20220329_habitat_types.txt")

# separate each value by semicolon into several rows
habitats <- habitats_raw %>% separate_rows(hab_type, sep = ";")


## CHALLENGE 3.2

# read data
habitats2_raw <- read_csv("./data/20220329/20220329_habitat_types_2.txt")

habitats2 <- pivot_longer(data = habitats2_raw,
                          cols = -c(polygon_id,year),
                          names_to = "habitat_type",
                          values_to = "values")

# clean up (remove habitats where FALSE)
habitats2 <- habitats2 %>%
  filter(values == TRUE) %>%
  select(-values)

## CHALLENGE 3.3

#' Do you get warnings?
#' Sure, the number of columns is not constant: data are NOT TIDY!
camtrap_data <- read_csv("./data/20220329/20220329_camtrap_data.txt",
                         col_names = paste0("V",seq_len(21)))

camtrap_data

# read metadata table
camtrap_meta <- read_csv("./data/20220329/20220329_camtrap_metadata.txt")

# get columns related to deployments from the metadata table
cols_deployments <- c(
  "deployment_id", "location_id", "location_name", "longitude", "latitude",
  "start", "end","setup_by", "camera_id", "camera_model", "camera_interval",
  "camera_height", "bait_use", "feature_type", "tags", "comments"
)

# you can also do it without copy pasting the column names, but it was not
# asked
cols_deployments <-
  camtrap_meta %>%
  filter(record_type == "deployment") %>%
  pull(column_name)
cols_deployments

# get rows with deployments info
deployments <-
  camtrap_data %>%
  filter(V1 == "deployment") %>%
  select(-V1)

# set right column names
names(deployments)[1:length(cols_deployments)] <- cols_deployments
# remove extra columns starting with "V"
deployments <-
  deployments %>%
  select(!starts_with("V"))

# final deployments table (data.frame)
deployments

# based on metadata table, define columns of multimedia
cols_multimedia <- c(
  "multimedia_id", "deployment_id", "sequence_id", "timestamp", "file_path",
  "file_name", "file_mediatype", "comments"
)

# if you want to extract the column names without copy pasting, you can!
cols_multimedia <-
  camtrap_meta %>%
  filter(record_type == "multimedia") %>%
  pull(column_name)
cols_multimedia

# get rows with multimedia info
multimedia <-
  camtrap_data %>%
  filter(V1 == "multimedia") %>%
  select(-V1)

# set right column names
names(multimedia)[1:length(cols_multimedia)] <- cols_multimedia
# remove extra columns starting with "V"
multimedia <-
  multimedia %>%
  select(!starts_with("V"))

multimedia

# based on metadata table, define columns of observations
cols_observations <- c(
  "observation_id", "deployment_id", "sequence_id", "multimedia_id",
  "timestamp", "observation_type", "sensor_method", "camera_setup",
  "scientific_name", "vernacular_name", "count", "age", "sex", "behaviour",
  "individual_id", "classification_method", "classified_by",
  "classification_timestamp", "classification_confidence", "comments"
)

# if you want to extract the column names without copy pasting, you can!
cols_observations <-
  camtrap_meta %>%
  filter(record_type == "observation") %>%
  pull(column_name)
cols_observations

# get rows with observations info
observations <-
  camtrap_data %>%
  filter(V1 == "observation") %>%
  select(-V1)

# set right column names
names(observations)[1:length(cols_observations)] <- cols_observations
# remove extra columns starting with "V"
observations <-
  observations %>%
  select(!starts_with("V"))

observations



## BONUS CHALLENGE

rings <- read_csv("./data/20220329/20220329_bird_rings_untidy.txt")

rings

rings_tidy <-
  rings %>%
  mutate(bird_id = row_number()) %>%
  select(-inscription) %>%
  pivot_longer(cols = c("first_inscription", "last_inscription"),
               names_to = "ring_id",
               values_to = "inscription") %>%
  select(bird_id, inscription, euring_code) %>%
  # remove duplicated rows when firs inscription is equal to last inscription
  group_by(bird_id, euring_code) %>%
  distinct(bird_id, inscription, euring_code) %>%
  mutate(ring_order = row_number())

rings_tidy
