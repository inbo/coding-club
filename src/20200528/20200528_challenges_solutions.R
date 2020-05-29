library(tidyverse)
# To use INBO style and colors in plots. Install via
# devtools::install_github("inbo/INBOtheme")
library(INBOtheme)

## CHALLENGE 1

# Compute the mean of every column in swiss.

swiss

# Initialize an output vector we call means
means <- vector("double", ncol(swiss))
# Calculate the means of each column and assign them to each slot of means
# seq_along(variable) is a "safe" version of the familiar 1:length(variable).
# See https://r4ds.had.co.nz/iteration.html#for-loops for more details
for (i in seq_along(swiss)) {
  means[[i]] <- mean(swiss[[i]])
}
# Show result
means

# You can save them as a named list instead of a vector using swiss column names
means_list <- list()
for (col_name in names(swiss)) {
  means_list[[col_name]] <- mean(swiss[[col_name]])
}
# Show result
means_list


# Determine the type of each column in iris.

iris

# In this case the output vector is of type character as the type of a column is
# a character
types <- vector("character", ncol(iris))
for (i in seq_along(iris)) {
  types[[i]] <- class(iris[[i]])
}
types

# output as a list
types_list <- list()
for (col_name in names(iris)) {
  types_list[[col_name]] <- class(iris[[col_name]])
}
types_list


# Compute the number of unique values in each column of iris.

# If you want to print them on screen (e.g. for quick data exploration)
for (i in seq_along(iris)) {
  print(unique(iris[[i]]))
}

# If you want to use those values then you can save them as a list
unique_iris <- list()
for (i in names(iris)) {
  # Notice how we can use the column names to name list elements
  unique_iris[[i]] <- unique(iris[[i]])
}
unique_iris

# Generate 10 random normals (rnorm(n = 10)) from distributions with means of
# -10, 0, 10, and 100.

random_normals <- list()
means <- c(-10, 0, 10, 100)
for (i in means) {
  # to use numbers as names of list elements, you need to convert them to
  # characters via as.character()
  random_normals[[as.character(i)]] <- rnorm(n = 10, mean = i)
}
print(random_normals)



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

years <- 2010:2019 # define the years we are interested to
for (year in years) {
  year_births_plot <-
    births %>%
    # filter based on a specific year
    filter(year == year) %>%
    ggplot() +
    geom_col(mapping = aes(x = month, y = n_births)) +
    ylab("Number of births") +
    coord_flip() +
    # Use year value to udpate title
    ggtitle(paste0("Number of births - ", year))
  # Adapt the filename as well by updating the year
  year_births_plot + ggsave(filename = paste0("./n_births_belgium_",
                                              year,
                                              ".png"),
                            year_births_plot,
                            device = "png")
}

# Check the files you have just generated in your project root...



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

age <- 0
reproduction <- FALSE
food <- ""
enemy <- "safe"
while (!food %in% c("starving", "poison") & # fox is not killed by poison or starvation
       enemy == "safe" & # fox is not killed by predators or parasites
       age < 10 & # fox is not too old (10 years old foxes die)
       reproduction == FALSE) { # fox didn't succeed to reproduce (goal of the game)
  # Play with the slot machine
  food <- sample(foods, size = 1) # random food value
  enemy <- sample(enemies, size = 1) # random enemy value
  reproduction <- sample(reproductions, size = 1) # random repoduction value
  print(paste0("Food: ", food,
               "; enemy: ", enemy,
               "; reproduction: ", reproduction))
  age <- age + 1 # After play fox is one year older
}

# Communicate the end result (this part is just to better communicate the result
# of the game)
if (reproduction == TRUE) {
  print(paste0("The fox succeeded to reproduce when she was ",
               age - 1,
               " year(s) old."))
} else {
  if (age == 10) {
    print("The fox died. It was old.")
  } else  {
    if (food %in% c("poison", "starvation")) {
      print("The fox has been poisoned.")
    }
    if (enemy != "safe") {
      print(paste0("The fox has been killed by a ", enemy, "."))
    }
  }
}

# PART 2. Extend the game to a population of 10 foxes. How many foxes succeeded
# to reproduce?

n_success <- 0 # Initialize number of foxes which succeeded to reproduce
for (i in 1:10) {
  # Reset the "slot machine" (= new fox) by initialize the "slot" values
  reproduction =  FALSE
  food = ""
  enemy = "safe"
  age <- 0 # A new fox is 0 year old
  while (!food %in% c("starving", "poison") &
         enemy == "safe" &
         age < 10 &
         reproduction == FALSE) {
    # Let's play to the Fox Slot machine
    food <- sample(foods, size = 1)
    enemy <- sample(enemies, size = 1)
    reproduction <- sample(reproductions, size = 1)
    # The fox becomes one year older
    age <- age + 1
  }
  if (reproduction == TRUE) {
    n_success <- n_success + 1 # Update number of successes
  }
}

print(paste0(n_success, " foxes succeeded to reproduce. ",
             "Thanks for playing to the Fox slot machine."))
