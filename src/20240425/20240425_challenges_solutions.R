library(tidyverse)

## Read data
obs <- readr::read_csv("./data/20240425/20240425_observations.csv")

# Preview of the data.frame structure
glimpse(obs)

## CHALLENGE 1

## 1. Display first 8 rows; display the last 8 rows
# Notice that `head()` and `tail()` are basic R functions
head(obs, 8)
tail(obs, 8)

# Similar output via functions slice_head() and slice_tail(), specific cases of
# slice()
dplyr::slice_head(obs, n = 8) # n must be explicitly named!
dplyr::slice(obs, 1:8)
dplyr::slice_tail(obs, n = 8)

# Notice that `slice()` is quite a powerful function. It allows to also remove
# rows by their index! For example, let's remove the first 8 rows.
dplyr::slice(obs, -(1:8))

# However, notice how the results are different when applying head()/tail() or
# slice_* functions to a grouped data.frame
# (grouped dataframes will be described in challenge 2)


## 2. Select columns `observationLevel`, `eventStart`, `eventEnd` and
## `scientificName`
# typical dplyr syntax
dplyr::select(obs, observationLevel, eventStart, eventEnd, scientificName)

# via c()
dplyr::select(obs, c(observationLevel, eventStart, eventEnd, scientificName))

# you can use column names as strings (as in basic R) but not really typical
# dplyr and it doesn't work with other dplyr functions (e.g. `group_by()`).
# Word completion will also not work
dplyr::select(obs,
              "observationLevel",
              "eventStart",
              "eventEnd",
              "scientificName"
)


## 3. Display the values of `observationLevel`. How many different values of
## `observationLevel`are?
dplyr::distinct(obs, observationLevel)
dplyr::n_distinct(obs$observationLevel)
# or
nrow(dplyr::distinct(obs, observationLevel))

# Other solutions
# `unique()`: but the output of `unique()` is a vector.
# `unique()` is a basic R function
unique(obs$observationLevel)
length(unique(obs$observationLevel))


## 4. How to remove observations with observationLevel `"media"`? How to remove
## observations with observationLevel `"media"` and empty `scientificName`?
dplyr::filter(obs, observationLevel != "media")
dplyr::filter(obs, observationLevel != "media" & !is.na(scientificName))

# Notice you can concatenate conditions by comma `,` is equals to
# concatenate them by `&` (AND operator)
dplyr::filter(obs, observationLevel != "media" , !is.na(scientificName))


## 5. Add a new column called `is_classified_by_human` which is TRUE if `classificationMethod`
## is equal to `"human"`.
## Add a new column `month` with the month of the observation (`eventStart`).
## Tip: use lubridate's `month()` and `year()` functions.
obs_extra_cols <- dplyr::mutate(
  obs,
  is_classified_by_human = classificationMethod == "human",
  month = lubridate::month(eventStart),
  year= lubridate::year(eventStart)
)
# Check
obs_extra_cols %>%
  dplyr::distinct(month, year, classificationMethod, is_classified_by_human)

# General solution using `if_else()`. It allows to map the
# output of the condition `classificationMethod == "human"` (`TRUE` or `FALSE`)
# to anything else.
obs_extra_cols <- dplyr::mutate(
  obs,
  is_classified_by_human = dplyr::if_else(
    classificationMethod == "human",
    true = TRUE,
    false = FALSE),
  month = lubridate::month(eventStart),
  year = lubridate::year(eventStart)
)

# Check
obs_extra_cols %>%
  dplyr::distinct(month, year, classificationMethod, is_classified_by_human)

# A even more general alternative to if_else() is case_when(), useful when you
# have more than two values to map.
obs_extra_cols <- dplyr::mutate(
  obs,
  is_classified_by_human = dplyr::case_when(
    classificationMethod == "human" ~ TRUE,
    .default = FALSE)
)

# Check
obs_extra_cols %>%
  dplyr::distinct(month, year, classificationMethod, is_classified_by_human)


# Why does dplyr function if_else() exists if basic R already provides
# `ifelse()`? Check if_else() documentation to get the answer:
# https://dplyr.tidyverse.org/reference/if_else.html Short answer: better
# handling missing values and preserve type
x <- c(-2:2, NA)
x
dplyr::if_else(x < 0, "negative", "positive", missing = "missing")
ifelse(x < 0, "negative", "positive")


## 6. Move the column `count` after `behavior`.
dplyr::relocate(obs, count, .after = behavior)

