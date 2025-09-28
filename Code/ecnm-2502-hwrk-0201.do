********************************************************************************
* ECONOMETRICS ANALYSIS - WAGE1 DATASET
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

use "$data_dir/ecnm-2502-hwrk-0201.dta" /// equivalent to "wage1.dta"

********************************************************************************
* PART A: DESCRIPTIVE STATISTICS AND HISTOGRAMS
********************************************************************************

* Calculate descriptive statistics for wage, educ, exper, tenure, and numdep
summarize wage educ exper tenure numdep, detail
estpost summarize wage educ exper tenure numdep
esttab using "$tables_dir\descriptive_statistics.tex", replace ///
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
graph export "$figures_dir/0201-hist_wage.eps", name(hist_wage) replace //For latex
graph export "$figures_dir/0201-hist_wage.png", name(hist_wage) replace //For review
graph export "$figures_dir/0201-hist_educ.eps", name(hist_educ) replace //For latex
graph export "$figures_dir/0201-hist_educ.png", name(hist_educ) replace //For review  
graph export "$figures_dir/0201-hist_expr.eps", name(hist_exper) replace // For latex
graph export "$figures_dir/0201-hist_expr.png", name(hist_exper) replace // For review
graph export "$figures_dir/0201-hist_tenr.eps", name(hist_tenure) replace // For latex
graph export "$figures_dir/0201-hist_tenr.png", name(hist_tenure) replace // For review
graph export "$figures_dir/0201-hist_numd.eps", name(hist_numdep) replace // For latex
graph export "$figures_dir/0201-hist_numd.eps", name(hist_numdep) replace // For review

********************************************************************************
* PART B: DESCRIPTIVE STATISTICS FOR CATEGORICAL VARIABLES
********************************************************************************

* Tabulate nonwhite variable
tabulate nonwhite

* Export nonwhite tabulation to LaTeX
estpost tabulate nonwhite
esttab using "$tables_dir\0201-nonwhite_frequency.tex", replace ///
    cell(b(fmt(0)) pct(fmt(1))) ///
	unstack ///
    booktabs ///
    title("Distribution by Race") ///
	substitute("\caption{Distribution by Race}" "\caption{Distribution by Race}\label{tab:0201-nonwhite_frequency}") ///
    addnote("Frequency and percentage shown")	
	
* Tabulate female variable
tabulate female

* Export female tabulation to LaTeX
estpost tabulate female
esttab using "$tables_dir/0201-female_frequency.tex", replace ///
    cell(b(fmt(0)) pct(fmt(1))) ///
    unstack ///
    booktabs ///
    title("Distribution by Gender") ///
	substitute("\caption{Distribution by Gender}" "\caption{Distribution by Gender}\label{tab:0201-female_frequency}") ///
    addnote("Frequency and percentage shown")

* Tabulate married variable
tabulate married

* Export married tabulation to LaTeX
estpost tabulate married
esttab using "$tables_dir/0201-married_frequency.tex", replace ///
    cell(b(fmt(0)) pct(fmt(1))) ///
    unstack ///
    booktabs ///
    title("Distribution by Marital Status") ///
	substitute("\caption{Distribution by Marital Status}" "\caption{Distribution by Marital Status}\label{tab:0201-married_frequency}") ///
    addnote("Frequency and percentage shown")

* Descriptive statistics by nonwhite status
bysort nonwhite: summarize wage educ exper tenure

* Create formatted table of means by race
estpost tabstat wage educ exper tenure, by(nonwhite) statistics(mean sd count) columns(statistics)
esttab using "$tables_dir/0201-descriptives_by_race.tex", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
    booktabs ///
    title("Descriptive Statistics by Race") ///
    mtitles("White" "Non-White") ///
	substitute("\caption{Descriptive Statistics by Race}" "\caption{Descriptive Statistics by Race}\label{tab:0201-descriptives_by_race}") ///
    addnote("Standard deviations shown below means")

* Descriptive statistics by gender
bysort female: summarize wage educ exper tenure

* Create formatted table of means by gender
estpost tabstat wage educ exper tenure, by(female) statistics(mean sd count) columns(statistics)
esttab using "$tables_dir/0201-descriptives_by_gender.tex", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
    booktabs ///
    title("Descriptive Statistics by Gender") ///
    mtitles("Male" "Female") ///
	substitute("\caption{Descriptive Statistics by Gender}" "\caption{Descriptive Statistics by Gender}\label{tab:0201-descriptives_by_gender}") ///    
    addnote("Standard deviations shown below means")

