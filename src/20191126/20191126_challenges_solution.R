library(tidyverse)

# read data
survey <- read_csv("./data/20180222/20180222_surveys.csv")
# remove records without weight or hindfoot length
survey <- survey %>%
  filter(!is.na(weight) & !is.na(hindfoot_length) & !is.na(sex))

## CHALLENGE 1


# Plot the hindfoot_length as function of weight using points
ggplot(data = survey, mapping = aes(x = weight, y = hindfoot_length)) +
  geom_point()

# Plot the weight as function of species using boxplot
ggplot(data = survey, mapping = aes(x = species_id, y = weight)) +
  geom_boxplot()

# Replace the box plot with a violin plot
ggplot(data = survey, mapping = aes(x = species_id, y = weight)) +
  geom_violin()

# How many surveys per gender? Show it as histogram
ggplot(data = survey, mapping = aes(x = sex)) +
  geom_bar()

# How many surveys per year? Show it as histogram
ggplot(data = survey, mapping = aes(x = year)) +
  geom_bar()

### CHALLENGE 2

# First plot
ggplot(data = survey, mapping = aes(x = weight,
                                    y = hindfoot_length,
                                    color = sex)) +
  geom_point(alpha = 0.5) +
  ylab("hindfoot length") +
  ggtitle("hindfoot length vs weight") +
  scale_x_log10() +
  scale_color_manual(values = c("red", "yellow"),
                    limits = c("F", "M"))

# Second plot
ggplot(data = survey, mapping = aes(x = year, fill = sex)) +
  geom_bar(position = "dodge", alpha = 0.5) +
  ylab("number of surveys") +
  ggtitle("Number of surveys per year") +
  coord_flip() +
  scale_fill_manual(values = c ("red", "yellow"),
                    limits = c("F", "M"))


## INTERMEZZO

# First plot
ggplot(data = survey,
       mapping = aes(x = weight,
                     y = hindfoot_length,
                     color = sex)) +
  geom_point(alpha = 0.5) +
  ylab("hindfoot length") +
  ggtitle("hindfoot length vs weight") +
  scale_x_log10() +
  facet_wrap(vars(sex))

# Second plot
ggplot(data = survey, mapping = aes(x = year, fill = sex)) +
  geom_bar(position = "dodge", alpha = 0.5) +
  ylab("number of surveys") +
  ggtitle("Number of surveys per year") +
  coord_flip() +
  scale_fill_manual(values = c("red", "yellow"),
                    limits = c("F", "M")) +
  facet_wrap(vars(sex)) # the same as  ~sex


## CHALLENGE 3

# Read iNaturalist obseration in and around Brussels from 2019
inat_bxl <- read_tsv("./data/20191126/20191126_BXL_iNaturalist_top20.csv",
                        na =  "")

# Plot the number of observations per species and year.
# Make the best plot ever!

ggplot(inat_bxl, aes(x = year)) +
  geom_bar() +
  facet_wrap(vars(species)) +
  scale_y_log10() +
  ylab("Number of observations") +
  theme(strip.text = element_text(size = 8))
# see hackmd for many other solutions...
