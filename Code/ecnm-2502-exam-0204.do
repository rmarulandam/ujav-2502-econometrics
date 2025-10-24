********************************************************************************
* GOLD AND STOCKS
********************************************************************************

* --- 1. SETUP ---
clear all

* Defining directory structure
global project_root "C:\repos\ujav-2502-econometrics"
global code_dir "$project_root\Code"
global figures_dir "$project_root\Figures"
global tables_dir "$project_root\Tables"
global data_dir "$project_root\Data"

cd "$project_root"

* --- 2. LOAD AND PREPARE DATA ---

* Import data from Excel
import excel "$data_dir/ecnm-2502-exam-0204.xlsx", firstrow clear

* Rename variables to English
rename Año Year
rename Preciodeloro GoldPrice
rename BVNY NYSE
rename IPC CPI

* Check structure of dataset
describe

* Generate summary statistics
summarize

* Detailed summary statistics for all three variables
summarize GoldPrice CPI NYSE, detail

********************************************************************************
* PART A: SCATTER PLOT - ALL THREE VARIABLES IN ONE DIAGRAM
********************************************************************************
graph twoway (scatter GoldPrice Year, mcolor(gold)) ///
             (scatter NYSE Year, mcolor(blue)) ///
             (scatter CPI Year, mcolor(red)), ///
             title("Gold Price, NYSE Index, and CPI") ///
             xtitle("Years") ///
             ytitle("Values") ///
             legend(order(1 "Gold Price" 2 "NYSE Index" 3 "CPI"))

graph export "$figures_dir/combined_scatter.png", replace


********************************************************************************
* PART B: REGRESSION ANALYSIS
********************************************************************************

regress GoldPrice CPI

regress NYSE CPI