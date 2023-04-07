# Faiz Essa
# GDELT Data Wrangling
# April 7th, 2023

#### SETUP ####
rm(list=ls())

# importing packages 
library(tidyverse)
library(haven)
library(lubridate)

# data import 
raw_data <- read_rds("Data/GDELT/RawGDELT.rds")

# dropping obs with missing district
# fixing date format
raw_data <- raw_data %>%
  filter(!is.na(ActionGeo_ADM2Code)) %>%
  mutate(date = as.Date(as.character(SQLDATE), "%Y%m%d")) %>%
  select(!SQLDATE)

#### CONSTRUCTING PANEL ####
date_list <- seq.POSIXt(ISOdate(2015,1,1),ISOdate(2023,1,1), by="day")

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
         intence_massviolence = ifelse(assault_count > assaultp75, 1, 0))

#### MERGING IN SHUTDOWN DATA ####


            




