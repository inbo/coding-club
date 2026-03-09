library(tidyverse)
library(sf)
library(terra)
library(leaflet)
library(leafem)
library(leafpop)
library(mapview)
library(viridis)
library(inbospatial)



# CHALLENGE 1 ####

# Load the data
visits <- readr::read_csv(
  file = "./data/20260225/20260225_butterflies_love_plants.csv",
  na = "") %>%
  # Convert to spatial data.frame
  sf::st_as_sf(coords = c("lng", "lat"), crs = 4326)


## 1.1 ####
mapview::mapview(visits)


## 1.2 ####
mapview::mapview(visits, zcol = "species", legend = TRUE)


## 1.3 ####
mapview::mapview(
  visits,
  zcol = "type",
  col.regions = c("trees" = "dark green", "shrubs" = "light green"),
  legend = TRUE
)


## 1.4 ####
mapview::mapview(
  visits,
  zcol = "species",
  legend = TRUE,
  alpha.regions = 0.4,
  alpha = 0.5,
  color = "red",
  layer.name = "Plants type",
  popup = leafpop::popupTable(visits,zcol = c("species", "type"))
)

## 1.5 ####
# `mapview()` shows by default the mouse coordinates: no need to add `leafem::addMouseCoordinates()`, commented here below.
# Also, the "zoom-to-layer" button is shown by default: no need to add `leafem::addHomeButton()`, commented here below as well.
mapview::mapview(
  visits,
  zcol = "species",
  legend = TRUE,
  map.types = "OpenStreetMap"
  ) 
  # %>% leafem::addMouseCoordinates()
  # %>% leafem::addHomeButton()

# Do not show zoom-to-layer button (home button).
mapview::mapview(
  visits,
  zcol = "species",
  legend = TRUE,
  map.types = "OpenStreetMap",
  homebutton = FALSE
)


## 1.6 (Extra) ####
visits <- visits %>%
  mutate(
    species = factor(species, levels = unique(species[order(type, species)]))
  )
color_palette <- viridis::inferno(length(unique(visits$species)))
mapview::mapview(
    visits %>% filter(type == "trees"),
    zcol = "species",
    col.regions = color_palette,
    legend = TRUE,
    layer.name = "Trees"
  ) +
  mapview::mapview(
    visits %>% filter(type == "shrubs"),
    zcol = "species",
    col.regions = color_palette,
    layer.name = "Shrubs"
  )



# CHALLENGE 2 ####
# Load the temperature raster data
temperature <- terra::rast(x = "./data/20260225/20260225_tdiff_tmax_tmin_01.tif")
# Check the layers
names(temperature)


## 2.1 ####
color_palette <- viridis::magma(100) # 100 colors should be enough for a good gradient, but you can experiment with more or less colors.
mapview::mapview(
  temperature,
  col.regions = color_palette,
  legend = TRUE,
  layer.name = "Average temperature fluctuation in January"
)


## 2.2 ####
min_value_diff <- terra::minmax(temperature)[1,1]
max_value_diff <- terra::minmax(temperature)[2,1]


mapview::mapview(
  temperature,
  col.regions = color_palette,
  legend = TRUE,
  at = seq(from = min_value_diff, to = max_value_diff, by = 5),
  layer.name = "Average temperature fluctuation in January"
)


## 2.3 ####
color_palette <- viridis::magma(100)
mapview::mapview(
  temperature[[1]],
  col.regions = color_palette,
  legend = TRUE,
  layer.name = "Average temperature fluctuation in January"
) +
  mapview::mapview(
    temperature[[2]],
    col.regions = color_palette,
    legend = TRUE,
    layer.name = "Average maximum temperature in January",
    hide = TRUE
  ) +
  mapview::mapview(
    temperature[[3]],
    col.regions = color_palette,
    legend = TRUE,
    layer.name = "Average minimum temperature in January",
    hide = TRUE
  )

# If you want to write DRY (Don't Repeat Yourself) code to make it more reusable and less error-prone, 
# you can create a function and then apply to all cases.
library(purrr)

