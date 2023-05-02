# Faiz Essa
# Synthetic Control
# May 2, 2023

#### SETUP ####
#install.packages("devtools")
#devtools::install_github("ebenmichael/augsynth")

library(tidyverse)
library(augsynth)

# data import 
gdelt_panel <- read_csv("Data/GDELT/gdelt_panel.csv")
gdelt_tone_panel <- read_csv("Data/GDELT/gdelt_tone_panel.csv")
prowess_panel <- read_csv("Data/Prowess/prowess_panel.csv")

gdelt_panel <- gdelt_panel %>%
  mutate(PostShutdown = ifelse(time >= group, 1, 0))

# test 
test <- multisynth( ~ cbr, State, year, 
                   nu = 0.5, analysis_df)

