library(tidyverse)

birds <- read_tsv("./data/20251127/20251127_bird_rings.tsv")
sc_names_df <- read_tsv("./data/20251127/20251127_scientificnames.tsv")
View(sc_names_df) # Column `comment` gives you an idea about what you should clean
sc_names <- sc_names_df$scientific_name

# CHALLENGE 1 ####

# Always good to start with a "glimpse" of the data
glimpse(birds)


## 1.1 ####
str_length(birds$metal_ring)

# Basic R solution is also nice
nchar(birds$metal_ring)

# With its default value, `str_count()` works as str_length(). However, notice that
# str_count() is more general as it counts occurrences of a pattern.
str_count(birds$metal_ring)

# Comparing results is easy with waldo package :-)
# Install it first if you don't have it yet
# install.packages("waldo")
waldo::compare(str_length(birds$metal_ring), str_count(birds$metal_ring))

# compact and sorted lengths
sort(unique(str_length(birds$metal_ring)))


# 1.2 ####
str_starts(birds$color_ring, pattern = "C")

# use negate  = TRUE to reverse the condition: which color rings do not start
# with "C"?
stringr::str_starts(color_ring, pattern = "C", negate = TRUE)

# general answer with `all()`
all(str_starts(birds$color_ring, "C"))


## 1.3 ####
str_ends(birds$color_ring, "R")

# general answer with `all()`
all(str_ends(birds$color_ring, "R"))

#' str_starts() and str_ends are "shortcuts" for the more general str_sub() with
#' arguments start = 1, end = 1 (start of the string) and start = -1, end = -1
#' (end of the string)
#' The equality condition (' == ') does the rest
str_sub(birds$color_ring, start = 1, end = 1) == "C"
str_sub(birds$color_ring, start = -1, end = -1) == "R"

# general answer with `all()`
all(str_sub(birds$color_ring, start = 1, end = 1) == "C")
all(str_sub(birds$color_ring, start = -1, end = -1) == "R")


## 1.4 ####

# Solution using str_to_upper and equality
birds$color_ring == str_to_upper(birds$color_ring)

# General answer with `all()`
all(birds$color_ring == str_to_upper(birds$color_ring))

# Can we still solve this using `str_detect()`? Yes! We have to use a regular
# expression (second page of the cheatsheet) that matches lowercase letters. So,
# the question is reversed: Are there any lowercase letters in color_ring?
any(str_detect(birds$color_ring, "[:lower:]"))

# Or if you want still to answer to the original question:
# Are all the color rings uppercase?
all(str_detect(birds$color_ring, "[:lower:]", negate = TRUE))

# Why so complicated? Because str_detect() looks for the presence of a pattern.
# So, using str_detect() with pattern = "[:upper:]" will always result to TRUE
# becasue it's enough that one ring contains an uppercase letter, as it's the
# case for all rings.
all(str_detect(birds$color_ring, "[:upper:]"))


## 1.5 ####
birds$color_ring <- str_to_upper(birds$color_ring)

# or if you are a dplyr addicted :-)
birds_cleaned <- birds %>%
  mutate(color_ring = str_to_upper(color_ring))


# Extra: notice how dplyr and stringr work well together for filtering
# rows based on string conditions
birds %>%
  dplyr::filter(str_length(metal_ring) == 6) %>%
  dplyr::filter(str_starts(color_ring, "C")) %>%
  dplyr::filter(str_ends(color_ring, "R"))



# CHALLENGE 2 ####

## 2.1 ####
birds$color_ring_complete <- str_c(birds$background_color,
                                   birds$inscription_color,
                                   "(",
                                   birds$color_ring,
                                   ")"
)

# Give a look
birds %>% select(background_color,
                 inscription_color,
                 color_ring,
                 color_ring_complete
)

# Another good way is using `str_glue()`
# Notice that with str_glue() you can use the column names directly
# without the `$` operator
birds$color_ring_complete <- birds %>%
  str_glue_data("{background_color}{inscription_color}({color_ring})")

# Give a look
birds %>%
  dplyr::select(background_color,
                inscription_color,
                color_ring,
                color_ring_complete
  )


## 2.2 ####
all(str_length(birds$color_ring) == 4)

all(str_count(birds$color_ring, pattern = "[:alpha:]") == 4)

all(str_sub(birds$color_ring, start = 3, end = 3) == "A")

# If you want to complicate your life because you cannot wait challenge 3 for using regex and you want the most general solution possible:
str_detect(birds_new$color_ring, "[:graph:][:graph:]A[:graph:]")
#' pattern "[:graph:]" means any visible character (letters, digits, symbols,
#' punctuation, etc.) except space. Equivalent of "[^\\s]" where \\s means any
#' whitespace character (space, tab, newline, etc.)
waldo::compare(
  str_detect(birds_new$color_ring, "[:graph:][:graph:]A[:graph:]"),
  str_detect(birds_new$color_ring, "[^\\s][^\\s]A[^\\s]")
)


## 2.3 ####
str_detect(birds$color_ring, pattern = "[:digit:]")

