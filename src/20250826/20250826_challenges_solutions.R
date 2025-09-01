library(tidyverse)
library(sf)
library(ggspatial)
library(ggrepel)
library(mapview)
library(leafpop)
library(leafem)
library(inbospatial)


# Read the Geopackage with number of Giant Hogweed occurrences per municipality
n_giant_hogweed <- sf::st_read(
  dsn = "data/20250826/20250826_giant_hogweed_per_municipality.gpkg",
  layer = "giant_hogweed_per_municipality"
)

# CHALLENGE 1 ####

## 1.1 ####
map_n_giant_hogweed <- mapview(
  n_giant_hogweed,
  # Define the column to use for the color scale
  zcol = "n",
  # Activate the legend
  legend = TRUE,
  # Set color of the polygon borders
  color = "white"
)
map_n_giant_hogweed

# You can use the pipe operator `%>%` to pass the first argument,
# `n_giant_hogweed`, to mapview() function. However, it can be that you don't
# get the right map in the Viewer pane. This is a bug in RStudio. See my comment
# on mapview's GitHub:
# https://github.com/r-spatial/mapview/issues/348#issuecomment-3233452165
n_giant_hogweed %>%
  mapview(legend = TRUE,
          zcol = "n",
          color = "white"
  )


## 1.2 ####
map_n_giant_hogweed <- mapview(
  n_giant_hogweed,
  # Define the column to use for the color scale
  zcol = "n",
  # Define the popup content
  popup = leafpop::popupTable(n_giant_hogweed,
                              zcol = c("mun_name_nl", "mun_name_fr", "n")),
  # Activate the legend
  legend = TRUE,
  # Set legend title
  layer.name = "Number of giant hogweed occurrences",
  # Set color of the polygon borders
  color = "white",
  # Set opacity of the polygons to 0.8
  alpha.regions = 0.8,
  # Set opacity of the lines to 0.5
  alpha = 0.5
)
map_n_giant_hogweed


## 1.3 ####
map_n_giant_hogweed <- mapview(
  n_giant_hogweed,
  # Allow only OpenStreetMap as basemap
  map.types = c("OpenStreetMap"),
  # Define the column to use for the color scale
  zcol = "n",
  # Define the popup content
  popup = leafpop::popupTable(n_giant_hogweed,
                              zcol = c("mun_name_nl", "mun_name_fr", "n")),
  # Activate the legend
  legend = TRUE,
  # Set legend title
  layer.name = "Number of giant hogweed occurrences",
  # Set color of the polygon borders
  color = "white",
  # Set opacity of the polygons to 0.8
  alpha.regions = 0.8,
  # Set opacity of the lines to 0.5
  alpha = 0.5
)
map_n_giant_hogweed


## 1.4 ####
giant_hogweed <- readr::read_tsv(
  "data/20250826/20250826_giant_hogweed_fl_bxl.tsv",
  na = ""
  ) %>%
  sf::st_as_sf(
    coords = c("decimalLongitude", "decimalLatitude"),
    crs = 4326
  )

map_giant_hogweed <- mapview(
  giant_hogweed,
  col.regions = "gray80",
  layer.name = "Giant hogweed occurrences",
  cex = 5
)

map_giant_hogweed

combined_map <- map_n_giant_hogweed + map_giant_hogweed
combined_map

## 1.5 ####
combined_map %>%
  leafem::addMouseCoordinates()


## 1.6 ####
combined_map %>%
  leafem::addMouseCoordinates() %>%
  mapshot(url = file.path("src", "20250826", "combined_map_hogweed.htmll"))

# Or using htmlwidgets package. Notice that mapshot() is using htmlwidgets
# under the hood.
library(htmlwidgets) # Install it first, if needed
# Save the map as an HTML widget
combined_map %>%
  leafem::addMouseCoordinates() %>%
  saveWidget(file =  file.path("src", "20250826", "combined_map_hogweed.html"))



# CHALLENGE 2 ####

# Get n_giant_hogweed for Brussels only
n_giant_hogweed_bxl <- n_giant_hogweed %>%
  dplyr::filter(reg_name_nl == "['Brussels Hoofdstedelijk Gewest']")

## 2.1 ####
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf()


## 2.2 ####
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n), color = "red")

# Extra: if you prefer to bin the values of `n` in categories, you can use
# `cut()` function. Save the categories in a new column `n_cat`:
step <- 5
n_giant_hogweed_bxl <- n_giant_hogweed_bxl %>%
  dplyr::mutate(n_cat = cut(n,
                            breaks = seq(0, max(n) + step, step),
                            include.lowest = TRUE)
)
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(
    aes(fill = n_cat),
    color = "red")


## 2.3 ####
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add labels
  ggplot2::geom_sf_label(aes(label = mun_name_nl),
                         size = 2,
                         color = "gray50",
                         fontface = "bold",
                         label.padding = ggplot2::unit(1, "lines")
  )

# If you don't like the white padding around the text, you can use
# `geom_sf_text()` instead of `geom_sf_label()`. However, pay attention that
# overlapping text can be an issue then. If argument `check_overlap` = `TRUE`,
# overlapping text in the same layer will not be plotted. See the documentation
# of `?geom_sf_text` for more details. Luckily `check_overlap` is `FALSE` by
# default.
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add text = no white padding
  ggplot2::geom_sf_text(
    aes(label = mun_name_nl),
    size = 2,
    color = "gray50",
    fontface = "bold"
  )

# Check how `Brussel` text disappears when using `check_overlap = TRUE`
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add text = no white padding
  ggplot2::geom_sf_text(
    aes(label = mun_name_nl),
    size = 2,
    color = "gray50",
    fontface = "bold",
    check_overlap = TRUE
  )


