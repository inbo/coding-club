library(sf)
library(tidyverse)
library(BelgiumMaps.StatBel)
library(leaflet)
library(htmltools)

# Get Flemish provinces
data("BE_ADMIN_PROVINCE") # load spatial object for provincial level
provinces_be <- st_as_sf(BE_ADMIN_PROVINCE) # convert to sf-object
provinces <-
  provinces_be %>%
  filter(TX_RGN_DESCR_NL == 'Vlaams Gewest')

# Plot provinces
ggplot() +
  geom_sf(data = provinces)

## Get number of Chiense mitten crab occurrences per province in 2015 en 2016
n_crab_provinces <- read_csv("./data/20190321_n_crabs_provinces.csv")

# Challenge 1:
# Color provinces based on number of crab occurrences in 2016
# Hint: https://workshop.mhermans.net/thematic-maps-r/04_plot.html#ggplot_with_geom_sf()
crab_provinces <-
  provinces %>%
  left_join(n_crab_provinces,
            by = c("CD_PROV_REFNIS", "TX_PROV_DESCR_NL")
  )

crab_provinces_2016 <-
  crab_provinces %>%
  filter(year == 2016)

ggplot(data = crab_provinces_2016,
       aes(fill = n)) +
  geom_sf()

# combine two plots with the facet option
ggplot(data = crab_provinces) +
  geom_sf(aes(fill = n)) +
  facet_grid(year ~ .)


# Challenge 2
# create an interactive map by using `leaflet` package showing the same information
# as in challenge 1
# Get inspired:
# https://rstudio.github.io/leaflet/colors.html
# https://rstudio.github.io/leaflet/legends.html
pal <- colorBin(palette = "Blues",
                domain = crab_provinces_2016$n)
crab_in_provinces_2016_leaflet <-
  leaflet(crab_provinces_2016) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = 0.7,
              fillColor = ~pal(n)) %>%
  addLegend("bottomright", pal = pal, values = ~n, opacity = 1)
crab_in_provinces_2016_leaflet

# Save it as a self-contained document:
#htmlwidgets::saveWidget(crab_in_provinces_2016_leaflet,
#           "docs/sessions/20190321_crab_leaflet.html",
#           selfcontained = TRUE)

# Challenge 3
# 1. Add occurrences from 2015 as markers/circles on the map
# 2. Provide popup
# 3. make sure the plot focuses on region around coordinate 51.1373384, 4.2813167
# 4. Add WMS services on rivers in Flanders as optional layers to the map

# Hints:
# - popups https://stackoverflow.com/questions/36887384/advanced-popups-in-r-shiny-leaflet
# - layercontrol https://rstudio.github.io/leaflet/showhide.html
# - wmstiles https://inbo.github.io/tutorials/tutorials/spatial_wms_services/#as-background-of-interactive-maps
# - look for layer names on https://geoservices.informatievlaanderen.be/raadpleegdiensten/VMM/wms?service=WMS&version=1.3.0&request=GetCapabilities

crab_df_2015 <- read_csv("./data/20190321_crab_occurrences_2015.csv")

wms_vmm <- "https://geoservices.informatievlaanderen.be/raadpleegdiensten/VMM/wms"
crab_provinces_occurrences <- leaflet() %>%
  setView(lng = 4.2813167, lat = 51.1373384, zoom = 12) %>%
  addTiles(group = "OSM") %>%
  addWMSTiles(
    wms_vmm,
    layers = "WsBekken",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    group = "Bekkens"
  ) %>%
  addWMSTiles(
    wms_vmm,
    layers = "WsDeelbek",  # Watervlakken
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    group = "Deelbekkens"
  ) %>%
  addWMSTiles(
    wms_vmm,
    layers = "VHAG",  # Watervlakken
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    group = "Vlaamse hydrologische atlas"
  ) %>%
  addCircles(data = crab_df_2015, ~decimalLongitude, ~decimalLatitude,
             popup = paste("Species: ", mittencrabs$species, "<br>",
                           "Date: ", mittencrabs$eventDate,"<br>")) %>%
  addLayersControl(
    overlayGroups = c("Bekkens", "Deelbekkens", "Vlaamse hydrologische atlas"),
    options = layersControlOptions(collapsed = FALSE)
  )
crab_provinces_occurrences

htmlwidgets::saveWidget(crab_provinces_occurrences,
                        "20190321_crab_occurrence_leaflet.html",
                        selfcontained = TRUE)


## Challenge 3bis bonus ----
# Add multiple years as different layers to the map

# get the years of the data set
years_data <- n_crab_provinces %>% distinct(year) %>% pull() %>% as.character()

pal <- colorBin(palette = "Blues",
                domain = crab_provinces$n)

highlight <- highlightOptions(
  weight = 5,
  color = "black",
  dashArray = "",
  fillOpacity = 0.7,
  bringToFront = TRUE)

label_options <- labelOptions(
  style = list("font-weight" = "normal", padding = "3px 8px"),
  textsize = "15px",
  direction = "auto")

crab_provinces_map <- leaflet() %>%
  setView(lng = 4.287638, lat = 50.703039, zoom = 8) %>%
  addTiles(group = "OSM") %>%

for (year_n in years_data) {
  print(year_n)
  # select the data of the specific year
  n_crab <- crab_provinces %>% filter(year == as.numeric(year_n))
  print(n_crab)

  # add polygons to map
  crab_provinces_map <- crab_provinces_map %>%
    addPolygons(data = n_crab, fillColor = ~pal(n),
                weight = 2, opacity = 1, color = "white",
                dashArray = "3", fillOpacity = 0.7,
                highlight = highlight,
                label = map(n_crab$n, HTML),
                labelOptions = label_options,
                group = year_n)
}

# add interactive layer control
crab_provinces_map <- crab_provinces_map %>%
  addLayersControl(
    baseGroups = years_data,
    options = layersControlOptions(collapsed = FALSE)
  )

crab_provinces_map


