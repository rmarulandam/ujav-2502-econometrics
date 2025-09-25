********************************************************************************
* ECONOMETRICS ANALYSIS - WAGE1 DATASET
********************************************************************************

* --- 1. SETUP ---
clear all

* Defining directory structure using local macros
local project_root "C:\repos\ujav-2502-econometrics"
local code_dir "`project_root'\Code"
local figures_dir "`project_root'\Figures"
local tables_dir "`project_root'\Tables"
local data_dir "`project_root'\Data"

cd "`project_root'" 

* --- 2. LOAD AND PREPARE DATA ---

use "`data_dir'/ecnm-2502-hwrk-0201.dta", clear /// equivalent to "wage1.dta"

********************************************************************************
* PART A: DESCRIPTIVE STATISTICS AND HISTOGRAMS
********************************************************************************

* Calculate descriptive statistics for wage, educ, exper, tenure, and numdep
*summarize wage educ exper tenure numdep, detail
estpost summarize wage educ exper tenure numdep
esttab using "`tables_dir'\descriptive_statistics.tex", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) min max count") ///
    label booktabs title("Descriptive Statistics")

* Store results in a table format
tabstat wage educ exper tenure numdep, ///
    statistics(count mean sd min p25 p50 p75 max) ///
    columns(statistics) format(%9.2f)

* Create histograms for each variable
* Wage histogram
histogram wage, frequency ///
    title("Frequency Distribution of Wages") ///
    xtitle("Wage (dollars per hour)") ///
    ytitle("Frequency") ///
    scheme(s2color) ///
    name(hist_wage, replace)

* Education histogram    
histogram educ, frequency discrete ///
    title("Frequency Distribution of Education") ///
    xtitle("Years of Education") ///
    ytitle("Frequency") ///
    scheme(s2color) ///
    name(hist_educ, replace)

* Experience histogram
histogram exper, frequency ///
    title("Frequency Distribution of Experience") ///
    xtitle("Years of Experience") ///
    ytitle("Frequency") ///
    scheme(s2color) ///
    name(hist_exper, replace)

* Tenure histogram    
histogram tenure, frequency ///
    title("Frequency Distribution of Tenure") ///
    xtitle("Years with Current Employer") ///
    ytitle("Frequency") ///
    scheme(s2color) ///
    name(hist_tenure, replace)

* Number of dependents histogram
histogram numdep, frequency discrete ///
    title("Frequency Distribution of Number of Dependents") ///
    xtitle("Number of Dependents") ///
    ytitle("Frequency") ///
    scheme(s2color) ///
    name(hist_numdep, replace)

* Export histograms
graph export "`figures_dir'/0201-hist_wage.eps", name(hist_wage) replace //For latex
graph export "`figures_dir'/0201-hist_wage.png", name(hist_wage) replace //For review
graph export "`figures_dir'/0201-hist_educ.eps", name(hist_educ) replace //For latex
graph export "`figures_dir'/0201-hist_educ.png", name(hist_educ) replace //For review  
graph export "`figures_dir'/0201-hist_expr.eps", name(hist_exper) replace // For latex
graph export "`figures_dir'/0201-hist_expr.png", name(hist_exper) replace // For review
graph export "`figures_dir'/0201-hist_tenr.eps", name(hist_tenure) replace // For latex
graph export "`figures_dir'/0201-hist_tenr.png", name(hist_tenure) replace // For review
graph export "`figures_dir'/0201-hist_numd.eps", name(hist_numdep) replace // For latex
graph export "`figures_dir'/0201-hist_numd.eps", name(hist_numdep) replace // For review

********************************************************************************
* PART B: TABULATION AND DESCRIPTIVE STATISTICS FOR CATEGORICAL VARIABLES
********************************************************************************

* Tabulate nonwhite variable
tabulate nonwhite
tab1 nonwhite, missing

