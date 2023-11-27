## CHALLENGE 1

# Pick the code below to generate the a static dashboard. See slides for the
# instructions.


# Load libraries:
library(tidyverse)    # to do datascience
library(here)         # to work easily with paths
library(geepack)      # to do modelling
library(heatmaply)    # to create interactive heatmaps
library(sf)           # to work with geospatial vector data
library(leaflet)      # to make dynamic maps
library(htmltools)    # to make nice html labels for dynamic maps


# Read data

catch_fl <- readr::read_csv(
  here::here("data", "20231128", "20231128_geese_counts_cleaned.txt"),
  na = ""
)

# # Static plots (page 1)
#
# ### per year and province (chart 1, on the left)
#
catch_per_year_province <-
  catch_fl %>%
  group_by(year, province) %>%
  summarize(catched = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(catched))
ggplot(catch_per_year_province,
       aes(x = year, y = catched, fill = province)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2012:2018)

# ### per province (chart 2, on the right, displayed as the 1st of a set of 2 tabs)
#
catch_per_province <- catch_fl %>%
  group_by(province) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(catched_total))
ggplot(catch_per_province,
       aes(x = province, y = catched_total)) +
  geom_bar(stat = 'identity') +
  scale_x_discrete(breaks = 2012:2018)

# ### per year (chart 3, on the right, displayed as the 2nd of a set of 2 tabs)
#
catch_per_year <- catch_fl %>%
  group_by(year) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(catched_total))
ggplot(catch_per_year,
       aes(x = year, y = catched_total)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2012:2018)


# ## Catch analysis at species level

# ### Catches per year and species (chart1, on the left)

catch_species <-
  catch_fl %>%
  group_by(year, commonName) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  arrange(commonName)
ggplot(catch_species,
       aes(x = year, y = catched_total, fill = commonName)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2012:2018)

# ### Data modelling
#
# We apply a GEE (generalized estimating equations) model to data from 2012.
species <- unique(catch_fl$commonName)
model_per_species <-
  purrr::map(
    species,
    function(s) {
      dfs <- catch_fl %>%
        dplyr::filter(commonName == s) %>%
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
overview_gee <- purrr::map2_dfr(
  overview_model,
  names(overview_model), function(model, name) {
    coefficients(model)[,1:2] %>%
      rownames_to_column(var = "year") %>%
      as_tibble() %>%
      mutate(species = name,
             year = str_sub(year, start = 5)) %>%
      dplyr::select(species, everything())
  })
overview_gee <-
  overview_gee %>%
  mutate(
    lwr = exp(Estimate - Std.err),
    upr = exp(Estimate + Std.err),
    Estimate = exp(Estimate)
)

#  Modelled data (chart2, on the right)
ggplot(overview_gee, aes(x = year, y = Estimate, ymin = lwr, ymax = upr)) +
  geom_errorbar(colour = "cyan3") + geom_point(colour = "cyan4") +
  facet_grid(.~species) +
  xlab("year") + ylab("Estimated number of geese per location") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 9))



# # Maps
#

# ## Heatmap
# Number of catches and counts per location

n_catches_per_location <- catch_fl %>%
  group_by(location) %>%
  summarise(counts = sum(.data$counts, na.rm = TRUE),
            catches = sum(.data$catched, na.rm = TRUE)) %>%
  as.data.frame()
row.names(n_catches_per_location) <- n_catches_per_location$location
n_catches_per_location$location <- NULL
heatmaply(n_catches_per_location, dendrogram = "none")


# ## Leaflet map
# Total number of catches per province (Chart 1, on top)

pr_fl <- sf::st_read(
  here::here("data", "20231128" ,"20231128_flemish_provinces.gpkg")
)
pr_fl <- pr_fl %>%
  dplyr::left_join(catch_per_province,
                   by = c("TX_PROV_DESCR_NL" = "province"))

#

bins <- seq(0, 6000, by = 1000)
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
      direction = "auto")) %>%
  addLegend(position = "bottomright",
            pal = pal,
            values = ~catched_total)
map_catch_pr



## CHALLENGE 3

# code to be on top in app.R

# CHECK THE PATH ;-)
catch_fl <- read_csv(
  here::here("data", "20231128", "20231128_geese_counts_cleaned.txt"),
  na = ""
)

# provinces
provinces <- unique(catch_fl$province)
# species
species <- unique(catch_fl$commonName)


# example of histogram for one selected province/species combination
p <- provinces[3] # Oost-Vlaanderen
s <- species[3] # Soepgans

catch_fl %>%
  filter(commonName == s,
         province == p) %>%
  group_by(year) %>%
  summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
  ungroup() %>%
  ggplot(aes(x = year, y = catched_total)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = 2012:2018) +
  labs(title = paste("Catches of", s, "in", p))
