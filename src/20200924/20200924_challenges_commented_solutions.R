library(tidyverse)

birds <- read_tsv("./data/20200924/20200924_bird_rings.tsv")


# CHALLENGE 1

# 1.1
birds %>%
  filter(str_length(metal_ring) == 6) %>%
  filter(str_starts(color_ring, "C")) %>%
  filter(str_ends(color_ring, "R"))

#' str_starts() and str_ends are "shortcuts" for the more general str_sub() with
#' arguments start = 1, end = 1 (start of the string) and start = -1, end = -1
#' (end of the string)
birds %>%
  filter(str_length(metal_ring) == 6) %>%
  filter(str_sub(color_ring, start = 1, end = 1) == "C") %>%
  filter(str_sub(color_ring, start = -1, end = -1) == "R")


# 1.2
birds %>%
  filter(color_ring != str_to_upper(color_ring))

# 1.3
birds <-
  birds %>%
  mutate(color_ring = str_to_upper(color_ring))

# or basic R
birds$color_ring <- str_to_upper(birds$color_ring)

# no color rings with lowercase letters anymore
birds %>%
  filter(color_ring != str_to_upper(color_ring))

# CHALLENGE 2

# 2.1
birds <-
  birds %>%
  mutate(color_ring_complete = str_c(background_color,
                                     inscription_color,
                                     "(",
                                     color_ring,
                                     ")"))
# Give a look
birds %>% select(background_color,
                 inscription_color,
                 color_ring,
                 color_ring_complete)


# 2.2

birds %>%
  filter(str_length(color_ring) == 4) %>%
  filter(str_sub(color_ring, start = 3, end = 3) == "A") %>%
  filter(str_count(color_ring, pattern = "[:alpha:]") == 4)

#' pattern "[:alpha:]" means any letter from alphabet. Equivalent of "[A-Za-z]"
#' In case of only uppercase letters: "[:lower:]" or "[A-Z]"

example_string <- "I. love. the. 2019(!!). INBO. Coding. Club! Session. of. 24/09/2020...."

# Extract all letters
str_extract_all(example_string, pattern = "[:alpha:]") # or
str_extract_all(example_string, pattern = "[A-Za-z]")

# Remove all uppercase letters
str_remove_all(example_string, pattern = "[A-Z]") # or
str_remove_all(example_string, pattern = "[:upper:]")

# Extract all digits
str_extract_all(example_string, pattern = "[:digit:]") # or
str_extract_all(example_string, pattern = "[0-9]")


# Remove any "." (nice to show the need of \\ before the "." as "." is a special
# character. See in cheatsheet: "." means every character except a new line)
str_remove_all(example_string, pattern = ".") # Oh no, everything is gone!
str_remove_all(example_string, pattern = "\\.") # this is correct


str_remove_all(example_string, pattern = "\\.+")

# The last .
str_remove_all(example_string, pattern = "\\.$") # anchor "$" to the end

# The first "20"
str_remove_all(example_string, pattern = "^I") # anchor "^" to the begin
# if you remove anchor you remove also the I from INBO
str_remove_all(example_string, pattern = "I") # without anchor "^"

# All . at the end
str_remove_all(example_string, pattern = "\\.+$") # show quantifier "+"

# Any extra "." , i.e. any . preceded by .
str_remove_all(example_string, pattern = "(?<=\\.)\\.") # show look around (?<=)


# CHALLENGE 3

# 3.1
birds %>%
  filter(str_remove_all(color_ring_dots, "\\.") != color_ring)

# 3.2
birds <-
  birds %>%
  mutate(metal_ring_clean = str_remove(metal_ring, pattern = "^\\*+"))

# if asterisks are only at the start of the string, anchoring ^ is not needed

# Show rows with asterisks in metal rings
birds %>%
  filter(metal_ring != metal_ring_clean) %>%
  select(metal_ring, metal_ring_clean)

# 3.3
birds %>%
  filter(str_detect(color_ring, pattern = "[AEIOU]{2}")) # {2} is a quantifier

#' Check the behavior of this quantifier on another example
example_string2 <- "AAEEIIOOUU"
str_extract_all(example_string2, pattern = "[AEIOU]{2}")
example_string3 <- "Damiano"
str_extract_all(example_string3, pattern = "[aeiou]{2}")


## BONUS CHALLENGE

# The cleaned rings with extra dots are saved in new column metal_ring_complete
birds <-
  birds %>%
  # calculate the number of dots needed
  mutate(ndots = 10 - str_length(metal_ring_clean)) %>%
  # created a string with the needed dots
  mutate(dots = str_dup(".", ndots)) %>%
  # concatenate the first uppercase letter, the dots and the digits together
  mutate(metal_ring_complete = str_c(
    str_extract(metal_ring_clean, "^[:upper:]+"),
    dots,
    str_extract(metal_ring_clean, "[:digit:]+$"))) %>%
  # remove auxiliary columns after use
  select(-c(ndots, dots))

# Show mapping
birds %>%
  select(metal_ring_clean, metal_ring_complete)

# Check we did everything correct
birds %>% filter(str_length(metal_ring_complete) != 10)
