# Faiz Essa
# Event Studies April 29th
# May 1, 2023

#### SETUP ####

rm(list=ls())

# importing packages 
library(tidyverse)
library(fixest)
library(readr)
library(stargazer)

# data import 
gdelt_panel <- read_csv("Data/GDELT/gdelt_panel.csv")
gdelt_tone_panel <- read_csv("Data/GDELT/gdelt_tone_panel.csv")
prowess_panel <- read_csv("Data/Prowess/prowess_panel.csv")

#### DATA WRANGLING ####
gdelt_panel <- gdelt_panel %>%
  # time to first shutdown
  mutate(time_from_sd = ifelse(group == 0, 0, time-group)) %>%
  # set >= 8 to 8, set <= -8 to -8 
  mutate(time_from_sd = ifelse(time_from_sd <= -8, -8, time_from_sd),
         time_from_sd = ifelse(time_from_sd >=8, 8, time_from_sd)) %>%
  rename(District = ActionGeo_ADM2Code, Time = time)

gdelt_tone_panel <- gdelt_tone_panel %>%
  # time to first shutdown
  mutate(time_from_sd = ifelse(group == 0, 0, time-group)) %>%
  # set >= 8 to 8, set <= -8 to -8 
  mutate(time_from_sd = ifelse(time_from_sd <= -8, -8, time_from_sd),
         time_from_sd = ifelse(time_from_sd >=8, 8, time_from_sd)) %>%
  mutate(zscore = scale(AvgGovTone)) %>%
  rename(District = Actor1Geo_ADM2Code, Time = time)

prowess_panel <- prowess_panel %>%
  # time to first shutdown
  mutate(time_from_sd = ifelse(group == 0, 0, time-group)) %>%
  # set >= 8 to 8, set <= -8 to -8 
  mutate(time_from_sd = ifelse(time_from_sd <= -8, -8, time_from_sd),
         time_from_sd = ifelse(time_from_sd >=8, 8, time_from_sd)) %>%
  rename(District = regddname, Time = time)

#### GDELT EVENT REGRESSIONS ####

# list of dependent vari
gdelt_depvars <- c("assault_count", "fight_count", "protest_count",
                   "log_assaults", "log_fights", "log_protests")

# running regressions
for (y in gdelt_depvars){
  
  formula <- as.formula(
    paste(y, "~i(time_from_sd,ref=-4) | District + Time", 
          sep = ""))
  
  model <- feols(formula,
                 cluster = ~District,
                 data = gdelt_panel)
  
  assign(y, model)
  
  rm(formula, model)
}

#### GDELT EVENT PLOTS ####

# plotting logs
pdf("results/Draft2EventStudiesV2/gdelt_logs.pdf")
iplot(list(log_assaults, log_fights, log_protests), sep = 0.2, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("topright", col = c(1, 2, 3), pch = c(20, 17, 15), 
      legend =  c("ln(Assaults+1)", "ln(Fights+1)", "ln(Protests+1)"))
dev.off()

# plotting raw counts
pdf("results/Draft2EventStudiesV2/gdelt_count.pdf")
iplot(list(assault_count, fight_count, protest_count), sep = 0.2, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("topright", col = c(1, 2, 3), pch = c(20, 17, 15), 
       legend =  c("Assaults", "Fights", "Protests"))
dev.off()

#### GDELT TONE REGRESSION ####

zscore <- feols(zscore ~ i(time_from_sd, ref = -4) |
                  District + Time,
                cluster = ~District,
                data = gdelt_tone_panel)

#### GDELT TONE PLOT ####
pdf("results/Draft2EventStudiesV2/gdelt_tone.pdf")
iplot(zscore, sep = 0.2, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("bottomright", col = 1, pch = 20, 
       legend =  c("Standardized Avg. Tone"))
dev.off()

#### PROWESS REGRESSIONS ####

prowess_depvars <- c("AvgBSEPrice", "AvgNSEPrice")

for (y in prowess_depvars) {
  log <- paste("log(",y,")")
  
  formula <- as.formula(
    paste(y, "~i(time_from_sd,ref=-4) | District + Time", 
          sep = ""))
  log_formula <- as.formula(
    paste(log, "~i(time_from_sd,ref=-4) | District + Time", 
          sep = ""))
  
  model <- feols(formula,
                 cluster = ~District,
                 data = prowess_panel)
  log_model <- feols(log_formula,
                     cluster = ~District,
                     data = prowess_panel)
  
  log_model_name <- paste("log", y, sep = "_")
  assign(y, model)
  assign(log_model_name, log_model)
}

#### PROWESS PLOTS ####

pdf("results/Draft2EventStudiesV2/prowess_price.pdf")
iplot(list(AvgBSEPrice, AvgNSEPrice), sep = 0.25, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("bottomleft", col = c(1, 2), pch = c(20, 17), 
       legend =  c("Avg. BSE Price", "Avg. NSE Price"))
dev.off()

pdf("results/Draft2EventStudiesV2/prowess_logs.pdf")
iplot(list(log_AvgBSEPrice, log_AvgNSEPrice), sep = 0.25, ref.line = -4,
      xlab = 'Weeks to first shutdown',
      main = '')
legend("bottomleft", col = c(1, 2), pch = c(20, 17), 
       legend =  c("ln(Avg. BSE Price)", "ln(Avg. NSE Price)"))
dev.off()

#### LATEX TABLE ####
test <- etable(assault_count, fight_count, protest_count, 
               log_assaults, log_fights, log_protests,
               zscore, 
               AvgBSEPrice, AvgNSEPrice,
               log_AvgBSEPrice, log_AvgNSEPrice,
               dict = c(assault_count = "Assaults",
                        fight_count = "Fights",
                        protest_count = "Protests",
                        log_assaults = "ln(Assaults+1)",
                        log_fights = "ln(Fights+1)",
                        log_protests = "ln(Protests+1)",
                        zscore = "Tone of Gov. Events",
                        AvgBSEPrice = "BSE Price",
                        AvgNSEPrice = "NSE Price",
                        log(AvgBSEPrice) = "ln(BSE Price)",
                        log(AvgNSEPrice) = "ln(NSE Price)",
                        time_from_sd = ""),
               i.equal = "",
               label = "tab:twfe",
               title = "Two-way fixed effects event study estimates",
               file = "results/Draft2EventStudiesV2/twfe_estimates.tex",
               tex = TRUE)
