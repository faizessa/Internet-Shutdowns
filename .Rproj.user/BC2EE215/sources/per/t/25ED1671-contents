# Faiz Essa
# Summary Stats for paper
# April 26th, 2023

#### SETUP ####
rm(list=ls())

# importing packages 
library(tidyverse)
library(stargazer)

# importing data 
gdelt_panel <- read_csv("Data/GDELT/gdelt_panel.csv") %>%
  select(assault_count, fight_count, protest_count) %>%
  rename(Assaults = assault_count, Fights = fight_count, Protests = protest_count)
gdelt_tone_panel <- read_csv("Data/GDELT/gdelt_tone_panel.csv") %>%
  select(AvgGovTone) %>%
  rename("Average Tone of Gov Events" = AvgGovTone)
prowess_panel <- read_csv("Data/Prowess/prowess_panel.csv") %>%
  select(AvgBSEPrice, AvgNSEPrice) %>%
  rename("Average BSE Opening Price" = AvgBSEPrice,
         "Average NSE Opening Price" = AvgNSEPrice)

#### COMPUTING SUMMARY STATISTICS ####
stargazer(as.data.frame(gdelt_panel),
          as.data.frame(gdelt_tone_panel),
          as.data.frame(prowess_panel),
          type = "latex",
          out = "results/Draft2Tables/summarystats.tex")
# I edit this file heavily directly in latex. The results are the same.
