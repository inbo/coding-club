library(tidyverse)
library(INBOtheme)

## CHALLENGE 2

# read data
births <- read_csv("./data/20200528/20200528_births_belgium.txt")

# Plot for year 2010

year_births_plot <-
  births %>%
  filter(year == 2010) %>%
  ggplot() +
  geom_col(mapping = aes(x = month, y = n_births)) +
  ylab("Number of births") +
  coord_flip() +
  ggtitle("Number of births - 2010")
year_births_plot + ggsave(filename = "./n_births_belgium_2010.png",
                          year_births_plot,
                          device = "png")

# Do the same for all years from 2010 to 2019 without repeating yourself



## CHALLENGE 3

