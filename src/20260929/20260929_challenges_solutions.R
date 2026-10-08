## CHALLENGE 0 ####

# pak::pak("inbo/inbodb")
library(inbodb)
library(DBI)
library(dplyr)
library(glue)
inboveg <- connect_inbo_dbase("D0010_00_Cydonia")
florabank <- connect_inbo_dbase("D0152_00_Flora")
taxonlijsten <- connect_inbo_dbase("D0156_00_Taxonlijsten")
vis <- connect_inbo_dbase("W0001_10_Vis")

# CHALLENGE 1 ####

## 1.1 - 1.3 ####

# No R coding needed

## 1.4 ####
DBI::dbListFields(florabank, "Taxon")
DBI::dbListFields(inboveg, "ivRecording")
DBI::dbListFields(taxonlijsten, "Taxonlijst")

# CHALLENGE 2 ####

## 2.1 ####
obs <- inbodb::get_florabank_observations(
  florabank,
  names = c("Impatiens glandulifera", "Hydrocotyle ranunculoides"),
  collect = TRUE
)
obs

## 2.2 ####
ABS_LIM2011_recs <- get_inboveg_recording(
  inboveg,
  survey_name = "ABS-LIM2011",
  collect = TRUE
)
ABS_LIM2011_recs

## 2.3 ####
prov_lists <- inbodb::get_taxonlijsten_lists(
  taxonlijsten,
  # the % symbol means "no matter what is %before or after%
  list = "%provinciaal belangrijke soorten%",
  version = "latest",
  collect = TRUE
)
prov_lists

## 2.4 ####
features <- inbodb::get_taxonlijsten_features(
  taxonlijsten,
  list = "Provinciaal belangrijke soorten%",
  version = "latest",
  collect = TRUE
)
features

## 2.5 ####
limburg_taxa <- inbodb::get_taxonlijsten_items(
  taxonlijsten,
  # If you know the taxonlist name, you do not need to do a partial string match
  # with %%
  list = "Provinciaal belangrijke soorten - Limburg",
  version = "latest",
  collect = TRUE
)
limburg_taxa

## 2.6 ####
habitat_limburg_taxa <- inbodb::get_taxonlijsten_items(
  taxonlijsten,
  list = "Provinciaal belangrijke soorten - Limburg",
  feature = "HS",
  version = "latest",
  collect = TRUE
)
habitat_limburg_taxa


# INTERMEZZO 2 ####

obs <- inbodb::get_florabank_observations(
  florabank,
  names = c("Impatiens glandulifera", "Hydrocotyle ranunculoides")
)
obs %>% collect()

# INTERMEZZO 3 ####

# Read a whole table
dbReadTable(florabank, "Bron")

# Query a database using SQL
dbGetQuery(florabank, "SELECT ID, Code, Beschrijving FROM Bron")

# Compose a query using R-code and dplyr syntax
tbl(florabank, "Bron") |>
  select("ID", "Code", "Beschrijving") |>
  collect()

# CHALLENGE 3 ####

## 3.1 ####

# The SQL-based solution
dbGetQuery(
  florabank,
  "SELECT TOP 10 * FROM Taxon"
)

# Notice that you can pass the schema dbo, but it's not needed as it's the
# default table in SQL Server
dbGetQuery(
  florabank,
  "SELECT TOP 10 * FROM dbo.Taxon"
)

# This won't work because SQL Server doesn't support LIMIT
# Notice we used LIMIT in previous coding club
dbGetQuery(
  florabank,
  "SELECT * FROM Taxon LIMIT 10"
)

# The dplyr-based solution
tbl(florabank, "Taxon") %>%
  head(10) %>%
  collect()

# Alternative using a mix between the two types of syntax
tbl(
  florabank,
  # pass the SQL query in `sql()` function instead of passing the table
  dplyr::sql("SELECT TOP 10 * FROM Taxon")
) %>%
  collect()

## 3.2 ####

# The SQL-based solution
rotsvorkje_query <- "
  SELECT NaamWetenschappelijk
  FROM Taxon
  WHERE NaamNederlands = 'Rotsvorkje'
"

dbGetQuery(
  florabank,
  rotsvorkje_query
)

# The dplyr-based solution
tbl(florabank, "Taxon") %>%
  filter(NaamNederlands == 'Rotsvorkje') %>%
  select(NaamWetenschappelijk) %>%
  collect()

# Alternative using a mix between the two types of syntax
tbl(florabank, dplyr::sql(rotsvorkje_query)) %>%
  collect()

## 3.3 ####
get_sc_names <- function(dbase_connection, dutch_name) {
  dbGetQuery(
    dbase_connection,
    glue_sql(
      "
      SELECT NaamWetenschappelijk
      FROM Taxon
      WHERE NaamNederlands = {dutch_name}",
      dutch_name = dutch_name,
      .con = dbase_connection
    )
  )
}
get_sc_names(florabank, "Rotsvorkje")

