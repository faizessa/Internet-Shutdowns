# Faiz Essa
# GDELT Data Wrangling
# April 19th, 2023

#### SETUP ####
rm(list=ls())

# importing packages 
library(tidyverse)
library(lubridate)
library(readxl)

# data import 
raw_data <- read_rds("Data/GDELT/RawGDELT.rds")
ShutdownData2022 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 1)
ShutdownData2021 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 2)
ShutdownData2020 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 3)
ShutdownData2019 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 4)
ShutdownDataPre19 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 5)
raw_tone_data <- read_rds("Data/GDELT/RawGDELTGovTone.rds") # government tone
raw_tone_data_2 <- read_rds("Data/GDELT/RawGDELTOppTone.rds") # opposition tone

#### CONSTRUCTING PANEL ####
# dropping obs with missing district
# fixing date format
raw_data <- raw_data %>%
  filter(!is.na(ActionGeo_ADM2Code)) %>%
  mutate(date = as.Date(as.character(SQLDATE), "%Y%m%d")) %>%
  select(!SQLDATE)

date_list <- seq.POSIXt(ISOdate(2016,1,1),ISOdate(2023,1,1), by="day")

# list of event codes 
event_codes <- raw_data %>%
  distinct(EventRootCode)

# creates list of unique adm2 codes
ActionGeo_ADM2Code <- raw_data %>%
  distinct(ActionGeo_ADM2Code)

# creating `blank` panel
dates <- data.frame(date=date_list) %>%
  mutate(date = as.Date(date)) %>%
  crossing(ActionGeo_ADM2Code) %>%
  crossing(event_codes) %>%
  arrange(ActionGeo_ADM2Code, EventRootCode, date)

# merging in gdelt data
gdelt_panel <- dates %>%
  left_join(raw_data, by = c("ActionGeo_ADM2Code", "date", "EventRootCode")) %>%
  arrange(ActionGeo_ADM2Code, EventRootCode, date) %>%
  mutate(f0_ = ifelse(is.na(f0_), 0, f0_)) %>%
  pivot_wider(names_from = EventRootCode, values_from = f0_) %>%
  rename(protest_count = "14", assault_count = "18", fight_count = "19", massviolence_count = "20")

#### AGGREGATING TO WEEKLY LEVEL ####

gdelt_panel <- gdelt_panel %>%
  mutate(year = year(date), week = week(date)) %>%
  group_by(ActionGeo_ADM2Code, year, week) %>%
  summarize(protest_count = sum(protest_count),
            assault_count = sum(assault_count),
            fight_count = sum(fight_count),
            massviolence_count = sum(massviolence_count)) %>%
  ungroup() %>%
  group_by(year, week) %>%
  mutate(time = cur_group_id()) %>%
  ungroup() %>% 
  # creating transformations of dv's
  mutate(protest_indicator = ifelse(protest_count > 0, 1, 0),
         assault_indicator = ifelse(assault_count > 0, 1, 0),
         fight_indicator = ifelse(fight_count > 0, 1, 0),
         massviolence_indicator = ifelse(massviolence_count > 0, 1, 0),
         log_protests = log(protest_count + 1),
         log_assaults = log(assault_count + 1),
         log_fights = log(fight_count + 1),
         log_massviolence = log(massviolence_count + 1)) %>%
  relocate(time, .before = "protest_count")

# CREATING INTENSE PROTESTS INDICATOR 
gdelt_thresholds <- gdelt_panel %>%
  group_by(ActionGeo_ADM2Code) %>%
  summarize(protestp75 = quantile(protest_count, probs = .75),
            assaultp75 = quantile(assault_count, probs = .75),
            fightp75 = quantile(fight_count, probs = .75),
            massviolencep75 = quantile(massviolence_count, probs = .75))

# Adding transformation 1(count > 75th percentile)
gdelt_panel <- gdelt_panel %>%
  left_join(gdelt_thresholds, by = "ActionGeo_ADM2Code") %>%
  mutate(intense_protests = ifelse(protest_count > protestp75, 1, 0),
         intense_assaults = ifelse(assault_count > assaultp75, 1, 0),
         intense_fights = ifelse(fight_count > fightp75, 1, 0),
         intense_massviolence = ifelse(assault_count > assaultp75, 1, 0))

#### MERGING IN SHUTDOWN DATA ####

