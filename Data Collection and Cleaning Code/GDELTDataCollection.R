# Faiz Essa
# GDELT Data Collection
# April 18th, 2023

#### SETUP ####

rm(list=ls())

# importing packages 
library(tidyverse)
library(bigrquery)

# bigrquery setup
# authorize bigquery below if not authorized
# bq_auth(email = "faiz.essa@gmail.com")
billing <- "whatsappgdelt"

#### GDELT EVENTS ####

# sql query
sql <- 
  "SELECT ActionGeo_ADM2Code, EventRootCode, SQLDATE, COUNT(*) 
FROM `gdelt-bq.gdeltv2.events` 
WHERE (EventRootCode = '14'
OR EventRootCode = '18' 
OR EventRootCode = '19'
OR EventRootCode = '20')
AND (ActionGeo_CountryCode = 'IN')
AND Year >= 2015
GROUP BY ActionGeo_ADM2Code, EventRootCode, SQLDATE
"

# data import
gdelt.data <- bq_project_query(billing, sql)
gdelt.table <- bq_table_download(gdelt.data)

# saving raw data
write_rds(gdelt.table, "Data/GDELT/RawGDELT.rds")

#### GDELT GOV ATTITUDES ####

sql2 <- 
  "SELECT Actor1Geo_ADM2Code, SQLDATE, COUNT(*), SUM(AvgTone)
FROM `gdelt-bq.gdeltv2.events` 
WHERE (Actor1Geo_CountryCode = 'IN') AND (Year >= 2015)
  AND (Actor1Type1Code = 'GOV' OR Actor1Type2Code = 'GOV' OR Actor1Type3Code = 'GOV')
GROUP BY Actor1Geo_ADM2Code, SQLDATE
"

# data import
gdelt.data.2 <- bq_project_query(billing, sql2)
gdelt.table.2 <- bq_table_download(gdelt.data.2)

# saving raw data
write_rds(gdelt.table.2, "Data/GDELT/RawGDELTGovTone.rds")

#### GDELT OPPOSITION ATTITUDES ####

sql3 <- 
  "SELECT Actor1Geo_ADM2Code, SQLDATE, COUNT(*), SUM(AvgTone)
FROM `gdelt-bq.gdeltv2.events` 
WHERE (Actor1Geo_CountryCode = 'IN') AND (Year >= 2015)
  AND (Actor1Type1Code = 'OPP' OR Actor1Type2Code = 'OPP' OR Actor1Type3Code = 'OPP')
GROUP BY Actor1Geo_ADM2Code, SQLDATE
"

# data import
gdelt.data.3 <- bq_project_query(billing, sql3)
gdelt.table.3 <- bq_table_download(gdelt.data.3)

# saving raw data
write_rds(gdelt.table.3, "Data/GDELT/RawGDELTOppTone.rds")

