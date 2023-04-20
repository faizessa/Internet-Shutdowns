# Faiz Essa
# GDELT Protest Data difference-in-differences
# April 19th, 2023

#### SETUP ####
rm(list=ls())

# importing packages 
library(tidyverse)
library(did)

# import data
gdelt_panel <- read_csv("Data/GDELT/gdelt_panel.csv")

#### EXECUTING DIFF-IN-DIFFS ####
depvars <- 
  c("protest_count", "log_protests", "protest_indicator", "intense_protests",
   "assault_count", "log_assaults", "assault_indicator", "intense_assaults",
   "fight_count", "log_fights", "fight_indicator", "intense_fights")

# loop through each dependent variable
for (y in depvars) {
  # retrieve estimates
  estimates <- att_gt(yname = y,
                      tname = "time",
                      idname = "ActionGeo_ADM2Code",
                      gname = "group",
                      xformla = ~1,
                      data = gdelt_panel,
                      bstrap = TRUE,
                      clustervars = c("ActionGeo_ADM2Code"))
  # saving estimates
  write_rds(estimates, 
            paste("/Users/faizessa/Documents/Data/GDELTProtestDiD/", 
                  y, ".rds", sep = ""))
  rm(estimates)
}

