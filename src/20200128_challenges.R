library(tidyverse)

butterflycounts_df <- read_delim("./data/20200128_garden_butterfly_counts.csv", delim = ";")

## CHALLENGE 1



## CHALLENGE 2

# let's work with `distinct()`



# let's work with `summarize()`



## CHALLENGE 3

# 1. summarise() as in challenge 2 but now lets' do it for each species


# 2. Total number of individuals per species and month


## BONUS CHALLENGE

# In how many months per year and per garden did countings occur?
# months_garden <-

# Code for plotting (number of months column is here called n_months)
p <- ggplot(months_garden, aes(n_months)) +
  geom_histogram(bins = 13, binwidth = 0.75) +
  scale_x_continuous(breaks = seq(0, 13, 1)) +
  xlab("Number of months") +
  ylab("Number of gardens") +
  facet_wrap(~jaartal)
p


# Top month for each species



# Top 3 months for each species