## 7. Move all columns starting with `"individual"` before `observationLevel`
obs_different_cols_order <- dplyr::relocate(
  obs,
  dplyr::starts_with("individual"),
  .before = observationLevel
)

# Check
names(obs_different_cols_order)


## 8. Observations with observationLevel = "event" have no `mediaID`, i.e.
## mediaID is `NA`. Is this statement true or false?
is.na(
  dplyr::pull( # pull() extracts a column as a vector
    dplyr::distinct(
      dplyr::filter(obs, observationLevel == "event"),
      mediaID
    )
  )
)

# An alternative solution

# Alternative solution using `setequal()`
dplyr::setequal(
  dplyr::select(
    dplyr::filter(obs, observationLevel == "event" & is.na(mediaID)), mediaID
  ),
  dplyr::select(dplyr::filter(obs, observationLevel == "event"), mediaID)
)

## Notice how the code starts to become very hard to read as we start to perform
## multiple data manipulation operations. The pipe `%>%` will help us. See
## intermezzo here below.

## INTERMEZZO: the pipe %>%

# Example inspired by challenge 1
obs %>%
  dplyr::filter(observationLevel == "event") %>%
  dplyr::mutate(
    is_classified_by_human = dplyr::if_else(
      classificationMethod == "human", true = TRUE, false = FALSE),
    month = lubridate::month(eventStart)) %>%
  dplyr::relocate(count, .after = behavior) %>%
  dplyr::relocate(dplyr::starts_with("taxon."), .before = observationLevel)

# The solution of the last exercise of challenge 1 rewritten using pipes
obs %>%
  dplyr::filter(observationLevel == "event") %>%
  dplyr::distinct(mediaID) %>%
  dplyr::pull() %>%
  is.na()

# Why the cheat sheet shows this pipe `|>` instead of `%>%`? The `|>` is the
# pipe introduced in R 4.0. It is base R! That's good news. R developers
# realised how important the %>% was within the R community. Why don't we use it
# here? Just because there are still people (outside INBO) which could still run
# R v3. So, to be inclusive we will still use `%>%` from the tidyverse ecosystem
# instead of `|>`. Notice that we at INBO can already use the new pipe, `|>`, as
# our IT team has rolled R v4 on our laptops a lot of time ago.
obs |>
  dplyr::filter(observationLevel == "event") |>
  dplyr::distinct(mediaID) |>
  dplyr::pull() |>
  is.na()

## CHALLENGE 2 - Summaries

## 1. How many observations per deploymentID? Show it as a dataframe with two
## columns: `deploymentID` and `n_obs`.
overview_obs <- obs %>%
  dplyr::count(deploymentID, name = "n_obs")
overview_obs

# Notice how handy the argument `name` is. In this way we don't need to rename
# the column afterwards as done here below, using `dplyr::rename()`.
overview_obs <- obs %>%
  dplyr::count(deploymentID) %>%
  dplyr::rename(n_obs = n)
overview_obs

# As described in count()'s documentation, `count()` is roughly equivalent to df
# %>% group_by(a, b) %>% summarise(n = n()). So, by using `summarise()` we can
# control directly the column name with the number of observations.
overview_obs <- obs %>%
  dplyr::group_by(deploymentID) %>%
  dplyr::summarise(n_obs = dplyr::n())
overview_obs


## 2. How many observations per deploymentID and observationLevel?
overview_obs <- obs %>%
  dplyr::count(deploymentID, observationLevel)
overview_obs

# Using the general recipe, `group_by()` %>% `summarise()`
overview_obs <- obs %>%
  dplyr::group_by(deploymentID, observationLevel) %>%
  dplyr::summarise(n_obs = dplyr::n())
overview_obs

# Notice how output of `summarise()` is still grouped by `deploymentID`. If you
# group by two variables (x, y), the output is by default grouped by one (x). If
# you group by three variables (`group_by(x, y, z)`), output is grouped by two
# (`c(x, y)`).
# You can see that the output is still grouped by printing the class:
# you can see that the first element is `"grouped_df"`
class(overview_obs)

# To drop grouping after summarising, use `.groups = "drop"`:
b <- obs %>%
  dplyr::group_by(deploymentID, observationLevel) %>%
  dplyr::summarise(n_obs = dplyr::n(), .groups = "drop")
class(b)

# To keep all groups (without dropping the last one), use `.groups = "keep"`
c <- obs %>%
  dplyr::group_by(deploymentID, observationLevel) %>%
  dplyr::summarise(n_obs = dplyr::n(), .groups = "keep")
