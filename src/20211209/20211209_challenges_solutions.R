library(tidyverse)
library(grDevices)
library(RColorBrewer)
library(sf)
library(terra)
library(raster)
library(exactextractr)
library(leaflet)
library(htmltools)
library(leaflet.minicharts)


## Challenge 1

#' 1. Create a `legend_land_use` data.frame based on information in table below.
#' Notice that you need to convert rgb to hex colors to use them for plotting.
#' Tip: use
#' [`rgb()`](https://stat.ethz.ch/R-manual/R-devel/library/grDevices/html/rgb.html)
#' function from  `grDevices` package.
#'
#' red, green, blue
#' 223, 115, 255
#' 38, 115, 0
#' 152, 230, 0
#' 255, 255, 0
#' 168, 0, 0
#' 137, 205, 102
#' 92, 137, 68
#' 0, 197, 255
#' 204, 204, 204

legend_land_use <- tibble(
  id = c(1:9),
  land_use = c(
    "Open natuur",
    "Bos",
    "Grasland",
    "Akker",
    "Urbaan",
    "Laag groen",
    "Hoog groen",
    "Water",
    "Overig"
  ),
  color = c(
    rgb(red = 223, green = 115, blue = 255, maxColorValue = 255),
    rgb(38, 115, 0, maxColorValue = 255),
    rgb(152, 230, 0, maxColorValue = 255),
    rgb(255, 255, 0, maxColorValue = 255),
    rgb(168, 0, 0, maxColorValue = 255),
    rgb(137, 205, 102, maxColorValue = 255),
    rgb(92, 137, 68, maxColorValue = 255),
    rgb(0, 197, 255, maxColorValue = 255),
    rgb(204, 204, 204, maxColorValue = 255)
  )
)
legend_land_use


#' - Read `lu_nara_2016` and plot it as static map (`plot()`) using the legend
#' you have just created. Tip: check solution of November's coding club session

lu_nara_2016 <- rast("./data/20211209/20211209_lu_nara_2016_100m.tif")

plot(lu_nara_2016,
     type = "classes",
     col = legend_land_use$color,
     levels = legend_land_use$land_use)



#' Read `20211209_vlops_tmd_1km_20MZ17M517.tif` continuous raster as
#' `nitrogen` and plot it as a static map (`plot()`) with a **legend**, a **range** from 10 to
#' 47, and the color scale `hcl.colors(n = 100, palette = "Blue-Red 3")`. See
#' more about color scales in `?grDevices::hcl.colors()`. Check all possible
#' color palettes via `hcl.pals()` and try out some other palettes.

nitrogen <- rast("./data/20211209/20211209_vlops_tmd_1km_20MZ17M517.tif")
nitrogen

plot(nitrogen,
     type = "continuous",
     legend = TRUE,
     range = c(10,47),
     col = hcl.colors(100, "Blue-Red 3")
)

# use another palette: "Reds"
plot(nitrogen,
     type = "continuous",
     legend = TRUE,
     range = c(10,47),
     col = hcl.colors(100, "Purple-Brown", rev = TRUE))

#' How to plot `nitrogen` with only 6 different color intervals? Use the color
#' palette you prefer.
plot(nitrogen,
     type = "continuous",
     legend = TRUE,
     range = c(10,47),
     col = hcl.colors(6, "Blue-Red 3", rev = TRUE))


## CHALLENGE 1C - rasters (dynamic maps)

#' Try to make dynamic maps of the static maps in 1A and 1B with `leaflet`. Tip:
#' dedicated page about [rasters](https://rstudio.github.io/leaflet/raster.html)
#' in the leaflet documentation.

#' transform to WGS84 (crs = 4326)
lu_nara_2016_wgs84 <- terra::project(
  x = lu_nara_2016,
  y = "epsg:4326"
)

nitrogen_wgs84 <- terra::project(
  x = nitrogen,
  y = "epsg:4326"
)

#' convert raster from SpatRaster (terra packge) to RasterLayer (raster package)
raster_lu_nara_2016_wgs84 <- raster(lu_nara_2016_wgs84)
raster_nitrogen_wgs84 <- raster(nitrogen_wgs84)

#' interactive map of land use raster
leaflet() %>%
  addTiles() %>%
  addRasterImage(raster_lu_nara_2016_wgs84,
                 colors = legend_land_use$color) %>%
  addLegend(labels = legend_land_use$land_use,
            colors = legend_land_use$color)



#' Create a continuous palette function setting the right range (domain) for nitrogen. Tip:
#' https://rstudio.github.io/leaflet/colors.html)
pal <- colorNumeric(
  palette = "Reds",
  domain = c(0,47),
  na.color = "transparent")

#' make the leaflet (adjust the number of bins)
leaflet() %>%
  addTiles() %>%
  addRasterImage(raster_nitrogen_wgs84,
                 colors = pal) %>%
  addLegend(pal = pal,
            values = c(0,47),
            title = "Nitrogen deposition <br/> (kg N/(ha.year))",
            bins = 5)


## CHALLENGE 2 - vector data

#' Read provinces and transform to WGS84 (crs = 4326) for visualization on maps
provinces <- st_read("./data/20211209/20211209_province_vl.shp", crs = 31370)
provinces <- st_transform(provinces, crs = 4326)

#' Read butterfly observations
obs <- read_csv2("./data/20211209/20211209_vlinders_20002013_xy_prov.txt")
#' transform to sf data.frame
obs_spatial <- st_as_sf(obs, crs = 4326, coords = c("lon", "lat"))

#' Visualize observations using **circle markers**. How to add the given labels?
#' How to cluster the observation points? Tip: the leaflet documentation on
#' [markers](https://rstudio.github.io/leaflet/markers.html)

