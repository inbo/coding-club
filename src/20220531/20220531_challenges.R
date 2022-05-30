library(tidyverse)
library(tidylog)

load("./data/20220531/20220531_data.Rdata")

# Challenge 1
#############

# 1. Make an overview of the number of observations in each WBE and call it *table1* (recap of last class; use group_by and summarize).

# 2. Add province, WBE name, and surface area to *table1* (where available)?

# 3. How are the columns ordered? Are the columns of *table1* on the left? Try to get the same result but putting them on the right.

# 4. Some observations have a missing value for column `wbe` and some WBE did not count at all. Join both *table1* and *WBE* and retain only WBE who are part of both.

# 5. How to invert the order of the columns?

# 6. Now, join both again but retain ALL EXISTING WBE. use the dplyr function `replace_na` to show a zero for those WBE that have not observed any partridges.



# Challenge 2
#############

# 1. Distributions from Belgium, Netherlands and Luxembourg should not overlap. How can you check it? There are several ways to do it, but try to use a data joining technique, which is likely the shortest and more readable way

# 2. Merge the three `distribution_*` dataframes into a data.frame called `distribution`

# 3. Check that all taxa in `vernacularname` point to taxa in `taxon`

# 4. Which taxa in `taxon` do not have vernacular names?


# Challenge 3
############

# 1. Add `vernacularname` information to `taxon`. Save the result as a new df called `extended_taxon`. What happens to columns with the same name?
#  Distinguish them by adding suffix "_taxon" to the column(s) from `taxon`, and
#"_distribution" to the column(s) from `distribution`.

# 2. Add `distribution` to `extended_taxon` and retain only the
#taxa found in Belgium, Netherlands or Luxembourg, i.e. only taxa in `distribution`

# 3. Dirk points to East, he wants to include butterfly data from the Balcans.
# His dear Albanian colleagues send him an Albanian national
# list based on the same format as the Belgian/Dutch/Luxembourg ones. He got three files: `taxon_AL`,
# `distribution_AL` and `vernacularname_AL`. Which species are found only in Albania? And which one in West Europe (`taxon`) but not in Albania?

# 4. Which species are found both in Albania (`taxon_AL`) and in West-Europe?

# 5. Help him to merge `taxon_AL`,  `distribution_AL` and `vernacularname_AL` to `taxon`, `distribution` and `vernacularname` respecitvely



