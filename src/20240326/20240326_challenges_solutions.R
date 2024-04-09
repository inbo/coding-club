library(tidyverse)
library(lubridate)
library(plotly)
library(scales)
library(patchwork)
library(ggforce)
library(magick)
library(gganimate)

# Read data
rodentia <- readr::read_tsv(file = "./data/20240326/20240326_rodents.txt")

## Given plots

plot1 <- ggplot(rodentia) +
  geom_bar(aes(x = year, fill = institutionCode)) +
  labs(y = "observations")
plot1

plot2 <- ggplot(rodentia) +
  geom_bar(mapping = aes(x = month, fill = species)) +
  facet_wrap(~species, scales = "free") +
  labs(y = "observations")
plot2


rodentia_n_2000 <- rodentia %>%
  dplyr::filter(year >= 2000) %>%
  dplyr::group_by(species,year, month) %>%
  dplyr::count() %>%
  mutate(date = make_date(year, month, 1))

plot3 <- ggplot(data = rodentia_n_2000,
                mapping = aes(x = date, y = n, color = species)) +
  geom_line() +
  facet_wrap(~species, scales = "free") +
  labs(y = "observations")
plot3

plot4 <- ggplot(rodentia %>%
                  dplyr::filter(
                    !is.na(decimalLatitude),
                    !is.na(decimalLongitude),
                    # added after coding club to reduce calculation time
                    year >= 2015)) +
  geom_point(mapping = aes(x = decimalLongitude,
                           y = decimalLatitude,
                           color = species)) +
  labs(x = "latitude",
       y = "longitude",
       title = "Observations from 2015 to 2020")
plot4

## Challenge 1: interactivity and scales

# 1
plot1_interactive <- ggplotly(plot1)
plot1_interactive

# 2

# The function in the hint, `pretty_breaks()` is superseded: use
# `breaks_pretty()` instead.
plot2 + scale_x_continuous(breaks= breaks_pretty())


# 3. Starting from plot3, use 'yy notation for x-labels (e.g. '12 instead of
# 2012). For y-labels, use "K" suffix for thousands (e.g. 2K for 2000). Hint:
# example code in ["Break and
# labels"](https://scales.r-lib.org/#breaks-and-labels) section of scales
# homepage.
plot3 +
  scale_x_date(
    labels = scales::label_date("'%y")
  ) +
  scale_y_continuous(
    labels = scales::label_number(scale_cut = scales::cut_short_scale())
  )


## Challenge 2: patchwork and ggforce

# 1

# Basic solution: legends take too much space
plot1 + plot2 + plot3 + plot4

# Save some space by grouping the legends
# Use other colors for `plot1` (institutions) then for the other plots (species
# distributions) for better readability
library(viridis)
((plot1 + scale_fill_viridis(discrete = TRUE)) +
    plot2 +
    (plot3) +
    (plot4)) +
  plot_layout(guides = 'collect') # puts all legends to the side

# Notice that the legends for species are not merged because we have points,
# lines and bars, so the legends are by R considered as three differents
# legends.
library(viridis)
((plot1 + scale_fill_viridis(discrete = TRUE)) +
    plot2 +
    (plot3 + theme(legend.position = "none")) +
    (plot4 + theme(legend.position = "none"))) +
  plot_layout(guides = 'collect') # puts all legends to the side

# 2
plot1 +
  facet_zoom(year >= 2015)


## Challenge 3: animations

# 1
anim1 <- plot4 +
  ggtitle('Now showing {closest_state}',
          subtitle = 'Frame {frame} of {nframes}') +
  transition_states(species) +
  enter_fade() +
  exit_fade()
animate(anim1)
# Save as gif
anim_save("./src/20240326/20240326_animation_plot4_by_species.gif")

#' 2. Create an animation showing the observations year by year. By default the animation has 100 frames and 10 frame per seconds
# (fps), i.e. a duration of 10s. How to change these values?