## 3.4 ####
obs_kortsnuitzeepaardje_query <- "
  SELECT dw.WaarnemingID
    , dp.ProjectCode
    , dm.MethodeOmschrijving as Methodenaam
    , dv.VispuntOmschrijving as Gebiednaam
    , dv.VHAVispuntNaam as Waterloop
    , dv.VHAVispuntGemeente as Gemeente
    , dv.VHAVispuntBekkenNaam as Bekken
    , dd.Datum as [Date]
    , dd.Jaar as YearNumber
    , dt.NaamNL as Soort
	  , dt.NaamWET as Soort_Wet
    , fm.MetingTaxonAantal as TAXONAANTAL
    , fm.MetingTaxonGewicht as TAXONGEW
    , fm.MetingTaxonLengteTotaal as TAXONLEN
    FROM dbo.DimWaarneming dw
      INNER JOIN dbo.DimMethode dm ON dm.MethodeCode = dw.WaarnemingMethodeCode
      INNER JOIN dbo.DimDatum dd ON dd.DatumWID = dw.WaarnemingDatumWID
      INNER JOIN dbo.DimVispunt dv ON dv.VispuntID = dw.WaarnemingVispuntID
      INNER JOIN dbo.DimProject dp ON dp.ProjectWID = dw.WaarnemingProjectWID
      LEFT OUTER JOIN dbo.FactMeting fm ON fm.WaarnemingWID = dw.WaarnemingWID
      LEFT OUTER JOIN dbo.DimTaxon dt On dt.TaxonWID = fm.TaxonWID
    WHERE dt.NaamNL = 'kortsnuitzeepaardje'
      AND WaarnemingStatusCode in ( 'VLD', 'ENT' )
  "

obs_kortsnuitzeepaardje <- dbGetQuery(vis, obs_kortsnuitzeepaardje_query)

# Define function
get_fish_infos <- function(dbase_connection, dutch_name) {
  # Query template
  query <- glue_sql(
    "
    SELECT dw.WaarnemingID
    , dp.ProjectCode
    , dm.MethodeOmschrijving as Methodenaam
    , dv.VispuntOmschrijving as Gebiednaam
    , dv.VHAVispuntNaam as Waterloop
    , dv.VHAVispuntGemeente as Gemeente
    , dv.VHAVispuntBekkenNaam as Bekken
    , dd.Datum as [Date]
    , dd.Jaar as YearNumber
    , dt.NaamNL as Soort
	  , dt.NaamWET as Soort_Wet
    , fm.MetingTaxonAantal as TAXONAANTAL
    , fm.MetingTaxonGewicht as TAXONGEW
    , fm.MetingTaxonLengteTotaal as TAXONLEN
    FROM dbo.DimWaarneming dw
      INNER JOIN dbo.DimMethode dm ON dm.MethodeCode = dw.WaarnemingMethodeCode
      INNER JOIN dbo.DimDatum dd ON dd.DatumWID = dw.WaarnemingDatumWID
      INNER JOIN dbo.DimVispunt dv ON dv.VispuntID = dw.WaarnemingVispuntID
      INNER JOIN dbo.DimProject dp ON dp.ProjectWID = dw.WaarnemingProjectWID
      LEFT OUTER JOIN dbo.FactMeting fm ON fm.WaarnemingWID = dw.WaarnemingWID
      LEFT OUTER JOIN dbo.DimTaxon dt On dt.TaxonWID = fm.TaxonWID
    WHERE dt.NaamNL = {dutch_name}
      AND WaarnemingStatusCode in ( 'VLD', 'ENT' )
    ",
    dutch_name = dutch_name,
    .con = dbase_connection
  )
  # Run query
  dbGetQuery(
    dbase_connection,
    query
  )
}

# Use the function as many times as you wish
obs_kortsnuitzeepaardje_via_func <- get_fish_infos(
  vis,
  dutch_name = "kortsnuitzeepaardje"
)
obs_kortsnuitzeepaardje_via_func

# You can check that the two data frames are identical with `waldo::compare()`
waldo::compare(
  obs_kortsnuitzeepaardje,
  obs_kortsnuitzeepaardje_via_func
)

# Apply to another species, e.g. zeebaars
obs_zeebaars_via_func <- get_fish_infos(vis, dutch_name = "zeebaars")
obs_zeebaars_via_func


