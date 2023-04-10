# Faiz Essa
# GDELT Data Collection
# April 7th, 2023

#### SETUP ####

rm(list=ls())

# importing packages 
library(tidyverse)
library(bigrquery)

# bigrquery setup
# authorize bigquery below if not authorized
# bq_auth(email = "faiz.essa@gmail.com")
billing <- "whatsappgdelt"

#### DATA DOWNLOAD ####

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

