
library(DBI)
library(odbc)
library(tidyverse)

# Challenge 1: ----
# Install/ and load the inborutils package
# Use the `connect_inbo_dbase` function from the inborutils package to
# connect to the database "W0003_00_Lims" or "D0021_00_userFlora".

# YOUR CODE...
con <- connect_inbo_dbase(database_name = "D0021_00_userFlora")


# Challenge 2: ----
# Connect to the database `W0003_00_Lims`
# Get first 10 rows of the table `vwDocumentatie`.
# Create a query to get the unique values of the `name` column.
# Get from table `vwDocumentatie` the documentation by filtering those rows
# where the `name` is equal to 'Description'.
#

# YOUR CODE...



# Challenge 3: ----
# We have a custom query available to get the scienticname from 'Gebogen kransblad'
# and want to reuse the query later on for other species...
#
# Create a function called `userflora_query_scientificname`
# the function has two input arguments: a connection and a dutch plant name
# the function returns the corresponding scientificname of userflora

# (install the glue library if not yet available (`install.packages('glue')`)
library(glue)

custom_query <- "
  SELECT NaamWetenschappelijk
  FROM dbo.tblTaxon
  WHERE NaamNederlands = 'Gebogen kransblad'
  "

# YOUR CODE...


