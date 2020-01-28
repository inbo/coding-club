library(tidyverse)

butterflycounts_df <- read_delim("./data/20200128_garden_butterfly_counts.csv", delim = ";")

## CHALLENGE 1

head(butterflycounts_df)
str(butterflycounts_df)
glimpse(butterflycounts_df)
summary(butterflycounts_df)
nrow(butterflycounts_df)
ncol(butterflycounts_df)
# or both via dim()
dim(butterflycounts_df)
View(butterflycounts_df)

## CHALLENGE 2

# let's work with `distinct()`
butterflycounts_df %>% distinct(year)
butterflycounts_df %>% distinct(species)
butterflycounts_df %>% distinct(year, month)
butterflycounts_df %>% distinct(species, year)

# let's work with `summarize()`
butterflycounts_df %>%
  summarise(n_distinct_gardens = n_distinct(id_garden),
            min_year = min(year),
            max_year = max(year),
            n_years = n_distinct(year),
            min_counts = min(n_individuals),
            max_counts = max(n_individuals),
            mean_counts = mean(n_individuals))


## CHALLENGE 3

# 1. summarise() as in challenge 2 but now lets' do it for each species

butterflycounts_df %>%
  group_by(species) %>%
  summarise(n_distinct_gardens = n_distinct(id_garden),
            min_year = min(year),
            max_year = max(year),
            n_years = n_distinct(year),
            min_counts = min(n_individuals),
            max_counts = max(n_individuals),
            mean_counts = mean(n_individuals))

# 2. Number of individuals per species (tot_species)
tot_species <- butterflycounts_df %>%
  group_by(species) %>%
  summarize(total = sum(n_individuals))
tot_species

# plot it! We used `total` for total number of individuals
ggplot(tot_species, aes(x = species, y = total)) +
  geom_bar(aes(reorder(species, total)), stat = "identity", fill = "darkred") +
  xlab("Species") +
  ylab("Total number of individuals") +
  theme_bw() +
  coord_flip()

# 3. Number of individuals per species and month (tot_species_month)
tot_species_month <- butterflycounts_df %>%
  group_by(species, month) %>%
  summarize(total = sum(n_individuals))
tot_species_month

# plot it! We used `total` for total number of individuals
# x = species y = total, facet =  month
ggplot(tot_species_month, aes(x = species, y = total)) +
  geom_col() +
  xlab("Species") +
  ylab("Number of individuals") +
  facet_wrap(~month, ncol = 2) +
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5, vjust = 0.5))

# plot it! x = month, y = total, facet = species
ggplot(tot_species_month, aes(x = month, y = total)) +
  geom_col() +
  xlab("Month") +
  ylab("Number of individuals") +
  facet_wrap(~species)


## BONUS CHALLENGE

# In how many months per year and per garden did countings occur?
months_garden <- butterflycounts_df %>%
  group_by(year, id_garden) %>%
  distinct(month) %>%
  summarise(n_months = n())

# Plot it! Column with number of months: `n_months`
ggplot(months_garden, aes(n_months)) +
  geom_histogram(bins = 13, binwidth = 0.75) +
  scale_x_continuous(breaks = seq(0, 13, 1)) +
  xlab("Number of months") +
  ylab("Number of gardens") +
  facet_wrap(~year)

# Top month of each species
tot_species_month %>%
  group_by(species) %>%
  filter(total == max(total)) %>%
  select(month)

# Top 3 months of each species
tot_species_month %>%
  group_by(species) %>%
  arrange(desc(total)) %>%
  top_n(3, total) %>%
  arrange(species)

# All species with at least 4 months with over 2000 individuals
tot_species_month %>%
  group_by(species) %>%
  filter(total > 2000) %>%
  filter(n_distinct(month) >= 4)

# Be careful with group_by and filter: the following will not be the same!!
tot_species_month %>%
  group_by(species) %>%
  filter(total > 2000,
         n_distinct(month) >= 4)