# rewritten plot4 with `year` as "group" in aesthetics of `geom_point()`.
# gganimate thinks to group by color if you don't use the "group" argument.
anim2 <- ggplot(rodentia %>%
                  dplyr::filter(!is.na(decimalLatitude),
                                !is.na(decimalLongitude))) +
  geom_point(mapping = aes(x = decimalLongitude,
                           y = decimalLatitude,
                           group = seq_along(year),
                           color = species)) +
  transition_time(year) +
  labs(x = "latitude",
       y = "longitude",
       title = 'Year: {frame_time}') +
  enter_fade() +
  exit_shrink()
animate(anim2, nframes = 400) # It can take long
anim_save("./src/20240326/20240326_animation_plot4_by_year.gif")


## BONUS CHALLENGE: add image to a plot

#' The R package [magick](https://docs.ropensci.org/magick/index.html) is the R
#' interface for ImageMagick, the most comprehensive open-source image processing
#' library available.
#'
#' Using magick, add the INBO coding club logo to one of our plots.

logo_file <- "./data/20240326/coding_club_logo_1.png"
logo <- image_read(logo_file)

# Add logo as an annotation raster with ggplot.
# It's an ad-hoc solution: the size of the logo is assessed based on the plot
# size window we wish to have. If you modify the window size, the logo size will
# also be modified.
image <- image_fill(logo, 'none')
raster <- as.raster(image)
plot1 +
  annotation_raster(raster,
                    xmin = 2010, xmax = 2020,
                    ymin = 14000, ymax = 17500)


# Another (better) solution is to save the plot without logo first. Then, use
# magick to add the logo to the saved plot image via `image_composite()`.
# We proposed a function to choose also the position of the logo and the scale.
# Based on https://themockup.blog/posts/2019-01-09-add-a-logo-to-your-plot/
# And thanks Jorre (statistiek Vlaanderen) for this solution!
add_logo <- function(plot_path, logo_path, logo_position, logo_scale = 10){

  # Requires magick R Package https://github.com/ropensci/magick

  # Useful error message for logo position
  if (!logo_position %in% c("top right", "top left", "bottom right", "bottom left")) {
    stop("Error Message: Uh oh! Logo Position not recognized\n  Try: logo_positon = 'top left', 'top right', 'bottom left', or 'bottom right'")
  }

  # read in raw images
  plot <- magick::image_read(plot_path)
  logo_raw <- magick::image_read(logo_path)

  # get dimensions of plot for scaling
  plot_height <- magick::image_info(plot)$height
  plot_width <- magick::image_info(plot)$width

  # default scale to 1/10th width of plot
  # Can change with logo_scale
  logo <- magick::image_scale(logo_raw, as.character(plot_width/logo_scale))

  # Get width of logo
  logo_width <- magick::image_info(logo)$width
  logo_height <- magick::image_info(logo)$height

  # Set position of logo
  # Position starts at 0,0 at top left
  # Using 0.01 for 1% - aesthetic padding

  if (logo_position == "top right") {
    x_pos = plot_width - logo_width - 0.01 * plot_width
    y_pos = 0.01 * plot_height
  } else if (logo_position == "top left") {
    x_pos = 0.01 * plot_width
    y_pos = 0.01 * plot_height
  } else if (logo_position == "bottom right") {
    x_pos = plot_width - logo_width - 0.01 * plot_width
    y_pos = plot_height - logo_height - 0.01 * plot_height
  } else if (logo_position == "bottom left") {
    x_pos = 0.01 * plot_width
    y_pos = plot_height - logo_height - 0.01 * plot_height
  }

  # Compose the actual overlay
  magick::image_composite(plot, logo, offset = paste0("+", x_pos, "+", y_pos))

}

logo_file <- "./data/20240326/20240326_coding_club_logo_1.png"

# Set file path where to save the plot created with ggplot.
plot_file <- "./src/20240326/20240326_plot1.png"

# Save plot1 using `ggsave()` function.
ggsave(filename = plot_file,
       plot = plot1,
       width = 8)

# Use our function, `add_logo()` to add the logo to the saved plot.
plot_image_with_logo <- add_logo(
  plot_path=plot_file,
  logo_path=logo_file,
  logo_position="top right",
  logo_scale = 12
)

# Save plot with logo using magick's function `image_write()`. We overwrite the
# plot without logo.
image_write(image = plot_image_with_logo, path = plot_file)
