library(tidyverse)

# Give a look at the CO2 dataset
str(CO2)

#' Plot `uptake` as function of `conc` using points



#' Distinguish by `Treatment` using points with different colors



#' and different shapes for `Type`



#'Change the y label to "CO2 uptake"



#' Add a title to the graph, e.g. "cold tolerance of the grass species Echinochloa crus-galli"



#' Use a logarithmic scale for the concentration



#' Set colors to "blue" for chilled plants and "indian red" for nonchilled





# Challenge 2

#' What’s gone wrong with this code? Why are the points not green and
#' transparency not correct?
ggplot(CO2, aes(x = conc, y = uptake, color = "green", alpha = 0.1)) +
  geom_point()

#' how to solve it?



#' With so many points it is hard to see the effect of `treatment` or `type` on `uptake`, isn't it? A box plot ( `geom_boxplot()`) could help, but what's gone wrong here? The x , `conc`, doesn't make any sense
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment)) +
  geom_boxplot()

#' How to solve it?





# Challenge 3A

#' Sometimes using colors, shapes, etc. is not
#' sufficient: you would like to split data in a grid of subplots to ease interpretation.
#'
#' How to modify this code to show data of each plant apart forming a grid of 12 subplots?
ggplot(CO2, aes(x = conc, y = uptake, color = Treatment, shape = Type)) +
  geom_point()



# Challenge 3B

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





# BONUS CHALLENGE

#' In challenge 1 we tried to understand the effect of `Type`  (`Quebec`, `Mississipi`) and `Treatment` (`chilled` , `nonchilled`) separately via box plots. Now we would like, still by means of a box plot, to see the effect of the interaction of these two variables together, so that we have four different situations (2 Type x 2 Treatment).


