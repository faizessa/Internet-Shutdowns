/* Faiz Essa 
GDELT Event Studies for Shutdown Project
April 10th, 2023
*/

// ********** SETUP **********

// set working directory
cd "/Users/faizessa/Documents/GitHub/Internet-Shutdowns"

// importing data
import delimited "Data/GDELT/gdelt_panel.csv", clear


// ********** DATA WRANGLING **********

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

// dropping irrelevant vars
drop protestp75 assaultp75 fightp75 massviolencep75

// ********** REGRESSIONS **********

foreach v of varlist protest_count-intense_massviolence {
	quietly reghdfe `v' ///
		lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 ///
		shutdown lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8, ///
		absorb(actiongeo_adm2code time) cluster(actiongeo_adm2code)
	
	coefplot, vertical drop(_cons) ///
		xlab(1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" 9 "0" ///
		10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8") ///
		scheme(s1color) ciopts(recast(rcap)) recast(connected) ///
		xline(9, lpattern(dash)) yline(0) ///
		xtitle("Weeks to Shutdown") ytitle("Estimated Coefficient")
	
	graph export "results/Apr10_EventStudies/`v'.png", replace
}

	
	