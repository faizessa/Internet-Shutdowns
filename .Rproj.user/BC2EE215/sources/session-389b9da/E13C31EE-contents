# Faiz Essa
# GDELT Tone Data difference-in-differences
# April 20th, 2023

#### SETUP ####

rm(list=ls())

# importing packages 
library(tidyverse)
library(did)

# import data
gdelt_tone_panel <- read_csv("Data/GDELT/gdelt_tone_panel.csv")

# adding logs
gdelt_tone_panel <- gdelt_tone_panel %>%
  mutate(log_AvgGovTone = log(AvgGovTone + 21),
         log_AvgOppTone = log(AvgOppTone + 21))

#### EXECUTING DIFF-IN-DIFFS ####

depvars <- c("AvgGovTone", "log_AvgGovTone",
             "AvgOppTone", "log_AvgOppTone")

# loop through each dependent variable
for (y in depvars) {
  # retrieve estimates
  estimates <- att_gt(yname = y,
                      tname = "time",
                      idname = "Actor1Geo_ADM2Code",
                      gname = "group",
                      xformla = ~1,
                      data = gdelt_tone_panel,
                      allow_unbalanced_panel = TRUE,
                      bstrap = TRUE,
                      clustervars = c("Actor1Geo_ADM2Code"))
  # saving estimates
  write_rds(estimates, 
            paste("/Users/faizessa/Documents/Data/GDELTToneDiD/", 
                  y, ".rds", sep = ""))
  rm(estimates)
}

