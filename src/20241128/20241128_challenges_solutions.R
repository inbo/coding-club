# List of required packages
required_packages <- c(
  "sf",
  "ggplot2",
  "ggrepel", # For avoiding label overlapping
  "ggspatial",
  "prettymapr", # For using map tiles with ggspatial
  "raster", # For using map tiles with ggspatial
  "mapview",
  "leafem", # For providing extensions to leaflet maps
  "leafpop", # For including tables, images and graphs in leaflet pop-ups
  "inbospatial" # For sharing useful R functions for dealing with spatial raster or vector data
)

# Install packages not yet installed
installed_packages <- required_packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  if (!"https://inbo.r-universe.dev" %in% getOption("repos")) {
    # Install inbospatial via GitHub
    devtools::install_github("inbo/inbospatial")
    # Remove inbospatial from the list of packages to install
    required_packages <- required_packages[required_packages != "inbospatial"]
  }
  # Install packages not yet installed
  install.packages(required_packages[!installed_packages])
}

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))


## CHALLENGE 1 - Plots

# Load the number of alien species in protected areas
ias_in_pa <- sf::st_read(
  dsn = "./data/20241128/20241128_ias_union_concern_Natura2000_B.gpkg"
)

ggplot2::ggplot(ias_in_pa) +
  ggplot2::geom_sf(aes(fill = n_ias), color = "black") +
  # Add labels
  ggplot2::geom_sf_label(aes(label = SITECODE), size = 2, color = "black", fontface = "bold") +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c()

# Avoid label overlapping
ggplot2::ggplot(ias_in_pa) +
  ggplot2::geom_sf(aes(fill = n_ias), color = "black") +
  # Add labels without overlapping
  ggrepel::geom_label_repel(aes(label = SITECODE, geometry = geom),
                            size = 2,
                            stat = "sf_coordinates",
                            max.overlaps = 40) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c()


# Via argument `option` of the function `scale_fill_viridis_c()` you can choose
# other palettes than the viridis palette (default). For example, use
# `"cividis"` palette, another color blind friendly palette.:
ggplot2::ggplot(ias_in_pa) +
  ggplot2::geom_sf(aes(fill = n_ias), color = "black") +
  # Add labels without overlapping
  ggrepel::geom_label_repel(aes(label = SITECODE, geometry = geom),
                            size = 2,
                            stat = "sf_coordinates",
                            max.overlaps = 40) +
  # Use continuous cividis palette
  ggplot2::scale_fill_viridis_c(option = "cividis")


# Extra: Dirk Maes preferred to bin data and use a discrete palette
step <- 5
ggplot2::ggplot(ias_in_pa) +
  ggplot2::geom_sf(
    aes(fill = cut(n_ias, breaks = seq(0, max(n_ias) + step, step))),
    color = "black"
  ) +
  # Add labels without overlapping
  ggrepel::geom_label_repel(aes(label = SITECODE, geometry = geom),
                            size = 2,
                            stat = "sf_coordinates",
                            max.overlaps = 40) +
  # Use discrete viridis palette
  ggplot2::scale_fill_viridis_d() +
  # Improve title of the legend
  ggplot2::labs(fill = "Number of alien species in Natura2000 areas")


## CHALLENGE 2 - Maps

# Take just 10 Natura2000 protected areas
ias_in_pa_sample <- ias_in_pa[1:10,]

ggplot2::ggplot(ias_in_pa_sample) +
  # Add Open Street Map tiles
  annotation_map_tile(
    # use zoomin = 0 to increase the zoom level
    zoomin = 0,
    cachedir = system.file("rosm.cache", package = "ggspatial")) +
  ggplot2::geom_sf(aes(fill = n_ias), color = "white") +
  # Add labels without overlapping
  ggrepel::geom_label_repel(aes(label = SITECODE, geometry = geom),
                            size = 2,
                            stat = "sf_coordinates",
                            max.overlaps = 40) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c() +
  # Add scale bar
  ggspatial::annotation_scale(location = "bl") +
  # Add north arrow
  ggspatial::annotation_north_arrow(location = "tr", which_north = "true")

# Use another map tile, for example `loviniahike` map tiles
ggplot2::ggplot(ias_in_pa_sample) +
  # Add Open Street Map tiles
  annotation_map_tile(
    type = "loviniahike",
    # use zoomin = 0 to increase the zoom level
    zoomin = 0,
    cachedir = system.file("rosm.cache", package = "ggspatial")) +
  ggplot2::geom_sf(aes(fill = n_ias), color = "white") +
  # Add labels without overlapping
  geom_label_repel(aes(label = SITECODE, geometry = geom),
                   size = 2,
                   stat = "sf_coordinates",
                   max.overlaps = 40) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c() +
  # Add scale bar
  annotation_scale(location = "bl") +
  # Add north arrow
  annotation_north_arrow(location = "tr", which_north = "true")

