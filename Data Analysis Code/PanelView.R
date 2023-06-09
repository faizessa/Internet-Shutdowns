# Faiz Essa
# Event Studies April 29th
# April 29th, 2023

#### SETUP ####

rm(list=ls())

# importing packages 
library(tidyverse)
library(panelView)
library(plm)
# data import 
gdelt_panel <- read_csv("Data/GDELT/gdelt_panel.csv") %>%
  mutate(treated = ifelse(group != 0 & time >= group, 1, 0)) %>% 
  rename(District = ActionGeo_ADM2Code, Time = time)
gdelt_tone_panel <- read_csv("Data/GDELT/gdelt_tone_panel.csv") %>%
  mutate(treated = ifelse(group != 0 & time >= group, 1, 0)) %>%
  rename(District = Actor1Geo_ADM2Code, Time = time)
prowess_panel <- read_csv("Data/Prowess/prowess_panel.csv") %>%
  mutate(treated = ifelse(group != 0 & time >= group, 1, 0)) %>%
  rename(District = regddname, Time = time) 

#### MAKING PLOTS ####

pdf("results/PanelView/GDELTEvents.pdf")
panelview(protest_count ~ treated,
          data = gdelt_panel,
          index = c("District", "Time"), type = "treat", 
          display.all = TRUE, gridOff = TRUE,
          by.timing = TRUE, 
          legend.labs = c("Pre-shutdown",
                          "Post-shutdown"), 
          axis.lab="off", 
          main = "",
          )
dev.off()

pdf("results/PanelView/GDELTTone.pdf")
panelview(AvgGovTone ~ treated,
          data = gdelt_tone_panel,
          index = c("District", "Time"), type = "treat", 
          display.all = TRUE, gridOff = TRUE,
          by.timing = TRUE, 
          legend.labs = c("Pre-shutdown",
                          "Post-shutdown",
                          "Missing"), 
          axis.lab="off", 
          main = ""
)
dev.off()

pdf("results/PanelView/bseprice.pdf")
panelview(AvgBSEPrice ~ treated, 
          data = prowess_panel,
          index = c("District", "Time"), type = "treat", 
          display.all = TRUE, gridOff = TRUE,
          by.timing = TRUE,
          legend.labs = c("Pre-shutdown",
                          "Post-shutdown",
                          "Missing"), 
          axis.lab="off", 
          main = ""
)
dev.off()

pdf("results/PanelView/nseprice.pdf")
panelview(AvgNSEPrice ~ treated, 
          data = prowess_panel,
          index = c("District", "Time"), type = "treat", 
          display.all = TRUE, gridOff = TRUE,
          by.timing = TRUE,
          legend.labs = c("Pre-shutdown",
                          "Post-shutdown",
                          "Missing"), 
          axis.lab="off", 
          main = ""
)
dev.off()

