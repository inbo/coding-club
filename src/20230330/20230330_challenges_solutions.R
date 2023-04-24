library(tidyverse)

# Read dataset about year of first observation of IAS in Belgium from 1950.
ias_be <- read_tsv(
  file = "./data/20230330/20230330_ias_first_observed_BE.txt",
  na = ""
)

# make a bar chart with the number of taxa observed for the first time in
# Belgium per year. Tip: check the difference between `geom_bar()` and
# `geom_col()`.
ias_first_obs <- ggplot(data = ias_be, mapping = aes(x = first_observed)) +
  geom_bar()

# Change x and y labels to "year of introduction" and "number of taxa"
# respectively
ias_first_obs <- ias_first_obs +
  xlab("year of introduction") +
  ylab("number of taxa")
ias_first_obs

# Notice you can specify x and y labels within function labels()
ggplot(data = ias_be, mapping = aes(x = first_observed)) +
  geom_bar() +
  labs(x = "year of introduction", y = "number of taxa")

# Shown only data from 1980 up to the latest year of `first_observed`
ias_first_obs_from_1980 <- ias_first_obs +
  coord_cartesian(
    xlim = c(1980, max(ias_be$first_observed, na.rm = TRUE))
)
ias_first_obs_from_1980

# you can use xlim as well. Notice that warnings are returned as the x values
# out of the limits are by xlim removed = missing values. coord_cartesian() will
# not change the underlying data like setting limits does and so no warnings are
# returned. You can see `coord_cartesian()` like a zoom lens.
ias_first_obs <- ias_first_obs +
  xlim(1980, max(ias_be$first_observed, na.rm = TRUE))
ias_first_obs

# you can also filter the data before plotting, e.g. via dplyr's `filter()`
ias_be %>%
  filter(first_observed >= 1980) %>%
  ggplot(mapping = aes(x = first_observed)) +
  geom_bar()  +
  labs(x = "year of introduction", y = "number of taxa")

# Fill bars with color blue and set contour color to red
ias_first_obs <- ias_first_obs +
  geom_bar(fill = "blue", color = "red")
ias_first_obs

# Sometimes is better to show aggregated data to better deal with outliers and
# show trends. In this case, how to group years in bins of 5 years.

# Solution using geom_histogram, i.e. x is seen as a continous variable now.
# Notice the space between bars disappears: a visual hint telling you that x is
# a continuous variable
ias_first_obs_hist <- ggplot(data = ias_be,
                             mapping = aes(x = first_observed)) +
  geom_histogram(binwidth = 5)
ias_first_obs_hist

# You can still work with geom_bar using `scale_x_binned()`: x is still seen as
# a discrete variable, i.e. the bars are spaced by default.
ggplot(data = ias_be, mapping = aes(x = first_observed)) +
  geom_bar() +
  scale_x_binned(breaks = seq(min(ias_be$first_observed),
                              max(ias_be$first_observed),
                              5),
                 limits = c(1980, max(ias_be$first_observed)))

# Another way of working with geom_bar(), which automatically creates nice
# labels with the specified intervals on x axis. However, this way of working
# makes setting limits difficult. Only filtering the data beforehand works
ias_be %>%
  dplyr::filter(first_observed >= 1980) %>%
ggplot(mapping = aes(x = first_observed)) +
  geom_bar(aes(x = cut(first_observed, length(unique(first_observed)) / 5)))


## Intermezzo: aesthetics

# equivalent statements
ggplot(data = ias_be, mapping = aes(x = first_observed)) +
  geom_bar()

ggplot(data = ias_be) +
  geom_bar(mapping = aes(x = first_observed))


# but second is better for superimposing geometries with different aesthetics.
# Example:
press_temp <- tibble::tibble(
  year = c(2000:2004),
  press = c(1.0, 1.1, 1.4, 1.2, 1.6),
  temp = c(13.2, 15.1, 12.2, 11.8, 10.9)
)
ggplot(press_temp) +
  geom_point(mapping = aes(x = year, y = press)) +
  geom_point(mapping = aes(x = year, y = temp), color = "red") +
  scale_y_continuous(sec.axis = sec_axis(~., name = "temperature")) +
  theme(axis.line.y.right = element_line(color = "red"),
        axis.text.y.right = element_text(color = "red"),
        axis.title.y.right = element_text(color = "red"))

# Notice that there is also another way to write aesthetics, but this way
# is rarely used:
ggplot(data = ias_be) +
  geom_bar() +
  aes(x = first_observed)
# order is not relevant
ggplot(data = ias_be) +
  aes(x = first_observed) +
  geom_bar()

# Challenge 2

# IAS data at regional level
ias_regions <- read_tsv(
  "./data/20230330/20230330_ias_first_observed_regions.txt",
  na = ""
)

# Make a bar chart plot similar to the ones in challenge 1 at
# regional level. How are the bars displayed per region, by default?
ggplot(ias_regions) +
  geom_bar(aes(x = first_observed, fill = locationId),
           color = "red")

ggplot(ias_regions) +
  geom_histogram(aes(x = first_observed, fill = locationId),
                 binwidth = 5,
                 color = "red")

# How to set them next to each other?
ias_first_obs_reg <- ggplot(ias_regions) +
  geom_bar(aes(x = first_observed, fill = locationId),
           position = "dodge")

ggplot(ias_regions) +
  geom_histogram(aes(x = first_observed, fill = locationId),
                 binwidth = 5,
                 position = "dodge")


