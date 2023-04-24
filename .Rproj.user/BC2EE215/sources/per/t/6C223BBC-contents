# Faiz Essa
# Prowess Data difference-in-differences
# April 20th, 2023

#### SETUP ####
rm(list=ls())

# importing packages 
library(tidyverse)
library(did)

# import data
prowess_panel <- read_csv("Data/Prowess/prowess_panel.csv")

# adding logs and encoding districts
prowess_panel <- prowess_panel %>%
  mutate(log_BSE = log(AvgBSEPrice),
         log_NSE = log(AvgNSEPrice),
         regddname = as.numeric(factor(regddname)))


#### EXECUTING DIFF-IN-DIFFS ####

depvars <- c("AvgBSEPrice", "log_BSE",
             "AvgNSEPrice", "log_NSE")

# loop through each dependent variable
for (y in depvars) {
  # retrieve estimates
  estimates <- att_gt(yname = y,
                      tname = "time",
                      idname = "regddname",
                      gname = "group",
                      xformla = ~1,
                      data = prowess_panel,
                      allow_unbalanced_panel = TRUE,
                      bstrap = TRUE,
                      clustervars = c("regddname"))
  # saving estimates
  write_rds(estimates, 
            paste("/Users/faizessa/Documents/Data/ProwessDiD/", 
                  y, ".rds", sep = ""))
  rm(estimates)
}

