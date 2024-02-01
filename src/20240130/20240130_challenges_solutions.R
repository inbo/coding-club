library(tidyverse)

birds <- read_tsv("./data/20240130/20240130_bird_rings.txt")
sc_names <- read_csv("./data/20240130/20240130_scientificnames.txt")
sc_names <- sc_names$scientific_name

# CHALLENGE 1

# Always good to start with a "glimpse" of the data
glimpse(birds)


# 1.1
str_length(birds$metal_ring)

# Basic R solution is also nice
nchar(birds$metal_ring)

# compact and sorted lengths
sort(unique(str_length(birds$metal_ring)))


# 1.2
str_starts(birds$color_ring, pattern = "C")

# use negate  = TRUE to reverse the condition: which color rings do not start
# with "C"?
stringr::str_starts(color_ring, pattern = "C", negate = TRUE)

# general answer with `all()`
all(str_starts(birds$color_ring, "C"))


# 1.3
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


# 1.4
birds$color_ring == str_to_upper(birds$color_ring)

# general answer with `all()`
all(birds$color_ring == str_to_upper(birds$color_ring))

# you can also start using regular expresssions for this (second page of the
# cheatsheet)
str_detect(birds$color_ring, "[A-Z]")


# 1.5
birds$color_ring <- str_to_upper(birds$color_ring)

# or if you are a dplyr addicted :-)
birds_cleaned <- birds %>%
  mutate(color_ring = str_to_upper(color_ring))


# Extra
birds %>%
  filter(str_length(metal_ring) == 6) %>%
  filter(str_starts(color_ring, "C")) %>%
  filter(str_ends(color_ring, "R"))


# CHALLENGE 2

# 2.1
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
                 color_ring_complete)


# 2.2
str_length(birds$color_ring) == 4 &
  str_count(birds$color_ring, pattern = "[:alpha:]") == 4 &
  str_sub(birds$color_ring, start = 3, end = 3) == "A"

# 2.3
str_detect(birds$color_ring, pattern = "[:digit:]")

# 2.4
birds$digit <- as.integer(str_extract(birds$color_ring, pattern = "[:digit:]"))

# Extra
birds %>%
  filter(str_length(color_ring) == 4) %>%
  filter(str_count(color_ring, pattern = "[:alpha:]") == 4) %>%
  filter(str_sub(color_ring, start = 3, end = 3) == "A")

#' pattern "[:alpha:]" means any letter from alphabet. Equivalent of "[A-Za-z]"
#' In case of only uppercase letters: "[:upper:]" or "[A-Z]"


# INTERMEZZO

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


# Remove any "." (nice to show the need of \\ before the "." as "." is a special
# character. See in cheatsheet: "." means every character except a new line)
str_remove_all(example_string, pattern = ".") # Oh no, everything is gone!
str_remove_all(example_string, pattern = "\\.") # this is correct

# Check it with str_view() also
str_view(example_string, pattern = ".", html = TRUE)
str_view(example_string, pattern = "\\.", html = TRUE)

## But why two backslash? Because backslash is a special character in R. So, you
## need always two of them to mean `\`. Try using one `\`
`str_view(example_string, pattern = "\.", html = TRUE)


# Remove all dots = one or more dots: add the quantifier symbol `+` at the end
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
# if you remove anchor you remove also the `I` from `INBO`
str_view(example_string, pattern = "I", html = TRUE)
str_remove_all(example_string, pattern = "I")

# All . at the end
str_remove_all(example_string, pattern = "\\.+$") # show quantifier "+"

# Any extra `.` i.e. any `.` preceded by `.`: use the look around (?<=)
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


## Intermezzo: real life example

# The {} means 1 or two repetitions
# Use `(` `)` or create groups
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

# if version contains four numbers and three dots, the last part is not
# extracted.
profile5 <- "cam/12.4.0.999/camtrap-dp-profile.json"
version5 <- str_extract(profile5, pattern_version)
version5


## CHALLENGE 3A

# 3.1
birds %>%
  filter(str_remove_all(color_ring_dots, "\\.") != color_ring)

# Notice that you can remove also by replacing by "", not really elegant but
# works
birds %>%
  filter(str_replace(birds$color_ring_dots, "\\.", "") != color_ring)

# 3.2
birds$metal_ring_clean <- str_remove(birds$metal_ring, pattern = "^\\*+")

# If yo uare sure asterisks are only present at the start of the string,
# anchoring ^ is not needed of course.
str_remove("***H146278", pattern = "\\*+")


# Show rows with asterisks in metal rings
birds %>%
  filter(metal_ring != metal_ring_clean) %>%
  select(metal_ring, metal_ring_clean)

# 3.3
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


# CHALLENGE 3B

# remove abbreviations first
cleaned_sc_names <- str_remove_all(
  sc_names,
  pattern = "sp\\.|spp\\.|spec\\.|indet\\.|cf|nov\\.|ined\\.") %>%
  # remove whitespaces
  str_squish(cleaned_sc_names)

cleaned_sc_names

# Notice that the pattern cf is dangerous: a scientific name could contain "cf" and it will be deleted as well!
# It doesn't occur in our example, but what if?
# Example: Nepenthes truncata Macfarl. (https://www.gbif.org/species/3702212)
str_view("Nepenthes truncata Macfarl.", pattern = "cf", html = TRUE)

# Use look-arounds: the cf we want to remove is preceded and followed by a space
str_view("Nepenthes truncata Macfarl.", pattern = "(?<= )cf(?= )", html = TRUE)

# So this cleaning pipeline is preferable
cleaned_sc_names <- str_remove_all(
  sc_names,
  pattern = "sp\\.|spp\\.|spec\\.|indet\\.|nov\\.|ined\\.") %>%
  str_remove_all(
    sc_names,
    pattern = "(?<= )cf(?= )") %>%
  # remove whitespaces
  str_squish(cleaned_sc_names)
