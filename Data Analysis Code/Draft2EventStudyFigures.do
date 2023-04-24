/* Faiz Essa 
Draft 2 Event Study Figures
April 24th, 2023
*/

// ********** SETUP **********

// set working directory
cd "/Users/faizessa/Documents/GitHub/Internet-Shutdowns"

// ********** GDELT DATA WRANGLING **********

// importing data
import delimited "Data/GDELT/gdelt_panel.csv", clear


// creating dummies for event studies 
sort actiongeo_adm2code time

by actiongeo_adm2code: gen lead8 = shutdown[_n+8] == 1
by actiongeo_adm2code: gen lead7 = shutdown[_n+7] == 1
by actiongeo_adm2code: gen lead6 = shutdown[_n+6] == 1
by actiongeo_adm2code: gen lead5 = shutdown[_n+5] == 1
by actiongeo_adm2code: gen lead4 = shutdown[_n+4] == 1
by actiongeo_adm2code: gen lead3 = shutdown[_n+3] == 1
by actiongeo_adm2code: gen lead2 = shutdown[_n+2] == 1
by actiongeo_adm2code: gen lead1 = shutdown[_n+1] == 1

by actiongeo_adm2code: gen lag1 = shutdown[_n-1] == 1
by actiongeo_adm2code: gen lag2 = shutdown[_n-2] == 1
by actiongeo_adm2code: gen lag3 = shutdown[_n-3] == 1
by actiongeo_adm2code: gen lag4 = shutdown[_n-4] == 1
by actiongeo_adm2code: gen lag5 = shutdown[_n-5] == 1
by actiongeo_adm2code: gen lag6 = shutdown[_n-6] == 1
by actiongeo_adm2code: gen lag7 = shutdown[_n-7] == 1
by actiongeo_adm2code: gen lag8 = shutdown[_n-8] == 1


// ********** GDELT REGRESSIONS **********
// raw counts
foreach v of varlist assault_count fight_count protest_count {
	quietly reghdfe `v' ///
		lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
		shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
		absorb(actiongeo_adm2code time) cluster(actiongeo_adm2code)
	estimates store `v'
}

coefplot (assault_count, label(Assaults) offset(-.15)) ///
	(fight_count, label(Fights)) ///
	(protest_count, label(Protests) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/Draft2Figures/gdelt_count_eventstudy.png", replace
estimates clear

// logs
foreach v of varlist log_assaults log_fights log_protests {
	quietly reghdfe `v' ///
		lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
		shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
		absorb(actiongeo_adm2code time) cluster(actiongeo_adm2code)
	estimates store `v'
}

coefplot (log_assaults, label(log(Assaults + 1)) offset(-.15)) ///
	(log_fights, label(log(Fights + 1))) ///
	(log_protests, label(log(Protests + 1)) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/Draft2Figures/gdelt_logs_eventstudy.png", replace
estimates clear

// indicators
foreach v of varlist assault_indicator fight_indicator protest_indicator {
	quietly reghdfe `v' ///
		lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
		shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
		absorb(actiongeo_adm2code time) cluster(actiongeo_adm2code)
	estimates store `v'
}

coefplot (assault_indicator, label(Assault Indicator) offset(-.15)) ///
	(fight_indicator, label(Fight Indicator)) ///
	(protest_indicator, label(Protest Indicator) offset(.15)),  ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny)  ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/Draft2Figures/gdelt_indicators_eventstudy.png", replace
estimates clear

// ********** PROWESS DATA WRANGLING **********

// set working directory
cd "/Users/faizessa/Documents/GitHub/Internet-Shutdowns"

// importing data
import delimited "Data/Prowess/prowess_panel.csv", clear

// taking logs
g log_bseprice = log(avgbseprice)
g log_nseprice = log(avgnseprice)


// creating dummies for event studies 
sort regddname time

by regddname: gen lead8 = shutdown[_n+8] == 1
by regddname: gen lead7 = shutdown[_n+7] == 1
by regddname: gen lead6 = shutdown[_n+6] == 1
by regddname: gen lead5 = shutdown[_n+5] == 1
by regddname: gen lead4 = shutdown[_n+4] == 1
by regddname: gen lead3 = shutdown[_n+3] == 1
by regddname: gen lead2 = shutdown[_n+2] == 1
by regddname: gen lead1 = shutdown[_n+1] == 1

by regddname: gen lag1 = shutdown[_n-1] == 1
by regddname: gen lag2 = shutdown[_n-2] == 1
by regddname: gen lag3 = shutdown[_n-3] == 1
by regddname: gen lag4 = shutdown[_n-4] == 1
by regddname: gen lag5 = shutdown[_n-5] == 1
by regddname: gen lag6 = shutdown[_n-6] == 1
by regddname: gen lag7 = shutdown[_n-7] == 1
by regddname: gen lag8 = shutdown[_n-8] == 1

// ********** REGRESSIONS **********

foreach v of varlist avgbseprice log_bseprice avgnseprice log_nseprice {
		reghdfe `v' ///
			lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
			shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
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

graph export "results/Draft2Figures/prowess_price_eventstudy.png", replace
	
coefplot (log_bseprice, label(log(BSE Price)) offset(-.1)) ///
	(log_nseprice, label(log(NSE Price)) offset(.1)), ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/Draft2Figures/prowess_logs_eventstudy.png", replace

