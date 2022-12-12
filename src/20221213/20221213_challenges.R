## CHALLENGE 1

# Convert the code below to a Rmd document called `1_geese_read_data.Rmd` and
# make an html version of it


# title : "Read and preprocess geese data"
#
# # Setup

# Load libraries:
library(tidyverse)    # to do datascience
library(geepack)      # to do modelling
library(INBOtheme)    # to apply INBO style to graphs
library(sf)           # to work with geospatial vector data
library(leaflet)      # to make dynamic maps
library(htmltools)    # to make nice html labels for dynamic maps

# # Introduction
#
# In this document we will:
#
# 1. read geese data
# 2. explore data
# 3. preprocess data
#
#
#
# # Read data
#
# Read catches and counts of geese in Flanders:
catch_fl <- read_csv("./data/20221213/20221213_geese_counts.txt",
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

# Number of catch data:
nrow(catch_fl)

# Preview:
head(catch_fl, n = 30)

# # Explore data

# ## Taxonomic information
#
# Species present:
catch_fl %>% distinct(latinName, commonName)

# ## Geographic information
#
# Data are geographically grouped by province and municipality (`location`):
#
catch_fl %>% distinct(province, location)

# ## Temporal information
#
# The data are temporally defined at year level:
#
years <- catch_fl %>% distinct(year) %>% pull()

# from:
min(years)

# to:
max(years)

# ## Preprocess data
#
# Data not linked to any `province` or `location` (`NAs`) will be removed.
#
# Number of rows removed:
catch_fl %>%
  filter(is.na(province) | is.na(location)) %>%
  nrow


# Final dataset:
catch_fl <- catch_fl %>% filter(!is.na(province) & !is.na(location))
catch_fl


## CHALLENGE 2

# Title: Data visualization

# In this section we will show how number of catches varies by year, province
# and species. Both static plots and dynamic maps are generated.
#
# # Static plots
#
# ## Show catches (make a tabbed section out of it)
# 
# ### per province (1st tab)

catch_per_province <- catch_fl %>%
  group_by(province) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(catched_total))
ggplot(catch_per_province,
       aes(x = province, y = catched_total)) +
  geom_bar(stat = 'identity') +
  scale_x_discrete(breaks = 2009:2018)

# ### per year (2nd tab)

catch_per_year <- catch_fl %>%
  group_by(year) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(catched_total))
ggplot(catch_per_year,
       aes(x = year, y = catched_total)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2009:2018)

# ### per year and province (3rd tab)

catch_per_year_province <-
  catch_fl %>%
  group_by(year, province) %>%
  summarize(catched = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(catched))
ggplot(catch_per_year_province,
       aes(x = year, y = catched, fill = province)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2009:2018)

# ## Catch analysis at species level
#
# ### Species selection
#
# Before we proceed to analyse the catches at species level, specify the species we are interested to by `commonName`:
# SHOW THIS CHUNK CODE!
species <- c(
  "Brandgans",
  "Canadese gans",
  "Grauwe gans",
  "Soepgans",
  "Nijlgans"
)

# ### Catches per year and species

catch_species <-
  catch_fl %>%
  filter(commonName %in% species) %>%
  group_by(year, commonName) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  arrange(commonName)
ggplot(catch_species,
       aes(x = year, y = catched_total, fill = commonName)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2009:2018)

# ### Data modelling
#
# We apply a GEE (generalized estimating equations) model to data from 2010.


model_per_species <-
  map(
    species,
    function(s) {
      dfs <- catch_fl %>%
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
overview_model <- map(model_per_species, ~summary(.))
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



# # Dynamic maps
#
# We make dynamic _leaflet_ maps of total number of catches per province.
#
pr_fl <- st_read("./data/20221213/20221213_flemish_provinces.gpkg")
pr_fl <- pr_fl %>%
  dplyr::left_join(catch_per_province,
                   by = c("TX_PROV_DESCR_NL" = "province"))
bins <- seq(0, 14000, by = 2000)
pal <- colorBin("YlOrRd", domain = pr_fl$catched_total, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g catches",
  pr_fl$TX_PROV_DESCR_NL, pr_fl$catched_total
) %>% lapply(HTML)

map_catch_pr <- leaflet(pr_fl) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~pal(catched_total),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    highlightOptions = highlightOptions(
      weight = 5,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"))
map_catch_pr



