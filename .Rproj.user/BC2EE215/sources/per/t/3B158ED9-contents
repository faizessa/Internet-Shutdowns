# Faiz Essa
# Event Studies April 29th
# April 29th, 2023

#### SETUP ####

rm(list=ls())

# importing packages 
library(tidyverse)
library(panelView)

# data import 
gdelt_panel <- read_csv("Data/GDELT/gdelt_panel.csv") %>%
  mutate(treated = ifelse(group != 0 & time >= group, 1, 0)) %>% 
  rename(District = ActionGeo_ADM2Code, Time = time)
gdelt_tone_panel <- read_csv("Data/GDELT/gdelt_tone_panel.csv")
prowess_panel <- read_csv("Data/Prowess/prowess_panel.csv")


panelview(protest_count ~ treated,
          data = gdelt_panel,
          index = c("District", "Time"), type = "treat", 
          display.all = TRUE, gridOff = TRUE,
          by.timing = TRUE, background = "white", 
          axis.lab="off", 
          main = "Internet Shutdown Treatment Status",
          )