# c is still grouped by `deploymentID` and `observationLevel`. You can see it by
# printing on console. The second line looks like:
# `# Groups:   deploymentID, observationLevel [4]`
c


## 3. Order the previous output per `n_obs` (descending order)
obs %>%
  dplyr::group_by(deploymentID, observationLevel) %>%
  dplyr::summarise(n_obs = dplyr::n(), .groups = "drop") %>%
  dplyr::arrange(-n_obs)

# The `-` replaces the `desc()` function, handy!
  dplyr::arrange(dplyr::desc(n_obs))
overview_obs

# Notice that `-` can also be used to remove one or more columns. For example,
# how to remove all columns starting with `"bbox"`, `"individual"` and
# `"classificiationMethod"`?
obs_without_some_cols <- obs %>%
  dplyr::select(-classificationMethod)
"classificationMethod" %in% names(obs_without_some_cols)

obs_without_some_cols <- obs %>%
  dplyr::select(-c(dplyr::starts_with("bbox"),
                   dplyr::starts_with("individual"),
                   classificationMethod)
)
obs_without_some_cols %>% names()

# Notice that the output is still grouped by `deploymentID` if we remove
# `.groups = "drop"` in the `summarise()` statement.
e <- obs %>%
  dplyr::group_by(deploymentID, observationLevel) %>%
  dplyr::summarise(n_obs = dplyr::n()) %>%
  dplyr::arrange(-n_obs)
e


## 4. Create a summary dataframe with the number of media-based observations
## (`observationLevel` = "media"), the number of event-based observations
## (`observationLevel` = "event") and the total number of observations per
## deploymentID. Notice that `observationLevel` is always filled in. The result
## should be a dataframe with 4 columns: `deploymentID`, `n_obs_event`,
## `n_obs_media` and `n_obs`. Tip: one way to solve this is by combining dplyr
## with tidyr.
obs %>%
  dplyr::group_by(deploymentID, observationLevel) %>%
  dplyr::summarise(n = dplyr::n()) %>%
  tidyr::pivot_wider(names_from = observationLevel,
                     values_from = n,
                     names_prefix = "n_obs_") %>%
  dplyr::mutate(n_obs = n_obs_event + n_obs_media)

#  Notice there is also a way to solve this using only dplyr
obs %>%
  dplyr::mutate(is_media = observationLevel == "media",
                is_event = observationLevel == "event") %>%
  dplyr::group_by(deploymentID) %>%
  dplyr::summarise(n_obs_event = sum(is_event),
                   n_obs_media = sum(is_media),
                   n_obs = n(),
                   .groups = "drop"
)


## 5. For each month, year and `deploymentID`, return the `eventStart` of the
## first and the last event-based observation (observationLevel = `event`) if
## there are 3 or more event-based observations. Call these two columns
## `first_event_obs` and `last_event_obs` respectively.
obs %>%
  # get month and year using lubridate
  dplyr::mutate(month = lubridate::month(eventStart),
                year = lubridate::year(eventStart)) %>%
  # only event-based observations
  dplyr::filter(observationLevel == "event") %>%
  dplyr::group_by(year, month, deploymentID) %>%
  # add number of observations per year, month and deploymentID as extra column
  dplyr::add_tally() %>%
  # only if there are 3 or more observations
  dplyr::filter(n >= 3) %>%
  # get first and last observations per year, month and deploymentID
  dplyr::summarise(first_event_obs = min(eventStart),
                   last_event_obs = max(eventStart),
                   .groups = "drop"
)

# Another solution without `add_tally()`: add number of observations as output
# of summary for filtering after the summary. Remove the column at the end.
obs %>%
  dplyr::mutate(month = lubridate::month(eventStart),
                year = lubridate::year(eventStart)) %>%
  dplyr::filter(observationLevel == "event") %>%
  group_by(year, month, deploymentID) %>%
  summarise(n = dplyr::n(),
            first_event = min(eventStart),
            last_event = max(eventStart),
            .groups = "drop" # conceptually correct, but same result without it
            ) %>%
  dplyr::filter(n >= 3) %>%
  dplyr::select(-n)

# Another possible solution
obs %>%
  dplyr::mutate(month = lubridate::month(eventStart),
         year = lubridate::year(eventStart)) %>%
  dplyr::filter(observationLevel == "event") %>%
  dplyr::group_by(year, month, deploymentID) %>%
  dplyr::mutate(n_obs = n()) %>%
  dplyr::ungroup() %>%
  dplyr::filter(n_obs >= 3) %>%
  dplyr::group_by(year, month, deploymentID) %>%
  dplyr::summarise(first_event_obs = min(eventStart),
            last_event_obs = max(eventStart),
            .groups = "drop")


