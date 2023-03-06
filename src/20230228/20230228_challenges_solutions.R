library(tidyverse)

## Read data

partridge <- read_csv("./data/20230228/20230228_partridge.txt", na = "")

# Preview of the data.frame structure
str(partridge)

## CHALLENGE 1

## 1. Display first 8 rows; display the last 8 rows
head(partridge, 8)
tail(partridge, 8)

# Similar output via functions slice_head() and slice_tail(), specific cases of
# slice()
slice_head(partridge, n = 8) # n must be explicitly named!
slice_tail(partridge, n = 8)

# However, notice how the results are different when applying head()/tail() or
# slice_* functions to a grouped data.frame
# (grouped dataframes will be described in challenge 2)


## Select columns wbe and date
select(partridge, wbe, date) # typical dplyr syntax

# via c()
select(partridge, c(wbe, date))

# you can use column names as strings (as in basic R) but not really typical
# dplyr and it doesn't work with other dplyr functions (e.g. group_by()).
select(partridge, "wbe", "date")


## Display the values of `type`. How many different values of `type` are?
n_distinct(partridge$type)

# other solutions
unique(partridge$type) # output of unique() is a vector. unique() is a basic R function
length(unique(partridge$type))

distinct(partridge, type) # output of dplyr function distinct() is a data.frame with one column
nrow(distinct(partridge, type))


# How to remove observations with type `Sound`? How to remove observations with type `Sound` and wbe NA?
filter(partridge, type != "Sound")
filter(partridge, type != "Sound" & !is.na(wbe))


# Add a new column called `seen` which is TRUE if `type` is not `"Sound"`.
# Add a column `month` with the month of the observation.
# Tip: use `lubridate::month()` function
partridge <- mutate(partridge,
                    seen = if_else(type != "Sound", TRUE, FALSE),
                    month = (lubridate::month(date))
)

# A more general alternative to if_else() is case_when()
partridge <- mutate(
  partridge,
  seen = case_when(type == "Sound" ~ FALSE, .default = TRUE)
)

# Why does dplyr function if_else() exists if basic R already provides
# `ifelse()`? Check if_else() documentation to get the answer:
# https://dplyr.tidyverse.org/reference/if_else.html Short answer: better
# handling missing values and preserve type
x <- c(-5:5, NA)
x
if_else(x < 0, "negative", "positive", missing = "missing")
ifelse(x < 0, "negative", "positive")

# Place the column `seen` after `type` and `month` after `date`
partridge <- relocate(partridge, seen, .after = type)
partridge <- relocate(partridge, month, .after = date)


## INTERMEZZO: the pipe %>%

# example inspired by challenge 1
partridge %>%
  mutate(seen = if_else(type != "Sound", TRUE, FALSE),
         month = (lubridate::month(date))) %>%
  distinct(wbe, type, seen, date, month) %>%
  filter(wbe > 530) %>%
  relocate(seen, .after = type) %>%
  relocate(month, .after = date)


## CHALLENGE 2 - Summaries

# 1. How many observations per WBE? Save it as `overview_partridge` as we will
# use it in challenge 3.
overview_partridge <- partridge %>%
  group_by(wbe) %>%
  summarise(n_obs = n())


# 2. How many observations per WBE and type?
partridge %>%
  group_by(wbe, type) %>%
  summarise(n_obs = n())

# notice how output of summarise() is still grouped by wbe. If you group by two
# variables (x, y), the output is by default grouped by one (x). If you group by
# three variables (`group_by(x, y, z)`), output is grouped by two (`c(x, y)`)
# To drop grouping after summarising, use `.groups = "drop"`:
b <- partridge %>%
  group_by(wbe, type) %>%
  summarise(n_obs = n(), .groups = "drop")
class(b)

# To keep all groups (without dropping the last one), use .groups = "keep"
c <- partridge %>%
  group_by(wbe, type) %>%
  summarise(n_obs = n(), .groups = "keep")
# c is still grouped by wbe and type. You can see it by printing on console
# (second line looks like: `# Groups:   wbe, type [210]`)
c

# another way is by printing the class: the first element is `"grouped_df"`
class(c)


# 3. Order the previous output per n_obs (descending order), wbe (ascending order), type (alphabetically).
d <- partridge %>%
  group_by(wbe, type) %>%
  summarise(n_obs = n(), .groups = "drop") %>%
  arrange(desc(n_obs), wbe, type)

# in this case we get same result if we don't drop the group wbe. But notice
# that the output is still grouped by wbe, while d is not
e <- partridge %>%
  group_by(wbe, type) %>%
  summarise(n_obs = n()) %>%
  arrange(desc(n_obs), wbe, type)

