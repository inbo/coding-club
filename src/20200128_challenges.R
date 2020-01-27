library(tidyverse)

butterflycounts_df <- read_delim("./data/20200128_garden_butterfly_counts.csv",
                                 delim = ";")

## CHALLENGE 1





## CHALLENGE 2

# let's work with `distinct()`



# let's work with `summarise()`



## CHALLENGE 3

# 1. summarise() as in challenge 2 but now let's do it for each species


# 2. Number of individuals per species (tot_species)


# plot it! We used `total` for total number of individuals
ggplot(tot_species, aes(x = species, y = total)) +
  geom_bar(aes(reorder(species, total)), stat = "identity", fill = "darkred") +
  xlab("Species") +
  ylab("Total number of individuals") +
  theme_bw() +
  coord_flip()

# 3. Number of individuals per species and month (tot_species_month)



# plot it! We used `total` for total number of individuals
# x = species, y = total, facet =  month
ggplot(tot_species_month, aes(x = species, y = total)) +
  geom_col() +
  xlab("Species") +
  ylab("Number of individuals") +
  facet_wrap(~month, ncol = 2) +
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5, vjust = 0.5))

# plot it! x = month, y = total, facet = species
ggplot(tot_spec_month, aes(x = month, y = tot_individuals)) +
  geom_col() +
  xlab("Month") +
  ylab("Number of individuals") +
  facet_wrap(~species)

## BONUS CHALLENGE

# In how many months per year and per garden did countings occur?
# (months_garden)

# Plot it! We used column with number of months is called `n_months`
ggplot(months_garden, aes(n_months)) +
  geom_histogram(bins = 13, binwidth = 0.75) +
  scale_x_continuous(breaks = seq(0, 13, 1)) +
  xlab("Number of months") +
  ylab("Number of gardens") +
  facet_wrap(~year)

# Top month as number of individuals for each species



# Top 3 months as number of individuals for each species


# Species-month combinations of species with at least 4 months with over 2000
# individuals

