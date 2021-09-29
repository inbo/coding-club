library(tidyverse)

#' 1. Plot length of odontoblasts, (`len`) as function of the supplement
#' (`supp`) using points
ggplot(data = ToothGrowth, ) +
  geom_point(aes(x = supp, y = len))


#' Plot length of odontoblasts (`len`) as function of the dose (`dose`) using
#' points
ggplot(data = ToothGrowth, ) +
  geom_point(aes(x = dose, y = len))



#' 3. Starting from 2, distinguish `supp` using points with different colors and
#' different shapes
ggplot(data = ToothGrowth, ) +
  geom_point(aes(x = dose, y = len, color = supp, shape = supp))


#' 4. Starting from 3, change the y-axis label to "length (mm)", change the
#' x-axis label to "dose (mg/day)", change the color/shape legend title to "supplement" and add a title to the graph, e.g. "The
#' Effect of Vitamin C on Tooth Growth in Guinea Pigs". Hint: check what [`labs()`](https://ggplot2.tidyverse.org/reference/labs.html) can do for you!
ggplot(data = ToothGrowth, ) +
  geom_point(aes(x = dose, y = len, color = supp, shape = supp)) +
  labs(title = "The Effect of Vitamin C on Tooth Growth in Guinea Pigs",
       color = "supplement",
       shape = "supplement",
       x = "dose (mg/day)",
       y = "length (mm)")


#' 5. Starting from 4 (or 3 if 4 not solved), set colors to "blue" for orange
#' juice supplemnet ("OJ") and "indian red" for vitamine C ("VC")
ggplot(data = ToothGrowth, ) +
  geom_point(aes(x = dose, y = len, color = supp, shape = supp)) +
  labs(title = "The Effect of Vitamin C on Tooth Growth in Guinea Pigs",
       color = "supplement",
       shape = "supplement",
       x = "dose (mg/day)",
       y = "length (mm)") +
  # this is the most general way to set colors, by using a named vector
  scale_color_manual(values = c(OJ = "blue", VC = "indian red"))


# INTERMEZZO. Aesthetics

#' This works:

ggplot(ToothGrowth, aes(x = dose, y = len, color = supp)) + geom_violin()

#' This works too

ggplot(ToothGrowth) +
  geom_violin(aes(x = dose, y = len, color = supp))

#' What should I use? Both are good, but, but, but...
#' But what if you want to plot two or more geometries with different
#' aesthetics? Which syntax is more readable?

# Example 1

# Option 1 (make changes to aesthetics of second geomtry, less readable)
ggplot(ToothGrowth, aes(x = dose, y = len, color = supp)) +
  geom_violin() +
  geom_violin(aes(color = NULL), alpha = 0.5)

# Option 2 (specify both aesthetics separately, maybe redundant)
ggplot(ToothGrowth) +
  geom_violin(aes(x = dose, y = len, color = supp)) +
  geom_violin(aes(x = dose, y = len), alpha = 0.5)

# Option 3 (specify the common part of the two aesthetics, best compromise)
ggplot(ToothGrowth, aes(x = dose, y = len)) +
  geom_violin(aes(color = supp)) +
  geom_violin(alpha = 0.5)

# Example 2 (using CO2 dataset) not shown during the coding club

# Option 1
ggplot(CO2, aes(x = conc, y = uptake, colour = Type, group = Plant)) +
  geom_line() +
  geom_smooth(aes(group = NULL))

# Option 2
ggplot(CO2) +
  geom_line(aes(x = conc, y = uptake, group = Plant, colour = Type)) +
  geom_smooth(aes(x = conc, y = uptake, colour = Type))

# Option 3
ggplot(CO2, aes(x = conc, y = uptake, colour = Type)) +
  geom_line(aes(group = Plant)) +
  geom_smooth()



## CHALLENGE 2

#' 1. What’s gone wrong with this code? Why are the points not red and
#' transparency not correct? How to solve it?
ggplot(ToothGrowth, aes(x = dose, y = len, color = "blue", alpha = 0.3)) +
  geom_point()

