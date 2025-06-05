library(tidyverse)
library(digest)
library(rgbif)

# Read datasets ####

## Read partridge counts dataset, `counts` ####
counts <- readr::read_tsv(
  file = "data/20250527/20250527_partridge_counts.tsv",
  na = ""
)


## Get an overview of `counts` ####
dplyr::glimpse(counts)



# CHALLENGE 1 ####

## 1.1 ####
counters_days <- counts %>%
  dplyr::distinct(date_count, counter_name) %>%
  group_by(counter_name) %>%
  summarise(n_days = n()) %>%
  dplyr::arrange(desc(n_days), counter_name)

counters_days

# By using `.by` argument in `dplyr::summarise()`, we can avoid the need to use `group_by()` and `ungroup()`. `ungroup()` is often used to remove the grouping after summarising, but it is not necessary in our case as we grouped by one variable and summarised it. If we would group by 2 or more variables, we would need to use `ungroup()` to remove the grouping after summarising, or use `.by` argument in `dplyr::summarise()` to specify the grouping variables. By default `dplyr::summarise()` will return a data frame with one grouped variable less. So, if we grouped by 2 variables, the summary will still be grouped by the other vaiable.
counters_days <- counts %>%
  dplyr::distinct(date_count, counter_name) %>%
  summarise(
    n_days = n(),
    .by = counter_name # .by leaves groups out, no need to ungroup()
  ) %>%
  dplyr::arrange(desc(n_days), counter_name)
counters_days

# Also, when we need to count only, we can use the shortcut function `count()` instead of `summarise(n_days = n())`. Notice that by using `count()` the output is always ungrouped, so we do not need to use `ungroup()` after summarising.
counters_days <- counts %>%
  dplyr::distinct(date_count, counter_name) %>%
  dplyr::count(counter_name, name = "n_days") %>%
  dplyr::arrange(desc(n_days), counter_name)

counters_days



# Another option for the `group_by()` aficionados is to use .group = "drop" in `dplyr::summarise()`, which is equivalent to use `ungroup()` after summarising.
counters_days <- counts %>%
  dplyr::distinct(date_count, counter_name) %>%
  group_by(counter_name) %>%
  summarise(
    n_days = n(),
    .groups = "drop" # even if not needed here
  ) %>%
  dplyr::arrange(desc(n_days), counter_name)
counters_days

# Example with 2 grouping variables, e.g. `counter_name` and `hunting_ground`:

# `count()`: no grouped data.frame returned
counters_days_grounds <- counts %>%
  dplyr::distinct(date_count, hunting_ground, counter_name) %>%
  dplyr::count(counter_name, hunting_ground, name = "n_days") %>%
  dplyr::arrange(desc(n_days), counter_name)

counters_days_grounds
class(counters_days_grounds) # no grouped data frame, but a regular data frame

# `group_by()` + `summarise()` without `.groups = "drop"`: the returned
# data.frame is grouped by `counter_name` and a message is printed on console
# with grouping information
counters_days_grounds <- counts %>%
  dplyr::distinct(date_count, hunting_ground, counter_name) %>%
  group_by(counter_name, hunting_ground) %>%
  summarise(n_days = n()) %>%
  dplyr::arrange(desc(n_days), counter_name)
counters_days_grounds
class(counters_days_grounds)

# `group_by()` + `summarise()` with `.groups = "drop_last"`: the returned
# data.frame is grouped by `counter_name`, but no message returned
counters_days_grounds <- counts %>%
  dplyr::distinct(date_count, hunting_ground, counter_name) %>%
  group_by(counter_name, hunting_ground) %>%
  summarise(n_days = n(), .groups = "drop_last") %>%
  dplyr::arrange(desc(n_days), counter_name)
counters_days_grounds
class(counters_days_grounds)


# `group_by()` + `summarise()` with `.groups = "drop"`: the returned data.frame
# is not grouped, no message returned
counters_days_grounds <- counts %>%
  dplyr::distinct(date_count, hunting_ground, counter_name) %>%
  group_by(counter_name, hunting_ground) %>%
  summarise(n_days = n(), .groups = "drop") %>%
  dplyr::arrange(desc(n_days), counter_name)
counters_days_grounds
class(counters_days_grounds)

# No `group_by()`. Only `summarise()` with `.by = c("counter_name",
# "hunting_ground")`: no grouped data.frame returned and no message returned
counters_days_grounds <- counts %>%
  dplyr::distinct(date_count, hunting_ground, counter_name) %>%
  summarise(
    n_days = n(),
    .by = c("counter_name", "hunting_ground") # no need to ungroup() or to specify `.groups = "drop"` or `.groups = "drop_last"` as we are not grouping the data frame beforehand
  ) %>%
  dplyr::arrange(desc(n_days), counter_name)
counters_days_grounds
class(counters_days_grounds)

## 1.2 ####

