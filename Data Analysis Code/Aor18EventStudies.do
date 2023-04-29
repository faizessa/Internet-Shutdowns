/* Faiz Essa 
Draft 2 Event Study Figures/Tables
April 26th, 2023
*/

// ********** SETUP **********
eststo clear
estimates clear
// set working directory
cd "/Users/faizessa/Documents/GitHub/Internet-Shutdowns"

// ********** GDELT EVENT DATA WRANGLING **********
// importing data
import delimited "Data/GDELT/gdelt_panel.csv", clear


// creating dummies for event studies 
sort actiongeo_adm2code time

by actiongeo_adm2code: gen lead8_v2 = time < group -7
by actiongeo_adm2code: gen lead8 = first_shutdown[_n+8] == 1
by actiongeo_adm2code: gen lead7 = first_shutdown[_n+7] == 1
by actiongeo_adm2code: gen lead6 = first_shutdown[_n+6] == 1
by actiongeo_adm2code: gen lead5 = first_shutdown[_n+5] == 1
by actiongeo_adm2code: gen lead4 = first_shutdown[_n+4] == 1
by actiongeo_adm2code: gen lead3 = first_shutdown[_n+3] == 1
by actiongeo_adm2code: gen lead2 = first_shutdown[_n+2] == 1
by actiongeo_adm2code: gen lead1 = first_shutdown[_n+1] == 1

by actiongeo_adm2code: gen lag1 = first_shutdown[_n-1] == 1
by actiongeo_adm2code: gen lag2 = first_shutdown[_n-2] == 1
by actiongeo_adm2code: gen lag3 = first_shutdown[_n-3] == 1
by actiongeo_adm2code: gen lag4 = first_shutdown[_n-4] == 1
by actiongeo_adm2code: gen lag5 = first_shutdown[_n-5] == 1
by actiongeo_adm2code: gen lag6 = first_shutdown[_n-6] == 1
by actiongeo_adm2code: gen lag7 = first_shutdown[_n-7] == 1
by actiongeo_adm2code: gen lag8 = first_shutdown[_n-8] == 1
by actiongeo_adm2code: gen lag8_v2 = time > group + 8

// ********** GDELT EVENT REGRESSIONS **********

// standard event study (comparison = -1)
foreach v of varlist assault_count fight_count protest_count log_assaults ///
	log_fights log_protests assault_indicator fight_indicator protest_indicator {
		quietly reghdfe `v' ///
			lead8_v2 lead7 lead6 lead5 lead4 lead3 lead2 ///
			first_shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8_v2, ///
			absorb(actiongeo_adm2code time) cluster(actiongeo_adm2code)
		estimates store `v'
}