## 2.4 ####
birds$digit <- as.integer(str_extract(birds$color_ring, pattern = "[:digit:]"))

# Extra
birds %>%
  dplyr::filter(str_length(color_ring) == 4) %>%
  dplyr::filter(str_count(color_ring, pattern = "[:alpha:]") == 4) %>%
  dplyr::filter(str_sub(color_ring, start = 3, end = 3) == "A")

#' pattern "[:alpha:]" means any letter from alphabet. Equivalent of "[A-Za-z]"
#' In case of only uppercase letters: "[:upper:]" or "[A-Z]"


# INTERMEZZO ####

example_string <- "I. love. the. 2024(!!) INBO. Coding. Club! Session. of. 30/01/2024...."

# Extract all letters
str_extract_all(example_string, pattern = "[:alpha:]") # or
str_extract_all(example_string, pattern = "[A-Za-z]")

# Remove all uppercase letters
str_remove_all(example_string, pattern = "[A-Z]") # or
str_remove_all(example_string, pattern = "[:upper:]")

# Use `str_view()` to check which parts of the string match the regex and which
# not. This is a handy explorative step before manipulating the string.
str_view(example_string, pattern = "[:alpha:]")
# To show the matches highlighted in Viewer pane, add `html = TRUE`
str_view(example_string, pattern = "[:alpha:]", html = TRUE)

# Extract all digits
str_view(example_string, pattern = "[:digit:]", html = TRUE)
str_extract_all(example_string, pattern = "[:digit:]") # or
str_extract_all(example_string, pattern = "[0-9]")


# Remove any "." (But "." is a special character. See in cheatsheet: "." means
# every character except a new line)
str_remove_all(example_string, pattern = ".") # Oh no, everything is gone!
str_remove_all(example_string, pattern = "\\.") # this is correct

# Check it with str_view() also
str_view(example_string, pattern = ".", html = TRUE) # Everything is matched
str_view(example_string, pattern = "\\.", html = TRUE) # Only dots are matched

## But why two backslash? Because backslash is in R a special character too. So,
## you need always two of them to mean `\`. Try using one `\` and you will get
## an error:
str_view(example_string, pattern = "\.", html = TRUE)


# How to remove all dots? All dots = one or more dots: you need to add the
# quantifier symbol `+` at the end of the `patttern` value
str_remove_all(example_string, pattern = "\\.+")

# Remove the very last dot `.` at the end of the string: use the anchor `$` at
# the end
str_remove_all(example_string, pattern = "\\.$")

# Remove all the dots `....` at the end of the string: use both quantifier and
# anchor
str_view(example_string, pattern = "\\.+$", html = TRUE)
str_remove_all(example_string, pattern = "\\.+$")


# Remove the first `I`: use anchor "^" at the beginning of the regex
str_view(example_string, pattern = "^I", html = TRUE)
str_remove_all(example_string, pattern = "^I")
# If you remove the anchor you remove also the `I` from `INBO`
str_view(example_string, pattern = "I", html = TRUE)
str_remove_all(example_string, pattern = "I")


# Remove any extra `.` i.e. any `.` preceded by `.`: use the look around (?<=)
str_view(example_string, pattern = "(?<=\\.)\\.", html = TRUE)
str_remove_all(example_string, pattern = "(?<=\\.)\\.")

# But what if your string contains exactly the substring "[:digit:]", or `$`?
# It is not detected:
str_view(string = "I love [:digit:]!!", pattern = "[:digit:]", html = TRUE)
# We need to pass a "fixed" pattern.
str_view(string = "I love [:digit:]!!",
         pattern = fixed("[:digit:]"),
         html = TRUE
)

# Example with `$`
str_view(string = "I love buy with dollars$",
         pattern = "dollars$",
         html = TRUE
)
str_view(string = "I love buy with dollars$",
         pattern = fixed("dollars$"),
         html = TRUE
)

# So, two very important pattern types are:
# - `regex()`, the default
# - `fixed()`
# Actually up to now we were using regex without being aware it :-)
# But we were "lucky" as we were searching for patterns not containing any `.`
# or `+` or `$` or others regex special characters)
# So, using `fixed()` is recommended when you are not thinking in terms of
# regex, e.g.
str_ends(birds$color_ring, pattern = fixed("R"))


# Another (last) way is using regex with `[ ]` in this case
str_view(string = "I love using .dots. everywhere...",
         pattern = "[.]",
         html = TRUE
)

# But it does NOT work always as with [ ] you can capture something else too
str_view(string = "I love buying using dollars$",
         pattern = "[dollars$]",
         html = TRUE
)



# CHALLENGE 3 ####

# Remove abbreviations first: ALMOST correct solution, but not perfect!
cleaned_sc_names <- str_remove_all(
  sc_names,
  pattern = "sp\\.|subsp\\.|spp\\.|spec\\.|indet\\.|cf|nov\\.|ined\\.") %>%
  str_replace_all(pattern = ";", replacement = ",") %>%
  # remove whitespaces
  str_squish()

