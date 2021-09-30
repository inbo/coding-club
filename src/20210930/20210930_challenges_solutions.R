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

my_color_palette <- c("#124B46",
                      "#327251",
                      "#6C9750",
                      "#B9B64E")

#' 2. How to use it for user case 1?

usercase1 +
  scale_color_manual(values = my_color_palette)


# 3. How to use it for user case 3?

usercase3 +
  scale_fill_gradientn(colours = my_color_palette)

# 4. How to invert the color scale of `usercase3`?

usercase3 +
  scale_fill_gradientn(colours = rev(my_color_palette))

# INTERMEZZO

#' A color palette should be: 1. printer-friendly (gray scale), 2. perceptually
#' uniform 3. easy to read by those with colorblindness. All of this can be
#' found in the [viridis
#' palette](https://www.r-bloggers.com/2018/07/ggplot2-welcome-viridis/) which
#' avoids the red and to go from blue to yellow passing through green (viridis:
#' green in Latin).


#' `ggplot2` includes some functions to use viridis palette directly.
#' Apply viridis discrete color scale (user case 1 and 2)

usercase1 +
  scale_color_viridis_d()


#' Apply viridis continuous color scale (user case 3 and 4)

usercase3 +
  scale_fill_viridis_c()

#' Invert the color direction.

usercase1 +
  scale_color_viridis_d(direction = -1)

usercase3 +
  scale_fill_viridis_c(direction = -1)


## CHALLENGE 2

#' 1. Display `usercase1` and `usercase2` next to each other
usercase1 | usercase2

#' 2. Display `usercase2` below `usercase1`
usercase1 / usercase2

#' 3. Display `usercase1` and `usercase2`in first row and `usercase3` and
#' `usercase4` in the second row creating a 2x2 plot grid
usercase1 + usercase2 + usercase3 + usercase4

#' 4. `usercase1` and `usercase2` share same legend. How to avoid duplicating
#' it in 1 and 2?
(usercase1 | usercase2) + plot_layout(guides = 'collect')
(usercase1 / usercase2) + plot_layout(guides = 'collect')

#' 5. What if you try to avoid duplicating the legend of `usercase3` and
#' `usercase4`? Can you understand why? How to solve it? Hint: _scale_ your
#' plots, check ggplot cheatsheet!
usercase3 + usercase4 + plot_layout(guides = 'collect')

usercase4_to_100 <- usercase4 +
  scale_fill_continuous(limits = c(0,100))

usercase3_to_100 <- usercase3 +
  scale_fill_continuous(limits = c(0,100))

usercase3_to_100 + usercase4_to_100 + plot_layout(guides = 'collect')

## CHALLENGE 3A. Fine tune your plots

#' 1. An heatmap as usercase3 should fill the entire plot space. No sense of
#' having space above, below, left or right. How to solve it?
improved_usercase3 <- usercase3 +
  scale_y_discrete(expand = c(0,0)) +
  scale_x_discrete(expand = c(0,0))

#' 2. Remove the title and the legend of `usercase3`
usercase3 +
  labs(title = element_blank()) +
  theme(legend.position = "none")

#' 3. Set legend of  `usercase3` below the heatmap. The title is set too low in
#' comparison with the colorbar, isn't? How to align it with the colorbar? How
#' to customize the legend background and border by using light grey as
#' background color and blue as border color?
usercase3 + theme(legend.position="bottom",
                  legend.title = element_text(vjust = 0.8),
                  legend.background = element_rect(fill = "light grey",
                                                   color = "blue"))

#' 4. Starting from 3, how to set a space of 0.5cm between plotting area and legend
#' box?
usercase3 + theme(legend.position="bottom", legend.box.spacing = unit(0.05,units = "cm"))


## CHALLENGE 3B. Make your plots interactive

#' Turn static plots made with ggplot to interactive plots thanks to package `plotly`.
#' 1. Make usercase1 interactive. Hint: give a look to this
#' [tutorial](https://www.musgraveanalytics.com/blog/2018/8/24/how-to-make-ggplot2-charts-interactive-with-plotly)
ggplotly(usercase1)

#' 2. Specify the following order of information displayed while hovering with mouse:
#' colour, x and y
ggplotly(usercase1, tooltip = c("colour", "x", "y"))

#' 3. Make usercase 3 interactive as well. But one decimal value is more than
#' enough for `meanArea`. How to improve the displayed info?
usercase3_rounded <- usercase3
usercase3_rounded$data$meanArea <- round(usercase3_rounded$data$meanArea, 1)
ggplotly(usercase3_rounded)

#' 4. Personalize the text shown while hovering as in the example below:
#' region: FL
#' biotope: Urban
#' area: 50.3%

area_biotopes_2000_improved <-
  area_biotopes_2000 %>%
  mutate(text = paste0("region: ", region, "\n",
                       "biotope: ", biotope, "\n",
                       "area: ", round(meanArea, 1), "%"))
usercase3_improved <-
  ggplot(area_biotopes_2000_improved,
         aes(x = region, y = biotope, text = text)) +
  geom_tile(aes(fill = meanArea)) +
  labs(title = "Average covered area (%) in 2000",
       fill = "Area (%)") +
  facet_wrap(~ species)

ggplotly(usercase3_improved, tooltip = "text")

## BONUS CHALLENGE - patchwork

#' 1. Display `usercase3` on the left and a table with the displayed data
#' (species, region, biotope, meanArea) on the right
usercase3 + gridExtra::tableGrob(usercase3$data %>% select(species, region, biotope, meanArea))

#' 2. The NARA team would like to add the plot from Challenge 2 - exercise 3 to
#' one of their indicators. How to apply the NARA _theme_ (you need INBOtheme
#' package for this) with also lowercase roman numerals to enumerate the
#' subplots?

# install INBOtheme if not already installed
if (!"remotes" %in% rownames(installed.packages())) {
  install.packages("remotes")
}
if (!"INBOtheme" %in% rownames(installed.packages())) {
  remotes::install_github("inbo/INBOtheme")
}

# load INBOtheme
library(INBOtheme)

patchwork <- usercase1 + usercase2 + usercase3 + usercase4
# solution 1
patchwork_nara <- patchwork & theme_nara() & plot_annotation(tag_levels = "i")
patchwork_nara
# solution 2
patchwork_nara <- patchwork + plot_annotation(tag_levels = "i") & theme_nara()
patchwork_nara
