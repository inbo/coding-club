library(tidyverse)
## library(tidylog) maybe to show at intermezzo 1

veg_df <- read_csv(file = "./data/20220428/20220428_inboveg_data.txt", na = "")


## CHALLENGE 1

# Display the very first 8 rows

veg_df %>% head(8) # notice that head() is basic R, not dplyr
veg_df %>% slice_head(n = 8) # dplyr version of head()

# Display the very last 8 rows

veg_df %>% tail(8) # notice that tail() is basic R, not dplyr
veg_df %>% slice_tail(n = 8) # dplyr version of tail()

# Display columns `Q1Code` and `Q1Description`
veg_df %>%
  select(.data$Q1Code, .data$Q1Description)

# Display the _distinct_ values of `Q1Code` and `Q1Description`

veg_df %>%
  distinct(.data$Q1Code, .data$Q1Description)

# Display all possible _distinct_ values of `Q2Code` and `Q2Description`

veg_df %>%
  distinct(.data$Q2Code, .data$Q2Description)


# How many data are reliable and how many are not (`NotSure` = `0` or `1`)?

veg_df %>%
  count(.data$NotSure)

# How to remove not reliable data?

veg_df %>% filter(.data$NotSure == 0)



## CHALLENGE 2A

# All `Q2Description` and all `Name` values contain the string `"31xx_"`.
# Please, remove it from botoh columns.
veg_df <-
  veg_df %>%
  mutate(Q2Description = str_remove(Q2Description, "31xx_"),
         Name = str_remove(Name, "31xx_"))

# For advanced: how to
# remove it from both columns at once? Tip: use
# [`across`](https://dplyr.tidyverse.org/reference/across.html)
veg_df <-
  veg_df %>%
  mutate(across(
    c(Name, .data$Q2Description),
    ~ str_remove(.x, pattern = "31xx_")))

# Select rows where `UserReference` contains `HGA`, `LIL` or `RIN`. Hint:
# combine dplyr and stringr
veg_df %>%
  filter(str_detect(string = .data$UserReference,
                    pattern = "HGA") |
           str_detect(string = .data$UserReference,
                      pattern = "LIL") |
           str_detect(string = .data$UserReference,
                      pattern = "RIN"))

# Alternatively, use regex expression in pattern. More compact and nicer!
veg_df %>%
  filter(str_detect(string = .data$UserReference,
                    pattern = "HGA|LIL|RIN"))



# The observers were anonymized and gender neutralized by using [Gravity
# Falls](https://en.wikipedia.org/wiki/Gravity_Falls) characters. This is not
# needed anymore, so we can use the real names. Change values in column `Observer`
# as follows:

# cartoon term | real name
# --- | ---
# `"Dipper Pines"` | `"Hans Van Calster"`
# `"Wendy"` | `"Emma Cartuyvels"`
# `"Dipper Pines & Ford Pines"` | `"Hans Van Calster & Dirk Maes"`
# `"Dipper Pines & Wendy"` | `"Hans Van Calster & Emma Cartuyvels"`
# `"Dipper Pines & Mabel Pines"` | `"Hans Van Calster & Raïsa Carmen"`
# `"Dipper Pines & Robbie Valentino"` | `"Hans Van Calster & Damiano Oldoni"`
# `"Dipper Pines, Wendy, Grunkle Stan & Robbie Valentino"` | `"Hans Van Calster, Emma Cartuyvels, Joost Vanoverbeke & Damiano Oldoni"`
# `"Dipper Pines, Wendy & Mabel Pines"` | `"Hans Van Calster, Emma Cartuyvels & Raïsa Carmen"`
# `"Gravity Falls"`|  `"INBO coding club core team"`

# the smartest way to do this is by noticing that there is a one-to-one
# relationship between each cartoon character and a person.
veg_df <-
  veg_df %>%
  mutate(Observer =
           str_replace_all(Observer,
                           c("Dipper Pines" = "Hans Van Calster",
                             "Wendy" = "Emma Cartuyvels",
                             "Ford Pines" = "Dirk Maes",
                             "Mabel Pines" = "Raïsa Carmen",
                             "Robbie Valentino" = "Damiano Oldoni",
                             "Gravity Falls" = "INBO coding club core team",
                             "Grunkle Stan" = "Joost Vanoverbeke")))

# check you did everything good
veg_df %>% distinct(.data$Observer)


# Alternatively, you can use `recode()` function and "blindly" copy-paste the
# given table above
veg_df <-
  veg_df %>%
  mutate(Observer = recode(.data$Observer,
                           "Dipper Pines" = "Hans Van Calster",
                           "Wendy" = "Emma Cartuyvels",
                           "Dipper Pines & Ford Pines" = "Hans Van Calster & Dirk Maes",
                           "Dipper Pines & Wendy" = "Hans Van Calster & Emma Cartuyvels",
                           "Dipper Pines & Mabel Pines" = "Hans Van Calster & Raïsa Carmen",
                           "Dipper Pines & Robbie Valentino" = "Hans Van Calster & Damiano Oldoni",
                           "Dipper Pines, Wendy, Grunkle Stan & Robbie Valentino" = "Hans Van Calster, Emma Cartuyvels, Luc Denys & Geert",
                           "Dipper Pines, Wendy & Mabel Pines" = "Hans Van Calster, Emma Cartuyvels & Raïsa Carmen",
                           "Gravity Falls" = "INBO coding club core team"))


## CHALLENGE 2B

