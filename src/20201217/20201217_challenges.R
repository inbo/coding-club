library(tidyverse)
library(viridis)
library(plotly)
library(gganimate)


## INTRODUCTION. useR Cases

area_biotopes <- read_csv("./data/20201124/20201124_area_biotopes.txt", na = "")

# usercase1 (colors = categorical/qualitative variable)
# Select species Pararge aegeria (Speckled wood)
area_biotopes_pararge <-
  area_biotopes %>%
  filter(species == "Pararge aegeria")

usercase1 <-
  ggplot(area_biotopes_pararge,
         aes(x = year,
             y = meanArea,
             color = as.factor(biotope))) +
  geom_point() +
  geom_smooth() +
  labs(title = "Distribution of Pararge aegeria per biotope and region",
       y = "Area (%)",
       color = "BIOTOPE"
       ) +
  facet_wrap(~ region)
usercase1

# usercase2  (colors = quantitative/continuous variable)
# Select year 2010
area_biotopes_2010 <-
  area_biotopes %>%
  filter(year == 2010)

usercase2 <-
  ggplot(area_biotopes_2010,
         aes(x = region, y = biotope)) +
  geom_tile(aes(fill = meanArea)) +
  labs(title = "Average covered area (%) in 2010",
       fill = "Area (%)") +
  facet_wrap(~ species)
usercase2


## Challenge 1. Color palettes

#' 1. A palette is nothing more than a character vector of colors. Create your
#' own 4-color palette with [color picker](http://tristen.ca/hcl-picker/).
#' Example: https://tristen.ca/hcl-picker/#/clh/4/1/3F2119/EEBEA2.



#' 2. How to use it for user case 1?



# 2. How to use it for user case 2?


# INTERMEZZO

#' A color palette should be: 1. printer-friendly (gray scale), 2. perceptually
#' uniform 3. easy to read by those with colorblindness. All of this can be
#' found in the [viridis
#' palette](https://www.r-bloggers.com/2018/07/ggplot2-welcome-viridis/) which
#' avoids the red and to go from blue to yellow passing through green (viridis:
#' green in Latin).


##Challenge 2


#' `ggplot2` includes some functions to use viridis palette directly.
#' 1. How to apply viridis discrete color scale to user case 1?



#' 2. How to apply viridis continuous color scale to user case 2?


#' 3. Invert the color direction. Note: typically inverted color directions are less intuitive


# 4. Use colormap "cividis" instead of default ("viridis")


## Challenge 3

#' 1. Make interactive plots for usercase1 and usercase2 using plotly.



#' 2. How to personalize the text displayed while hovering on the tiles of usercase2? See example below



# apply the same to usercase1:
# hint make sure the "unofficial" aes(text = ...) is only passed on to geom_text



#' 3. usercase2 shows the situation in 2010. By making an animation plot over year you can see the evolution of the average covered area over time from 2000 to 2018.

#' 1. Make a basic animation plot and set year in the title

# step 1 make standard faceted heatmap

# step 2 add animation by year

# step 3 set year in the title

#' 2. Use animate() to render the animated graph and pick sensible values for nframes and fps parameters


#' 3. Save animation as gif (default) and set width to 800 pixels and height to 550 pixels


#' 4. Do you hate gifs? Well, save the animation as a mp4 video


## BONUS CHALLENGE 1

#' 1. arrange usercase1 and usercase3 side by side, and above usercase2
area_biotopes_limenitis <-
  area_biotopes %>%
  filter(species == "Limenitis camilla")

usercase3 <-
  ggplot(area_biotopes_limenitis,
         aes(x = year,
             y = meanArea,
             color = as.factor(biotope))) +
  geom_point() +
  geom_smooth() +
  labs(title = "Distribution of Pararge aegeria per biotope and region",
       y = "Area (%)",
       color = "BIOTOPE"
  ) +
  facet_wrap(~ region)



#' 2 collect all legends to the right



## BONUS CHALLENGE 2


#' ggplot function `scale_color_brewer()` allows you to use the brewer color palettes, which are also very nice and satisfy the criteria mentioned above.


#' 1. Which _type_ should you use for better distinguishing different biotopes of user case 1? How to specify a specific palette instead of the default one? ²


# same plot if palette is Accent (= default)


#' 2. You could think that `scale_fill_brewer()` would allow you to do the same for user case 2. But you get the error below. How to solve it?

# This gives an error
usercase2 +
  scale_fill_brewer()

library(RColorBrewer)

