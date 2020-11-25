library(tidyverse)

# Give a look at the CO2 dataset
str(CO2)

#' Plot `uptake` as function of `conc` using points
ggplot(CO2, aes(x = conc, y = uptake)) + geom_point()
#' Distinguish by `Treatment` using points with different colors
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment)) + geom_point()
#' and different shapes for `Type`
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment, shape = Type)) +
  geom_point()

#'Change the y label to "CO2 uptake"
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment, shape = Type)) +
  geom_point() +
  ylab("C02 uptake")

#' Add a title to the graph, e.g. "cold tolerance of the grass species Echinochloa crus-galli"
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment, shape = Type)) +
  geom_point() +
  ylab("C02 uptake") +
  ggtitle("cold tolerance of the grass species Echinochloa crus-galli")

#' Use a logarithmic scale for the concentration
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment, shape = Type)) +
  geom_point() +
  ylab("C02 uptake") +
  ggtitle("cold tolerance of the grass species Echinochloa crus-galli") +
  scale_x_log10()

#' Set colors to "blue" for chilled plants and "indian red" for nonchilled
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment, shape = Type)) +
  geom_point() +
  ylab("C02 uptake") +
  ggtitle("cold tolerance of the grass species Echinochloa crus-galli") +
  scale_x_log10() +
  # use a "named vector" to avoid that order plays a role in color choice
  scale_color_manual(values = c("chilled" = "blue",
                                "nonchilled" = "indian red"))

# INTERMEZZO. Aesthetics

#' This works:

ggplot(CO2, aes(x = Type, y = uptake)) + geom_violin()

#' This works too

ggplot(CO2) +
  geom_violin(aes(x = Type, y = uptake))

#' What should I use? Both are good, but, but, but...
#' But what if you want to plot two or more geometries with different aesthetics? Which syntax is more readable?

# Example 1

# Option 1 (make changes to aesthetics of second geomtry, less readable)
ggplot(CO2, aes(x = Type, y = uptake, color = Treatment)) +
  geom_violin() +
  geom_violin(aes(color = NULL), alpha = 0.5)

# Option 2 (specify both aesthetics separately, maybe reduandant)
ggplot(CO2) +
  geom_violin(aes(x = Type, y = uptake, color = Treatment)) +
  geom_violin(aes(x = Type, y = uptake), alpha = 0.5)

# Option 3 (specify the common part of the two aesthetics, best compromise)
ggplot(CO2, aes(x = Type, y = uptake)) +
  geom_violin(aes(color = Treatment)) +
  geom_violin(alpha = 0.5)

# Example 2

# Option 1
ggplot(CO2, aes(x = conc, y = uptake, colour = Type, group = Plant)) +
  geom_line() +
  geom_smooth(group = NULL)

# Option 2
ggplot(CO2) +
  geom_line(aes(x = conc, y = uptake, group = Plant, colour = Type)) +
  geom_smooth(aes(x = conc, y = uptake, colour = Type))

# Option 3
ggplot(CO2, aes(x = conc, y = uptake, colour = Type)) +
  geom_line(aes(group = Plant)) +
  geom_smooth()


# Challenge 2

#' What’s gone wrong with this code? Why are the points not green and
#' transparency not correct?
ggplot(CO2, aes(x = conc, y = uptake, color = "green", alpha = 0.1)) +
  geom_point()

#' how to solve it?
#' in aes() only variables like column names!
#' Fixed values in correspondent geometry
ggplot(CO2, aes(x = conc, y = uptake)) +
  geom_point(color = "green", alpha = 0.1)


#' With so many points it is hard to see the effect of `treatment` or `type` on `uptake`, isn't it? A box plot ( `geom_boxplot()`) could help, but what's gone wrong here? The x , `conc`, doesn't make any sense
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment)) +
  geom_boxplot()

#' How to solve it?

#' SOLUTION 1
#' Make a factor of concentration (conc) via as.factor()
#' Notice that conc is now returned as factor so valeus are equally spaced
ggplot(CO2, aes(x = as.factor(conc), y = uptake, color = Treatment)) +
  geom_boxplot()

#' SOLUTION 2
#' group data by the combination of conc (as factor) and Treatment
#' Notice that conc valus on x are NOT equally spaced
ggplot(CO2, aes(x = conc,
                y = uptake,
                group = as.factor(conc):Treatment,
                color = Treatment)) +
  geom_boxplot()


#' How do you see the concentration `conc`?
#' As a categorical variable (= factor)? Or a quantitative variable? That's the key

# as quantitative variable
ggplot(CO2) +
  geom_col(aes(x = conc, y = uptake))

# as categorical variable
ggplot(CO2) +
  geom_col(aes(x = as.factor(conc), y = uptake))

# Challenge 3

#' Sometimes using colors, shapes, etc. is not
#' sufficient: you would like to split data in a grid of subplots to ease interpretation.
#'
#' How to modify this code to show data of each plant apart forming a grid of 12 subplots?
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment, shape = Type)) +
  geom_point()

ggplot(CO2, aes(x = conc, y = uptake, color = Treatment, shape = Type)) +
  geom_point() +
  facet_wrap(~ Plant) +
  theme(strip.text.x = element_text(size = 12))


#' The dataframe `area_biotopes` contains the average area (`meanArea`) and standard error (`seArea`) of 4 biotopes per year in the grid cells where two flinders species (Pararge aegeria and Limenitis camilla) were observed. This was done in Flanders (`FL`), South-Netherland (`NL_South`) en North-Netherland (`NL_North`).

area_biotopes <- read_csv("./data/20201124/20201124_area_biotopes.txt", na = "")

#' The plot on the left is unreadable
ggplot(area_biotopes,
            aes(x = year,
                y = meanArea,
                colour = species,
                shape = biotope,
                alpha = region)) +
  geom_pointrange(aes(ymin = meanArea - seArea,
                      ymax = meanArea + seArea))

#' The plot on the right is much better, isn't? Try to get something similar or even better!
library(INBOtheme)
ggplot(area_biotopes,
       aes(x = year,
           y = meanArea,
           colour = species)) +
  geom_pointrange(aes(ymin = meanArea - seArea,
                      ymax = meanArea + seArea)) +
  facet_grid(biotope ~ region,
             scales = "free") +
  geom_smooth(se = FALSE) +
  theme(strip.text = element_text(size = 10, face = "bold"))

# BONUS CHALLENGE

#' In challenge 1 we tried to understand the effect of `Type`  (`Quebec`, `Mississipi`) and `Treatment` (`chilled` , `nonchilled`) separately via box plots. Now we would like, still by means of a box plot, to see the effect of the interaction of these two variables together, so that we have four different situations (2 Type x 2 Treatment).

#' Using interaction() allows specifying the separator where needed
ggplot(CO2) +
  geom_boxplot(aes(x = conc,
                   y = uptake,
                   group = as.factor(conc):Type:Treatment,
                   color = interaction(Type, Treatment, sep = "-"))) +
  labs(x = "concentration", color = "Type-Treatment")

# You can use always interaction() of course
ggplot(CO2) +
  geom_boxplot(aes(x = conc,
                   y = uptake,
                   group = interaction(as.factor(conc), Type, Treatment),
                   color = interaction(Type, Treatment, sep = "-"))) +
  labs(x = "concentration", color = "Type-Treatment")
