## CHALLENGE 1

#' Convert the code below to a Rmd document called `1_geese_read_data.Rmd` and
#' make an html version of it



#' ## Setup

#' Load libraries:
library(tidyverse)    # to do datascience
library(geepack)      # to do modelling
library(INBOtheme)    # to apply INBO style to graphs


#' ## Introduction
#'
#' In this document we will:
#'
#' 1. read geese data
#' 2. explore data
#' 3. preprocess data
#'
#'
#'
#' ## Read data
#'
#' Read catches and counts of geese in Flanders:
catch_fl <- read_csv("./data/20211216/20211216_geese_counts.txt",
                    na = "NA",
                    col_types = cols(
                      province = col_character(),
                      location = col_character(),
                      year = col_double(),
                      latinName = col_character(),
                      commonName = col_character(),
                      counts = col_double(),
                      catched = col_double(),
                      adult = col_double(),
                      pulli = col_double(),
                      not_catched = col_double()
                    ))

#' General preview
head(catch_fl, n = 10)

#' ## Explore data

#' ### Taxonomic information
#'
#' Species present:
catch_fl %>% distinct(latinName, commonName)

#' ### Geographic information
#'
#' Data are geographically grouped by province and municipality (`location`):
#'
catch_fl %>% distinct(province, location)

#' ### Temporal information
#'
#' The data are temporally defined at year level:
#'
years <- catch_fl %>% distinct(year) %>% pull()

#' from:
min(years)

#' to:
max(years)

#' ## Preprocess data
#'
#' Remove data not linked to any `province` or `location` (`NAs`):
catch_fl <- catch_fl %>% filter(!is.na(province), !is.na(location))



## catch per year and province
catch_per_year_province <-
  catch_be %>%
  group_by(year, province) %>%
  summarize(catched = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(catched))

catch_per_year_province

## catch per province
catch_per_province <- catch_per_year_province %>%
  group_by(province) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(catched_total))

catch_per_province

## Graph
ggplot(catch_per_year_province,
       aes(x = year, y = catched, fill = province)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2009:2018)

## geese we are interested to in further analysis (by commonName):
species <- c(
  "Brandgans",
  "Canadese gans",
  "Grauwe gans",
  "Soepgans",
  "Nijlgans"
)

# how many catched geese per year and species?
catch_species <-
  catch_be %>%
  filter(commonName %in% species) %>%
  group_by(year, commonName) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  # mutate(commonName = as.factor(commonName)) %>%
  arrange(commonName)

catch_species

# Bar plot per year and species
ggplot(catch_species,
       aes(x = year, y = catched_total, fill = commonName)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2009:2018)


# Apply GLM model. Is number of catched geese function of year?
# Remove data before 2010
model_per_species <-
  map(
    species,
    function(s) {
      dfs <- catch_be %>%
        filter(commonName == s & year >= 2010) %>%
        arrange(location, year) %>%
        mutate(year = as_factor(as.character(year)),
               location = as_factor(location))
      geeglm(counts ~ 0 + year,
             family = poisson,
             data = dfs,
             waves = year,
             id = location)
    })
names(model_per_species) <- species

## Show results
overview_model <- map(model_per_species, ~summary(.))

####################################
### Graph models via Generalized ###
### Estimating Equations (gee) #####
####################################

# build the GEE from coefficients of the model (estimate and std_err)
overview_gee <- map2_dfr(
  overview_model,
  names(overview_model), function(model, name) {
    coefficients(model)[,1:2] %>%
      rownames_to_column(var = "year") %>%
      as_tibble() %>%
      mutate(species = name,
             year = str_sub(year, start = 5)) %>%
      select(species, everything())
  })
# add lower and upper bounds and get Exponential values to get counts back
overview_gee <-
  overview_gee %>%
  mutate(
    lwr = exp(Estimate - Std.err),
    upr = exp(Estimate + Std.err),
    Estimate = exp(Estimate)
)

ggplot(overview_gee, aes(x = year, y = Estimate, ymin = lwr, ymax = upr)) +
  geom_errorbar(colour = "cyan3") + geom_point(colour = "cyan4") +
  facet_grid(.~species) +
  xlab("year") + ylab("Estimated number of geese per location") +
  theme_inbo(14) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 9)) +
  labs(title = "All provinces")
