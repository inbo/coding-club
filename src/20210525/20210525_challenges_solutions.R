library(tidyverse)
library(tidylog)

load("./data/20210525/20210525_data.Rda")

# 1. How to add orcid information to coding club core team dataframe (where available)?
left_join(coding_club_core_team, bmk_team, by = "name")

# or using pipe `%>%`
coding_club_core_team %>%
  left_join(bmk_team, by = "name")

# you can omit `by = "name"` in this case as all join functions automatically
# join by columns called with the same name.


# 2. How are the columns ordered? Are the columns of coding_club_core_team on the left? Try to get same result but putting them on the right
bmk_team %>%
  right_join(coding_club_core_team, by = "name")

# 3. Join coding club core team with BMK team and retain only people who are part of both.
coding_club_core_team %>%
  inner_join(bmk_team, by = "name")

# 4. How to invert the order of the columns?
bmk_team %>%
  inner_join(coding_club_core_team, by = "name")

# 5. Now, join both again but retain ALL people
coding_club_core_team %>%
  full_join(bmk_team, by = "name")


## INTERMEZZO

# In 5 of 1st challenge, we do not only add columns (_variables_), but also rows
# (_cases_). Why cannot we do it then by functions which combine rows?


# try this?
union_all(coding_club_core_team, bmk_team)

# or this?
union(coding_club_core_team, bmk_team)

# or this?
bind_rows(coding_club_core_team, bmk_team)


## CHALLENGE 2

# 1. distribution data.frames from Belgium, Netherlands and Luxembourg should not overlap. How can you check it? There are several ways to do it, but try to use the appropriate combining technique, which is likely the shortest way as well

intersect(distribution_BE, distribution_NL) %>% nrow
intersect(distribution_BE, distribution_LU) %>% nrow
intersect(distribution_NL, distribution_LU) %>% nrow

# check right number rows
nrow(distr_all) ==  nrow(distribution_BE) + nrow(distribution_LU) + nrow(distribution_NL)

# 2. Merge distributions from Belgium, Netherlands and Luxembourg into a
# data.frame called `distribution`
distribution <- bind_rows(distribution_BE,
                          distribution_NL,
                          distribution_LU)


# 3. Check that all taxa in vernacularname point to taxa in taxon df.
vernacularname %>%
  anti_join(taxon, by = c("taxon_id"= "id"))


# 4. Which taxa do not have vernacular names?
taxon %>%
  anti_join(vernacularname, by = c("id" = "taxon_id"))

## CHALLENGE 3

#' 1. Add `vernacularname` information to `taxon`. Save the result as new df
#' called `extended_taxon`. What happens to columns with the same
#' name? Distinguish them by adding suffix "_taxon" to the column(s) from
#' `taxon`, and "_distribution" to the colum (s) from `distribution`. Save
#' result in new variable called `extended_taxon`

extended_taxon <-
  taxon %>%
  left_join(vernacularname, by = c("id" = "taxon_id"), suffix = c("_taxon", "_distribution"))

# in this specific case this also works: all taxa in vernacularnames are also in
# taxon
extended_taxon <-
  taxon %>%
  full_join(vernacularname,
            by = c("id" = "taxon_id"),
            suffix = c("_taxon", "_distribution"))


#' 2. Add `distribution` to `extended_taxon` and retain only the taxa found in
#' Belgiumn, Netherlands or Luxembourg, i.e. only taxa in `distribution`

extended_taxon <-
  extended_taxon %>%
  right_join(distribution, by = c("id" = "taxon_id"))


#' 3. Dirk points to East, he wants to include butterfly data from the Balcans.
#' His dear Albanian colleagues sent him an Albanian national list based on the
#' same format as the Belgian/Dutch/Luxembourg ones. He got three file:
#' `taxon_AL`, `distribution_AL` and `vernacularname_AL`.
#' Which species are found only in Albania? And which one in West Europe
#' (`taxon`) but not in Albania?
taxon_AL %>% setdiff(taxon)
taxon %>% setdiff(taxon_AL)


# 4. Which species are found both in Albania (`taxon_AL`) and in West-Europe?
taxon_AL %>% intersect(taxon)


# 5. Help him to merge `taxon_AL`,  `distribution_AL` and `vernacularname_AL` to
# `taxon`, `distribution` and `vernacularname` respecitvely

taxon_with_AL <- taxon %>% union(taxon_AL)
distribution_with_AL <- distribution %>% union(distribution_AL)
# as national distributions are not overlapping sets, bind_rows() can be used as
# well
vernacularname_with_AL <- vernacularname %>% bind_rows(vernacularname_AL)