* Descriptive statistics by nonwhite status
bysort nonwhite: summarize wage educ exper tenure

* Tabulate female variable
tabulate female
tab1 female, missing

* Descriptive statistics by gender
bysort female: summarize wage educ exper tenure

* Tabulate married variable
tabulate married
tab1 married, missing

* Descriptive statistics by marital status
bysort married: summarize wage educ exper tenure

* Cross-tabulations to understand relationships
tab2 nonwhite female, row column cell
tab2 nonwhite married, row column cell
tab2 female married, row column cell

* Three-way tabulation
table nonwhite female married, statistic(frequency)

********************************************************************************
* PART C: COUNT NON-WHITE FEMALES
********************************************************************************

* Calculate number of non-white females in the sample
count if nonwhite == 1 & female == 1
display "Number of non-white females: " r(N)

* Alternative method using tabulation
tab nonwhite female, cell

* Store the result
gen nonwhite_female = (nonwhite == 1 & female == 1)
sum nonwhite_female
display "Number of non-white females: " r(sum)
drop nonwhite_female

********************************************************************************
* PART D: COUNT WHITE MARRIED MALES
********************************************************************************

* Calculate number of white married males
count if nonwhite == 0 & married == 1 & female == 0
display "Number of white married males: " r(N)

* Alternative method
gen white = (nonwhite == 0)
gen male = (female == 0)
count if white == 1 & married == 1 & male == 1
display "Number of white married males: " r(N)

* Cross-check with tabulation
tab married if nonwhite == 0 & female == 0

********************************************************************************
* PART E: COUNT WHITE SINGLE FEMALES
********************************************************************************

* Calculate number of white single females
count if nonwhite == 0 & married == 0 & female == 1
display "Number of white single females: " r(N)

* Alternative method using generated variables
gen single = (married == 0)
count if white == 1 & single == 1 & female == 1
display "Number of white single females: " r(N)

* Cross-check with tabulation
tab married if nonwhite == 0 & female == 1

********************************************************************************
* PART F: COVARIANCE AND CORRELATION ANALYSIS
********************************************************************************

* Correlation matrix for continuous variables
correlate wage educ exper tenure numdep

* Display correlation matrix with significance levels
pwcorr wage educ exper tenure numdep, sig

* Covariance matrix
correlate wage educ exper tenure numdep, covariance

* Store correlation matrix
matrix C = r(C)
matrix list C

* Store covariance matrix  
correlate wage educ exper tenure numdep, covariance
matrix V = r(C)
matrix list V

* Create a more detailed correlation analysis with observations
pwcorr wage educ exper tenure numdep, obs sig star(0.05)

* Pairwise correlations (handling missing values)
pwcorr wage educ exper tenure numdep, print(0.05)

********************************************************************************
* ADDITIONAL ANALYSES (OPTIONAL BUT USEFUL)
********************************************************************************

* Summary statistics by groups
table female nonwhite married, ///
    statistic(mean wage educ exper) ///
    statistic(sd wage educ exper) ///
    statistic(count wage)

* Check for missing values
misstable summarize

* Generate summary report
log using wage1_analysis.log, replace text
describe
summarize
correlate wage educ exper tenure numdep
tab1 nonwhite female married
log close

********************************************************************************
* EXPORT RESULTS (OPTIONAL)
********************************************************************************

* Export descriptive statistics to Excel
putexcel set wage1_results.xlsx, replace
putexcel A1 = "Wage1 Dataset Analysis Results"
putexcel A3 = "Descriptive Statistics"
tabstat wage educ exper tenure numdep, ///
    statistics(count mean sd min max) save
putexcel A5 = matrix(r(StatTotal))

* Save graphs
graph export "wage_histograms.png", replace

********************************************************************************
* END OF DO FILE
********************************************************************************

* Display final summary
display "======================="
display "Analysis Complete"
display "======================="
describe, short
summarize wage educ exper tenure numdep, detail