# Faiz Essa
# GDELT Data Wrangling
# April 20th, 2023

#### SETUP ####
rm(list=ls())

# importing packages 
library(tidyverse)
library(lubridate)
library(readxl)

# data import 
prowess_stockprice <- read_delim(
  "/Users/faizessa/Documents/data/prowess_stockprice_dat.txt", delim = "|")
prowess_identity <- read_delim(
  "/Users/faizessa/Documents/data/prowess_identity.txt", delim = "|")

ShutdownData2022 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 1)
ShutdownData2021 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 2)
ShutdownData2020 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 3)
ShutdownData2019 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 4)
ShutdownDataPre19 <- read_excel("Data/Shutdowns/shutdown_data_raw.xlsx", sheet = 5)

#### CONSTRUCTING PANEL ####
prowess_panel <- prowess_stockprice %>%
  select(co_code, co_stkdate,
         bse_opening_price, bse_returns, 
         nse_opening_price, nse_returns) %>%
  mutate(date = as.Date(co_stkdate, "%d-%m-%Y")) %>% # fixing date format
  mutate(year = year(date), week = week(date)) %>%
  select(!co_stkdate) %>%
  relocate(c(date,year,week), .before = bse_opening_price) %>%
  filter(year >= 2016)

# keep only district info in identitiy data
prowess_districts <- prowess_identity %>%
  select(co_code, regddname) 
# could try corpdname or hoddname, but these are often missing

# merging in district info
prowess_panel <- prowess_panel %>%
  left_join(prowess_districts, by = "co_code") %>%
  # aggregating to district-year-week level
  group_by(regddname, year, week) %>%
  summarize(AvgBSEPrice = mean(bse_opening_price, na.rm = TRUE),
            AvgBSEReturns = mean(bse_returns, na.rm = TRUE),
            AvgNSEPrice = mean(nse_opening_price, na.rm = TRUE),
            AvgNSEReturns = mean(nse_returns, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(across(everything(), ~replace_na(.x, NA)))


# list of districts
districts <- prowess_panel %>%
  select(regddname) %>%
  distinct()

# creating "blank" panel
blank_panel <- seq.POSIXt(ISOdate(2016,1,1),ISOdate(2022,1,1), by="week") %>%
  data.frame() %>%
  mutate(year = year(.), week= week(.)) %>%
  select(year, week) %>%
  crossing(districts) %>%
  arrange(regddname, year, week)

# using blank panel to add missing dates
prowess_panel <- blank_panel %>%
  left_join(prowess_panel, by = c("regddname", "year", "week")) %>%
  # adding time index 
  group_by(year, week) %>%
  mutate(time = cur_group_id()) %>%
  ungroup() %>%
  relocate(time, .before = AvgBSEPrice) %>%
  relocate(c(year,week), .before = time) %>%
  mutate(regddname = tolower(regddname))

#### MERGING IN SHUTDOWN DATA ####
# keeping relevant vars
ShutdownData2022 <- select(ShutdownData2022, start_date, area_name)
ShutdownData2021 <- select(ShutdownData2021, start_date, area_name) 
ShutdownData2020 <- select(ShutdownData2020, start_date, area_name) 
ShutdownData2019 <- select(ShutdownData2019, start_date, area_name) 
ShutdownDataPre19 <- select(ShutdownDataPre19, start_date, area_name)

ShutdownDataRaw <- bind_rows(list(ShutdownData2022, ShutdownData2021, 
                                  ShutdownData2020, ShutdownData2019,
                                  ShutdownDataPre19)) %>%
  mutate(area_name = tolower(area_name))

# defining pattern for extraction 
district_pattern <- paste(unique(prowess_panel$regddname), 
                          collapse = "|")

ShutdownData <- ShutdownDataRaw %>%
  mutate(year = year(start_date), week = week(start_date),
         regddname = str_extract_all(area_name, district_pattern)) %>%
  mutate(regddname = ifelse(lengths(regddname)==0, NA, regddname)) %>%
  filter(!is.na(regddname)) %>%
  unnest(regddname) %>%
  select(regddname, year, week) %>%
  mutate(shutdown = 1) %>%
  distinct()

# merging
prowess_panel <- prowess_panel %>%
  left_join(ShutdownData, by = c("regddname", "year", "week"), multiple = "all") %>%
  mutate(shutdown = ifelse(is.na(shutdown), 0, shutdown))

# first shutdown 
first_shutdown <- prowess_panel %>% 
  filter(shutdown == 1) %>%
  group_by(regddname) %>%
  summarise(time = min(time)) %>%
  mutate(first_shutdown = 1)

# adding in first shutdown
prowess_panel <- prowess_panel %>% 
  left_join(first_shutdown, by = c("regddname", "time")) %>%
  mutate(first_shutdown = ifelse(is.na(first_shutdown), 0, first_shutdown))

# creating groups for callawa-santa'anna diff-in-diff (first time treated)
prowess_panel_groups <- prowess_panel %>%
  filter(shutdown == 1) %>%
  group_by(regddname) %>%
  summarise(group = min(time))

prowess_panel <- prowess_panel %>%
  left_join(prowess_panel_groups, by = "regddname") %>% 
  mutate(group = ifelse(is.na(group), 0, group))
  

write_csv(prowess_panel, "Data/Prowess/prowess_panel.csv", na = "")