# Try to apply the pipe to concatenate all steps below.
# 1. Save the rows containing the maximal depth of the watercourse (`Q2Code`= `Diept`)
# or  the Secchi depth in meters (`Q3Code`= `Secch`) as a new dataframe called `extract_df`.
#
# 2. Remove from `extract_df` the columns `Name`, `QualifierType`, `ParentID`, `QualifierResource` and all the columns whose name starts with `Q1`.
#
# 3. Add to `extract_df` a new column called `value` containing the numeric values
# extracted from column `Elucidation`. After that, remove `Elucidation` column as well.
#
# 4. Map the values 0, 1 in column `NotSure` to `FALSE`, `TRUE` respectively. Hint: [basic R](https://datacornering.com/convert-r-true-and-false-values-to-1-and-0-and-vice-versa/) can help.
#
# 5. Get the rows from `extract_df` with the 5 deepest measuring points.

extract_df <- veg_df %>%
  filter(Q2Code == "Diept" | Q3Code == "Secch") %>%
  select(-c(Name,
            QualifierType,
            starts_with("Q1"),
            ParentID,
            QualifierResource)) %>%
  mutate(value = str_replace(Elucidation, ",", ".")) %>%
  mutate(value = str_remove(value, "max= ")) %>%
  mutate(value = as.numeric(value)) %>%
  select(-Elucidation) %>%
  mutate(NotSure = as.logical(.data$NotSure))

extract_df

# Get the rows from `extract_df` with the 5 deepest measuring points
extract_df %>%
  filter(Q2Code == "Diept") %>%
  slice_max(value, n = 5)

## INTERMEZZO

# During the [last
# session](https://inbo.github.io/coding-club/sessions/20220329_tidy_data.html#1)
# we sproke about tidy data. This dataset is not tidy, and so `extract_df`: the
# watercourse depth and the Secchi depth should be spread over two columns as
# they are two different variables. Here the code to create a tidy version of
# `extract_df` called `extract_df_tidy` and which we will use for the rest of
# the challenge:

extract_df_tidy <-
  extract_df %>%
  tidyr::pivot_wider(names_from = Q2Code,
                     values_from = c(Q2Description,
                                     Q3Code,
                                     Q3Description,
                                     value, NotSure))

## CHALLENGE 3

# Change the column order of `extract_df_tidy` by showing first `RecordingGivid `, `UserReference`,
# `Observer`, then the columns related to clarity (column name ending with
# `_Helde`), and then the ones related to watercourse depth (column name ending
# with `_Dept`).
extract_df_tidy <-
  extract_df_tidy %>%
  relocate(RecordingGivid, UserReference, Observer,
           ends_with("_Helde"),
           ends_with("_Dept"))


# Create a _summary_ for each recording event (`RecordingGivid`) to show the
# relative water clarity, as column `RelWaterClarity`. We define the relative
# water clarity as the Secchi depth divided by the total depth.
extract_df_tidy %>%
  group_by(RecordingGivid) %>%
  summarise(RelWaterClarity = .data$value_Helde/.data$value_Diept)

# As not all data are declared as reliable (`NotSure_*` = `TRUE`), set
# `RelWaterClarity` as NA in these cases:
extract_df_tidy %>%
  group_by(RecordingGivid) %>%
  summarise(RelWaterClarity = ifelse(
    .data$NotSure_Helde == FALSE & .data$NotSure_Diept == FALSE,
    .data$value_Helde/.data$value_Diept,
    NA_real_)
  )

# Create a column called `datetime` containing the datetime of the measurement as
# encoded in `RecordingGivid`, e.g. IV**20190809105108**87. Hint: to transform a
# string yyyymmddhhmmss to a datetime object, you can use
# lubridate::as_datetime(), e.g. `lubridate::as_datetime("20190809105108")`
extract_df_tidy <-
  extract_df_tidy %>%
  mutate(datetime = str_sub(.data$RecordingGivid, start = 3, end = 16)) %>%
  mutate(datetime = lubridate::as_datetime(datetime))

# Create a _summary_ for each observer with the number of recordings (call it `n`), the deepest watercourse
# ever measured (`max_depth`), the most cloudy water ever measured
# (`min_secch_depth`), the oldest (`first_rec`) and the most recent
# recording (`last_rec`). Show the results ordered by the number of recordings `n`, from
# highest to lowest and by `last_rec`, most recent recordings first.
extract_df_tidy %>%
  group_by(.data$Observer) %>%
  summarise(n = n_distinct(.data$RecordingGivid),
            max_depth = max(.data$value_Diept, na.rm = TRUE),
            min_secch_depth = min(.data$value_Helde, na.rm = TRUE),
            first_rec = min(.data$datetime, na.rm = TRUE),
            last_rec = max(.data$datetime, na.rm = TRUE)) %>%
  arrange(desc(.data$n), desc(.data$last_rec))

# Calculate the _summary_ above only for `Observers` with less than 10% unreliable
# recordings, i.e. less than 1 out of 10 recorded depth or clarity
extract_df_tidy %>%
  group_by(.data$Observer) %>%
  summarise(n = n_distinct(.data$RecordingGivid),
            max_depth = max(.data$value_Diept, na.rm = TRUE),
            min_secch_depth = min(.data$value_Helde, na.rm = TRUE),
            first_rec = min(.data$datetime, na.rm = TRUE),
            last_rec = max(.data$datetime, na.rm = TRUE),
            # help variables
            not_sure_recs = sum(.data$NotSure_Diept, .data$NotSure_Helde, na.rm = TRUE),
            sure_recs = sum(!is.na(c(.data$NotSure_Diept, .data$NotSure_Helde)))) %>%
  filter(.data$not_sure_recs/.data$sure_recs < 0.1) %>%
  select(-c(not_sure_recs, sure_recs)) %>%
  arrange(desc(.data$n), desc(.data$last_rec))