# Define labels for each layer
labels <- c(
  "tdiff_01" = "Average temperature fluctuation in January", 
  "tmin_01" = "Average maximum temperature in January", 
  "tmax_01" = "Average minimum temperature in January"
)
# Define default visibility for each layer (TRUE = visible, FALSE = hidden)
visibility <- c("tdiff_01" = TRUE, "tmin_01" = FALSE, "tmax_01" = FALSE)

create_temp_mapview_layer <- function(layer, global_minmax = TRUE) {

  # Color legend range options
  if (global_minmax) {
    # Find global temperature min/max for uniform legend (same values across layers)
    min_value_diff <- floor(min(terra::minmax(temperature)["min", ]))
    max_value_diff <- ceiling(max(terra::minmax(temperature)["max", ]))
  } else {
    # You could do this layer-wise, but it might lead to different color scales across layers, which can be confusing
    min_value_diff <- terra::minmax(temperature)["min", layer]
    max_value_diff <- terra::minmax(temperature)["max", layer]
  }
  
  # Create a color sequence
  color_seq <- seq(from = min_value_diff, to = max_value_diff, by = 5)
    
  # Create the map and return it
  m_new <- mapview(
    temperature[layer],
    col.regions = viridis::magma(length(color_seq + 1)),
    at = color_seq,
    layer.name = labels[[layer]],
    hide = !visibility[[layer]],
    homebutton = FALSE
  )
  return(m_new)
}

# Create all maps with `purrr::map()` and then show them by "reducing" them with +
temperature_layers <- names(temperature)
maps_list <- purrr::imap(temperature_layers, create_temp_mapview_layer)
purrr::reduce(maps_list, `+`) # short version of: maps_list[[1]] + maps_list[[2]] + maps_list[[3]]



# CHALLENGE 3 ####

# Load data
moth_captures <- readr::read_csv(
  file = "./data/20260225/20260225_moth_captures.csv",
  na = "")


## 3.1 ####
leaflet::leaflet(moth_captures) %>%
  leaflet::addTiles() %>%
  leaflet::addProviderTiles(providers$Esri.WorldImagery) %>%
  leaflet::addPolylines(
    lng = ~x,
    lat = ~y,
    color = "red",
    weight = 3
  )


## 3.2 ####
captures_map <- leaflet::leaflet(moth_captures) %>%
  leaflet::addTiles() %>%
  leaflet::addProviderTiles(providers$Esri.WorldImagery) %>%
  leaflet::addPolylines(
    lng = ~x,
    lat = ~y,
    color = "red",
    weight = 3,
    label = ~paste0("Total distance: ", total_distance, " m")
  )
captures_map


## 3.3 ####
captures_3_3 <- captures_map %>%
  leaflet::addCircleMarkers(
    lng = ~x,
    lat = ~y,
    radius = 6,
    color = "white",
    fillColor = "turquoise",
    fillOpacity = 1,
    label = ~paste0("Date of capture: ", date)
  )
captures_3_3


## 3.4 ####
captures_3_4 <- captures_map %>%
  leaflet::addCircleMarkers(
    lng = ~x,
    lat = ~y,
    radius = 6,
    color = "white",
    fillColor = "turquoise",
    fillOpacity = 1,
    label = ~paste0("Date of capture: ", date),
    labelOptions = leaflet::labelOptions(noHide = TRUE, textOnly = TRUE)
  )
captures_3_4


## 3.5 ####
captures_3_5 <- captures_map %>%
  leaflet::addCircleMarkers(
    lng = ~x,
    lat = ~y,
    radius = 6,
    color = "white",
    fillColor = "turquoise",
    fillOpacity = 1,
    label = ~paste0("Date of capture: ", date),
    labelOptions = leaflet::labelOptions(
      noHide = TRUE,
      textOnly = TRUE,
      style = list(
        "color" = "white",
        "font" = "sans-serif",
        "font-size" = "12px",
        "font-weight" = "bold"
      )
  )
)
captures_3_5
