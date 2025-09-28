/*******************************************************************************
* STATA DO-FILE for CAPM Analysis
*******************************************************************************/

* --- 1. SETUP ---

clear all

cd "C:\repos\ujav-2502-econometrics\Data" 

* --- 2. LOAD AND PREPARE DATA ---

use "ecnm-2502-hwrk-0204.dta" /// equivalent to "cpmn4.dta"

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

* "------------------------------------------------------------------"
* "1. Estimating CAPM for Microsoft"
* "------------------------------------------------------------------"
regress msft_ex mktrf

* "------------------------------------------------------------------"
* "2. Estimating CAPM for General Electric (GE)"
* "------------------------------------------------------------------"
regress ge_ex mktrf

* "------------------------------------------------------------------"
* "3. Estimating CAPM for General Motors (GM)"
* "------------------------------------------------------------------"
regress gm_ex mktrf

* "------------------------------------------------------------------"
* "4. Estimating CAPM for IBM"
* "------------------------------------------------------------------"
regress ibm_ex mktrf

* "------------------------------------------------------------------"
* "5. Estimating CAPM for Disney"
* "------------------------------------------------------------------"
regress dis_ex mktrf

* "------------------------------------------------------------------"
* "6. Estimating CAPM for Mobil-Exxon"
* "------------------------------------------------------------------"
regress xom_ex mktrf

* Constrained models (alpha = 0)
* "------------------------------------------------------------------"
* "1. Microsoft - Constrained (alpha = 0)"
* "------------------------------------------------------------------"
regress msft_ex mktrf, noconstant


* "------------------------------------------------------------------"
* "2. General Electric - Constrained (alpha = 0)"
* "------------------------------------------------------------------"
regress ge_ex mktrf, noconstant


* "------------------------------------------------------------------"
* "3. General Motors - Constrained (alpha = 0)"
* "------------------------------------------------------------------"
regress gm_ex mktrf, noconstant


* "------------------------------------------------------------------"
* "4. IBM - Constrained (alpha = 0)"
* "------------------------------------------------------------------"
regress ibm_ex mktrf, noconstant


* "------------------------------------------------------------------"
* "5. Disney - Constrained (alpha = 0)"
* "------------------------------------------------------------------"
regress dis_ex mktrf, noconstant


* "------------------------------------------------------------------"
* "6. Exxon-Mobil - Constrained (alpha = 0)"
* "------------------------------------------------------------------"
regress xom_ex mktrf, noconstant

