library(tidyverse)
library(lubridate)

# read data
persian_hogweed <- read_tsv("./data/20230126/20230126_persian_hogweed_2022_scandinavia.txt")


## CHALLENGE 1




## CHALLENGE 2

# Read deployments. ISO datetimes are immediately interpreted as datetimes
deployments <- readr::read_csv(
  "./data/20230126/20230126_deployments.txt",
  na = ""
)
deployments$start
deployments$end





## CHALLENGE 3





## BONUS CHALLENGES - strings





## BONUS CHALLENGES - dates

# read data of Phlogophora meticulosa
pheno_phlogo <- readr::read_delim(
  file = "./data/20230126/20230126_pheno_phlogo.txt",
  delim = ";"
)
head(pheno_phlogo)

# add year and week number
pheno_phlogo$year <- lubridate::year(pheno_phlogo$datum)
pheno_phlogo$week <- lubridate::week(pheno_phlogo$datum)
head(pheno_phlogo)

# define periods
pheno_phlogo <- pheno_phlogo %>%
  mutate(Period = case_when(year >= 1980 & year <= 2012 ~ "2003_2012",
                            year >= 2013 & year <= 2022 ~ "2013_2022"))
head(pheno_phlogo)

df_pheno_plot <- pheno_phlogo %>%
  dplyr::group_by(species_nl, Period, week) %>%
  dplyr::summarise(nObs = n())
head(df_pheno_plot)

df_sum_species <- df_pheno_plot %>%
  dplyr::group_by(species_nl, Period) %>%
  dplyr::summarise(sum = sum(nObs))
head(df_sum_species)

df_pheno_plot <- dplyr::inner_join(df_pheno_plot,
                                   df_sum_species,
                                   by = c("species_nl", "Period")) %>%
  dplyr::select(species_nl,
                Period,
                week,
                nObs,
                sum)

head(df_pheno_plot)

df_pheno_plot <- df_pheno_plot %>%
  dplyr::mutate(pObs = 100*nObs/sum)
df_pheno_plot

cbbPalette <- c("#000000", "#E69F00")

## plot
p <- ggplot(df_pheno_plot,
            aes(x = week,
                y = pObs,
                fill = Period)) +
  geom_bar(stat = "identity",
           position = position_dodge(width = 0.9)) +
  xlab("Month") +
  ylab("observations (%)") +
  scale_fill_manual(values = cbbPalette)
p
