# Faiz Essa
# Descriptive Analysis
# April 26th, 2023

#### SETUP ####
rm(list=ls())

# importing packages 
library(tidyverse)
library(lubridate)
library(wbstats)
library(countrycode)
library(ggrepel)
library(stargazer)

# importing data
ShutdownData <- read.csv("data/Shutdowns/CleanShutdownData.csv")
polity5 <- read.csv("data/other/polity5.csv")

#### creating plots for polity2 and GDP per capita ####
# number of shutdowns by country
shutdowns_by_country <- ShutdownData %>%
  group_by(iso3c) %>%
  summarize(shutdowns = n()) %>%
  ungroup() %>%
  mutate(percent = round(shutdowns/sum(shutdowns), digits = 2) * 100) %>%
  mutate(percent = paste(as.character(percent), "%", sep = "")) %>%
  filter(!is.na(iso3c)) 

# cleaning polity5
polity5 <- polity5 %>%
  filter(year == 2018, polity2 >= -10 | polity2 <= 10) %>%
  select(country, polity2) %>%
  mutate(iso3c = countrycode(country, origin="country.name", destination = "iso3c"))  %>%
  select(!country)

# importing GDP per capita and population data 
gdp <- wb_data(c("NY.GDP.PCAP.PP.CD", "SP.POP.TOTL"), mrv = 1) %>%
  rename(gdppc = "NY.GDP.PCAP.PP.CD", pop = "SP.POP.TOTL") %>%
  select(country, iso3c, gdppc, pop)

shutdowns_by_country <- gdp %>%
  left_join(shutdowns_by_country, by = "iso3c") %>%
  left_join(polity5, by = "iso3c") %>%
  mutate(shutdowns = ifelse(is.na(shutdowns), 0, shutdowns))

# adding labels
labeled_countries <- shutdowns_by_country %>%
  filter(shutdowns >= 15) %>%
  mutate(label = country) %>%
  mutate(label = ifelse(iso3c == "IRN", "Iran", label),
         label = ifelse(iso3c == "YEM", "Yemen", label),
         label = ifelse(iso3c == "SYR", "Syria", label)) %>%
  select(iso3c, label)

shutdowns_by_country <- shutdowns_by_country %>%
  left_join(labeled_countries, by = "iso3c")


# generating plots 
ggplot(shutdowns_by_country, aes(x = log(gdppc), y = log(shutdowns+1))) + 
  geom_point(aes(size = pop), shape = 1, color = "light blue") +
  geom_smooth(method = lm, color = "black") +
  geom_label_repel(aes(label = label),
                   box.padding   = 0.3, 
                   point.padding = 0.3,
                   min.segment.length = .25,
                   segment.color = 'grey50') +
  theme_linedraw() +
  theme(text = element_text(size = 17)) +
  theme(legend.position = "none") + 
  ylab("log(# of Shutdowns + 1)") +
  xlab("log(GDP per Capita, PPP) (2021)")
ggsave("results/Draft2Figures/gdpplot.png")

ggplot(shutdowns_by_country, aes(x = polity2, y = log(shutdowns+1))) + 
  geom_point(aes(size = pop), shape = 1, color = "light blue") +
  geom_smooth(method = lm, color = "black") +
  geom_label_repel(aes(label = label),
                   box.padding   = 0.3, 
                   point.padding = 0.3,
                   min.segment.length = .25,
                   segment.color = 'grey50') +
  theme_linedraw() +
  theme(text = element_text(size = 17)) +
  theme(legend.position = "none") + 
  ylab("log(# of Shutdowns + 1)") +
  xlab("polity score (2018)")
ggsave("results/Draft2Figures/polityplot.png")

#### Bar graph with most common places to shut down internet ####
shutdowns_by_country <- shutdowns_by_country %>%
  filter(!is.na(label)) %>%
  select(label, shutdowns, percent) 

ggplot(shutdowns_by_country, aes(x=reorder(label, -shutdowns), y=shutdowns)) +
  geom_bar(stat="identity", fill='steelblue') + 
  geom_text(aes(label=percent), vjust=-0.25) + 
  theme_linedraw() + 
  theme(text = element_text(size = 17)) +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  xlab("Countries with at least 15 internet shutdowns") +
  ylab("# of Internet Shutdowns")

ggsave("results/Draft2Figures/ShutdownsByCountry.png")

#### Line plot with shutdowns over time ####

# organizing data
shutdowns_by_time <- ShutdownData %>%
  mutate(month=month(start_date),
         year=year(start_date)) %>%
  unite(year_month, year, month)

shutdowns_by_time <- ShutdownData %>%
  mutate(month=month(start_date),
         year=year(start_date)) %>%
  group_by(year, month) %>%
  summarize(shutdowns = n()) %>%
  ungroup() %>%
  filter(year >= 2016) %>%
  mutate(date = as.Date(paste(year,month,"01", sep="-")))

ggplot(shutdowns_by_time, aes(x=date, y=shutdowns)) +
  geom_line() + 
  theme_linedraw() + 
  theme(text = element_text(size = 17)) +
  xlab("Time") +
  ylab("# of Internet Shutdowns")

ggsave("results/Draft2Figures/ShutdownsOverTime.png")

#### Shutdown Durations Summary Statistics####
durations <- select(ShutdownData, duration) %>%
  filter(!is.na(duration)) %>%
  rename("Shutdown Duration" = duration) 
stargazer(durations, type = "latex", out = "results/Draft2Tables/ShutdownDurations.tex")
# I use these results to add to my table in latex

#### Shutdown Geographic Scope Bar Graph ####

shutdowns_by_geo <- ShutdownData %>%
  group_by(geo_scope) %>%
  summarize(shutdowns = n()) %>%
  ungroup() %>%
  mutate(percent = round(shutdowns/sum(shutdowns), digits = 2) * 100) %>%
  mutate(percent = paste(as.character(percent), "%", sep = "")) %>%
  filter(!is.na(geo_scope))

ggplot(shutdowns_by_geo, aes(x=reorder(geo_scope, -shutdowns), y=shutdowns)) +
  geom_bar(stat="identity", fill='steelblue') + 
  geom_text(aes(label=percent), vjust=-0.25) + 
  theme_linedraw() + 
  theme(text = element_text(size = 17)) +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  xlab("Geographic Scope") +
  ylab("# of Internet Shutdowns")

ggsave("results/Draft2Figures/ShutdownsByGeoScope.png")

#### Shutdown Geographic Scope Bar Graph ####
shutdowns_by_extent <- ShutdownData %>%
  group_by(shutdown_extent) %>%
  summarize(shutdowns = n()) %>%
  ungroup() %>%
  mutate(percent = round(shutdowns/sum(shutdowns), digits = 2) * 100) %>%
  mutate(percent = paste(as.character(percent), "%", sep = "")) %>%
  filter(!is.na(shutdown_extent))

ggplot(shutdowns_by_extent, aes(x=reorder(shutdown_extent, -shutdowns), y=shutdowns)) +
  geom_bar(stat="identity", fill='steelblue') + 
  geom_text(aes(label=percent), vjust=-0.25) + 
  theme_linedraw() + 
  theme(text = element_text(size = 17)) +
  xlab("Extent to which services are blocked") +
  ylab("# of Internet Shutdowns")

ggsave("results/Draft2Figures/ShutdownsByExtent.png")


  