#'  Solution: color and transparency are constants. Constants are out of the
#'  aesthetics
ggplot(ToothGrowth, aes(x = dose, y = len)) +
  geom_point(color = "blue", alpha = 0.3)

#' In plots With so many points it is hard to see the effect of `supp` on
#' `len`, isn't it? A box plot ( `geom_boxplot()`) could help, but what's
#' gone wrong here? The x , `dose`, doesn't make any sense.
#' Hint: look at the examples in the help file of ?geom_boxplot
ggplot(ToothGrowth, aes(x = dose, y = len, color = supp, group = supp)) +
  geom_boxplot()

ggplot(ToothGrowth,
       aes(x = dose, y = len, color = supp, group = as.factor(dose):supp)) +
  geom_boxplot()

#' Let's work with growth of orange trees from dataset `Orange`. A point plot is
#' sometimes difficult to understand, see left image. How to get a nice smoother
#' for all trees and for each tree apart as shown in the right figure? 
#' Do not show standard error for the smoothers at tree level, reorder the tree 
#' numbers in Legend at increasing order.
ggplot(Orange) +
  geom_point(aes(x = age, y = circumference, color = Tree))

Orange$Tree <- factor(Orange$Tree, levels = c(1:5))

ggplot(Orange) +
  geom_smooth(aes(x = age, y = circumference, color = Tree, group = Tree),
              size = 1,
              se = FALSE) +
  geom_smooth(aes(x = age, y = circumference), color = "red", size = 2)


## CHALLENGE 3

#' Sometimes using colors or shapes  is not sufficient: you would like to
#' split data in a grid of subplots. How to plot the
#' growth of each tree as a different subplot as shown in the figure below?

ggplot(Orange) +
  geom_smooth(aes(x = age, y = circumference)) +
  facet_wrap(~ Tree, nrow = 1)

#' How to get `"Tree 1"`, `"Tree 2"`, `"Tree 3"`, etc. above each subplot
#' instead of  `1`, `2`, `3`, etc.?

# use the very handy and versatile arg labeller and the function label_both
ggplot(Orange) +
  geom_smooth(aes(x = age, y = circumference)) +
  facet_wrap(~ Tree, nrow = 1, labeller = label_both)


#' After transforming  `HairEyeColor` to a data.frame, try to best show the
#' difference among males and females for all different combinations of hair-eye
#' color. Here below one possible way
hair_eye_color_df <- as.data.frame(HairEyeColor)

# Use INBO colors
library(INBOtheme) # install it first, if still not done yet: remotes::install_github("inbo/INBOtheme")

ggplot(hair_eye_color_df) +
  geom_col(aes(x = Hair, y = Freq, fill = Sex), position = "dodge") +
  facet_wrap(~ Eye, labeller = label_both)


## BONUS CHALLENGE

#' Using `airquality` dataset, how to plot each air quality variables (`Ozone`,
#' `Solar.R`, `Wind` and `Temp`) as function of the date (`month`- `day`
#' combination) with a smoother on top of it as shown in the figure below?
#' Think about the best way to display the y-axis scale(s) of the subplots. Note
#' that the code to combine `month` and `day` to a variable called `date` is
#' already provided, see code below. Hint: `ggplot2` alone could be not enough,
#' you could opt for combining `ggplot2` with another `tidyverse` package.

airquality$date <- lubridate::as_date(paste("1973",
                                            paste(airquality$Month,
                                                  airquality$Day,
                                                  sep = "-"),
                                            sep = "-"))

airquality_new <- tidyr::pivot_longer(airquality,
                                      cols = c("Ozone", "Solar.R", "Wind", "Temp"),
                                      names_to = "variable",
                                      values_to = "value")

# Check how the data have been reshaped
head(airquality_new)

ggplot(airquality_new, aes(x = date, y = value)) +
  geom_line() +
  geom_smooth() +
  facet_wrap(~ variable, scales = "free_y")
