
library(tidyverse)

# check that:
# your dbplyr version is 1.4.1 or higher and
# dplyr version is 0.8.1 or higher with this code below:
tidyverse_deps() %>%
  filter(package %in% c("dbplyr", "dplyr"))
# if not, restart the R session and install tidyverse with:
# install.packages("tidyverse")
# library(tidyverse)

# Challenge 1: -----

# (Install and) load the inborutils package
library(inborutils)
# Use the `connect_inbo_dbase` function from the inborutils package to
# connect to the database "D0021_00_userFlora"
con <- connect_inbo_dbase(database_name = "D0021_00_userFlora")

# connect to taxon table `tblTaxon`
taxon <- tbl(con, from = "tblTaxon")
class(taxon)
# Get the names of the columns in `taxon`
# Get preview first 10 rows of `taxon`
# Get the first 10 Dutch names in `taxon`
# How many taxa are in `taxon` data.frame?
# Get the first 10 Dutch names in `taxon` as a "normal" data.frame
# (tip: check https://dbplyr.tidyverse.org/)
# Get the scientific name of 'Geel schorpioenmos'
# YOUR CODE...




# Challenge 2: -----
# We found in Challenge 1 how to get the scientific name
# of 'Geel schorpioenmos'. We want to reuse the query later on for other
# species...
# Complete the function called `userflora_query_scientificname` to do it. The
# function has two input arguments: a connection to a table and a dutch plant
# name. The funcion returns the corresponding scientificname
userflora_dutch_to_scientificname <- function(table, dutchname) {
  table %>%
    # YOUR CODE ...

}

# test your function:
taxon %>%
  userflora_dutch_to_scientificname("Aardappel")
taxon %>%
  userflora_dutch_to_scientificname("Donker glanswier")

# Try to extend the function `userflora_dutch_to_scientificname` to work on
# partial matches, i.e. search for all taxa CONTAINING the input dutch plant
# name in column `NaamNederlands`. For example, searching
# all dutch names containing the string `sterkranswier`.
# Tip: see https://dbplyr.tidyverse.org/articles/sql.html
userflora_dutch_to_scientificname_extended <- function(table, dutchname) {
  table %>%
    # YOUR CODE ...

}

# test your function
taxon %>%
  userflora_dutch_to_scientificname_extended("sterkranswier")
taxon %>%
  userflora_dutch_to_scientificname_extended("kalkmos")



# Challenge 3: -----
# Get taxon groups: table `tblTaxonGroep`
taxongroup <- tbl(con, from = "tblTaxonGroep")
taxongroup
# Get relationship between the groups and the taxa in `taxon`
rel_taxon_taxongroup <- tbl(con, from = "relTaxonTaxonGroep")
rel_taxon_taxongroup

# Try to add the group name (Naam) to `taxon`
# Try also to count how many taxa are in each group
# YOUR CODE ...
