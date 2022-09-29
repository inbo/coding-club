library(tidyverse)
library(patchwork)
library(viridis)


## create the four use cases (plots)

# read dataset
area_biotopes <- read_csv("./data/20220929/20220929_area_biotopes.txt", na = "")

# usecase1 and usecase2 (colors = categorical/qualitative variable)

# Select species Pararge aegeria (Speckled wood)
area_biotopes_pararge <-
  area_biotopes %>%
  filter(species == "Pararge aegeria")

usecase1 <-
  ggplot(area_biotopes_pararge,
         aes(x = year,
             y = meanArea,
             color = biotope)) +
  geom_point() +
  geom_smooth() +
  labs(title = "Distribution of Pararge aegeria",
       y = "Area (%)",
       color = "BIOTOPE"
  ) +
  facet_wrap(~ region)
usecase1

# Select species Limenitis camilla
area_biotopes_limenitis <-
  area_biotopes %>%
  filter(species == "Limenitis camilla")

usecase2 <-
  ggplot(area_biotopes_limenitis,
         aes(x = year,
             y = meanArea,
             color = biotope)) +
  geom_point() +
  geom_smooth() +
  labs(title = "Distribution of Limenitis camilla",
       y = "Area (%)",
       color = "BIOTOPE"
  ) +
  facet_wrap(~ region)
usecase2

# usecase3 and usecase4 (filling color = quantitative/continuous variable)
# Select year 2000
area_biotopes_2000 <-
  area_biotopes %>%
  filter(year == 2000)

usecase3 <-
  ggplot(area_biotopes_2000,
         aes(x = region, y = biotope)) +
  geom_tile(aes(fill = meanArea)) +
  labs(title = "Average covered area (%) in 2000",
       fill = "Area (%)") +
  facet_wrap(~ species)
usecase3

# usecase4  (colors = quantitative/continuous variable)
# Select year 2018
area_biotopes_2018 <-
  area_biotopes %>%
  filter(year == 2018)

usecase4 <-
  ggplot(area_biotopes_2018,
         aes(x = region, y = biotope)) +
  geom_tile(aes(fill = meanArea)) +
  labs(title = "Average covered area (%) in 2018",
       fill = "Area (%)") +
  facet_wrap(~ species)
usecase4

# Challenge 1. Palette

# 1. A palette is nothing more than a character vector of colors. Create your
# own 4-color palette with [color picker](http://tristen.ca/hcl-picker/).
# Example: http://tristen.ca/hcl-picker/#/hlc/4/1/7D414A/74C9EC


# 2. How to use it for `usecase1`?



# 3. How to use it for `usecase3`?



# 4. How to invert the color scale of `usecase3`?



# 5. How to use the official INBO palette (without changing all layout!)? Check:
# [`inbo_palette()`](https://inbo.github.io/INBOtheme/reference/inbo_palette.html).
# You need to have package `INBOtheme` installed.



# INTERMEZZO

# A color palette should be: 1. printer-friendly (gray scale), 2. perceptually
# uniform 3. easy to read by those with colorblindness. All of this can be
# found in the [viridis
# palette](https://www.r-bloggers.com/2018/07/ggplot2-welcome-viridis/) which
# avoids the red and to go from blue to yellow passing through green (viridis:
# green in Latin).


# `ggplot2` includes some functions to use viridis palette directly.
# Apply viridis discrete color scale (use case 1 and 2)

usecase1 +
  scale_color_viridis_d()

# equivalent to
my_viridis_palette <- viridis(4)
usecase1 +
  scale_color_manual(values = my_viridis_palette)

# Apply viridis continuous color scale (use case 3 and 4)

usecase3 +
  scale_fill_viridis_c()

# equivalent to
usecase3 +
  scale_fill_gradientn(colours = my_viridis_palette)
# or
usecase3 +
  scale_fill_continuous(type = "viridis")

# Invert the color direction.
usecase3 +
  scale_fill_viridis_c(direction = -1)

# equivalent to
usecase3 +
  scale_fill_gradientn(colours = rev(my_viridis_palette))

usecase3 +
  scale_fill_continuous(type = "viridis", direction = -1)


## CHALLENGE 2: combine separate ggplots with `patchwork`

# 1. Display `usecase1` and `usecase2` next to each other



# 2. Display `usecase2` below `usecase1`



# 3. Display `usecase1` and `usecase2`in first row and `usecase3` and
# `usecase4` in the second row creating a 2x2 plot grid.



# 4. `usecase1` and `usecase2` share same legend. How to avoid duplicating
# it in 1 and 2? Check [guides controlling section](https://patchwork.data-imaginist.com/articles/guides/layout.html#controlling-guides)
# of "Controlloing Layout" vignette



# 5. What if you try to avoid duplicating the legend of `usecase3` and
# `usecase4`? Can you understand why? How to solve it? Hint: _scale_ your
# plots, check ggplot cheatsheet!



# 6. Display `usecase3` on the left and a table with the displayed data
# (species, region, biotope, meanArea) on the right. Hint: check this
# [vignette](https://patchwork.data-imaginist.com/articles/guides/assembly.html#adding-non-ggplot-content).



## CHALLENGE 3

# 1. The heatmap in `usecase3` adds some spaces above, below, left or right.
# How to fill the entire plot space?



# 2. Remove the title and the legend of `usecase3`



# notice that the title arg in theme() removes all text titles (plots, axes, legends)



# 3. Set legend of  `usecase4` below the heatmap. The title of the legend,
# "Area (%)", is set too low in comparison with the colorbar, isn't? How to
# align it with the colorbar? How to customize the legend background and border
# by using light grey as background color and blue as border color?



# 4. Starting from 3, how to set a space of 0.5cm between plotting area and legend
# box?


