# CHALLENGE 0 ####
# Prepare ingredients on the table = Define input values
my_grains <- 20
my_yeast <- 1
my_water <- 2
my_salt <- 3

# Add ingredients in the food processor = Pass input values to arguments of the
# function `make_bread()`
my_bread <- make_bread(
  grains = my_grains,
  yeast = my_yeast,
  water = my_water,
  salt = my_salt
) # Press `Enter`
my_bread

# Add ingredients in the food processor = Pass input values to arguments of the
# function `make_focaccia()`
my_focaccia <- make_focaccia(
  grains = my_grains,
  yeast = my_yeast,
  water = my_water,
  salt = my_salt
) # Press `Enter`
my_focaccia

# Make both focaccia and bread at once = Pass input values to arguments of the
# function `make_doughs()`
my_doughs <- make_doughs(
  grains = my_grains,
  yeast = my_yeast,
  water = my_water,
  salt = my_salt
) # Press `Enter`
my_doughs

# CHALLENGE 1  ####

## 1.1, 1.2
obs <- read_moth(year = 2022)

# Using function `read_moth_with_path()` with extra arg for path
obs <- read_moth_with_path(path = file.path("data", "20250626"), year = 2022)

# path can be also "hard coded"
obs <- read_moth_with_path(path = "data/20250626", year = 2022)

# Using `read_moth_with_path_pipes()`
obs <-  read_moth_with_path_pipes(path = file.path("data", "20250626"),
                                  year = 2022
)

## 1.3
effort_year <- get_effort(df = obs)
effort_year

abundance_year <- get_abundance(df = obs)
abundance_year

richness_year <- get_richness(df = obs)
richness_year


# CHALLENGE 2 ####

## 2.1 ####
effort_year <- get_effort(df = obs,
                          breaks = c(-Inf, 5, 10, Inf),
                          labels = c("short", "medium", "long"))
effort_year

# Use defaults
effort_year <- get_effort(df = obs)
effort_year

abundance_year <- get_abundance(df = obs,
                              breaks = c(-Inf, 10, 20, Inf),
                              labels = c("low", "medium", "high"))
abundance_year

# Use defaults
abundance_year <- get_abundance(df = obs)
abundance_year

richness_year <- get_richness(df = obs,
                              breaks = c(-Inf, 3, 17, Inf),
                              labels = c("low", "medium", "high"))
richness_year

# Use defaults
richness_year <- get_richness(df = obs)
richness_year


## 2.2 ####
plot_abundance_year_cossus_cossus <- plot_abundance(
  df = abundance_year,
  scientific_name = "Cossus cossus"
)
plot_abundance_year_cossus_cossus

plot_abundance_year_deilephila_elpenor <- plot_abundance(
  df = abundance_year,
  scientific_name = "Deilephila elpenor"
)
plot_abundance_year_deilephila_elpenor


## 2.3 ####
plot_abundance_year_cossus_cossus_nl <- plot_abundance(
  df = abundance_year,
  scientific_name = "Cossus cossus",
  language = "nl"
)
plot_abundance_year_cossus_cossus_nl

# Use default language (English)
plot_abundance_year_cossus_cossus <- plot_abundance(
  df = abundance_year,
  scientific_name = "Cossus cossus"
)
plot_abundance_year_cossus_cossus


# CHALLENGE 3 ####

## 3.1 ####
plot_effort_nl <- plot_effort(df = effort_year, language = "nl")
plot_effort_nl

# Check documentation for `plot_effort()`
docstring(plot_effort)

# Use defaults
plot_effort <- plot_effort(df = effort_year)
plot_effort

plot_richness_nl <- plot_richness(df = richness_year, language = "nl")
plot_richness_nl

# Check documentation for `plot_richness()`
docstring(plot_richness)

# Use defaults
plot_richness <- plot_richness(df = richness_year)
plot_richness

## 3.2 ####
indicators <- get_indicators(
  year = 2022,
  breaks_effort = c(-Inf, 4, 7, Inf),
  labels_effort = c("short", "long", "very long"),
  breaks_abundance = c(-Inf, 14, 39, Inf),
  labels_abundance = c("L", "M", "H"),
  breaks_richness = c(-Inf, 9, 14, Inf),
  labels_richness = c("Low", "Medium", "High")
)
indicators

# Check doucmentation for `get_indicators()`
docstring(get_indicators)

# Use defaults
indicators_2022 <- get_indicators(year = 2022)
indicators_2022

# Check with data from 2023
indicators_2023 <- get_indicators(year = 2023)
indicators_2023

# BONUS CHALLENGE  ####

docstring(plot_indicators)

plots_indicators_2022 <- plot_indicators(indicators = indicators_2022,
                                         scientific_name = "Cossus cossus",
                                         language = "nl")
plots_indicators_2022

indicators_2O23 <- get_indicators(
  year = 2023,
  breaks_effort = c(-Inf, 4, 7, Inf),
  labels_effort = c("short", "long", "very long"),
  breaks_abundance = c(-Inf, 14, 39, Inf),
  labels_abundance = c("L", "M", "H"),
  breaks_richness = c(-Inf, 9, 14, Inf),
  labels_richness = c("Low", "Medium", "High")
)

plots_indicators_2023_sphinx_ligustri <- plot_indicators(
  indicators = indicators_2O23,
  scientific_name = "Sphinx ligustri",
  language = "nl"
)
plots_indicators_2022_sphinx_ligustri <- plot_indicators(
  indicators = indicators_2022,
  scientific_name = "Sphinx ligustri",
  language = "en"
)
plots_indicators_2022_sphinx_ligustri
