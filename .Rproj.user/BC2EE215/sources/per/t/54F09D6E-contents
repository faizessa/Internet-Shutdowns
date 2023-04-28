# Faiz Essa
# Cleaning Data for Descriptive Analysis Section
# April 26th, 2023

#### SETUP ####
rm(list=ls())

# importing packages 
library(tidyverse)
library(readxl)
library(countrycode)

# importing data
ShutdownData2022 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 1)             
ShutdownData2021 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 2)
ShutdownData2020 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 3)
ShutdownData2019 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 4)
ShutdownDataPre19 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 5) 

#### DATA WRANGLING pre-19 data ####

ShutdownDataPre19 <- ShutdownDataPre19 %>%
  select(start_date, duration_days, country, geo_scope, shutdown_type_group) %>%
  rename(duration = duration_days) %>%
  mutate(geo_scope = tolower(geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == "multi-regional", "regional", geo_scope)) %>%
  mutate(geo_scope = ifelse(!(geo_scope %in% c("local", "regional", "national")),
                            NA, geo_scope)) %>%
  mutate(shutdown_type_group = tolower(shutdown_type_group)) %>%
  mutate(shutdown_type_group = ifelse(!(shutdown_type_group %in% c("full network", 
                                                           "service-based",
                                                           "full and service-based")),
                                  NA, shutdown_type_group)) %>%
  rename(shutdown_extent = shutdown_type_group)
  
#### DATA WRANGLING 2019 data ####
ShutdownData2019 <- ShutdownData2019 %>%
  select(start_date, duration, country, geo_scope, "full or service-based") %>%
  mutate(geo_scope = tolower(geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == "level 1", "local", geo_scope),
         geo_scope = ifelse(geo_scope == "level  2", "regional", geo_scope),
         geo_scope = ifelse(geo_scope == "level 3", "national", geo_scope)) %>%
  mutate(geo_scope = ifelse(!(geo_scope %in% c("local", "regional", "national")),
                            NA, geo_scope)) %>%
  rename(shutdown_extent = "full or service-based") %>%
  mutate(shutdown_extent = tolower(shutdown_extent)) %>%
  mutate(shutdown_extent = ifelse(shutdown_extent == "full",
                                  "full network", shutdown_extent)) %>%
  mutate(shutdown_extent = ifelse(!(shutdown_extent %in% c("full network",
                                                           "service-based", 
                                                           "full and service-based")), 
                                  NA, shutdown_extent)) 
#### DATA WRANGLING 2020 data ####
ShutdownData2020 <- ShutdownData2020 %>% 
  select(start_date, country, area_name, geo_scope, shutdown_extent) %>%
  mutate(area_name = tolower(area_name)) %>%
  mutate(shutdown_extent = tolower(shutdown_extent)) %>%
  mutate(geo_scope = tolower(geo_scope)) %>%
  mutate(geo_scope = ifelse(area_name %in% c("national", "nationwide", "nation wide"), 
      "national", 
      geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == 
                              "it affected locations in more than one state, province, or region",
                                "regional", geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == "it only affected one city, county, or village",
                            "local", geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == "it affected more than one city in the same state, province, or region",
                            "local", geo_scope)) %>%
  mutate(geo_scope = ifelse(!(geo_scope %in% c("local", "regional", "national")), 
                            NA, geo_scope)) %>%
  mutate(shutdown_extent = ifelse(shutdown_extent == "full network, service-based",
      "full and service-based",
      shutdown_extent)) %>%
    mutate(shutdown_extent = ifelse(!(shutdown_extent %in% c("full network",
                                                             "service-based", 
                                                             "full and service-based")), 
                                    NA, shutdown_extent)) %>%
  select(!area_name) %>%
  mutate(duration = NA)
    
#### DATA WRANGLING 2021 data ####
ShutdownData2021 <- ShutdownData2021 %>% 
  select(start_date, country, area_name, geo_scope, shutdown_extent) %>%
  mutate(area_name = tolower(area_name)) %>%
  mutate(shutdown_extent = tolower(shutdown_extent)) %>%
  mutate(geo_scope = tolower(geo_scope)) %>%
  mutate(geo_scope = ifelse(area_name %in% c("national", "nationwide", "nation wide"), 
                            "national", 
                            geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == 
                              "it affected locations in more than one state, province, or region",
                            "regional", geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == "it only affected one city, county, or village",
                            "local", geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == "it affected more than one city in the same state, province, or region",
                            "local", geo_scope)) %>%
  mutate(geo_scope = ifelse(!(geo_scope %in% c("local", "regional", "national")), 
                            NA, geo_scope)) %>%
  mutate(shutdown_extent = ifelse(shutdown_extent == "full network, service-based",
                                  "full and service-based",
                                  shutdown_extent)) %>%
  mutate(shutdown_extent = ifelse(!(shutdown_extent %in% c("full network",
                                                           "service-based", 
                                                           "full and service-based")), 
                                  NA, shutdown_extent)) %>%
  select(!area_name) %>%
  mutate(duration = NA)

#### DATA WRANGLING 2022 data ####
ShutdownData2022 <- ShutdownData2022 %>% 
  select(start_date, country, area_name, geo_scope, shutdown_extent) %>%
  mutate(area_name = tolower(area_name)) %>%
  mutate(shutdown_extent = tolower(shutdown_extent)) %>%
  mutate(geo_scope = tolower(geo_scope)) %>%
  mutate(geo_scope = ifelse(area_name %in% c("national", "nationwide", "nation wide"), 
                            "national", 
                            geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == 
                              "it affected locations in more than one state, province, or region",
                            "regional", geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == "it only affected one city, county, or village",
                            "local", geo_scope)) %>%
  mutate(geo_scope = ifelse(geo_scope == "it affected more than one city in the same state, province, or region",
                            "local", geo_scope)) %>%
  mutate(geo_scope = ifelse(!(geo_scope %in% c("local", "regional", "national")), 
                            NA, geo_scope)) %>%
  mutate(shutdown_extent = ifelse(shutdown_extent == "full network, service-based",
                                  "full and service-based",
                                  shutdown_extent)) %>%
  mutate(shutdown_extent = ifelse(!(shutdown_extent %in% c("full network",
                                                           "service-based", 
                                                           "full and service-based")), 
                                  NA, shutdown_extent)) %>%
  select(!area_name) %>%
  mutate(duration = NA)

#### COMBINING AND SAVING CLEANED DATA ####

ShutdownData <- rbind(ShutdownDataPre19, ShutdownData2019, ShutdownData2020,
                       ShutdownData2021, ShutdownData2022)

# adding country isocode
ShutdownData <- ShutdownData %>%
  mutate(iso3c = countrycode(country, origin = "country.name",
                             destination = "iso3c")) %>%
  mutate(country_name = countrycode(iso3c, origin = "iso3c",
                                    destination = "country.name")) %>%
  select(!country) %>%
  relocate(c(country_name, iso3c), .after = "start_date")

# fixing duration variable 
ShutdownData <- ShutdownData %>%
  mutate(duration = ifelse(str_detect(duration, "hours"), 0, duration)) %>%
  mutate(duration = as.numeric(duration)) %>%
  mutate(duration = ifelse(duration <= 0, NA, duration)) %>%
  mutate(duration = ifelse(duration < 1, 0, duration))

write_csv(ShutdownData, "data/Shutdowns/CleanShutdownData.csv")