labels <- sprintf(
  "<strong>%s</strong><br/>%s<br/>%s observations",
  obs$species, obs$year, obs$n
) %>% lapply(htmltools::HTML)


leaflet(obs) %>%
  addTiles() %>%
  addCircleMarkers(
    label = labels,
    clusterOptions = markerClusterOptions())


#' - Visualize provinces (polygons!) and assign a color to them based on the
#' sum of `n` over all year and species. Run the provided code first. Tip: the
#' leaflet documentation on
#' [choropleths maps](https://rstudio.github.io/leaflet/choropleths.html)

#' Make first a spatial join to know which province each observation belongs to
obs_spatial_province <- st_join(obs_spatial, provinces, join = st_intersects)

#' remove geometry to these data (the position of the points are not important
#' anymore) so get a "normal" data.frame
obs_province <- st_drop_geometry(obs_spatial_province)

#' calculate total number of observations in each province
tot_n_obs <- obs_province %>%
  group_by(NAAM) %>%
  summarise(total = sum(n))
tot_n_obs

#' add this info to provinces
provinces <- provinces %>% left_join(tot_n_obs, by = "NAAM")

#' make labels
labels <- sprintf(
  "<strong>%s</strong><br/>%g observations",
  provinces$NAAM, provinces$total
) %>% lapply(htmltools::HTML)

bins <- seq.int(0,4000, by = 800)
pal <- colorBin("YlOrRd", domain = provinces$total, bins = bins)
m <- leaflet(provinces) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~pal(total),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7
  ) %>%
  addLegend(pal = pal,
            values = ~total,
            opacity = 0.7,
            title = "Total number of observations",
            position = "bottomright")
m

#' - With package `leaflet.minicharts` add histograms to show the sum of `n` over
#' the years for each species. How to show pie charts instead? Run the
#' provided code first. Tip: do it with
#' [`leaflet.minicharts`](https://cran.r-project.org/web/packages/leaflet.minicharts/vignettes/introduction.html)

#' calculate total n for each species in each province
tot_n_obs_species <-
  tot_n_obs <- obs_province %>%
  group_by(NAAM, species) %>%
  dplyr::summarise(total_obs_species = sum(n), .groups = "drop")

#' filter NAs (observations falling out of the provinces)
tot_n_obs_species <- tot_n_obs_species  %>% filter(!is.na(NAAM))

tot_n_obs_species
#' leaflet.minicharts needs to have species as columns (wide table)
tot_n_obs_species <- tot_n_obs_species %>%
  pivot_wider(names_from = species,
              values_from = total_obs_species)
tot_n_obs_species

#' get the coordinates of the province centroids for placing the minicharts
lon_lat <- st_centroid(provinces) %>% st_coordinates()
colnames(lon_lat) <- c("lon", "lat")
lon_lat <- lon_lat %>%
  as.data.frame() %>%
  bind_cols(tibble(NAAM = provinces$NAAM))
lon_lat

species <- c("Celastrina argiolus",
             "Gonepteryx rhamni",
             "Ochlodes sylvanus",
             "Vanessa atalanta")

tot_n_obs_species <-
  tot_n_obs_species %>%
  left_join(lon_lat , by = "NAAM")

#' histograms (default)
m %>%
  addMinicharts(lng = tot_n_obs_species$lon,
                lat = tot_n_obs_species$lat,
                chartdata = tot_n_obs_species %>%
                  dplyr::select(one_of(species)),
                width = 45, height = 45)

#' pie charts
m %>%
  addMinicharts(lng = tot_n_obs_species$lon,
                lat = tot_n_obs_species$lat,
                chartdata = tot_n_obs_species %>%
                  dplyr::select(one_of(species)),
                type = "pie",
                width = 45, height = 45)

#' Make a dynamic map showing the province borders and pie charts on top of it
#' showing the areal proportion of land cover classes. The code is given.

#' Use exact_extract() by almost coy-pasting from this
#' [very similar example](https://isciences.gitlab.io/exactextractr/articles/vig2_categorical.html#summarizing-land-cover-classifications)
#' or from previous coding club
land_use_fracs <- exact_extract(lu_nara_2016, provinces, function(df) {
  df %>%
    dplyr::mutate(frac_total = coverage_fraction / sum(coverage_fraction)) %>%
    dplyr::group_by(NAAM, value) %>%
    dplyr::summarize(freq = sum(frac_total), .groups = "drop")
}, summarize_df = TRUE, include_cols = "NAAM")

land_use_fracs

#' Add land cover use names
land_use_fracs <- land_use_fracs %>%
  left_join(legend_land_use, by = c("value" = "id")) %>%
  rename(id = value)
land_use_fracs

#' Remove id and color columns and make a wide version with land use category
#' names as columns (this is the way leaflet.minicharts wants the data to plot)
land_use_fracs <-
  land_use_fracs  %>%
  dplyr::select(-c(color, id)) %>%
  pivot_wider(names_from = land_use, values_from = freq)
land_use_fracs

# add lon_lat of province centroids
land_use_fracs <-
  land_use_fracs %>%
  left_join(lon_lat, by = "NAAM") %>%
  relocate(NAAM, lon, lat)

land_use_fracs

# make leaflet with minicharts
leaflet(provinces) %>%
  addTiles() %>%
  addPolygons() %>%
  addMinicharts(lng = land_use_fracs$lon,
                lat = land_use_fracs$lat,
                chartdata = land_use_fracs %>%
                  dplyr::select(one_of(legend_land_use$land_use), "NA"),
                width = 80, height = 80)