## 2.4 ####
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add labels
  ggplot2::geom_sf_label(aes(label = mun_name_nl),
                         size = 2,
                         color = "gray50",
                         fontface = "bold"
  ) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c()


## 2.5 ####
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add labels
  ggrepel::geom_label_repel(
    aes(label = mun_name_nl, geometry = geom),
    stat = "sf_coordinates",
    size = 2,
    fontface = "bold",
    color = "gray50",
    label.padding = unit(0.25, "lines")
  ) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c()

# If you opted for using geom_sf_text() instead of geom_sf_label(), you can use
# ggrepel::geom_text_repel().
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add labels
  ggrepel::geom_text_repel(
    aes(label = mun_name_nl, geometry = geom),
    stat = "sf_coordinates",
    size = 2,
    fontface = "bold",
    color = "gray50"
  ) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c()

# Via argument `option` of the function `scale_fill_viridis_c()` you can choose
# other palettes than the viridis palette (default). For example, use
# `"cividis"` palette, another color blind friendly palette:
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add labels
  ggrepel::geom_label_repel(
    aes(label = mun_name_nl, geometry = geom),
    stat = "sf_coordinates",
    size = 2,
    fontface = "bold",
    color = "gray50",
    label.padding = unit(0.25, "lines")
  ) +
  # Use continuous cividis palette
  ggplot2::scale_fill_viridis_c(option = "cividis")

# Extra: when binning data (column `n_cat`), you should use a discrete palette:
# `scale_fill_viridis_d()`
ggplot2::ggplot(n_giant_hogweed_bxl) +
  ggplot2::geom_sf(aes(fill = n_cat), color = "red") +
  # Add labels
  ggrepel::geom_label_repel(
    aes(label = mun_name_nl, geometry = geom),
    stat = "sf_coordinates",
    size = 2,
    fontface = "bold",
    color = "gray50",
    label.padding = unit(0.25, "lines")
  ) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_d()



# CHALLENGE 3 ####

## 3.1 ####

# Code with labels and viridis palette omitted for clarity
ggplot2::ggplot(n_giant_hogweed_bxl) +
  # Add Open Street Map tiles
  annotation_map_tile() +
  ggplot2::geom_sf(aes(fill = n), color = "red")

# Increase the zoom level of the basemap via `zoomin = -1` or `zoomin = 0`
# use zoomin = -1 or 0 to increase the zoom level of 1 or 2 levels. It takes a
# bit longer to download the tiles, though.
ggplot2::ggplot(n_giant_hogweed_bxl) +
  # Add Open Street Map tiles
  annotation_map_tile(zoomin = -1) +
  ggplot2::geom_sf(aes(fill = n), color = "red")


## 3.2 ####
ggplot2::ggplot(n_giant_hogweed_bxl) +
  # Add Open Street Map tiles
  annotation_map_tile(
    zoomin = 0,
    cachedir = system.file("rosm.cache", package = "ggspatial")) +
  ggplot2::geom_sf(aes(fill = n), color = "red")


## 3.3 ####

ggplot2::ggplot(n_giant_hogweed_bxl) +
  # Add Open Street Map tiles
  annotation_map_tile(
    zoomin = -1,
    cachedir = system.file("rosm.cache", package = "ggspatial")) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add north arrow
  ggspatial::annotation_north_arrow(location = "tr", which_north = "true") +
  # Add scale bar
  ggspatial::annotation_scale(location = "bl")


## 3.4 ####

# Example using the "loviniacycle" tiles
ggplot2::ggplot(n_giant_hogweed_bxl) +
  # Add Open Street Map tiles
  annotation_map_tile(
    type = "loviniacycle",
    zoomin = -1,
    cachedir = system.file("rosm.cache", package = "ggspatial")) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add north arrow
  ggspatial::annotation_north_arrow(location = "tr", which_north = "true") +
  # Add scale bar
  ggspatial::annotation_scale(location = "bl")

# Example using the "cartodark" tiles
ggplot2::ggplot(n_giant_hogweed_bxl) +
  # Add Open Street Map tiles
  annotation_map_tile(
    type = "cartodark",
    zoomin = -1,
    cachedir = system.file("rosm.cache", package = "ggspatial")) +
  ggplot2::geom_sf(aes(fill = n), color = "red") +
  # Add north arrow
  ggspatial::annotation_north_arrow(location = "tr", which_north = "true") +
  # Add scale bar
  ggspatial::annotation_scale(location = "bl")



# BONUS CHALLENGE 1 ####

## BC.1 ####
map_giant_hogweed@map %>%
  inbospatial::add_wms_fl_forestnature(add_wms_legend = TRUE)


## BC.2 ####
map_giant_hogweed@map %>%
  inbospatial::add_wms_fl_forestnature(add_wms_legend = TRUE) %>%
  inbospatial::add_wms_fl_grbmap()



# BONUS CHALLENGE 2 ####

library(leaflet)
library(leaflet.extras)
library(htmlwidgets)

my_gps <- map_giant_hogweed %>%
  leafem::addMouseCoordinates() %>%
  leaflet.extras::addControlGPS(
    options = gpsOptions(
      position = "topleft",
      activate = TRUE,
      autoCenter = TRUE,
      maxZoom = 10,
      setView = TRUE
    )
  )

# RStudio doesn't render the GPS functionality correctly. It has no rights to
# access your location. Save the leaflet map as html file and open it in your
# web browser to test the GPS functionality
saveWidget(
  my_gps,
  file = file.path("src", "20250826", "map_with_gps_location.html")
)