# keeping relevant vars
ShutdownData2022 <- select(ShutdownData2022, start_date, area_name)
ShutdownData2021 <- select(ShutdownData2021, start_date, area_name)
ShutdownData2020 <- select(ShutdownData2020, start_date, area_name)
ShutdownData2019 <- select(ShutdownData2019, start_date, area_name)
ShutdownDataPre19 <- select(ShutdownDataPre19, start_date, area_name)

# concatinating dataframes
ShutdownDataRaw <- bind_rows(list(ShutdownData2022, ShutdownData2021, 
                               ShutdownData2020, ShutdownData2019,
                               ShutdownDataPre19)) %>%
  mutate(area_name = tolower(area_name))

# merging ADM2Codes with names 
ADM2CrosswalkRaw <- read_delim(
  "/Users/faizessa/Documents/data/GNS-GAUL-ADM2-CROSSWALK.txt",
  delim = "\t") 

# keeping relevant vars 
ADM2Crosswalk <- select(ADM2CrosswalkRaw, GAULADM2Code, GAULADM2Name) %>%
  rename(ActionGeo_ADM2Code = GAULADM2Code) 

# creating list of unique districts
ActionGeo_ADM2Code <- ActionGeo_ADM2Code %>%
  mutate(ActionGeo_ADM2Code = as.double(ActionGeo_ADM2Code)) %>%
  left_join(ADM2Crosswalk, by = "ActionGeo_ADM2Code", multiple = "all") %>%
  distinct() %>%
  filter(GAULADM2Name != "Administrative unit not available") %>%
  mutate(GAULADM2Name = tolower(GAULADM2Name))

# defining pattern for extraction 
district_pattern <- paste(unique(ActionGeo_ADM2Code$GAULADM2Name), 
                          collapse = "|")

# Adding district names to shutdown data 
ShutdownData <- ShutdownDataRaw %>%
  mutate(year = year(start_date), week = week(start_date),
         GAULADM2Name = str_extract_all(area_name, district_pattern)) %>%
  mutate(GAULADM2Name = ifelse(lengths(GAULADM2Name)==0, NA, GAULADM2Name)) %>%
  filter(!is.na(GAULADM2Name)) %>%
  unnest(GAULADM2Name) %>% 
  left_join(ActionGeo_ADM2Code, by = "GAULADM2Name") %>%
  select(year, week, ActionGeo_ADM2Code) %>%
  distinct() %>%
  mutate(shutdown = 1)

# merging shutdown data into panel
gdelt_panel <- gdelt_panel %>%
  mutate(ActionGeo_ADM2Code = as.double(ActionGeo_ADM2Code)) %>%
  left_join(ShutdownData, by = c("year", "week", "ActionGeo_ADM2Code")) %>%
  mutate(shutdown = ifelse(is.na(shutdown), 0, shutdown))

# creating groups for callawa-santa'anna diff-in-diff (first time treated)
gdelt_did_groups <- gdelt_panel %>%
  filter(shutdown == 1) %>%
  group_by(ActionGeo_ADM2Code) %>%
  summarise(group = min(time))

gdelt_panel <- gdelt_panel %>%
  left_join(gdelt_did_groups, by = "ActionGeo_ADM2Code") %>% 
  mutate(group = ifelse(is.na(group), 0, group))

write_csv(gdelt_panel, "Data/GDELT/gdelt_panel.csv")

#### CONSRTRUCTING PANEL FOR TONE DATA ####

# dropping obs with missing district
# fixing date format and renaming vars
raw_tone_data <- raw_tone_data %>%
  filter(!is.na(Actor1Geo_ADM2Code)) %>%
  mutate(date = as.Date(as.character(SQLDATE), "%Y%m%d")) %>%
  select(!SQLDATE) %>%
  rename(GovEvents = f0_, GovTone = f1_)

raw_tone_data_2 <- raw_tone_data_2 %>%
  filter(!is.na(Actor1Geo_ADM2Code)) %>%
  mutate(date = as.Date(as.character(SQLDATE), "%Y%m%d")) %>%
  select(!SQLDATE) %>%
  rename(OppEvents = f0_, OppTone = f1_)

# creates list of unique adm2 codes
Actor1Geo_ADM2Code <- raw_tone_data %>%
  bind_rows(raw_tone_data_2) %>%
  distinct(Actor1Geo_ADM2Code)