waldo::compare(cleaned_sc_names, sc_names)

# Notice that the pattern cf is dangerous: the "cf" in a scientific name is deleted!
# Examples in our names:
# - Citrus decumana var. paradisi (Macfad.) H.H.A.Nicholls (https://www.gbif.org/species/7586096)
# - Nepenthes truncata Macfarl. (https://www.gbif.org/species/3702212)
str_view("Citrus decumana var. paradisi (Macfad.) H.H.A.Nicholls", pattern = "cf", html = TRUE)
str_view("Nepenthes truncata Macfarl.", pattern = "cf", html = TRUE)


# Use look-arounds: the cf we want to remove is preceded and followed by a space
str_view("Nepenthes truncata Macfarl.", pattern = "(?<= )cf(?= )", html = TRUE)

# Also, subsp. in the middle of the string must not be removed.
# Example in our names:
# - "Betulapion simile subsp. simile (W.Kirby, 1811)"
str_view("Betulapion simile subsp. simile (W.Kirby, 1811)",
         pattern = "subsp\\.",
         html = TRUE
)
# So we need to use the $ anchor to remove only those abbreviations at the end
# of the string. So, in this case nothing is selected:
str_view("Betulapion simile subsp. simile (W.Kirby, 1811)",
         pattern = "subsp\\.$",
         html = TRUE
)
# While in this case it is selected:
str_view("Betulapion simile subsp.", pattern = "subsp\\.$", html = TRUE)

# So this cleaning pipeline is the correct one:
cleaned_sc_names <- str_remove_all(
  sc_names,
  pattern = "subsp\\.$|sp\\.$|spp\\.$|spec\\.$|indet\\.$|nov.$|ined\\.$") %>%
  str_remove_all(
    pattern = "(?<= )cf(?= )") %>%
  # Correct `"Tetanocera Duméril; 1800"` to `"Tetanocera Duméril, 1800"`
  str_replace_all(";", ",") %>%
  # Correct "`Alo1sa Linck, 1790`" to Aloisa Linck, 1790:
  # digits between letters are typos and must be removed
  str_remove_all(pattern = "(?<=[:alpha:])\\d+(?=[:alpha:])") %>%
  # remove whitespaces
  str_squish()

# You can use `waldo::compare()` to check the changes.
# Visualize all differences
waldo::compare(sc_names, cleaned_sc_names, max_diffs = Inf)


# BONUS CHALLENGE (BC) ####

## BC.1 ####
birds %>%
  filter(str_remove_all(color_ring_dots, "\\.") != color_ring)

# Notice that you can remove also by replacing with "", not really elegant but
# works
birds %>%
  filter(str_replace(birds$color_ring_dots, "\\.", "") != color_ring)

## BC.2 ####
birds$metal_ring_clean <- str_remove(birds$metal_ring, pattern = "^\\*+")

# If you are sure asterisks are only present at the start of the string,
# anchoring ^ is not needed of course. Example with non existing case:
str_remove("***H146*278*", pattern = "\\*+")


# Show rows with asterisks in metal rings
birds %>%
  filter(metal_ring != metal_ring_clean) %>%
  select(metal_ring, metal_ring_clean)

## BC.3 ####
birds %>%
  filter(str_detect(color_ring, pattern = "[AEIOU]{2}")) # {2} is a quantifier

# If you want to include lowercase vowels as well
birds %>%
  filter(str_detect(color_ring, pattern = "[aeiouAEIOU]{2}"))


# Check the behavior of this quantifier on another example
example_string2 <- "Damiano-DAMIANO"
str_view(example_string2, pattern = "[AEIOU]{2}", html = TRUE)
example_string3 <- "Damiano-DAMIANO"
str_view(example_string3, pattern = "[aeiou]{2}", html = TRUE)

## BC.4 ####

# \\d+ means one or more digits
# \\. means a dot (escaped with backslash)
# `{1,2}` means 1 or 2 repetitions
# Use `(` `)` to group the part `\\.\\d+` so that the quantifier
# `{1,2}` applies to the whole group
pattern_version <- "\\d+(\\.\\d+){1,2}"

profile1 <- "https://rs.gbif.org/sandbox/data-packages/camtrap-dp/1.0/profile/camtrap-dp-profile.json"
version1 <- stringr::str_extract(profile1, pattern_version)
version1

profile2 <- "a/b/c/d1d/cam/3.0.5/camtrap-dp-profile.json"
version2 <- str_extract(profile2, pattern_version)
version2

profile3 <- "a/b/c/d1d/cam/v2/camtrap-dp-profile.json"
version3 <- str_extract(profile3, pattern_version)
version3

profile4 <- "a/b/c/d1.d/cam/3.0.5/camtrap-dp-profile.json"
version4 <- str_extract(profile4, pattern_version)
version4

# If version contains four numbers and three dots, the last part is not
# extracted.
profile5 <- "cam/12.4.0.999/camtrap-dp-profile.json"
version5 <- str_extract(profile5, pattern_version)
version5

