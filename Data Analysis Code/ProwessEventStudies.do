/* Faiz Essa 
Prowess Stock Price Event Studies
April 18th, 2023
*/

// ********** SETUP **********

// set working directory
cd "/Users/faizessa/Documents/GitHub/Internet-Shutdowns"

// importing data
import delimited "Data/Prowess/prowess_panel.csv", clear

// ********** DATA WRANGLING **********

// taking logs
g log_bseprice = log(avgbseprice)
g log_nseprice = log(avgnseprice)
g log_bsereturns = log(avgbsereturns)
g log_nsereturns = log(avgnsereturns)

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

foreach v of varlist avgbseprice log_bseprice avgnseprice log_nseprice ///
	avgbsereturns log_bsereturns avgnsereturns log_nsereturns {
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

graph export "results/ProwessEventStudies/price.png", replace
	
coefplot (log_bseprice, label(log(BSE Price)) offset(-.1)) ///
	(log_nseprice, label(log(NSE Price)) offset(.1)), ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/ProwessEventStudies/logprice.png", replace

coefplot (avgbsereturns, label(BSE Returns) offset(-.1)) ///
	(avgnsereturns, label(NSE Returns) offset(.1)), ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
graph export "results/ProwessEventStudies/returns.png", replace

coefplot (log_bsereturns, label(log(BSE Returns)) offset(-.1)) ///
	(log_nsereturns, label(log(NSE Returns)) offset(.1)), ///
	vertical drop(_cons) ///
	xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
	10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
	scheme(s1color) msize(tiny) recast(connected) ///
	xline(9, lpattern(dash)) yline(0) ///
	xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")

graph export "results/ProwessEventStudies/logreturns.png", replace