# To not repeat ourselves, here we show only the option with `.by` argument in
# `dplyr::summarise()`
counters_days <- counts %>%
  dplyr::distinct(date_count, counter_name) %>%
  summarise(
    n_days = n(),
    days = paste(date_count, collapse = ", "),
    .by = counter_name
  ) %>%
  dplyr::arrange(desc(n_days), counter_name)

counters_days


## 1.3 ####

# Via `tidyr::unite()`
counts1 <- counts %>%
  tidyr::unite(
    "org_counter",
    organisation_id,
    counter_name,
    sep = "-",
    remove = FALSE
  )
# The new column is inserted before the first of the columns to unite
names(counts1)

# Via `dplyr::mutate()`: the new column is added at the end of the data frame. Add a `relocate()` step to move the columns to the desired position.
counts <- counts %>%
  dplyr::mutate(org_counter = paste(organisation_id, counter_name, sep = "-"))
# Example of `relocate()` to move the new column to the same position as in `counts1`
counts <- counts %>%
  dplyr::relocate(org_counter, .before = counter_name)

names(counts)

counts

## 1.4 ####

# Old school, using `dplyr::arrange()`, `group_by()`, `mutate()` and `filter()`
counters <- counts %>%
  dplyr::arrange(date_digitalisation, org_counter) %>%
  dplyr::group_by(org_counter) %>%
  mutate(count = dplyr::row_number()) %>%
  dplyr::filter(count == 1) %>%
  dplyr::ungroup() %>%
  dplyr::pull(org_counter)

# Better solution using `dplyr::slice()` with `.by` argument to get the first row of each group, which is more efficient than using `group_by()`, `mutate()` and `filter()`.
counters1 <- counts %>%
  dplyr::arrange(date_digitalisation, org_counter) %>%
  dplyr::slice(1, .by = org_counter) %>%
  dplyr::pull(org_counter)


# CHALLENGE 2 ####

# Option using a double `group_by()`. Notice the use of `reframe()`, a new
# function in `{dplyr}` introduced in dplyr 1.1.0. From documentaton: While
# `summarise()` requires that each argument returns a single value, and
# `mutate()` requires that each argument returns the same number of rows as the
# input, `reframe()` is a more general workhorse with no requirements on the
# number of rows returned per group. More in vignette:
# https://www.tidyverse.org/blog/2023/02/dplyr-1-1-0-pick-reframe-arrange/
overview <- counts %>%
  mutate(date_count = as.Date(date_count)) %>%
  dplyr::group_by(hunting_ground, date_count, org_counter) %>%
  dplyr::reframe(
    date_count = sprintf("%s (%s)", date_count, org_counter)
  ) %>%
  dplyr::group_by(hunting_ground) %>%
  dplyr::reframe(
    n_counts = dplyr::n_distinct(org_counter, date_count),
    dates_counters = paste0(unique(date_count), collapse = ", ")
  ) %>%
  dplyr::arrange(hunting_ground)
overview

# Another very nice alternative, also making use of the new basic R pipe `|>`
# and avoiding using  `group_by()` calls by using `.by` in `summarise()`. Order
# within `dates_counters` not really the same as previous result, but we didn't
# specify any order, actually.
overview2 <- counts |>
  dplyr::arrange(date_count) |>
  mutate(
    date_counter=sprintf(
      '%s (%i-%s)',
      as.Date(date_count),
      organisation_id,
      counter_name
    )
  ) |>
  summarize(
    n_counts=n_distinct(date_counter),
    dates_counters=paste(unique(date_counter),collapse=', '),
    .by=hunting_ground
  ) |>
  arrange(hunting_ground)
overview2


# INTERMEZZO ####

digest::digest(object = "Damiano Oldoni", algo = "sha256")

digest::digest(object = "Damiano Oldoni", algo = "blake3")



# CHALLENGE 3A ####

## 3A.1 ####

# Use `purrr::map_chr()` to apply the function `digest::digest()` to each
# element of column `counter_name` and return a character vector
counts_anonymised <- counts %>%
  dplyr::mutate(counter_name = map_chr(
    .$counter_name,
    function(x) digest::digest(x, algo = "sha256")
    )
  )

# Alternative: vectorize the `digest::digest()` function using `Vectorize()`. In this way we can apply the function to a vector of values without using `purrr::map_chr()`.
vectorized_digest <- Vectorize(digest::digest, "object", "algo")
counts_anonymised2 <- counts
counts_anonymised2$counter_name <- vectorized_digest(
  object = counts_anonymised2$counter_name,
  algo = "sha256") %>%
  # Remove names of the vector, so we get a simple character vector
  purrr::set_names(NULL)
# To use only R basic functions, just remove the pipe and use `names()`
counts_anonymised3 <- counts
counts_anonymised3$counter_name <- vectorized_digest(
  object = counts_anonymised3$counter_name,
  algo = "sha256")
names(counts_anonymised3$counter_name) <- NULL