* Descriptive statistics by marital status
bysort married: summarize wage educ exper tenure

* Create formatted table of means by marital status
estpost tabstat wage educ exper tenure, by(married) statistics(mean sd count) columns(statistics)
esttab using "$tables_dir/0201-descriptives_by_marital.tex", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
    booktabs ///
    title("Descriptive Statistics by Marital Status") ///
    mtitles("Single" "Married") ///
	substitute("\caption{Descriptive Statistics by Marital Status}" "\caption{Descriptive Statistics by Marital Status}\label{tab:0201-descriptives_by_marital}") ///
    addnote("Standard deviations shown below means")

* =================================================================
* CROSS-TABULATIONS WITH LATEX EXPORT
* =================================================================

* Cross-tabulation: race and gender
tab2 nonwhite female, row column cell

* Export cross-tabulation to LaTeX
estpost tabulate nonwhite female
esttab using "$tables_dir/0201-crosstab_race_gender.tex", replace ///
    cell(b(fmt(0))) ///
    booktabs ///
    title("Cross-tabulation: Race by Gender") ///
	substitute("\caption{Cross-tabulation: Race by Gender}" "\caption{Cross-tabulation: Race by Gender}\label{tab:0201-crosstab_race_gender}") ///
    addnote("Cell frequencies shown")

* Cross-tabulation: race and marital status
tab2 nonwhite married, row column cell

* Export to LaTeX
estpost tabulate nonwhite married
esttab using "$tables_dir/0201-crosstab_race_married.tex", replace ///
    cell(b(fmt(0))) ///
    booktabs ///
    title("Cross-tabulation: Race by Marital Status") ///
	substitute("\caption{Cross-tabulation: Race by Marital Status}" "\caption{Cross-tabulation: Race by Marital Status}\label{tab:0201-crosstab_race_married}") ///
    addnote("Cell frequencies shown")

* Cross-tabulation: gender and marital status  
tab2 female married, row column cell

* Export to LaTeX
estpost tabulate female married
esttab using "$tables_dir/0201-crosstab_gender_married.tex", replace ///
    cell(b(fmt(0))) ///
    booktabs ///
    title("Cross-tabulation: Gender by Marital Status") ///
	substitute("\caption{Cross-tabulation: Gender by Marital Status}" "\caption{Cross-tabulation: Gender by Marital Status}\label{tab:0201-crosstab_gender_married}") ///
    addnote("Cell frequencies shown")

* =================================================================
* THREE-WAY TABULATION (DISPLAY ONLY - NOT EXPORTED TO LATEX)
* =================================================================

* Three-way tabulation - display results in Stata output
display as text "Three-way tabulation (Race × Gender × Marital Status):"
table nonwhite female married, statistic(frequency)

* =================================================================
* SUMMARY TABLE OF ALL CATEGORICAL VARIABLES
* =================================================================

* Create a comprehensive summary of all categorical variables
estpost tabstat nonwhite female married, statistics(mean count) columns(statistics)
esttab using "$tables_dir/0201-categorical_summary.tex", replace ///
    cells("mean(fmt(3)) count(fmt(0))") ///
    booktabs ///
    title("Summary of Categorical Variables") ///
	substitute("\caption{Summary of Categorical Variables}" "\caption{Summary of Categorical Variables}\label{tab:0201-categorical_summary}") ///
    addnote("Proportions and sample sizes shown")

********************************************************************************
* PART C: COUNT NON-WHITE FEMALES
********************************************************************************

* Calculate number of non-white females in the sample
count if nonwhite == 1 & female == 1
display "Number of non-white females: " r(N)

********************************************************************************
* PART D: COUNT WHITE MARRIED MALES
********************************************************************************

* Calculate number of white married males
count if nonwhite == 0 & married == 1 & female == 0
display "Number of white married males: " r(N)

* Cross-check with tabulation
tab married if nonwhite == 0 & female == 0

********************************************************************************
* PART E: COUNT WHITE SINGLE FEMALES
********************************************************************************

* Calculate number of white single females
count if nonwhite == 0 & married == 0 & female == 1
display "Number of white single females: " r(N)

* Cross-check with tabulation
tab married if nonwhite == 0 & female == 1

********************************************************************************
* PART F: COVARIANCE AND CORRELATION ANALYSIS
********************************************************************************

* Correlation matrix for continuous variables
correlate wage educ exper tenure numdep

* Covariance matrix
correlate wage educ exper tenure numdep, covariance


