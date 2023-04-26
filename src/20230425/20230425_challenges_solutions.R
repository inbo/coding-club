library(tidyverse)
library(patchwork)
library(ggforce)
library(gganimate)
library(plotly)

## preliminary code to run (solutions start at line 69)

# read datasets
ias_be <- read_tsv("./data/20230425/20230425_ias_first_observed_BE.txt",
                   na = ""
)

ias_regions <- read_tsv(
  "./data/20230425/20230425_ias_first_observed_regions.txt",
  na = ""
)

ias_pathways <- read_tsv("./data/20230425/20230425_ias_pathways_count.txt",
                         na = "")

area_biotopes <- read_csv(
  "./data/20230425/20230425_area_biotopes.txt", na = "",
  col_types = cols(year = col_integer())
)

# create basic plots

# number of IAS observed for the first time within time interval of 5 years at
# national level
ias_first_obs_be <-
  ggplot(ias_be) +
  geom_histogram(aes(x = first_observed),
                 binwidth = 5,
                 position = "dodge"
  )
ias_first_obs_be

# number of IAS observed for the first time within time interval of 5 years at
# regional level
ias_first_obs_reg <-
  ggplot(ias_regions) +
  geom_histogram(aes(x = first_observed, fill = locationId),
                 binwidth = 5,
                 position = "dodge"
  )
ias_first_obs_reg


# number of IAS introduced per pathway and time interval (bin width = 5 years)
# from 1950
ias_first_obs_paths <- ggplot(ias_pathways) +
  geom_point(mapping = aes(x = first_observed,
                           y = n,
                           color = pathway),
             shape = 1,
             size = 3) +
  geom_line(mapping = aes(x = first_observed,
                          y = n,
                          # group argument tells R  which points have to be linked together to form a line
                          group = pathway,
                          color = pathway)) +
  labs(x = "year of introduction", y = "number of taxa") +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5))

ias_first_obs_paths


## CHALLENGE 1

# 1. Display `ias_first_obs_be` and `ias_first_obs_reg` next to each other
ias_first_obs_be | ias_first_obs_reg

# 2. Display `ias_first_obs_reg` below `ias_first_obs_be`
ias_first_obs_be / ias_first_obs_reg

# 3. Similar to 2, but this time instead of showing dodge histograms altogether,
# display different regions as different facets and call it
# `ias_first_obs_reg_facets`. You should end up with one big histogram on top
# and 3 histograms (= 3 locations) on the bottom. Tip: adding a facet to
# `ias_first_obs_reg` is standard ggplot.
ias_first_obs_reg_facets <-
  ias_first_obs_reg +
  facet_wrap(vars(locationId), nrow = 1) # or facet_grid(cols = vars(locationId))
ias_first_obs_reg_facets

ias_first_obs_be / ias_first_obs_reg_facets

# 4. Starting from the histogram ias_first_obs_be, display different kingdoms as
# facets. Then, put this plot on the right, the plots in 3 on the left.
ias_first_obs_be_kingdom_facets <-
  ias_first_obs_be +
  facet_wrap(vars(kingdom))
ias_first_obs_be_kingdom_facets

ias_first_obs_be_kingdom_facets <-
  ias_first_obs_be +
  facet_grid(vars(kingdom))

(ias_first_obs_be / ias_first_obs_reg_facets) | ias_first_obs_be_kingdom_facets

# 5. Display `ias_first_obs_reg_facets` on the left and a table with three rows
# showing the total number of introductions at regional level on the right.
# Hint: check this
# [vignette](https://patchwork.data-imaginist.com/articles/guides/assembly.html#adding-non-ggplot-content).
data_to_show <- ias_regions %>%
  count(locationId)

ias_first_obs_reg_facets +
  gridExtra::tableGrob(data_to_show)


## CHALLENGE 2

# 1. Add a zooming facet to `ias_first_obs_paths` to zoom around the time interval 1980 -
# 2000. How to zoom on the y-axis values as well?
ias_first_obs_paths +
  ggforce::facet_zoom(x = first_observed >= 1980 & first_observed <=2000)