# Extra: how to improve the north arrow style, via `north_arrow_*()` functions.
# Example 1: `style = north_arrow_nautical()`
ggplot2::ggplot(ias_in_pa_sample) +
  # Add Open Street Map tiles
  annotation_map_tile(
    # use zoomin = 0 to increase the zoom level
    zoomin = 0,
    cachedir = system.file("rosm.cache", package = "ggspatial")) +
  ggplot2::geom_sf(aes(fill = n_ias), color = "white") +
  # Add labels without overlapping
  ggrepel::geom_label_repel(aes(label = SITECODE, geometry = geom),
                            size = 2,
                            stat = "sf_coordinates",
                            max.overlaps = 40) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c() +
  # Add scale bar
  ggspatial::annotation_scale(location = "bl") +
  # Add north arrow
  ggspatial::annotation_north_arrow(
    location = "tr",
    which_north = "true",
    style = ggspatial::north_arrow_nautical())

# Example 2: `style = north_arrow_fancy_orienteering()`.
# More at `?north_arrow_orienteering()`.
ggplot2::ggplot(ias_in_pa_sample) +
  # Add Open Street Map tiles
  annotation_map_tile(
    # use zoomin = 0 to increase the zoom level
    zoomin = 0,
    cachedir = system.file("rosm.cache", package = "ggspatial")) +
  ggplot2::geom_sf(aes(fill = n_ias), color = "white") +
  # Add labels without overlapping
  ggrepel::geom_label_repel(aes(label = SITECODE, geometry = geom),
                            size = 2,
                            stat = "sf_coordinates",
                            max.overlaps = 40) +
  # Use continuous viridis palette
  ggplot2::scale_fill_viridis_c() +
  # Add scale bar
  ggspatial::annotation_scale(location = "bl") +
  # Add north arrow
  ggspatial::annotation_north_arrow(
    location = "tr",
    which_north = "true",
    style = ggspatial::north_arrow_fancy_orienteering())


## CHALLENGE 3 - Interactive maps

# Read geopackage file with Flemish municipalities
flanders <- sf::st_read("./data/20241128/20241128_flemish_municipalities.gpkg")

# Map with number of alien species in Natura2000 areas
map_ias_in_pa <- mapview(ias_in_pa,
                         # Define the column to use for the color scale
                         zcol = "n_ias",
                         # Activate the legend
                         legend = TRUE,
                         # Set color of the polygon borders
                         color = "gray30"
)
map_ias_in_pa

# Improve the map
map_ias_in_pa_2 <- mapview(
  ias_in_pa,
  popup = popupTable(ias_in_pa,
                     zcol = c("SITECODE", "SITENAME", "n_ias")),
  zcol = "n_ias",
  legend = TRUE,
  color = "gray30",
  # Show `NAAM` column while hovering over the polygons

  # Show only one map tile, the OpenStreetMap base layer
  map.types = "OpenStreetMap",
  # Set opacity of the polygons to 0.8
  alpha.regions = 0.8,
  # Set layer name (and legend name)
  layer.name = "Alien species of Union concern",
  # Set width of the polygon lines
  lwd = 0.2
)
map_ias_in_pa_2


# Map with municipalities
map_flanders <- mapview(flanders,
                        zcol = NULL,
                        color = "black",
                        map.types = "OpenStreetMap",
                        alpha.regions = 0,
                        layer.name = "municipality",
                        label = NULL,
                        legend = NULL,
                        lwd = 1
)
map_flanders

# Combine both maps
combined_map <- map_flanders + map_ias_in_pa_2
combined_map

# Notice that the order of the layers is important! If you invert it, you will
# not be able anymore to click on Natura2000 areas as the layer with the
# municipalities is on the foreground and covers the entire Flanders.
bad_map <- map_ias_in_pa_2 + map_flanders
bad_map


## BONUS CHALLENGE

map_ias_in_pa_2@map %>%
  # Add forest and nature layer: you can click on these added polygons to get
  # more info
  inbospatial::add_wms_fl_forestnature() %>%
  # Add orthophotographs
  inbospatial::add_wms_be_ortho()

# Use GRB basemap instead of adding municipalities
map_ias_in_pa_2@map %>%
  inbospatial::add_wms_fl_grbmap()