# Another suggested alternative is worth to be discussed. It uses `dplyr::mutate()` only, no `{purrr}` or vectorized function. The solution is however wrong. Can you find out why?
counts_anonymised4 <- counts %>%
  mutate(counter_name = digest::digest(object = counter_name, algo = "sha256"),
         .by = counter_name)
counts_anonymised4$counter_name[1] == counts_anonymised$counter_name[1]
# The problem is that `mutate()` with `.by` argument does not work as expected
# here. It applies the function to each group defined by `counter_name`. Let's
# take the first name as example, "Germayne Galea":
counts %>%
  dplyr::filter(counter_name == "Germayne Galea") %>%
  nrow()
counts_anonymised4 %>%
  dplyr::filter(counter_name == counts_anonymised4$counter_name[1]) %>%
  nrow()
# This hash is the same for all the 75 rows and it is the hash of a vector
# containing 75 times `"Germayne Galea"`. See below:
counts_anonymised4$counter_name[1]
digest::digest(object = rep("Germayne Galea",75), algo = "sha256")



## 3A.2 ####
ordered_hashes <- counts_anonymised %>%
  dplyr::distinct(org_counter) %>%
  dplyr::arrange(org_counter) %>%
  dplyr::mutate(index = dplyr::row_number())
ordered_hashes

counts_anonymised %>%
  dplyr::left_join(ordered_hashes, by = "org_counter") %>%
  mutate(date_count = as.Date(date_count)) %>%
  dplyr::group_by(index, date_count, hunting_ground) %>%
  dplyr::reframe(
    date_count = sprintf("%s (%s)", date_count, index)) %>%
  dplyr::group_by(hunting_ground) %>%
  dplyr::reframe(
    n_counts = dplyr::n_distinct(index, date_count),
    dates_counters = paste0(unique(date_count), collapse = ", "))


# CHALLENGE 3B ####

## Code provided ####
library(rgbif)

taxa_ad_hoc <- rgbif::name_usage(
  datasetKey = "1f3505cd-5d98-4e23-bd3b-ffe59d05d7c2",
  limit = 1000 # Enough high to get all taxa
  ) %>%
  purrr::pluck("data") %>% # Similar to use $data, but nice for piping
  dplyr::filter(origin == "SOURCE") # Remove any higher taxonomy provided by checklist authors

# Extract GBIF Backbone taxon keys
backbone_taxa <- taxa_ad_hoc %>%
  # Filter out taxa with not match with the GBIF Backbone
  dplyr::filter(!is.na(nubKey)) %>%
  dplyr::pull(nubKey)

# Get vernacular names of one taxon as example (set max to 1000 names)
backbone_taxon <- backbone_taxa[1]
vernacular_names_example <- rgbif::name_usage(
  key = backbone_taxon,
  data = "vernacularNames",
  limit = 1000) %>%
  purrr::pluck("data")

## 3B.1 ####
vernacular_names <- purrr::map(
  backbone_taxa,
  function(taxon) { # anonymous function defined directly in the `purrr::map()`
    rgbif::name_usage(
      key = taxon,
      data = "vernacularNames",
      limit = 1000) %>%
      purrr::pluck("data")
  }) %>%
  purrr::list_rbind()

multiple_vernacular_names <- vernacular_names %>%
  dplyr::distinct(taxonKey, vernacularName, language) %>%
  group_by(taxonKey, language) %>%
  add_tally() %>%
  dplyr::filter(n > 1)


## 3B.2 ####
vernacular_names_wide <- vernacular_names %>%
  dplyr::filter(language != "") %>%
  dplyr::select(taxonKey, vernacularName, language) %>%
  tidyr::pivot_wider(
    names_from = c(language),
    values_from = vernacularName,
    names_prefix = "vernacularName_",
    values_fn = list
  )

## 3B.3 ####

# Instead of storing the names as a list, keep only one of them, e.g. the first
# one.
vernacular_names_wide_first <- vernacular_names %>%
  dplyr::filter(language != "") %>%
  dplyr::select(taxonKey, vernacularName, language) %>%
  tidyr::pivot_wider(
    names_from = c(language),
    values_from = vernacularName,
    names_prefix = "vernacularName_",
    values_fn = ~ purrr::pluck(.x, 1)
  )


## 3B.4 ####

# In this case the function in `values_fn` argument would be very complex and
# not possible to specify within `tidyr::pivot_wider()`. For complex summary
# operations, is recommended to summarise before reshaping. Source:
# https://tidyr.tidyverse.org/articles/pivot.html#aggregation
vernacular_names_wide_preferred <- vernacular_names %>%
  dplyr::filter(language != "") %>%
  dplyr::select(taxonKey, vernacularName, language, preferred) %>%
  group_by(taxonKey, language) %>%
  arrange(desc(preferred == TRUE), na.rm = TRUE) %>%
  slice(1) %>%
  ungroup() %>%
  tidyr::pivot_wider(
    names_from = c(language),
    values_from = c(vernacularName, preferred),
    names_prefix = "vernacularName_"
  )
