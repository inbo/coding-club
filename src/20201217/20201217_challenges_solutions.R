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

my_color_palette <- c("#3F2119",
                      "#7B4E3F",
                      "#B6836D",
                      "#EEBEA2")


#' 2. How to use it for user case 1?

usercase1 +
  scale_color_manual(values = my_color_palette)


# 2. How to use it for user case 2?

usercase2 +
  scale_fill_gradientn(colours = my_color_palette)

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

usercase1 +
  scale_color_viridis_d()


#' 2. How to apply viridis continuous color scale to user case 2?

usercase2 +
  scale_fill_viridis_c()

#' 3. Invert the color direction. Note: typically inverted color directions are less intuitive

usercase1 +
  scale_color_viridis_d(direction = -1)

usercase2 +
  scale_fill_viridis_c(direction = -1)

# 4. Use colormap "cividis" instead of default ("viridis")
usercase1 +
  scale_color_viridis_d(option = "cividis")

usercase2 +
  scale_fill_viridis_c(option = "cividis")


## Challenge 3

#' 1. Make interactive plots for user case 1 and 2 using plotly.

# note: interactive plots appear in the Viewer pane (instead of the plot pane)
# if nothing is shown in the Viewer pane it is probably time to update your Rstudio version (> 1.3)
# a temporary workaround in that case is to click export in the Viewer pane and then "Save as webpage"
# After you saved the webpage as *.html you can view the interactive plot in your webbrowser.
ggplotly(usercase1)
ggplotly(usercase2)


#' 2. How to personalize the text displayed while hovering on the tiles of user case 2? See example below

area_biotopes_2010_interactive <-
  area_biotopes_2010 %>%
  mutate(text = paste0("region: ", region, "\n", "biotope: ", biotope, "\n", "value: ",round(meanArea, 1)))

heatmap_area_biotopes_2010 <-
  ggplot(area_biotopes_2010_interactive,
         aes(x = region, y = biotope, text = text)) +
  geom_tile(aes(fill = meanArea)) +
  labs(title = "Average covered area (%) in 2010",
       fill = "Area (%)") +
  facet_wrap(~ species)
ggplotly(heatmap_area_biotopes_2010, tooltip = "text")


# to apply the same to user case 1: make sure the "unofficial" aes(text = ...) is only passed on to geom_point
# passing it to geom_smooth results in the smoother not being shown in the plot (which is probably a bug)
area_biotopes_pararge <-
  area_biotopes_pararge %>%
  mutate(text = paste0("year: ",
                       year, "\n",
                       "Area: ",
                       round(meanArea, 2),
                       "%\n",
                       "biotope: ",
                       biotope))

usercase1_with_text <-
  ggplot(area_biotopes_pararge,
         aes(x = year,
             y = meanArea,
             color = as.factor(biotope))) +
  geom_point(aes(text = text)) +
  geom_smooth() +
  labs(color = "BIOTOPE") +
  facet_wrap(~ region)
#the warning can be safely ignored
ggplotly(usercase1_with_text, tooltip = "text")


#' 3. user case 2 shows the situation in 2010. By making an animation plot over year you can see the evolution of the average covered area over time from 2000 to 2018.

#' 1. Make a basic animation plot and set year in the title

# step 1 make standard faceted heatmap
heatmap_area_biotopes <-
  ggplot(area_biotopes,
         aes(x = region, y = biotope)) +
  geom_tile(aes(fill = meanArea)) +
  labs(fill = "Area (%)") +
  facet_wrap(~ species)

# step 2 add animation by year
heatmap_area_biotopes_animation <-
  heatmap_area_biotopes +
  transition_time(time = year)

# step 3 set year in the title
heatmap_area_biotopes_animation <-
  heatmap_area_biotopes_animation +
  ggtitle("Average covered area (%) in {frame_time}",
          subtitle = "Showing frame {frame} of {nframes}")

#' 2. adjust nframes and fps

animate(heatmap_area_biotopes_animation,
        nframes = length(unique(area_biotopes$year)),
        fps = 1)

#' 3. Save animation as gif (default) and set width to 800 pixels and height to 550 pixels

anim_save("20201217_animation_heatmap_biotopes.gif",
          animation = heatmap_area_biotopes_animation,
          path = "./docs/assets/images/20201217",
          width = 800,
          height = 500,
          nframes = length(unique(area_biotopes$year)),
          fps = 1)

#' 4. Do you hate gifs? Well, save the animation as a mp4 video

anim_save(filename = "20201217_animation_heatmap_biotopes.mp4",
          animation = heatmap_area_biotopes_animation,
          path = "./docs/assets/images/20201217",
          width = 800,
          height = 500,
          nframes = length(unique(area_biotopes$year)),
          fps = 1,
          renderer = ffmpeg_renderer(format = "mp4"))

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
  labs(title = "Distribution of Limenitis camilla aegeria per biotope and region",
       y = "Area (%)",
       color = "BIOTOPE"
  ) +
  facet_wrap(~ region)

library(patchwork)

pw <- (usercase1 + usercase3) / usercase2
pw

#' 2 collect all legends to the right

pw + plot_layout(guides = "collect")

## BONUS CHALLENGE 2


#' ggplot function `scale_color_brewer()` allows you to use the brewer color palettes, which are also very nice and satisfy the criteria mentioned above.


#' 1. Which _type_ should you use for better distinguishing different biotopes of user case 1? How to specify a specific palette instead of the default one? ²

usercase1 +
  scale_color_brewer(type = "qual")

# same plot if palette is Accent (= default)
usercase1 +
  scale_color_brewer(type = "qual", palette = "Accent")

usercase1 +
  scale_color_brewer(type = "qual", palette = "Set1")


#' 2. You could think that `scale_fill_brewer()` would allow you to do the same for user case 2. But you get the error below. How to solve it?

# This gives an error
usercase2 +
  scale_fill_brewer()

library(RColorBrewer)
usercase2 +
  scale_fill_gradientn(colours = brewer.pal(n = 10, name = "BrBG"))


