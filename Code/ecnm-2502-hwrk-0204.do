/*******************************************************************************
* STATA DO-FILE for CAPM Analysis
*
* Description: This script estimates the Capital Asset Pricing Model (CAPM)
* for six different companies to determine their market risk (beta).
* Data file:   capm4.dat
* Date:        September 17, 2025
*******************************************************************************/

* --- 1. SETUP ---
* Clear any previous session and set Stata to not pause on long outputs
clear all
set more off

cd "C:\repos\Econometrics\hwrk-0204" 

* --- 2. LOAD AND PREPARE DATA ---

use "capm4.dta", clear

* See the data and variable names after loading
describe

* a) Market excess return (market return - risk-free rate)
gen mktrf = mkt - riskfree
label var mktrf "Market Excess Return (MKT - RF)"

* b) Company excess returns (company return - risk-free rate)
gen msft_ex = msft - riskfree
gen ge_ex   = ge - riskfree
gen gm_ex   = gm - riskfree
gen ibm_ex  = ibm - riskfree
gen dis_ex  = dis - riskfree
gen xom_ex  = xom - riskfree

* Label the new variables for clarity
label var msft_ex "Microsoft Excess Return"
label var ge_ex   "GE Excess Return"
label var gm_ex   "GM Excess Return"
label var ibm_ex  "IBM Excess Return"
label var dis_ex  "Disney Excess Return"
label var xom_ex  "Mobil-Exxon Excess Return"


* --- 3. ESTIMATE CAPM FOR EACH COMPANY ---
* The CAPM model is: company_excess_return = alpha + beta * market_excess_return
* A simple linear regression for each company is runned. The estimated coefficient
* on the `mktrf` variable is the company's Beta.

di ""
di "------------------------------------------------------------------"
di "1. Estimating CAPM for Microsoft"
di "------------------------------------------------------------------"
regress msft_ex mktrf

di ""
di "------------------------------------------------------------------"
di "2. Estimating CAPM for General Electric (GE)"
di "------------------------------------------------------------------"
regress ge_ex mktrf

di ""
di "------------------------------------------------------------------"
di "3. Estimating CAPM for General Motors (GM)"
di "------------------------------------------------------------------"
regress gm_ex mktrf

di ""
di "------------------------------------------------------------------"
di "4. Estimating CAPM for IBM"
di "------------------------------------------------------------------"
regress ibm_ex mktrf

di ""
di "------------------------------------------------------------------"
di "5. Estimating CAPM for Disney"
di "------------------------------------------------------------------"
regress dis_ex mktrf

di ""
di "------------------------------------------------------------------"
di "6. Estimating CAPM for Mobil-Exxon"
di "------------------------------------------------------------------"
regress xom_ex mktrf
