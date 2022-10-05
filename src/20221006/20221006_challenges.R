library(tidyverse)


## CHALLENGE 3

# code to be on top of app.R

# read dataset (path to be checked)
butterfly_data <- read_csv("./data/20221006/20221006_butterflies_data.txt", na = "")
# biotopes
biotopes <- unique(butterfly_data$biotope)
# species
sp <- unique(butterfly_data$species)


# example of plot for one selected biotope/species combination
b <- biotopes[1] # Agriculture
s <- sp[1] # Limenitis camilla

ggplot(butterfly_data %>%
         filter(species == s,
                biotope == b),
         aes(x = year,
             y = meanArea)) +
  geom_point() +
  geom_smooth() +
  labs(title = paste("Distribution of ", s, "- biotope:", b),
       y = "Area (%)") +
  facet_wrap(~ region)