## 6. How to return the same dataframe as 5 but now limiting us to the months
## with the highest number of event-based observations for each year and
## `deploymentID`?
obs %>%
  dplyr::mutate(month = lubridate::month(eventStart),
                year = lubridate::year(eventStart)) %>%
  dplyr::filter(observationLevel == "event") %>%
  group_by(year, deploymentID, month) %>%
  add_tally() %>%
  filter(n >= 3) %>%
  summarise(n = unique(n), # hold n in the summary
            first_event = min(eventStart),
            last_event = max(eventStart)) %>%
  dplyr::filter(n == max(n))

# Notice that the solution above works well because we paid attention to the
# order of the columns in `group_by()`. The output of `summarise()` is still
# grouped by `year` and `deploymentID` as by deafult the last column in the
# `group_by()` is dropped. Are you not sure about all this? Just group your data
# again and so you don't have to think too much about the order of the columns
# in the `group_by()`. Notice however that the order of the first columns
# reflect the order mentioned in the first grouping.
obs %>%
  dplyr::mutate(month = lubridate::month(eventStart),
                year = lubridate::year(eventStart)) %>%
  dplyr::filter(observationLevel == "event") %>%
  dplyr::group_by(month, year, deploymentID) %>% # Changed order just to show
  dplyr::add_tally() %>%
  dplyr::filter(n >= 3) %>%
  dplyr::summarise(n = unique(n),
            first_event = min(eventStart),
            last_event = max(eventStart)) %>%
  dplyr::group_by(deploymentID, year) %>% # Write explicitly the wished grouping
  dplyr::filter(n == max(n))

# What if I drop the groups before filtering? Very different result!
obs %>%
  dplyr::mutate(month = lubridate::month(eventStart),
                year = lubridate::year(eventStart)) %>%
  dplyr::filter(observationLevel == "event") %>%
  group_by(year, month, deploymentID) %>%
  add_tally() %>%
  filter(n >= 3) %>%
  summarise(n = unique(n),
            first_event = min(eventStart),
            last_event = max(eventStart),
            .groups = "drop") %>%
  dplyr::filter(n == max(n))



## CHALLENGE 3 - Two-table verbs

# Read the media information
media <- read_csv("./data/20240425/20240425_media.csv", na = "")

## 1. How to add the media information stored in `media` to the observations?
obs %>% dplyr::left_join(media, by = "mediaID")

# notice that in this case the join occurs by a column which has same name in
# both dataframes. What if such column is named differently? You need `by =
# c("col1name" = "col2name")`.
obs %>% dplyr::left_join(media, by = c("mediaID" = "mediaID"))

# Notice also that using the column name without " " doesn't work. Just
# uncomment the line here below and run it to see the error:
# obs %>% left_join(media, by = mediaID)
# But this is not really intuitive as dplyr typically allows us to use column
# names without " "! Since dplyr 1.1.0 we can finally get rid of this
# inconsistency via `join_by()` function.
obs %>% dplyr::left_join(media, by = dplyr::join_by(mediaID))

## For joins over columns called differently: join_by(col1name == col2name) is
## the best way to do it now.
obs %>% dplyr::left_join(media, by = dplyr::join_by(mediaID == mediaID))


## 2. How are the columns ordered? Are the columns from observations on the
## left? Try to put them on the right.
media %>% dplyr::right_join(obs, by = dplyr::join_by(mediaID))


## 3. Are there media not in observations, i.e. are there media not linked to any
## observation?
media %>% dplyr::anti_join(obs, by = dplyr::join_by(mediaID))

# Another solution using setdiff instead of joins
dplyr::setdiff(dplyr::pull(media,mediaID), dplyr::pull(obs,mediaID))


## 4. Some observations have a missing value for column `mediaID`. Get rid of
## them while joining.
obs %>% dplyr::inner_join(media, by = dplyr::join_by(mediaID))


## 5. As deploymentID is present in both dataframes, it gets duplicated and the
## suffixes `".x"` and `".y"` are added. How to change the suffixes to `"_obs"`
## and `"_media"` while performing the exercise 1?
obs %>%
  dplyr::left_join(media,
                   by = dplyr::join_by(mediaID),
                   suffix = c("_obs", "_media")
)


## 6. How to add the suffix only for the column `deploymentID` in `media`?
obs %>%
  dplyr::left_join(media,
                   by = dplyr::join_by(mediaID),
                   suffix = c("", "_media")
)


