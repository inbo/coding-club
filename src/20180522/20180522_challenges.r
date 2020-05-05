# coding club 2018-05-22
#
# S. Van Hoey
#

library(tidyverse)

surveys <- read_csv("../data/20180222/20180222_surveys.csv") %>% 
  filter(!is.na(weight),           # remove missing weight
         !is.na(hindfoot_length),  # remove missing hindfoot_length
         !is.na(sex))                # remove missing sex

# ----------------
# challenge 1
# ----------------

ggplot(surveys, aes(x = weight, 
                    y = hindfoot_length,
                    color = sex)) + 
  facet_wrap(facets = factor("year")) + 
  geom_point(alpha = 0.5) +
  ylab("hindfoot length") +
  scale_x_log10() + 
  scale_color_brewer(2) +
  theme_light()

# ----------------
# challenge 2
# ----------------

tidy_bevolking <- read_csv("../data/20180522/20180522_gent_groeiperwijk_tidy.csv")

# heatmap of the data
# https://learnr.wordpress.com/2010/01/26/ggplot2-quick-heatmap-plotting/
ggplot(tidy_bevolking, aes(factor(year), wijk, fill = growth)) +
  geom_tile(colour = "white") +
  theme_minimal(base_size = 14) +
  scale_fill_distiller(palette = "RdBu", type = "div", 
                       direction = 1) +
  labs(x = "", y = "")

# ----------------
# challenge 3
# ----------------

# make sure the 'magick' package is installed

library(cowplot)
library(INBOtheme)

weight_scatter <- ggplot(surveys, aes(x = weight, 
                    y = hindfoot_length)) + 
  geom_point()

weight_density <- ggplot(surveys, aes(x = weight)) + 
  geom_histogram(bins = 30, aes(y = ..density..), 
                 alpha = 0.3, color = "gray") +
  geom_density(color = "black", size = 0.75)

# combine the plots with cowplot
my_plot <- plot_grid(weight_scatter, weight_density, 
          labels = c("A", "B"), align = "h")

# add logo to the graph with cowplot
ggdraw() +
  draw_plot(my_plot) +
  draw_image("../images/coding_club_logo_1.png", 
             x = 0.6, y = 0.6, scale = 0.2)



  



