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



## CHALLENGE 3: the Fox slot machine

foods <- c(rep("voles", 10),
           rep("mice",20),
           rep("squirrels",30),
           rep("hamsters",20),
           rep("woodchucks",14),
           rep("starving", 5),
           rep("poison",1))
enemies <- c(rep("leopard", 3),
             rep("caracal", 4),
             rep("lynx", 3),
             rep("leptospirosis", 1),
             rep("rabbit fever", 1),
             rep("brucellosis", 1),
             rep("safe", 87))
reproductions <- c(rep(FALSE, 85),
                   rep(TRUE, 15))

# Let's play to the Fox Slot machine once
food <- sample(foods, size = 1)
enemy <- sample(enemies, size = 1)
reproduction <- sample(reproductions, size = 1)
print(paste0("Food: ", food,
             "; enemy: ", enemy,
             "; reproduction: ", reproduction))

# PART 1. Use the code above and loops techniques to simulate the fox life. Does
# it succeed to reproduce or does it die before?




# PART 2. Extend the game to a population of 10 foxes. How many foxes succeeded
# to reproduce?