# creating `blank` panel
dates <- data.frame(date=date_list) %>%
  mutate(date = as.Date(date)) %>%
  crossing(Actor1Geo_ADM2Code) %>%
  arrange(Actor1Geo_ADM2Code, date)

# merging in gdelt tone data
gdelt_tone_panel <- dates %>%
  left_join(raw_tone_data, by = c("Actor1Geo_ADM2Code", "date")) %>%
  left_join(raw_tone_data_2, by = c("Actor1Geo_ADM2Code", "date")) %>%
  arrange(Actor1Geo_ADM2Code, date) 

#### AGGREGATING TONE DATA TO WEEKLY LEVEL ####

gdelt_tone_panel <- gdelt_tone_panel %>%
  mutate(year = year(date), week = week(date)) %>%
  group_by(Actor1Geo_ADM2Code, year, week) %>%
  summarize(GovEvents = sum(GovEvents, na.rm = TRUE),
            OppEvents = sum(OppEvents, na.rm = TRUE),
            GovTone = sum(GovTone, na.rm = TRUE),
            OppTone = sum(OppTone, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(AvgGovTone = ifelse(GovEvents != 0, GovTone/GovEvents, NA),
         AvgOppTone = ifelse(OppEvents != 0, OppTone/OppEvents, NA)) %>%
  group_by(year, week) %>%
  mutate(time = cur_group_id()) %>%
  ungroup() %>%
  relocate(time, .before = GovEvents)

#### MERGING IN SHUTDOWN DATA TO TONE PANEL ####

# keeping relevant vars 
ADM2Crosswalk <- select(ADM2CrosswalkRaw, GAULADM2Code, GAULADM2Name) %>%
  rename(Actor1Geo_ADM2Code = GAULADM2Code) 

# creating list of unique districts
Actor1Geo_ADM2Code <- Actor1Geo_ADM2Code %>%
  mutate(Actor1Geo_ADM2Code = as.double(Actor1Geo_ADM2Code)) %>%
  left_join(ADM2Crosswalk, by = "Actor1Geo_ADM2Code", multiple = "all") %>%
  distinct() %>%
  filter(GAULADM2Name != "Administrative unit not available") %>%
  mutate(GAULADM2Name = tolower(GAULADM2Name))

# defining pattern for extraction 
district_pattern <- paste(unique(Actor1Geo_ADM2Code$GAULADM2Name), 
                          collapse = "|")

# Adding district names to shutdown data 
ShutdownData2 <- ShutdownDataRaw %>%
  mutate(year = year(start_date), week = week(start_date),
         GAULADM2Name = str_extract_all(area_name, district_pattern)) %>%
  mutate(GAULADM2Name = ifelse(lengths(GAULADM2Name)==0, NA, GAULADM2Name)) %>%
  filter(!is.na(GAULADM2Name)) %>%
  unnest(GAULADM2Name) %>% 
  left_join(Actor1Geo_ADM2Code, by = "GAULADM2Name") %>%
  select(year, week, Actor1Geo_ADM2Code) %>%
  distinct() %>%
  mutate(shutdown = 1)

# merging shutdown data into panel
gdelt_tone_panel <- gdelt_tone_panel %>%
  mutate(Actor1Geo_ADM2Code = as.double(Actor1Geo_ADM2Code)) %>%
  left_join(ShutdownData2, by = c("year", "week", "Actor1Geo_ADM2Code")) %>%
  mutate(shutdown = ifelse(is.na(shutdown), 0, shutdown))

# creating groups for callawa-santa'anna diff-in-diff (first time treated)
gdelt_tone_did_groups <- gdelt_tone_panel %>%
  filter(shutdown == 1) %>%
  group_by(Actor1Geo_ADM2Code) %>%
  summarise(group = min(time))

gdelt_tone_panel <- gdelt_tone_panel %>%
  left_join(gdelt_tone_did_groups, by = "Actor1Geo_ADM2Code") %>% 
  mutate(group = ifelse(is.na(group), 0, group))

# constructing z-score for attitudes towards incumbents

gdelt_tone_panel <- gdelt_tone_panel %>%
  group_by(Actor1Geo_ADM2Code) %>%
  mutate(z_score = (GovTone - mean(GovTone))/sd(GovTone)) %>%
  ungroup()

# saving data
write_csv(gdelt_tone_panel, "Data/GDELT/gdelt_tone_panel.csv", na = "")