## 3.5 ####
obs_zeebaars_filtered_query <-
  "
  SELECT
      dw.WaarnemingID
    , dp.ProjectCode
    , dm.MethodeOmschrijving as Methodenaam
    , dv.VispuntOmschrijving as Gebiednaam
    , dv.VHAVispuntNaam as Waterloop
    , dv.VHAVispuntGemeente as Gemeente
    , dv.VHAVispuntBekkenNaam as Bekken
    , dd.Datum as [Date]
    , dd.Jaar as YearNumber
    , dt.NaamNL as Soort
	  , dt.NaamWET as Soort_Wet
    , fm.MetingTaxonAantal as TAXONAANTAL
    , fm.MetingTaxonGewicht as TAXONGEW
    , fm.MetingTaxonLengteTotaal as TAXONLEN
    , CONVERT( Decimal(18,3), cp.aantalDagen ) as AantalDagen
    , CONVERT( Decimal(18,3), cp.aantalFuiken ) as AantalFuiken
    FROM dbo.DimWaarneming dw
    OUTER APPLY OPENJSON( dw.WaarnemingCPUEParameters,'$' )
      WITH (
        aantalDagen float '$.NUMBER_DAYS',
        aantalFuiken float '$.FYKE_COUNT'
      ) cp
    INNER JOIN dbo.DimMethode dm ON dm.MethodeCode = dw.WaarnemingMethodeCode
    INNER JOIN dbo.DimDatum dd ON dd.DatumWID = dw.WaarnemingDatumWID
    INNER JOIN dbo.DimVispunt dv ON dv.VispuntID = dw.WaarnemingVispuntID
    INNER JOIN dbo.DimProject dp ON dp.ProjectWID = dw.WaarnemingProjectWID
    LEFT OUTER JOIN dbo.FactMeting fm ON fm.WaarnemingWID = dw.WaarnemingWID
    LEFT OUTER JOIN dbo.DimTaxon dt On dt.TaxonWID = fm.TaxonWID
    WHERE dt.NaamNL IN ('zeebaars')
    AND dd.Jaar IN ('2025')
    AND dp.ProjectCode IN ('Estuaria vnf13')
    AND dv.VHAVispuntNaam IN ('Zeeschelde', 'Rupel', 'Bovenschelde')
    AND dv.VHAVispuntBekkenNaam IN ('Beneden-Scheldebekken', 'Boven-Scheldebekken')
    AND WaarnemingStatusCode IN ( 'VLD', 'ENT' )
  "
obs_zeebaars_filtered <- dbGetQuery(vis, obs_zeebaars_filtered_query)

get_fish_infos2 <- function(
    dbase_connection,
    dutch_names,
    years,
    projects,
    watercourses,
    basins,
    obs_statuses) {
  query <- glue_sql(
    "
    SELECT
    dw.WaarnemingID
    , dp.ProjectCode
    , dm.MethodeOmschrijving as Methodenaam
    , dv.VispuntOmschrijving as Gebiednaam
    , dv.VHAVispuntNaam as Waterloop
    , dv.VHAVispuntGemeente as Gemeente
    , dv.VHAVispuntBekkenNaam as Bekken
    , dd.Datum as [Date]
    , dd.Jaar as YearNumber
    , dt.NaamNL as Soort
    , dt.NaamWET as Soort_Wet
    , fm.MetingTaxonAantal as TAXONAANTAL
    , fm.MetingTaxonGewicht as TAXONGEW
    , fm.MetingTaxonLengteTotaal as TAXONLEN
    , CONVERT( Decimal(18,3), cp.aantalDagen ) as AantalDagen
    , CONVERT( Decimal(18,3), cp.aantalFuiken ) as AantalFuiken
    FROM dbo.DimWaarneming dw
    OUTER APPLY OPENJSON( dw.WaarnemingCPUEParameters,'$' )
    WITH (
      aantalDagen float '$.NUMBER_DAYS',
      aantalFuiken float '$.FYKE_COUNT'
    ) cp
    INNER JOIN dbo.DimMethode dm ON dm.MethodeCode = dw.WaarnemingMethodeCode
    INNER JOIN dbo.DimDatum dd ON dd.DatumWID = dw.WaarnemingDatumWID
    INNER JOIN dbo.DimVispunt dv ON dv.VispuntID = dw.WaarnemingVispuntID
    INNER JOIN dbo.DimProject dp ON dp.ProjectWID = dw.WaarnemingProjectWID
    LEFT OUTER JOIN dbo.FactMeting fm ON fm.WaarnemingWID = dw.WaarnemingWID
    LEFT OUTER JOIN dbo.DimTaxon dt On dt.TaxonWID = fm.TaxonWID
    WHERE dt.NaamNL IN ({dutch_names*})
    AND dd.Jaar IN ({years*})
    AND dp.ProjectCode IN ({projects*})
    AND dv.VHAVispuntNaam IN ({watercourses*})
    AND dv.VHAVispuntBekkenNaam IN ({basins*})
    AND WaarnemingStatusCode IN ({obs_statuses*})
    ",
    dutch_names = dutch_names,
    years = years,
    projects = projects,
    watercourses = watercourses,
    basins = basins,
    obs_statuses = obs_statuses,
    .con = dbase_connection
  )
  # Run query
  dbGetQuery(
    dbase_connection,
    query
  )
}

# Use the function
obs_zeebaars_filtered_via_func <- get_fish_infos2(
  dbase_connection = vis,
  dutch_names = "zeebaars",
  years = "2025",
  projects = "Estuaria vnf13",
  watercourses = c("Zeeschelde", "Rupel", "Bovenschelde"),
  basins = c("Beneden-Scheldebekken", "Boven-Scheldebekken"),
  obs_statuses = c("VLD", "ENT")
)

obs_zeebaars_filtered_via_func

# You can check that the two data frames are identical with `waldo::compare()`
waldo::compare(
  obs_zeebaars_filtered,
  obs_zeebaars_filtered_via_func
)

## 3.6 ####
dbDisconnect(inboveg)
dbDisconnect(florabank)
dbDisconnect(taxonlijsten)