# Notice that "dodge" is a kind of abbreviation for `position_dodge()` function
# with default values
ias_first_obs_reg <- ggplot(ias_regions) +
  geom_bar(aes(x = first_observed, fill = locationId),
           position = position_dodge())

# How to split the bar chart in subplots based on kingdom? Set the y scale free,
# not the x one.
ias_first_obs_reg +
  facet_wrap(vars(kingdom), scales = "free_y")

# the very same expression using ~
ias_first_obs_reg +
  facet_wrap(~ kingdom, scales = "free_y")


# Set order of the subplots as in figure on the left
ias_first_obs_reg +
  facet_wrap(
    vars(factor(kingdom,
                levels = c("Animalia", "Plantae", "Fungi", "Chromista"))
         ),
    scales = "free"
)

# Split sublots by kingdom and location as in figure on the right
ggplot(ias_regions) +
  geom_bar(aes(x = first_observed, fill= locationId)) +
  facet_grid(
    rows = vars(factor(kingdom,
                       levels = c("Animalia", "Plantae", "Fungi", "Chromista"))
                ),
    cols = vars(locationId)
)
# Notice that you can change kingdom type to factor BEFORE plotting of course,
# e.g. via `mutate()`. Probably the best way qua code readibility
ias_regions %>%
  mutate(kingdom = factor(kingdom,
       levels = c("Animalia", "Plantae", "Fungi", "Chromista"))) %>%
  ggplot() +
  geom_bar(aes(x = first_observed, fill= locationId)) +
  facet_grid(
    rows = vars(kingdom),
    cols = vars(locationId)
  )

## INTERMEZZO: Themes

# Use a ggplot2 theme
ggplot(data = ias_be, mapping = aes(x = first_observed)) +
  geom_bar() + theme_bw()

# Customize your plot via `theme()`
ggplot(data = ias_be, mapping = aes(x = first_observed)) +
  geom_bar() +
  theme(panel.background = element_rect(fill = "red"),
        panel.grid.major = element_line(colour = "blue", linewidth = 2))

# Use INBOtheme
library(INBOtheme)

ggplot(data = ias_be, mapping = aes(x = first_observed)) +
  geom_bar() +
  ggtitle(label = "Temporal distribution of alien species introdutions")

## CHALLENGE 3: Categorical variables

ias_path <- read_tsv("./data/20230330/20230330_ias_pathways.txt", na = "")

# Bar chart plot with number of introduced taxa per pathway and kingdom, see
# figure on the left. Note the space among the bars within same pathway. Use
# INBOtheme to get same colors and text style.

ggplot(ias_path) +
  geom_bar(aes(x = pathway, fill = kingdom), position = "dodge2") +
  coord_flip() +
  ylab("number of introduced taxa")

# "dodge2" is a shortcut for `position_dodge2()` with default values:
ggplot(ias_path) +
  geom_bar(aes(x = pathway, fill = kingdom), position = position_dodge2()) +
  coord_flip() +
  ylab("number of introduced taxa")

# by using `position_dodge2()` you have control on "padding", i.e. the space
# between the bars within same pathway. Example, below with negative padding
ggplot(ias_path) +
  geom_bar(aes(x = pathway, fill = kingdom),
           position = position_dodge2(padding = -0.2)) +
  coord_flip() +
  ylab("number of introduced taxa")


# After adding bins_first_observed_label columns (code provided), try to
# reproduce the plot on the right.
bin <- 10
ias_path <-
  ias_path %>%
  mutate(
    bins_first_observed_label =
      floor(.data$first_observed / bin) * bin
  ) %>%
  mutate(bins_first_observed_label = paste(
    as.character(.data$bins_first_observed_label),
    "-",
    as.character(.data$bins_first_observed_label + bin - 1)
  ))


# create a summary (count) first, e.g. via dplyr
ias_path_count <- ias_path %>%
  count(bins_first_observed_label, pathway)
ias_path_count

# Notice the message returned by INBOtheme telling you that using more than 4
# colours might make the plot hard to read
ggplot(ias_path_count) +
  geom_point(mapping = aes(x = bins_first_observed_label,
                           y = n,
                           color = pathway),
             shape = 1,
             size = 3) +
  geom_line(mapping = aes(x = bins_first_observed_label,
                          y = n,
                          # group argument tells R  which points have to be linked together to form a line
                          group = pathway,
                          color = pathway)) +
  theme(axis.text.x = element_text(angle = 60, vjust = 0.5))


## Extra challenge

# Starting from the [ToothGrowth](https://www.rdocumentation.org/packages/datasets/versions/3.6.2/topics/ToothGrowth) dataset, you first plot the tooth length against the dose of the supplement using

ggplot(ToothGrowth, aes(x = dose, y = len, color = supp)) +
  geom_point()

# However, with so many points it is hard to see the effect of supp and dose on
# len. A box plot (`geom_boxplot()`) could help, but what's gone wrong with this
# code? The x, `dose`, doesn't make any sense. How to solve it?

ggplot(ToothGrowth, aes(x = dose, y = len, color = supp, group = supp)) +
  geom_boxplot()


# group by dose (as a factor!) and supp. See more about in coding club session
# of
# [2022-08-30](https://inbo.github.io/coding-club/sessions/20220830_ggplot.html)
ggplot(ToothGrowth,
       aes(x = dose, y = len, color = supp, group = as.factor(dose):supp)) +
  geom_boxplot()
