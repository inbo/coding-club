
# 20190124 - Challenge 3 - tidy data analysis

library(readr)
library(tidyverse)

# Read the experimental data:
main_experiment <- read_csv("../data/20190124/20190124_dryad_arias_hall_v3.csv",
                            col_types = cols())

# Untidy the columns
# ... Add your GATHER magic here ...
