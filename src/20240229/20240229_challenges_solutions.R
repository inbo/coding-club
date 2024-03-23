library(tidyverse)
library(ggridges) # used in challenge 3
library(viridis) #used in challenge 3

rodentia <- readr::read_tsv(
  file = "./data/20240229/20240229_rodentia.txt",
  na = "",
  guess_max = 136300)


## CHALLENGE 1

ggplot(data = rodentia) +
  geom_bar(mapping = aes(x = year))

# labels via `xlab`, `ylab()`
ggplot(data = rodentia) +
  geom_bar(mapping = aes(x = year)) +
  xlab("Year") +
  ylab("Number of observations")

# Or via labs, which allows you to add the title as well
ggplot(data = rodentia) +
  geom_bar(mapping = aes(x = year)) +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium")

# Set x axis limits.

# Use `coord_cartesian`, which acts as a zoom lens on the plot
ggplot(data = rodentia) +
  geom_bar(mapping = aes(x = year)) +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium") +
  coord_cartesian(xlim = c(2000,max(rodentia$year)))

# You can use `xlim()` as well (see below). But notice that warnings are
# returned as the x values out of the limits are removed by `xlim()`.
# `coord_cartesian()` will not change the underlying data like setting limits
# does and so no warnings are returned.
ggplot(rodentia) +
  geom_bar(mapping = aes(x = year)) +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium") +
  # the extremes of the interval are not taken included in xlim
  xlim(c(1999,max(rodentia$year) + 1))

# You can also use filter the data before plotting, e.g. via dplyr::filter()`
ggplot(data = rodentia %>% dplyr::filter(year >= 2000)) +
  geom_bar(mapping = aes(x = year)) +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium")

# Fill with blue and set red as contour color
ggplot(data = rodentia %>% dplyr::filter(year >= 2000)) +
  geom_bar(mapping = aes(x = year), fill = "blue", color = "red") +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium")

# Group data at 5 year level.

# Notice how the x-variable is seen as a continuous variable using
# `geom_histogram`. How do you see that? The space between the bars disappears.
# Notice that using `geom_histogram` the bars are built by using intervals
# centered at 2000, 2005, 2010 and 2020! In other words, the first bar on the
# left shows the number of observations of 1998, 1999, 2000, 2001 and 2002. The
# second bar the observations from 2003 up to 2007 and so on. The bar on the
# right centered at 2020 shows only the data from 2018, 2019 and 2020.
ggplot(rodentia) +
  geom_histogram(mapping = aes(x = year),
                 fill = "blue",
                 color = "red",
                 binwidth = 5) +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium") +
  coord_cartesian(xlim = c(2000,max(rodentia$year)))

# Notice that using `dplyr::filter` in combination with `geom_histogram` the
# first bar on the left is different as it shows the number of observations of
# 2000, 2001 and 2002 only, as we truncated the data via `dplyr::filter`!
ggplot(rodentia %>% dplyr::filter(year >= 2000)) +
  geom_histogram(mapping = aes(x = year),
                 fill = "blue",
                 color = "red",
                 binwidth = 5) +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium")

# We didn't speak about statistic functions in ggplot, like `stat_bin()`, as it
# makes things just more complex: to do statistics you can use other packages
# like dplyr after all. To bin data, you can do via `geom_histogram` for
# example. Indeed, the plot below is exactly the
# same as the one shown above using `geom_histogram`.
ggplot(data = rodentia%>% dplyr::filter(year >= 2000),
       aes(x = year)) +
  stat_bin(binwidth = 5, fill = "blue", color = "red") +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium")


# You can still work with `geom_bar()` using `scale_x_binned()`: x is still seen
# as a discrete variable, i.e. the bars are spaced by default. Notice that the
# very first bar is higher then expected as it shows the number of observations
# (= rows) from 2000 to 2005, extremes included. The second bar from the left,
# starts counting from 2006, the third from 2011 etc. The reason is that binning 21
# years in groups of 5 we need a group of 6 years.
ggplot(data = rodentia %>% dplyr::filter(year >= 2000)) +
  geom_bar(mapping = aes(x = year),
           fill = "blue",
           color = "red") +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium") +
  coord_cartesian(xlim = c(2000,max(rodentia$year))) +
  scale_x_binned(breaks = seq(2000, max(rodentia$year), 5))


ggplot(data = rodentia) +
  geom_bar(mapping = aes(x = year),
           fill = "blue",
           color = "red") +
  labs(x = "Year",
       y = "Number of observations",
       title = "Evolution of rodents in Belgium") +
  scale_x_binned(breaks = seq(2000, max(rodentia$year), 5))


## Intermezzo

# dummy dataset
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


## Challenge 2A

