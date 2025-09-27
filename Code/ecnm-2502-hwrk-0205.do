********************************************************************************
* Housing Price Regression Models
* Dataset: stockton4.dat (15,009 houses sold in Stockton, CA, 1996-1998)
********************************************************************************

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

use "$data_dir/ecnm-2502-hwrk-0205.dta" /// equivalent to "stockton4.dta"

* Display basic information about the dataset
describe
summarize sprice livarea age

********************************************************************************
* PART A: Scatter plot of sale price vs living area
********************************************************************************

* Create scatter plot of sale price against living area for all houses
scatter sprice livarea, ///
    title("Sale Price vs Living Area") ///
    xtitle("Living Area (square feet)") ///
    ytitle("Sale Price ($)") ///
    msize(tiny) mcolor(navy%30) ///
    name(scatter_basic, replace)
	
* Export scatter
graph export "$figures_dir/0205-scatter_basic.eps", name(scatter_basic) replace //For latex
graph export "$figures_dir/0205-scatter_basic.png", name(scatter_basic) replace //For review

********************************************************************************
* PART B: Linear regression model
********************************************************************************

* Estimate linear model: sprice = β₀ + β₁livarea + u
regress sprice livarea

* Store results for later comparison
estimates store linear_model

* Generate predicted values and residuals
predict sprice_hat_linear, xb
predict residuals_linear, residuals

* Calculate Sum of Squared Errors (SSE) for linear model
gen squared_resid_linear = residuals_linear^2
quietly sum squared_resid_linear
scalar SSE_linear = r(sum)
display "SSE Linear Model: " SSE_linear

********************************************************************************
* PART C: Quadratic model
********************************************************************************

* Generate squared living area variable
gen livarea2 = livarea^2
label variable livarea2 "Living area squared"

* Estimate quadratic model: sprice = β₀ + β₁livarea² + u
regress sprice livarea2

* Store results
estimates store quadratic_model

* Generate predicted values and residuals
predict sprice_hat_quad, xb
predict residuals_quad, residuals

* Calculate SSE for quadratic model
gen squared_resid_quad = residuals_quad^2
quietly sum squared_resid_quad
scalar SSE_quad = r(sum)
display "SSE Quadratic Model: " SSE_quad

* Calculate marginal effect of 100 additional square feet for a 1500 sq ft house
* Derivative of sprice with respect to livarea = 2*β₁*livarea
display "===========================================" 
display "Marginal effect at 1500 square feet:"
display "Derivative = 2*β₁*livarea = 2*" _b[livarea2] "*1500 = " 2*_b[livarea2]*1500
display "Effect of 100 additional sq ft = " 2*_b[livarea2]*1500*100
display "==========================================="

********************************************************************************
* PART D: Graph with fitted lines for both models
********************************************************************************

* Sort data for smooth fitted lines
sort livarea

* Create combined graph with scatter plot and both fitted lines
twoway (scatter sprice livarea, msize(tiny) mcolor(gray%20)) ///
       (line sprice_hat_linear livarea, lcolor(blue) lwidth(medium) lpattern(solid)) ///
       (line sprice_hat_quad livarea, lcolor(red) lwidth(medium) lpattern(dash)), ///
       legend(order(2 "Linear Model" 3 "Quadratic Model") position(6)) ///
       title("Sale Price vs Living Area: Linear and Quadratic Models") ///
       xtitle("Living Area (square feet)") ///
       ytitle("Sale Price ($)") ///
       name(fitted_comparison, replace)

* Display SSE comparison
display "===========================================" 
display "SSE Comparison:"
display "SSE Linear Model: " SSE_linear
display "SSE Quadratic Model: " SSE_quad
display "Difference (Linear - Quadratic): " SSE_linear - SSE_quad
display "==========================================="

* Export combined graph
graph export "$figures_dir/0205-fitted_comparison.eps", name(fitted_comparison) replace //For latex
graph export "$figures_dir/0205-fitted_comparison.png", name(fitted_comparison) replace //For review

********************************************************************************
* PART E: Quadratic model by lot type (large vs non-large lots)
********************************************************************************

* Check the distribution of lot types
tab lgelot
sum lgelot

* Summary statistics by lot type
bysort lgelot: summarize sprice livarea livarea2

********************************************************************************
* Regression for LARGE LOTS ONLY (lgelot == 1)
********************************************************************************

* Estimate quadratic model for large lots
regress sprice livarea2 if lgelot == 1

* Store results for comparison
estimates store quad_large_lots

* Generate predicted values for large lots
predict sprice_hat_large if lgelot == 1, xb
predict residuals_large if lgelot == 1, residuals

* Calculate SSE for large lots
gen squared_resid_large = residuals_large^2 if lgelot == 1
quietly sum squared_resid_large
scalar SSE_large = r(sum)
display "SSE Large Lots Model: " SSE_large

********************************************************************************
* Regression for NON-LARGE LOTS (lgelot == 0)
********************************************************************************

* Estimate quadratic model for non-large lots
regress sprice livarea2 if lgelot == 0

* Store results for comparison
estimates store quad_small_lots

* Generate predicted values for non-large lots
predict sprice_hat_small if lgelot == 0, xb
predict residuals_small if lgelot == 0, residuals

* Calculate SSE for non-large lots
gen squared_resid_small = residuals_small^2 if lgelot == 0
quietly sum squared_resid_small
scalar SSE_small = r(sum)
display "SSE Non-Large Lots Model: " SSE_small

********************************************************************************
* Compare results side by side
********************************************************************************