ias_first_obs_paths +
  ggforce::facet_zoom(xy = first_observed >= 1980 & first_observed <=2000)

# Using split TRUE is also possible but reader doesn't really get any benefit :-)
ias_first_obs_paths +
  ggforce::facet_zoom(xy = first_observed >= 1980 & first_observed <=2000,
                      split = TRUE)

# 2. In challenge 1 we used standard ggplot facetting for creating
# `ias_first_obs_reg_facets`. How to use ggforce to set the facet labels (the
# `locationId` values) on the bottom instead of on the top as usual?
ias_first_obs_reg +
facet_row(vars(locationId), strip.position = "bottom")


# Another interesting faceting function in ggforce is `facet_wrap_paginate()`.
# This is useful when you have so many facets it's impossible to have them all
# in one page. As you see below, it works well within a loop
npages = 4
for (i in 1:npages) {
  print(
    ggplot(diamonds) +
      geom_point(aes(carat, price), alpha = 0.1) +
      facet_wrap_paginate(~ cut:clarity, ncol = 3, nrow = 3, page = i)
  )
}


## CHALLENGE 3A

# Create a GIF as the one below by using ggplot2 and
# [gganimate](https://gganimate.com/) packages. Notice we used `"cubic-in-out"`
# _easing_ to smooth the transition between states. Save the GIF on disk as well
# (width = 1000, height = 300). Kind of a bonus: save it as a video instead of
# GIF.

animated_area_biotopes <-
  ggplot(area_biotopes) +
  geom_point(aes(x = species, y = meanArea, size = meanArea,  color = biotope)) +
  theme(axis.text.x = element_text(angle = 60, vjust = 0.5)) +
  facet_wrap(vars(region)) +
  labs(title = "Year: {frame_time}") +
  transition_time(year) +
  enter_fade() +
  exit_shrink() +
  ease_aes("cubic-in-out")

gganimate::anim_save(filename = "./data/20230425/animation.gif",
                     animation = animated_area_biotopes,
                     width = 1000, height = 300
)

# save as video mmpeg. Notice that it could not work if ffmpeg.exe is not
# installed. To install it on Windows, follow these instructions:
# https://www.wikihow.com/Install-FFmpeg-on-Windows
gganimate::anim_save(filename = "./data/20230425/animation.mpeg",
                     animation = animated_area_biotopes,
                     width = 1000, height = 300,
                     renderer = ffmpeg_renderer()
)

# You can opt to save video using avi format by using av package (run
# `install.packages("av")` and then `library(av)`)
gganimate::anim_save(filename = "./data/20230425/animation.avi",
                     animation = animated_area_biotopes,
                     width = 1000, height = 300,
                     renderer = av_renderer()
)

## CHALLENGE 3B

# 1. Make the plot `ias_first_obs_paths` interactive by using
# [plotly](https://plotly-r.com/). Explore the interactivity tools. In
# particular check the legend filtering capabilities on pathway!
# Tip: documentation in the ["intro to ggplotly"](https://plotly-r.com/overview.html#intro-ggplotly) section.

ggplotly(ias_first_obs_paths)

# 2. How to add dynamic ticks functionality to the interactive plot in 1?
# dynamic ticks means generating new axis ticks on zoom

ggplotly(ias_first_obs_paths, dynamicTicks = TRUE)

# 3. Improve the text shown while hovering so that it looks something like in screenshot below:

ias_pathways_with_text <- ias_pathways %>%
  mutate(text = paste0("year: ", first_observed, "\n",
                       "introduction pathway: ", pathway, "\n",
                       "number of taxa: ", n))

ias_first_obs_paths <- ggplot(ias_pathways_with_text,
                              aes(text = text)) +
  geom_point(mapping = aes(x = first_observed,
                           y = n,
                           color = pathway),
             shape = 1,
             size = 3) +
  geom_line(mapping = aes(x = first_observed,
                          y = n,
                          # group argument tells R  which points have to be linked together to form a line
                          group = pathway,
                          color = pathway)) +
  labs(x = "year of introduction", y = "number of taxa") +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5))

ggplotly(ias_first_obs_paths, tooltip = "text")
