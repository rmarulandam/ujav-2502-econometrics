********************************************************************************
* sleep75
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

bcuse sleep75

* Display basic information about the dataset
describe
summarize
set pformat %5.4f

********************************************************************************
* PART A: Men and women
********************************************************************************

regress sleep totwrk educ age agesq yngkid if male==1

regress sleep totwrk educ age agesq yngkid if male==0

// Part c: Chow test with interactions
gen male_totwrk = male * totwrk
gen male_educ = male * educ
gen male_age = male * age
gen male_agesq = male * agesq
gen male_yngkid = male * yngkid

regress sleep totwrk educ age agesq yngkid male male_totwrk male_educ male_age male_agesq male_yngkid

test male male_totwrk male_educ male_age male_agesq male_yngkid

// Part d: Test slope interactions
test male_totwrk male_educ male_age male_agesq male_yngkid