// raw counts
coefplot (assault_count, label(Assaults) offset(-.15)) ///
	(fight_count, label(Fights)) ///
	(protest_count, label(Protests) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "0" 9 "1" ///
	10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(7.5, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/Apr18_EventStudies/gdelt_count_eventstudy_std.png", replace

coefplot (log_assaults, label(Assaults) offset(-.15)) ///
	(log_fights, label(Fights)) ///
	(log_protests, label(Protests) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "0" 9 "1" ///
	10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(7.5, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/Apr18_EventStudies/gdelt_logs_eventstudy_std.png", replace

coefplot (assault_indicator, label(Assaults) offset(-.15)) ///
	(fight_indicator, label(Fights)) ///
	(protest_indicator, label(Protests) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "0" 9 "1" ///
	10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(7.5, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/Apr18_EventStudies/gdelt_indicators_eventstudy_std.png", replace

// my event study (comparison = avg)
estimates clear
foreach v of varlist assault_count fight_count protest_count log_assaults ///
	log_fights log_protests assault_indicator fight_indicator protest_indicator {
		quietly reghdfe `v' ///
			lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
			first_shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
			absorb(actiongeo_adm2code time) cluster(actiongeo_adm2code)
		estimates store `v'
}
// raw counts
coefplot (assault_count, label(Assaults) offset(-.15)) ///
	(fight_count, label(Fights)) ///
	(protest_count, label(Protests) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/Apr18_EventStudies/gdelt_count_eventstudy.png", replace

// logs
coefplot (log_assaults, label(log(Assaults + 1)) offset(-.15)) ///
	(log_fights, label(log(Fights + 1))) ///
	(log_protests, label(log(Protests + 1)) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/Apr18_EventStudies/gdelt_logs_eventstudy.png", replace

// indicators
coefplot (assault_indicator, label(1(Assaults > 0)) offset(-.15)) ///
	(fight_indicator, label(1(Fights > 0))) ///
	(protest_indicator, label(1(Protests > 0)) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/Apr18_EventStudies/gdelt_indicators_eventstudy.png", replace

estimates clear

// ********** GDELT TONE DATA WRANGLING **********

import delimited "Data/GDELT/gdelt_tone_panel.csv", clear

bysort actor1geo_adm2code: egen zscore=std(avggovtone)

// creating dummies for event studies 
sort actor1geo_adm2code time

by actor1geo_adm2code: gen lead8_v2 = time < group - 7
by actor1geo_adm2code: gen lead8 = first_shutdown[_n+8] == 1
by actor1geo_adm2code: gen lead7 = first_shutdown[_n+7] == 1
by actor1geo_adm2code: gen lead6 = first_shutdown[_n+6] == 1
by actor1geo_adm2code: gen lead5 = first_shutdown[_n+5] == 1
by actor1geo_adm2code: gen lead4 = first_shutdown[_n+4] == 1
by actor1geo_adm2code: gen lead3 = first_shutdown[_n+3] == 1
by actor1geo_adm2code: gen lead2 = first_shutdown[_n+2] == 1
by actor1geo_adm2code: gen lead1 = first_shutdown[_n+1] == 1

by actor1geo_adm2code: gen lag1 = first_shutdown[_n-1] == 1
by actor1geo_adm2code: gen lag2 = first_shutdown[_n-2] == 1
by actor1geo_adm2code: gen lag3 = first_shutdown[_n-3] == 1
by actor1geo_adm2code: gen lag4 = first_shutdown[_n-4] == 1
by actor1geo_adm2code: gen lag5 = first_shutdown[_n-5] == 1
by actor1geo_adm2code: gen lag6 = first_shutdown[_n-6] == 1
by actor1geo_adm2code: gen lag7 = first_shutdown[_n-7] == 1
by actor1geo_adm2code: gen lag8 = first_shutdown[_n-8] == 1
by actor1geo_adm2code: gen lag8_v2 = time > group + 8


// ********** GDELT TONE REGRESSION **********

// standard event study (comparison = -1)
reghdfe zscore ///
	lead8_v2 lead7 lead6 lead5 lead4 lead3 lead2 ///
	first_shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8_v2, ///
	absorb(actor1geo_adm2code time) cluster(actor1geo_adm2code)

coefplot, ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "0" ///
	9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ciopts(recast(rcap)) ///
	xline(7.5, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
graph export "results/Apr18_EventStudies/gdelt_tone_std.png", replace

// my event study (comparison = avg)
reghdfe zscore ///
	lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
	first_shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
	absorb(actor1geo_adm2code time) cluster(actor1geo_adm2code)
	
coefplot, ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ciopts(recast(rcap)) ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
graph export "results/Apr18_EventStudies/gdelt_tone.png", replace

// ********** PROWESS DATA WRANGLING **********
estimates clear
// set working directory
cd "/Users/faizessa/Documents/GitHub/Internet-Shutdowns"

// importing data
import delimited "Data/Prowess/prowess_panel.csv", clear

// taking logs
g log_bseprice = log(avgbseprice)
g log_nseprice = log(avgnseprice)


// creating dummies for event studies 
sort regddname time

by regddname: gen lead8_v2 = time < group -7
by regddname: gen lead8 = first_shutdown[_n+8] == 1
by regddname: gen lead7 = first_shutdown[_n+7] == 1
by regddname: gen lead6 = first_shutdown[_n+6] == 1
by regddname: gen lead5 = first_shutdown[_n+5] == 1
by regddname: gen lead4 = first_shutdown[_n+4] == 1
by regddname: gen lead3 = first_shutdown[_n+3] == 1
by regddname: gen lead2 = first_shutdown[_n+2] == 1
by regddname: gen lead1 = first_shutdown[_n+1] == 1

by regddname: gen lag1 = first_shutdown[_n-1] == 1
by regddname: gen lag2 = first_shutdown[_n-2] == 1
by regddname: gen lag3 = first_shutdown[_n-3] == 1
by regddname: gen lag4 = first_shutdown[_n-4] == 1
by regddname: gen lag5 = first_shutdown[_n-5] == 1
by regddname: gen lag6 = first_shutdown[_n-6] == 1
by regddname: gen lag7 = first_shutdown[_n-7] == 1
by regddname: gen lag8 = first_shutdown[_n-8] == 1
by regddname: gen lag8_v2 = time > group -7

// ********** PROWESS EVENT REGRESSIONS **********

// standard event study (comparison = -1)
foreach v of varlist avgbseprice avgnseprice log_bseprice log_nseprice {
		reghdfe `v' ///
			lead8_v2 lead7 lead6 lead5 lead4 lead3 lead2 ///
			first_shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8_v2, ///
			absorb(regddname time) cluster(regddname)
		estimates store `v'
}

coefplot (avgbseprice, label(BSE Price) offset(-.1)) ///
	(avgnseprice, label(NSE Price) offset(.1)), ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "0" 9 "1" ///
	10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ///
	xline(7.5, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/Apr18_EventStudies/prices_std.png", replace

coefplot (log_bseprice, label(log(BSE Price)) offset(-.1)) ///
	(log_nseprice, label(log(NSE Price)) offset(.1)), ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "0" 9 "1" ///
	10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ///
	xline(7.5, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/Apr18_EventStudies/log_price_std.png", replace


// my event study (comparison = mean)
foreach v of varlist avgbseprice avgnseprice log_bseprice log_nseprice {
		reghdfe `v' ///
			lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
			first_shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
			absorb(regddname time) cluster(regddname)
		estimates store `v'
}

coefplot (avgbseprice, label(BSE Price) offset(-.1)) ///
	(avgnseprice, label(NSE Price) offset(.1)), ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/Apr18_EventStudies/prices.png", replace

coefplot (log_bseprice, label(log(BSE Price)) offset(-.1)) ///
	(log_nseprice, label(log(NSE Price)) offset(.1)), ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/Apr18_EventStudies/log_price.png", replace

