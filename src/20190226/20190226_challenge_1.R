library(tidyverse)
library(sf)
library(rgbif)

# download GBIF occurrences of Chinese mitten crab (Eriocheir sinensis) in
# Belgium with valid coordinates
key <- "0043019-181108115102211"
crab_zipfile <- occ_download_get(key,
                                 path = "../data/",
                                 overwrite = TRUE)

# unzip only occurrence file
crab_occs <- paste0(key, ".csv")
unzip(zipfile = crab_zipfile, files = crab_occs, exdir = "../data/.")

# read file in R as data.frame
crab_df <- read_tsv(paste0("../data/", crab_occs))