## 7. How to avoid actually to have this column twice?
obs %>%
  dplyr::left_join(media,
                   by = dplyr::join_by(mediaID, deploymentID),
                   suffix = c("", "_media")
)



## BONUS CHALLENGE 1 - dplyr + tidyr = love

# After reading `20240425_ias_plants.csv` dataset (code provided), make it tidy.
# Please, notice that for some species two vernacular names with the same language are given.
ias <- read_csv("./data/20240425/20240425_ias_plants.csv", na = "")
dplyr::glimpse(ias) # overview
ias_tidy <- ias %>%
  tidyr::pivot_longer(
    c("english_name", "dutch_name", "french_name"),
    names_to = "language",
    values_to = "vernacular_name") %>%
  dplyr::mutate(language = dplyr::case_match(language,
                                             "english_name" ~ "en",
                                             "dutch_name" ~ "nl",
                                             "french_name" ~ "fr")
)

# Notice also you can use tidyselect predicates to select the columns to pivot.
# In this case, we can select all columns ending with `"h_name"` by using the
# function `ends_with()`:
ias_tidy <- ias %>%
  tidyr::pivot_longer(
    dplyr::ends_with("h_name"),
    names_to = "language",
    values_to = "vernacular_name") %>%
  dplyr::mutate(language = dplyr::case_match(language,
                                             "english_name" ~ "en",
                                             "dutch_name" ~ "nl",
                                             "french_name" ~ "fr")) %>%
  # to take care of double vernacular names in same language
  tidyr::separate_longer_delim(vernacular_name, delim = ";")



## BONUS CHALLENGE 2 - dplyr + stringr = love

a <- tibble::tibble(
  name = c("Damiano", "Amber", "Rhea", "Dirk", "Emma", "Raïsa"),
  my_favorite_number_string = c("104", "023", "7", "666", "3", "9")
)
a

a %>% dplyr::arrange(
  stringr::str_rank(my_favorite_number_string, numeric = TRUE)
)


## BONUS CHALLENGE 3 - dplyr + tidyverse packages = love

si_data <- readr::read_csv(
  file = "./data/20240425/20240425_si_species_per_year_cell.csv"
)

## 1. Calculate the cumulative number of species observed over time in each
## square
si_cumulative <- si_data %>%
  dplyr::group_by(eea_cell_code) %>%
  dplyr::arrange(year, .by_group = TRUE) %>%
  dplyr::group_by(eea_cell_code, year) %>%
  dplyr::summarise(
    species_list = list(speciesKey)) %>%
  dplyr::mutate(
    accumulated_species_list = purrr::accumulate(
      species_list, dplyr::union, .simplify = FALSE),
    cumulative_n_species = purrr::map_dbl(accumulated_species_list, length)
  ) %>%
  dplyr::ungroup()

## 2. Find the 10 cells with the highest cumulative number of species.
cells_highest_n_species <- si_cumulative %>%
  dplyr::group_by(eea_cell_code) %>%
  dplyr::summarise(max_n_species = max(cumulative_n_species)) %>%
  dplyr::arrange(desc(max_n_species)) %>%
  dplyr::slice_head(n = 10) %>%
  dplyr::pull(eea_cell_code)

# Extra: plot the cumulative number of species for these 10 cells
si_cumulative %>%
  dplyr::filter(eea_cell_code %in% cells_highest_n_species) %>%
  ggplot2::ggplot() +
  ggplot2::geom_line(
    ggplot2::aes(x = year,
                 y = cumulative_n_species,
                 group = eea_cell_code,
                 color = eea_cell_code),
    alpha = 0.3
)

## BOUNS CHALLENGE 4 - dealing with lists? purrr!

datapackage_json <-
  jsonlite::read_json("https://raw.githubusercontent.com/inbo/etn/main/inst/assets/datapackage.json")

datapackage_tbl <-
  datapackage_json %>%
  purrr::chuck("resources") %>%
  purrr::map(
    \(resource) purrr::set_names(
      purrr::chuck(resource, "schema", "fields"),
      purrr::chuck(resource, "name")
    )
  ) %>%
  purrr::map(
    \(resource) purrr::map(
      resource,
      ~ dplyr::tibble(
        name = purrr::pluck(.x, "name"),
        type = purrr::pluck(.x, "type"),
        resource_name = unique(names(resource))
      )
    )
  ) %>%
  purrr::map(purrr::list_rbind) %>%
  purrr::list_rbind()

datapackage_tbl
