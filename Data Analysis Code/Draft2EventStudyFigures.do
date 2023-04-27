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


// ********** GDELT EVENT REGRESSIONS **********
foreach v of varlist assault_count fight_count protest_count log_assaults ///
	log_fights log_protests assault_indicator fight_indicator protest_indicator {
		eststo: quietly reghdfe `v' ///
			lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
			shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
			absorb(actiongeo_adm2code time) cluster(actiongeo_adm2code)
		quietly estadd local fixedd "Yes", replace
		quietly estadd local fixedw "Yes", replace
		quietly estadd scalar clusters = e(N_clust)
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
	
graph export "results/Draft2Figures/gdelt_count_eventstudy.png", replace

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
	
graph export "results/Draft2Figures/gdelt_logs_eventstudy.png", replace

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
	
graph export "results/Draft2Figures/gdelt_indicators_eventstudy.png", replace

// ********** GDELT TONE DATA WRANGLING **********

import delimited "Data/GDELT/gdelt_tone_panel.csv", clear

bysort actor1geo_adm2code: egen zscore=std(avggovtone)

// creating dummies for event studies 
sort actor1geo_adm2code time

by actor1geo_adm2code: gen lead8 = shutdown[_n+8] == 1
by actor1geo_adm2code: gen lead7 = shutdown[_n+7] == 1
by actor1geo_adm2code: gen lead6 = shutdown[_n+6] == 1
by actor1geo_adm2code: gen lead5 = shutdown[_n+5] == 1
by actor1geo_adm2code: gen lead4 = shutdown[_n+4] == 1
by actor1geo_adm2code: gen lead3 = shutdown[_n+3] == 1
by actor1geo_adm2code: gen lead2 = shutdown[_n+2] == 1
by actor1geo_adm2code: gen lead1 = shutdown[_n+1] == 1

by actor1geo_adm2code: gen lag1 = shutdown[_n-1] == 1
by actor1geo_adm2code: gen lag2 = shutdown[_n-2] == 1
by actor1geo_adm2code: gen lag3 = shutdown[_n-3] == 1
by actor1geo_adm2code: gen lag4 = shutdown[_n-4] == 1
by actor1geo_adm2code: gen lag5 = shutdown[_n-5] == 1
by actor1geo_adm2code: gen lag6 = shutdown[_n-6] == 1
by actor1geo_adm2code: gen lag7 = shutdown[_n-7] == 1
by actor1geo_adm2code: gen lag8 = shutdown[_n-8] == 1

// ********** GDELT TONE REGRESSION **********
eststo: reghdfe zscore ///
	lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
	shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
	absorb(actor1geo_adm2code time) cluster(actor1geo_adm2code)
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedw "Yes", replace
quietly estadd scalar clusters = e(N_clust)

coefplot, ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ciopts(recast(rcap)) ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/Draft2Figures/gdelt_tone_eventstudy.png", replace

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

// ********** PROWESS REGRESSIONS **********

foreach v of varlist avgbseprice log_bseprice avgnseprice log_nseprice {
		eststo: reghdfe `v' ///
			lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
			shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
			absorb(regddname time) cluster(regddname)
		quietly estadd local fixedd "Yes", replace
		quietly estadd local fixedw "Yes", replace
		quietly estadd scalar clusters = e(N_clust)
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

// ********** EXPORTING REGRESSION OUTPUT **********

// labelling lead/lag variables
label variable lead8 "8 weeks to shutdown"
label variable lead7 "7 weeks to shutdown"
label variable lead6 "6 weeks to shutdown"
label variable lead5 "5 weeks to shutdown"
label variable lead4 "4 weeks to shutdown"
label variable lead3 "3 weeks to shutdown"
label variable lead2 "2 weeks to shutdown"
label variable lead1 "1 week to shutdown"
label variable shutdown "Shutdown Week"
label variable lag1 "1 week from shutdown"
label variable lag2 "2 weeks from shutdown"
label variable lag3 "3 weeks from shutdown"
label variable lag4 "4 weeks from shutdown"
label variable lag5 "5 weeks from shutdown"
label variable lag6 "6 weeks from shutdown"
label variable lag7 "7 weeks from shutdown"
label variable lag8 "8 weeks from shutdown"


esttab using "results/Draft2Tables/eventstudies.tex", ///
	label replace se(3) r2 ar2 star(* 0.10 ** 0.05 *** .01) ///
	s(fixedd fixedw N clusters r2, ///
	label("District FE" "Year-Week FE" ///
	"Observations" "\# of Clusters" "R squared")) ///
	mtitles("Assaults" "Fights" "Protests"  ///
	"ln(Assaults+1)" "ln(Fights+1)" "ln(Protests+1)" ///
	"1(Assaults>0)" "1(Fights>0)" "1(Protests>0)" ///
	"Gov Attitude Score" ///
	"BSE Price" "ln(BSE Price)" "NSE Price" "ln(NSE Price)") ///
	title(Event Studies\label{tab:eventstudies}) 
