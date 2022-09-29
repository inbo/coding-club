library(tidyverse)

# read data
survey <- read_csv("./data/20220830/20220830_surveys.txt")

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

# How many surveys per gender? Show it as bar plot
ggplot(data = survey, mapping = aes(x = sex)) +
  geom_bar()

# How many surveys per year? Show it as a bar plot
ggplot(data = survey, mapping = aes(x = year)) +
  geom_bar()


## How to get the same plot starting from the summarised data, `survey_per_year`?
survey_per_year <- read_csv("./data/20220830/20220830_surveys_per_year.txt")

# Solution using geom_col()
ggplot(data = survey_per_year,
       mapping = aes(x = year, y = n)) +
  geom_col()

# Solution using geom_bar() in combination with "identity" statistics, i.e. do
# not count, just take the numbers in y as they are
ggplot(data = survey_per_year,
       mapping = aes(x = year, y = n)) +
  geom_bar(stat = "identity")

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
  geom_boxplot(mapping = aes(x = species_id, y = weight, color = sex)) +
  geom_boxplot(mapping = aes(x = species_id, y = weight))


# Option 3 (specify the common part of the two aesthetics, best compromise)
ggplot(data = survey, mapping = aes(x = species_id, y = weight)) +
  geom_boxplot(aes(color = sex)) +
  geom_boxplot()

### CHALLENGE 2

# 1. What’s wrong with this code? Why are the boxplots not blue and transparency
# is not correct? How to solve it?
ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = species_id,
                             y = weight,
                             alpha = weight,
                             color = "blue"),
)

# Solution: color and transparency are constants. Constants are not an
# aesthetics. They should be out of mapping, actually

ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = species_id,
                             y = weight),
               alpha = 0.05,
               color = "blue")

# 2. First plot

## Basic plot to start with
ggplot(data = survey, mapping = aes(x = weight, y = hindfoot_length)) +
  geom_point()

# Solution
ggplot(data = survey, mapping = aes(x = weight,
                                    y = hindfoot_length,
                                    color = sex)) +
  geom_point(alpha = 0.5) +
  ylab("hindfoot length") +
  ggtitle("hindfoot length vs weight") +
  scale_x_log10() +
  scale_color_manual(values = c("red", "yellow"),
                    limits = c("F", "M"))

# Notice you can pass a named vector to values. The names are used as limits
ggplot(data = survey, mapping = aes(x = weight,
                                    y = hindfoot_length,
                                    color = sex)) +
  geom_point(alpha = 0.5) +
  ylab("hindfoot length") +
  ggtitle("hindfoot length vs weight") +
  scale_x_log10() +
  scale_color_manual(values = c("F" = "red", "M" = "yellow"))

# 3. Second plot

## Basic plot to start with
ggplot(data = survey, mapping = aes(x = year)) + geom_bar()

# Solution
ggplot(data = survey, mapping = aes(x = year, fill = sex)) +
  geom_bar(position = "dodge", alpha = 0.5) +
  ylab("number of surveys") +
  ggtitle("Number of surveys per year") +
  coord_flip() +
  scale_fill_manual(values = c ("F" = "red", "M" = "yellow"))


## INTERMEZZO

# First plot (shown in slides). Notice that vars() is a dplyr function
ggplot(data = survey,
       mapping = aes(x = weight,
                     y = hindfoot_length,
                     color = sex)) +
  geom_point(alpha = 0.5) +
  ylab("hindfoot length") +
  ggtitle("hindfoot length vs weight") +
  scale_x_log10() +
  facet_wrap(facets = vars(sex))

# Second plot. Notice you can use ~ sex instead of vars(sex) in facet_wrap()
ggplot(data = survey, mapping = aes(x = year)) +
  geom_bar(position = "dodge", alpha = 0.5) +
  ylab("number of surveys") +
  ggtitle("Number of surveys per year") +
  coord_flip() +
  facet_wrap(~ sex)


## CHALLENGE 3

## 1. What’s wrong with this code? How to correctly plot data with year as x and
## sex as color?

ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = year,
                             y = weight,
                             color = sex))

# Solution
ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = plot_id,
                             y = weight,
                             color = plot_id,
                             group = as.factor(plot_id):as.factor(sex)))

# Another possible solution: pass year as factor to x. Factors and chars are
# automatically interpreted as group variables.
# However, notice how the x-asix changes. As factor (categorical variable), all
# values must be shown making the plot less readable if many factor levels are
# present as in this case.
ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = as.factor(year),
                             y = weight,
                             color = sex))

# 2. To improve readability of the previous plot we choose to group data at 5
# years interval. How to do it? Hint: Check examples at ?geom_boxplot.
ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = year,
                             y = weight,
                             color = sex,
                             group = cut_width(year, 5):as.factor(sex)))

# Based on this solution, you can rethink the solution of the previous exercise
# by cutting years with width 1
ggplot(data = survey) +
  geom_boxplot(mapping = aes(x = year,
                             y = weight,
                             color = sex,
                             group = cut_width(year, 1):as.factor(sex)))


## 3. In the intermezzo we saw how to facet based on values of one column,
## `sex`. How to facet based on two columns? Transform the given plot by using
## sex as facet column, and plot_id as facet row. Improve labels of facets by
## showing "variable name : variable value", e.g. `"plot_id : 1"` or `"sex : F"`
p <- ggplot(data = survey,
            mapping = aes(x = weight,
                          y = hindfoot_length,
                          color = sex)) +
  geom_point(alpha = 0.5) +
  ylab("hindfoot length") +
  ggtitle("hindfoot length vs weight") +
  scale_x_log10()

# Solution using vars() in combination with rows and cols arguments
p_facet <-
  p +
  facet_grid(rows = vars(sex), cols = vars(plot_id), labeller = label_both)
p_facet

# Solution using formula, i.e. using ~
p_facet <-
  p +
  facet_grid(sex ~ plot_id, labeller = label_both)
p_facet

## 4. Customize the non-data components of your plots by using `theme()`. E.g.
## set text size to 8 and text font italic for the facet labels. Use font family
## Courier New for both legend title and text. Set also legend background color
## to green.  Hint: to know the family fonts installed on your (Windows) laptop,
## use `windowsFonts()`.
p_facet +
  theme(
    strip.text = element_text(size = 12,
                              face = "italic"),
    legend.title = element_text(family = "mono"),
    legend.text = element_text(family = "mono"),
    legend.background = element_rect(fill = "green"))

## 5. Use the official INBO layout by loading INBOtheme package
library(INBOtheme)
p_facet
