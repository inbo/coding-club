library(tidyverse)
library(patchwork)
library(viridis)
library(plotly)


## INTRODUCTION: create the user case plots

# read dataset
area_biotopes <- read_csv("./data/20210930/20210930_area_biotopes.txt", na = "")

#' usercase1 and usercase2 (colors = categorical/qualitative variable)

#' Select species Pararge aegeria (Speckled wood)
area_biotopes_pararge <-
  area_biotopes %>%
  filter(species == "Pararge aegeria")

usercase1 <-
  ggplot(area_biotopes_pararge,
         aes(x = year,
             y = meanArea,
             color = biotope)) +
  geom_point() +
  geom_smooth() +
  labs(title = "Distribution of Pararge aegeria per biotope and region",
       y = "Area (%)",
       color = "BIOTOPE"
  ) +
  facet_wrap(~ region)
usercase1

#' Select species Limenitis camilla
area_biotopes_limenitis <-
  area_biotopes %>%
  filter(species == "Limenitis camilla")

usercase2 <-
  ggplot(area_biotopes_pararge,
         aes(x = year,
             y = meanArea,
             color = biotope)) +
  geom_point() +
  geom_smooth() +
  labs(title = "Distribution of Limenitis camilla per biotope and region",
       y = "Area (%)",
       color = "BIOTOPE"
  ) +
  facet_wrap(~ region)
usercase2

#' usercase3 and usercase4 (filling color = quantitative/continuous variable)
#' Select year 2000
area_biotopes_2000 <-
  area_biotopes %>%
  filter(year == 2000)

usercase3 <-
  ggplot(area_biotopes_2000,
         aes(x = region, y = biotope)) +
  geom_tile(aes(fill = meanArea)) +
  labs(title = "Average covered area (%) in 2000",
       fill = "Area (%)") +
  facet_wrap(~ species)
usercase3

# usercase4  (colors = quantitative/continuous variable)
# Select year 2018
area_biotopes_2018 <-
  area_biotopes %>%
  filter(year == 2018)

usercase4 <-
  ggplot(area_biotopes_2018,
         aes(x = region, y = biotope)) +
  geom_tile(aes(fill = meanArea)) +
  labs(title = "Average covered area (%) in 2018",
       fill = "Area (%)") +
  facet_wrap(~ species)
usercase4

# Challenge 1. Palette


#' 1. A palette is nothing more than a character vector of colors. Create your
#' own 4-color palette with [color picker](http://tristen.ca/hcl-picker/).
#' Example: https://tristen.ca/hcl-picker/#/hlc/4/1/124B46/7DC979



#' 2. How to use it for user case 1?




# 3. How to use it for user case 3?



# 4. How to invert the color scale of `usercase3`?





## CHALLENGE 2

#' 1. Display `usercase1` and `usercase2` next to each other




#' 2. Display `usercase2` below `usercase1`




#' 3. Display `usercase1` and `usercase2`in first row and `usercase3` and
#' `usercase4` in the second row creating a 2x2 plot grid




#' 4. `usercase1` and `usercase2` share same legend. How to avoid duplicating
#' it in 1 and 2?


#' 5. What if you try to avoid duplicating the legend of `usercase3` and
#' `usercase4`? Can you understand why? How to solve it? Hint: _scale_ your
#' plots, check ggplot cheatsheet!






## CHALLENGE 3A. Fine tune your plots

#' 1. An heatmap as usercase3 should fill the entire plot space. No sense of
#' having space above, below, left or right. How to solve it?





#' 2. Remove the title and the legend of `usercase3`





#' 3. Set legend of  `usercase3` below the heatmap. The title is set too low in
#' comparison with the colorbar, isn't? How to align it with the colorbar? How
#' to customize the legend background and border by using light grey as
#' background color and blue as border color?




#' 4. Starting from 3, how to set a space of 0.5cm between plotting area and legend
#' box?





## CHALLENGE 3B. Make your plots interactive

#' Turn static plots made with ggplot to interactive plots thanks to package `plotly`.
#' 1. Make usercase1 interactive. Hint: give a look to this
#' [tutorial](https://www.musgraveanalytics.com/blog/2018/8/24/how-to-make-ggplot2-charts-interactive-with-plotly)





#' 2. Specify the following order of information displayed while hovering with mouse:
#' colour, x and y




#' 3. Make usercase 3 interactive as well. But one decimal value is more than
#' enough for `meanArea`. How to improve the displayed info?




#' 4. Personalize the text shown while hovering as in the example below:
#' region: FL
#' biotope: Urban
#' area: 50.3%






## BONUS CHALLENGE - patchwork

#' 1. Display `usercase3` on the left and a table with the displayed data
#' (species, region, biotope, meanArea) on the right




#' 2. The NARA team would like to add the plot from Challenge 2 - exercise 3 to
#' one of their indicators. How to apply the NARA theme with also lowercase
#' roman numerals to enumerate the subplots?

# install INBOtheme if not already installed
if (!"remotes" %in% rownames(installed.packages())) {
  install.packages("remotes")
}
if (!"INBOtheme" %in% rownames(installed.packages())) {
  remotes::install_github("inbo/INBOtheme")
}

# load INBOtheme
library(INBOtheme)