* Display comparison table
estimates table quad_large_lots quad_small_lots, ///
    stats(N r2 rmse) b(%9.3f) se(%9.3f) ///
    title("Comparison: Large Lots vs Non-Large Lots - Quadratic Model")

* Alternative detailed comparison
display "==========================================="
display "DETAILED COMPARISON OF QUADRATIC MODELS"
display "==========================================="

* Large lots
quietly regress sprice livarea2 if lgelot == 1
display "LARGE LOTS (lgelot = 1):"
display "Coefficient on livarea2: " _b[livarea2]
display "Constant: " _b[_cons]
display "R-squared: " e(r2)
display "RMSE: " e(rmse)
display "N: " e(N)
display "---"

* Non-large lots
quietly regress sprice livarea2 if lgelot == 0
display "NON-LARGE LOTS (lgelot = 0):"
display "Coefficient on livarea2: " _b[livarea2]
display "Constant: " _b[_cons]
display "R-squared: " e(r2)
display "RMSE: " e(rmse)
display "N: " e(N)
display "==========================================="

********************************************************************************
* Calculate marginal effects at 1500 sq ft for both groups
********************************************************************************

* For large lots
quietly regress sprice livarea2 if lgelot == 1
scalar me_large_1500 = 2*_b[livarea2]*1500
display "Marginal effect at 1500 sq ft for LARGE lots: " me_large_1500
display "Effect of 100 additional sq ft for LARGE lots: " me_large_1500*100

* For non-large lots
quietly regress sprice livarea2 if lgelot == 0
scalar me_small_1500 = 2*_b[livarea2]*1500
display "Marginal effect at 1500 sq ft for NON-LARGE lots: " me_small_1500
display "Effect of 100 additional sq ft for NON-LARGE lots: " me_small_1500*100

display "Difference in marginal effects: " me_large_1500 - me_small_1500

********************************************************************************
* Create comparison graph with fitted lines for both lot types
********************************************************************************

* Sort for smooth lines
sort livarea

* Graph with fitted lines by lot type
twoway (scatter sprice livarea if lgelot==1, msize(tiny) mcolor(blue%30)) ///
       (scatter sprice livarea if lgelot==0, msize(tiny) mcolor(red%30)) ///
       (line sprice_hat_large livarea if lgelot==1, lcolor(blue) lwidth(medium)) ///
       (line sprice_hat_small livarea if lgelot==0, lcolor(red) lwidth(medium) lpattern(dash)), ///
       legend(order(3 "Large Lots" 4 "Non-Large Lots") position(6)) ///
       title("Quadratic Model: Large vs Non-Large Lots") ///
       xtitle("Living Area (square feet)") ///
       ytitle("Sale Price ($)") ///
       name(lots_comparison, replace)

* Export graph
graph export "$figures_dir/0205-lots_comparison.eps", name(lots_comparison) replace
graph export "$figures_dir/0205-lots_comparison.png", name(lots_comparison) replace

********************************************************************************
* Test if coefficients are statistically different between groups
********************************************************************************

* Create interaction term
gen livarea2_lgelot = livarea2 * lgelot

* Run pooled regression with interaction
regress sprice livarea2 lgelot livarea2_lgelot

* Test if the interaction is significant
test livarea2_lgelot
display "P-value for difference in livarea2 coefficient: " r(p)

* Clean up temporary variables
drop squared_resid_large squared_resid_small

********************************************************************************
* PART F: Models with house age
********************************************************************************

* Create scatter plot of price vs age
scatter sprice age, ///
    title("Sale Price vs House Age") ///
    xtitle("Age (years)") ///
    ytitle("Sale Price ($)") ///
    msize(tiny) mcolor(navy%30) ///
    name(price_age_scatter, replace)
	
* Export graph
graph export "$figures_dir/0205-price_age_scatter.eps", name(price_age_scatter) replace
graph export "$figures_dir/0205-price_age_scatter.png", name(price_age_scatter) replace

* Linear model: sprice = β₀ + β₁*age + u
regress sprice age
estimates store linear_age

* Generate predicted values for linear model
predict sprice_hat_age_lin, xb

* Create log of sale price for log-linear model
gen ln_sprice = ln(sprice)
label variable ln_sprice "Natural log of sale price"

* Log-linear model: ln(sprice) = β₀ + β₁*age + u
regress ln_sprice age
estimates store loglinear_age

* Generate predicted values for log-linear model
predict ln_sprice_hat, xb
gen sprice_hat_age_log = exp(ln_sprice_hat)

* Sort for smooth lines
sort age

* Graph with both fitted lines
twoway (scatter sprice age, msize(tiny) mcolor(gray%20)) ///
       (line sprice_hat_age_lin age, lcolor(blue) lwidth(medium)) ///
       (line sprice_hat_age_log age, lcolor(red) lwidth(medium) lpattern(dash)), ///
       legend(order(2 "Linear Model" 3 "Log-linear Model") position(6)) ///
       title("Price vs Age: Model Comparison") ///
       xtitle("Age (years)") ///
       ytitle("Sale Price ($)") ///
       name(age_models_comparison, replace)

* Export graph
graph export "$figures_dir/0205-age_models_comparison.eps", name(age_models_comparison) replace
graph export "$figures_dir/0205-age_models_comparison.png", name(age_models_comparison) replace

* Display and compare model results
estimates table linear_age loglinear_age, ///
    stats(N r2 rmse aic bic) b(%9.4f) se(%9.4f) ///
    title("Comparison: Linear vs Log-linear Model (Age)")

* Interpretation note for log-linear model
display "===========================================" 
display "Log-linear model interpretation:"
display "A one-year increase in age is associated with"
display "approximately " _b[age]*100 "% change in price"
display "==========================================="