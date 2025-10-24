* ==============================================================================
* PRODUCTIVITY AND COMPENSATION ANALYSIS
* Parts a, c, and d
* ==============================================================================

* --- 1. SETUP ---
clear all

* Defining directory structure using local macros
global project_root "C:\repos\ujav-2502-econometrics"
global code_dir "$project_root\Code"
global figures_dir "$project_root\Figures"
global tables_dir "$project_root\Tables"
global data_dir "$project_root\Data"

cd "$project_root"

* --- 2. LOAD AND PREPARE DATA ---

* Import data from Excel
import excel "$data_dir/ecnm-2502-exam-0203.xlsx", sheet("Productividad y remuneración") firstrow cellrange(A4) clear

* Rename variables
rename Año year
rename Producciónporhoranegocios x_business
rename Producciónporhoranegociosno x_nonfarm
rename RemuneraciónrealporhoraNego y_business
rename Remuneraciónrealporhoranego y_nonfarm

* ==============================================================================
* PART A: SCATTER PLOTS
* ==============================================================================

* Scatter plot for Business Sector
twoway (scatter y_business x_business, mcolor(blue) msize(medium)), ///
    title("Business Sector: Real Compensation vs Productivity") ///
    xtitle("Production per Hour (X)") ///
    ytitle("Real Compensation per Hour (Y)") ///
    note("Base Year: 1992 = 100") ///
    graphregion(color(white)) bgcolor(white)
graph export "$figures_dir/exam-0203-scatter_business.png", replace

* Scatter plot for Non-farm Business Sector
twoway (scatter y_nonfarm x_nonfarm, mcolor(green) msize(medium)), ///
    title("Non-farm Business Sector: Real Compensation vs Productivity") ///
    xtitle("Production per Hour (X)") ///
    ytitle("Real Compensation per Hour (Y)") ///
    note("Base Year: 1992 = 100") ///
    graphregion(color(white)) bgcolor(white)
graph export "$figures_dir/exam-0203-scatter_nonfarm.png", replace

* ==============================================================================
* PART C: OLS REGRESSION
* ==============================================================================

* Business Sector Regression
regress y_business x_business
estimates store business_reg

* Non-farm Business Sector Regression
regress y_nonfarm x_nonfarm
estimates store nonfarm_reg

* Compare both regressions
estimates table business_reg nonfarm_reg, stats(N r2 r2_a rmse)

* Scatter plots with fitted regression lines
twoway (scatter y_business x_business, mcolor(blue) msize(small)) ///
       (lfit y_business x_business, lcolor(red) lwidth(medium)), ///
    title("Business Sector with OLS Fit") ///
    xtitle("Production per Hour (X)") ///
    ytitle("Real Compensation per Hour (Y)") ///
    legend(order(1 "Observed" 2 "Fitted") position(6)) ///
    note("Base Year: 1992 = 100") ///
    graphregion(color(white)) bgcolor(white)
graph export "$figures_dir/exam-0203-regression_business.png", replace

twoway (scatter y_nonfarm x_nonfarm, mcolor(green) msize(small)) ///
       (lfit y_nonfarm x_nonfarm, lcolor(red) lwidth(medium)), ///
    title("Non-farm Business Sector with OLS Fit") ///
    xtitle("Production per Hour (X)") ///
    ytitle("Real Compensation per Hour (Y)") ///
    legend(order(1 "Observed" 2 "Fitted") position(6)) ///
    note("Base Year: 1992 = 100") ///
    graphregion(color(white)) bgcolor(white)
graph export "$figures_dir/exam-0203-regression_nonfarm.png", replace

* ==============================================================================
* PART D: ELASTICITY ANALYSIS
* ============================================================================

* Log-log model for constant elasticity

generate ln_x_business = ln(x_business)
generate ln_y_business = ln(y_business)
generate ln_x_nonfarm = ln(x_nonfarm)
generate ln_y_nonfarm = ln(y_nonfarm)

* Business Sector log-log
regress ln_y_business ln_x_business
local elasticity_log_bus = _b[ln_x_business]
estimates store loglog_business

* Non-farm Business Sector log-log
regress ln_y_nonfarm ln_x_nonfarm
local elasticity_log_nf = _b[ln_x_nonfarm]
estimates store loglog_nonfarm

* Compare log-log models

estimates table loglog_business loglog_nonfarm, stats(N r2 r2_a)
