library(tidyverse)

# read data
survey <- read_csv("./data/20220830/20220830_surveys.txt")

## CHALLENGE 1

# Plot the hindfoot_length as function of weight using points


# Plot the weight as function of species using boxplot


# Replace the box plot with a violin plot


# How many surveys per gender? Show it as bar plot



# How many surveys per year? Show it as a bar plot



# How to get the same plot starting from the summarised data, `survey_per_year`
survey_per_year <- read_csv("./data/20220830/20220830_surveys_per_year.txt")



# INTERMEZZO. Aesthetics

# This works:
ggplot(data = survey, aes(x = species_id, y = weight)) +
  geom_boxplot()

# This works too:
ggplot(data = survey) +
  geom_boxplot(aes(x = species_id, y = weight, color = sex))

# What should I use? Both are good, but ...
# But what if you want to plot two or more geometries with different
# aesthetics? Which syntax is more readable?

# Example

# Option 1 (make changes to aesthetics of second geometry, less readable)
ggplot(data = survey, aes(x = species_id, y = weight, color = sex)) +
  geom_boxplot() +
  geom_boxplot(aes(color = NULL))

# Option 2 (specify both aesthetics separately, maybe redundant)
ggplot(data = survey) +
  geom_boxplot(aes(x = species_id, y = weight)) +
  geom_boxplot(aes(x = species_id, y = weight, color = sex))

# Option 3 (specify the common part of the two aesthetics, best compromise)
ggplot(data = survey, aes(x = species_id, y = weight)) +
  geom_boxplot(aes(color = sex)) +
  geom_boxplot()


### CHALLENGE 2

# 1. What’s wrong with this code? Why are the boxplots not blue and transparency
# is not correct? How to solve it?
ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = species_id,
                             y = weight,
                             alpha = 0.05,
                             color = "blue"))



# 2. First plot

# Basic plot to start with
ggplot(data = survey, mapping = aes(x = weight, y = hindfoot_length))



# 3. Second plot

# Basic plot to start with
ggplot(data = survey, mapping = aes(x = year)) + geom_bar()




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
  facet_wrap(facets = vars(sex))

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

# 1. What’s wrong with this code? How to correctly plot data with year as x and
# sex as color?

ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = year,
                             y = weight,
                             color = sex))




# 2. To improve readability of the previous plot we choose to group data at 5
# years interval. How to do it? Hint: Check examples at ?geom_boxplot.




# 3. In the intermezzo we saw how to facet based on values of one column, `sex`.
# How to facet based on two columns? Transform the given plot by using sex as
# facet column, and plot_id as facet row. Improve labels of facets by showing
# "variable name : variable value", e.g. `"plot_id : 1"` or `"sex : F"`
p <- ggplot(data = survey,
            mapping = aes(x = weight,
                          y = hindfoot_length,
                          color = sex)) +
  geom_point(alpha = 0.5) +
  ylab("hindfoot length") +
  ggtitle("hindfoot length vs weight") +
  scale_x_log10()




# 4. Customize the non-data components of your plots by using `theme()`. E.g.
# set text size to 8 and text font italic for the facet labels. Use font family
# Courier New for both legend title and text. Set also legend background color
# to green.  Hint: to know the family fonts installed on your (Windows) laptop,
# use `windowsFonts()`.

