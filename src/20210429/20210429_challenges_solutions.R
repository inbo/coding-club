library(tidyverse)


# load aquatic trap data
df <- read_csv("./data/20210429/20210429_aquatictrap_data.csv")

## CHALLENGE 1

# Display the columns "id" and "weight_total"
select(df, id, weight_total)


# Display the distinct values of "location_id" and "location_name"
distinct(df, location_id, location_name)


# Display data where both "weight" and "weight_total" are missing
filter(df, is.na(weight), is.na(weight_total)) # comma is equivalent of & in condition statements


#' Order the rows by number of trapped individuals ("n_individuals"). How to order in
#' increasing order? And in decreasing order?
arrange(df, n_individuals)

arrange(df, desc(n_individuals))


#' Improve previous ordering by adding "date" as second variable (in case
#' same number of individuals occurs). Order both variables in descending order
arrange(df, desc(n_individuals), desc(date))


#' Display "id", "species", "n_individuals", "weight" and "weight_total" for
#' observations with non-empty values of "weight_total"
result <- select(df, id, species, n_individuals, weight, weight_total)
result <- filter(result, !is.na(weight_total))

## INTERMEZZO

## the pipe %>% en how it works, use previous exercises as examples


## CHALLENGE 2:  manipulate data

#' We can proceed by cleaning "df".

#' Set "weight_total" equal to "weight" if empty, remove column "weight" and
#' save as new object "df_cleaned"
df_cleaned <-
  df %>%
  mutate(weight_total = if_else(is.na(weight_total), weight, weight_total)) %>%
  select(-weight)

#' Based on number of trapped individuals ("n_individuals") and "weight_total", calculate
#' the average weight for each catch and set it in a new column of "df_cleaned"
#' called "weight". Put the columns "id", "species",
#' "n_individuals", "n_traps" and all ones starting with "weight" ahead
df_cleaned <-
  df_cleaned %>%
  mutate(weight = weight_total / n_individuals) %>%
  relocate(id, species, n_individuals, n_traps, starts_with("weight"))
  # or via select()
  # select(id, species, n, n_traps, starts_with("weight"), everything())


#' Improve location_name by applying this changes:
#' "Zandplaat Kastel" -> "Kastel, zandplaat"
#' "Antwerpen, Kennedytunnel" -> do not change
#' "Grens Steendorp/Temse" -> "Steendorp, grens met Temse"
df_cleaned <-
  df_cleaned %>%
  mutate(location_name = recode(
    location_name,
    "Zandplaat Kastel" = "Kastel, zandplaat",
    "Grens Steendorp/Temse" = "Steendorp, grens met Temse")) %>%
  distinct(location_name)

## CHALLENGE 3

#' 1. For each combination of species and location, calculate the "weight_mean",
#' "depth_mean", the "length_mean", the minimum, the maximum and the total
#' number of trapped individuals, the date of the oldest and the most recent
#' campaign
df_cleaned %>%
  group_by(species, location_id, location_name) %>%
  summarise(weight_mean = mean(weight, na.rm =  TRUE),
            # not needed for depth, but I suggest to add always na.rm = TRUE in
            # case you are not bothered by presence of NAs
            depth_mean = mean(depth, na.rm =  TRUE),
            length_mean = mean(length, na.rm =  TRUE),
            min_n = min(n_individuals, na.rm =  TRUE),
            max_n = max(n_individuals, na.rm =  TRUE),
            total_n = sum(n_individuals, na.rm =  TRUE),
            first_deployment_date = min(date),
            last_deployment_date = max(date)) %>%
  ungroup() # summarise() removes the last level of grouping each time is used


#' 2. How many measurement campaigns for each date-location? Select the top 10
df_cleaned %>%
  group_by(date, location_id, location_name) %>%
  summarise(n_campaigns = n()) %>%
  arrange(desc(n_campaigns)) %>%
  # important to ungroup otherwise R thinks you want the top10 within each group
  slice_head(n = 10)


# in dplyr 1.0.x summarise() has an argument called .groups (still in
# experimental phase) where you can specify the grouping structure of the
# result. ungroup() can be replaced by specifying .groups:
df_cleaned %>%
  group_by(date, location_id, location_name) %>%
  summarise(n_campaigns = n(), .groups = "drop") %>%
  arrange(desc(n_campaigns)) %>%
  slice_head(n = 10)

#' 3. Get number of successful catches (n_individuals > 0 or species not NA) and
#' number of species found in each location
df_cleaned %>%
  filter(n_individuals > 0) %>%
  group_by(location_id, location_name) %>%
  summarise(n_success = n(),
            n_species = n_distinct(species))


#' 4. Calculate the statistics in 1 only for locations with more than 5000
#' successful catches
df_cleaned %>%
  filter(n_individuals > 0) %>%
  # add_count creates a new column called n
  add_count(location_id, location_name) %>%
  filter(n > 5000) %>%
  # you can remove column n if not needed anymore
  select(-n) %>%
  group_by(species, location_id, location_name) %>%
  summarise(weight_mean = mean(weight, na.rm =  TRUE),
            # not needed for depth, but I suggest to add always na.rm = TRUE in
            # case you are not bothered by presence of NAs
            depth_mean = mean(depth, na.rm =  TRUE),
            length_mean = mean(length, na.rm =  TRUE),
            min_n = min(n_individuals, na.rm =  TRUE),
            max_n = max(n_individuals, na.rm =  TRUE),
            total_n = sum(n_individuals, na.rm =  TRUE),
            first_deployment_date = min(date, na.rm = TRUE),
            last_deployment_date = max(date, na.rm = TRUE))