ggplot(rodentia) +
  geom_bar(mapping = aes(x = year, fill = genus))


# Via position_*() functions
ggplot(rodentia) +
  geom_bar(mapping = aes(x = year, fill = genus),
           position = position_jitter()) # position = "jitter" will do the same

ggplot(rodentia) +
  geom_bar(mapping = aes(x = year, fill = genus),
           position = position_dodge()) # position = "dodge" will do the same

ggplot(rodentia) +
  geom_bar(mapping = aes(x = year, fill = genus),
           position = position_dodge2()) # position = "dodge2" will do the same

ggplot(rodentia) +
  geom_bar(mapping = aes(x = year, fill = genus),
           position = position_fill()) # position = "fill" will do the same


# Faceting using facet_wrap is a classic :-)
ggplot(rodentia) +
  geom_bar(mapping = aes(x = year, fill = genus)) +
  facet_wrap(~family, scales = "free")


## Challenge 2B

rodentia_selection <- rodentia %>%
  dplyr::filter(species %in% c("Ondatra zibethicus",
                        "Rattus norvegicus"))

rodentia_selection_n <- rodentia_selection %>%
  dplyr::group_by(species,year) %>%
  dplyr::count()

# 1. Show both points and lines and distinguish the two species via color.
ggplot(rodentia_selection_n,
       aes(x = year, y = n, color = species)) +
  geom_point() +
  geom_line()

# 2. Show smoother on the data

ggplot(rodentia_selection_n,
       aes(x = year, y = n, color = species)) +
  geom_point() +
  geom_smooth(method = "gam")



## Challenge 3

# Some examples following the R graph gallery

# Ridgeplots

# x = year
ggplot(rodentia, aes(x = year, y = species, fill = species)) +
  geom_density_ridges() +
  theme_ridges() +
  theme(legend.position = "none")

# x = month
ggplot(rodentia, aes(x = month, y = species, fill = species)) +
  geom_density_ridges() +
  theme_ridges() +
  theme(legend.position = "none")

# boxplot + individual observations via jitter geometry
rodentia %>%
  ggplot(aes(x = species, y = year, fill = species)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  geom_jitter(color="black", size=0.4, alpha=0.9)

# jitter is not always interesting. For example, it has not really sense if we
# want to show the distribution at month level
rodentia %>%
  ggplot(aes(x = species, y = month, fill = species)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  geom_jitter(color="black", size=0.4, alpha=0.9)

# box plot only is way better
rodentia %>%
  ggplot(aes(x = species, y = month, fill = species)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6)

# violin plot to show the distribution at year level
rodentia %>%
  ggplot(aes(x=species, y=year, fill=species)) +
  geom_violin() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6, option="A") +
  ggtitle("Violin chart") +
  xlab("")

# violin plot to show the distribution at month level
rodentia %>%
  ggplot(aes(x=species, y=month, fill=species)) +
  geom_violin() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6, option="A") +
  ggtitle("Violin chart") +
  xlab("")

# Add `scale_y_continuous()` to avoid decimals on y-axis (months)
rodentia %>%
  ggplot(aes(x=species, y=month, fill=species)) +
  geom_violin() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6, option="A") +
  scale_y_continuous(breaks = 1:12, labels = as.character(1:12)) +
  ggtitle("Violin chart") +
  xlab("")


# A pie chart example

# Add first the category as factor. Adjust the order of the levels of the factor
# to have "Other" as last value in legend.
rodentia_categories <- rodentia %>%
  mutate(category = ifelse(genus %in% c("Ondatra", "Rattus"),
                           genus,
                           "Other")) %>%
  mutate(category = factor(category, levels = c("Ondatra", "Rattus", "Other")))

ggplot(rodentia_categories) +
  # x = "" is essential to make the pie looking a pie :-)
  geom_bar(aes(x = "", fill = category)) +
  coord_polar("y", start = 0) +
  # remove background, grid, numeric labels
  theme_void()

# To add the legend as labels on the piechart it's just "trial-and-error". Based
# on R graph gallery example: https://r-graph-gallery.com/piechart-ggplot2.html

rodentia_for_best_piechart <- rodentia_categories %>%
  dplyr::count(category) %>%
  # needed for best aligning the categories on the pie
  arrange(desc(category)) %>%
  mutate(prop = n / sum(.data$n) *100) %>%
  mutate(ypos = cumsum(prop) - 0.3 * prop)

ggplot(rodentia_for_best_piechart) +
  geom_col(aes(x="", y=prop, fill=category), width=1, color="white") +
  coord_polar("y", start=0) +
  theme_void() +
  theme(legend.position="none") +
  geom_text(aes(x = "", y = ypos, label = category),
            color = "white",
            size=4,
            fontface="bold")
