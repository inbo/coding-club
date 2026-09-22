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



# CHALLENGE 2 ####

## 2.1 ####



## 2.2 ####



## 2.3 ####



## 2.4 ####



## 2.5 ####



## 2.6 ####



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



## 3.2 ####



## 3.3 ####



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





## 3.5 ####
obs_zeebaars_filtered <-
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



## 3.6 ####

