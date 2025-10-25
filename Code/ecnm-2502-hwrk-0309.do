********************************************************************************
* DISCRIM
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

bcuse discrim

* Display basic information about the dataset
describe
summarize
set pformat %5.4f

********************************************************************************
* PART A: Summary statistics for prpblck and income
********************************************************************************

summarize prpblck income

********************************************************************************
* PART B: Regression of psoda on prpblck and income
********************************************************************************

regress psoda prpblck income

********************************************************************************
* PART C: Simple regression of psoda on prpblck
********************************************************************************

regress psoda prpblck

// Part d: Log model - log(psoda) on prpblck and log(income)
gen lpsoda = log(psoda)
gen lincome = log(income)
regress lpsoda prpblck lincome

// Part e: Add prppov to the log model
regress lpsoda prpblck lincome prppov

// Part f: Correlation between log(income) and prppov
correlate lincome prppov