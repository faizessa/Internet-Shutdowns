# Faiz Essa
# Event Studies April 29th
# April 29th, 2023

#### SETUP ####

rm(list=ls())

# importing packages 
library(tidyverse)
library(fixest)
library(readr)

# data import 
gdelt_panel <- read_csv("Data/GDELT/gdelt_panel.csv")
gdelt_tone_panel <- read_csv("Data/GDELT/gdelt_tone_panel.csv")
prowess_panel <- read_csv("Data/Prowess/prowess_panel.csv")

#### DATA WRANGLING ####
gdelt_panel <- gdelt_panel %>%
  mutate(rel_time = ifelse(group != 0, time-group, NA)) %>%
  mutate(rel_time = ifelse(rel_time <= -8, -8, rel_time),
         rel_time = ifelse(rel_time >=8, 8, rel_time)) %>%
  mutate(cohort = ifelse(group == 0, 100, group)) 
  
gdelt_tone_panel <- gdelt_tone_panel %>%
  mutate(cohort = ifelse(group == 0, 100, group)) %>%
  mutate(rel_time = time-cohort) %>%
  mutate(rel_time = ifelse(rel_time <= -8, -8, rel_time),
         rel_time = ifelse(rel_time >=8, 8, rel_time)) %>%
  mutate(zscore = scale(AvgGovTone)) 

prowess_panel <- prowess_panel %>%
  mutate(cohort = ifelse(group == 0, 100, group)) %>%
  mutate(rel_time = time-cohort) %>%
  mutate(rel_time = ifelse(rel_time <= -8, -8, rel_time),
         rel_time = ifelse(rel_time >=8, 8, rel_time)) 
  
#### GDELT EVENT REGRESSIONS ####

# list of dependent variables
gdelt_depvars <- c("assault_count", "fight_count", "protest_count",
                   "log_assaults", "log_fights", "log_protests")

# running regressions
for (y in gdelt_depvars){
  
  formula <- as.formula(
    paste(y, "~sunab(cohort, rel_time, ref.p=-4) | ActionGeo_ADM2Code + time", 
          sep = ""))
  
  model <- feols(formula,
                 cluster = ~ActionGeo_ADM2Code,
                 data = gdelt_panel)
  
  assign(y, model)
  
  rm(formula, model)
}

#### GDELT EVENT PLOTS ####

# plotting logs
pdf("results/draft2sunab/gdelt_logs_sunab.pdf")
iplot(list(log_assaults, log_fights, log_protests), sep = 0.2, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("topright", col = c(1, 2, 3), pch = c(20, 17, 15), 
       legend =  c("ln(Assaults+1)", "ln(Fights+1)", "ln(Protests+1)"))
dev.off()

# plotting raw counts
pdf("results/draft2sunab/gdelt_count_sunab.pdf")
iplot(list(assault_count, fight_count, protest_count), sep = 0.2, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("topright", col = c(1, 2, 3), pch = c(20, 17, 15), 
       legend =  c("Assaults", "Fights", "Protests"))
dev.off()

#### GDELT TONE REGRESSION ####

zscore <- feols(zscore ~ sunab(cohort, rel_time, ref.p=-4) |
                  Actor1Geo_ADM2Code + time,
                cluster = ~Actor1Geo_ADM2Code,
                data = gdelt_tone_panel)

#### GDELT TONE PLOT ####

pdf("results/draft2sunab/gdelt_tone_sunab.pdf")
iplot(zscore, sep = 0.2, ref.line = -4,
      xlab = 'Weeks to shutdown',
      main = '')
legend("bottomright", col = 1, pch = 20, 
       legend =  c("Standardized Avg. Tone"))
dev.off()

#### PROWESS REGRESSIONS ####

prowess_depvars <- c("AvgBSEPrice", "AvgNSEPrice")

for (y in prowess_depvars) {
  log <- paste("log(",y,")")
  
  formula <- as.formula(
    paste(y, "~sunab(cohort, rel_time, ref.p=-4) | regddname + time", 
          sep = ""))
  log_formula <- as.formula(
    paste(log, "~i(sunab(cohort, rel_time, ref.p=-4) | regddname + time", 
          sep = ""))
  
  model <- feols(formula,
                 cluster = ~regddname,
                 data = prowess_panel)
  log_model <- feols(log_formula,
                     cluster = ~regddname,
                     data = prowess_panel)
  
  log_model_name <- paste("log", y, sep = "_")
  assign(y, model)
  assign(log_model_name, log_model)
}

#### PROWESS PLOTS ####

pdf("results/draft2sunab/prowess_price_sunab.pdf")
iplot(list(AvgBSEPrice, AvgNSEPrice), sep = 0.25, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("bottomleft", col = c(1, 2), pch = c(20, 17), 
       legend =  c("Avg. BSE Price", "Avg. NSE Price"))
dev.off()

pdf("results/draft2sunab/prowess_logs_sunab.pdf")
iplot(list(log_AvgBSEPrice, log_AvgNSEPrice), sep = 0.25, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("bottomleft", col = c(1, 2), pch = c(20, 17), 
       legend =  c("ln(Avg. BSE Price)", "ln(Avg. NSE Price)"))
dev.off()