# same result as d or e. Notice that the output is still grouped by wbe as e, but the arrange works globally.
f <- partridge %>%
  group_by(wbe, type) %>%
  summarise(n_obs = n()) %>%
  arrange(desc(n_obs), wbe, type, .by_group = FALSE)


## 4. For each month, returns the wbe with the highest number of observations and such number
partridge %>%
  group_by(month, wbe) %>%
  summarise(n_obs = n()) %>%
  # use filter on the data.frame grouped by month
  filter(n_obs == max(n_obs))

# What if I drop the groups before filtering? Very different result!
partridge %>%
  group_by(month, wbe) %>%
  summarise(n_obs = n(), .groups = "drop") %>%
  # use filter on the ungroped data.frame
  filter(n_obs == max(n_obs))

## CHALLENGE 3 one and two-table verbs

# read the game management units details
WBE <- read_csv("./data/20230228/20230228_wbe_info.txt", na = "")

# 1. Add province, WBE name, and surface area to `overview_partridge` (where available)?
overview_partridge %>% left_join(WBE, by = "wbe")

# notice that in this case the join occurs by a column which is has same name in
# both data.frames. What such column is named differently? You need `by =
# c("col1name" = "col2name")`
overview_partridge %>% left_join(WBE, by = c("wbe" = "wbe"))

# Notice also that using the column name without " " doesn't work. Just
# uncomment the line here below and run:
# overview_partridge %>% left_join(WBE, by = wbe)
# But this is not really intuitive as dplyr typically allows us to use column
# names without " "! Since dplyr 1.1.0 we can finally get rid of this
# inconsistency via `join_by()` function
overview_partridge %>% left_join(WBE, by = join_by(wbe))
# for joins over columns called differently: join_by(col1name == col2name)
overview_partridge %>% left_join(WBE, by = join_by(wbe == wbe))


# 2. How are the columns ordered? Are the columns of `overview_partridge` on the left? Try to put them on the right.
WBE %>% right_join(overview_partridge, by = join_by(wbe))


# 3. Which WBEs are not in `partridge`, i.e. are not linked to any observation?
WBE %>% anti_join(partridge, by = join_by(wbe))

# another solution using setdiff instead of joins
setdiff(pull(WBE,wbe), pull(partridge,wbe))


# 4. Some observations have a missing value for column `wbe` and some WBEs have no observations at all. Get rid of them while joining.
overview_partridge %>% inner_join(WBE, by = join_by(wbe))


# 5. Now, join both again but retain ALL EXISTING WBEs. Set 0 to WBEs where no partridges were observed.
WBE %>% left_join(overview_partridge, by = join_by(wbe)) %>%
  mutate(n_obs = replace_na(n_obs, 0))

## BONUS CHALLENGE 1 - Tidy data

# After reading `20230228_ias_plants.txt` dataset (code provided), make it tidy. Please, notice that for some species two vernacular names are given. See figure below.
ias <- read_csv("./data/20230228/20230228_ias_plants.txt", na = "")
head(ias)
ias_tidy <- ias %>%
  pivot_longer(
    c("english_name", "dutch_name", "french_name"),
    names_to = "language",
    values_to = "vernacular_name") %>%
  mutate(language = case_match(language,
                               "english_name" ~ "en",
                               "dutch_name" ~ "nl",
                               "french_name" ~ "fr"))

# notice also how you can use tidyselect predicates to select the columns to
# pivot. In this case, we can select all columns ending with `"h_name"`:
ias_tidy <- ias %>%
  pivot_longer(
    ends_with("h_name"),
    names_to = "language",
    values_to = "vernacular_name") %>%
  mutate(language = case_match(language,
                               "english_name" ~ "en",
                               "dutch_name" ~ "nl",
                               "french_name" ~ "fr")) %>%
  # to take care of double vernacular names in same language
  separate_longer_delim(vernacular_name, delim = ";")

## BONUS CHALLENGE 2 - sharing is caring

# see related section on hackmd
# https://hackmd.io/B8aoQT_YRUOVks-j916YPA?view#Bonus-challenge-2


## Closing the circle ;-)

a <- tibble(
  name = c("Damiano", "Amber", "Hans", "Dirk", "Emma", "Raïsa"),
  my_favorite_number_string = c("104", "023", "7", "666", "3", "9")
)
a

a %>% arrange(stringr::str_rank(my_favorite_number_string, numeric = TRUE))
