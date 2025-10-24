********************************************************************************
* CollegeDistance
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

use "$data_dir/ecnm-2502-pexm-0202.dta" /// equivalent to "CollegeDistance.dta"

* Display basic information about the dataset
describe
summarize dist ed

* Diagrama de dispersión básico
twoway (scatter growth tradeshare), ///
    title("Relación entre Crecimiento y Comercio" ///
          "65 países, 1960-1995") ///
    xtitle("Participación del Comercio (TradeShare)") ///
    ytitle("Tasa de Crecimiento Anual Media (%)") ///
    note("Fuente: Growth dataset (Stock & Watson)")
graph export "scatter_growth_trade.png", replace

* Diagrama mejorado con línea de ajuste
twoway (scatter growth tradeshare) ///
       (lfit growth tradeshare), ///
    title("Crecimiento vs. Participación del Comercio") ///
    xtitle("Participación del Comercio (TradeShare)") ///
    ytitle("Tasa de Crecimiento Anual Media (%)") ///
    legend(order(1 "Países observados" 2 "Línea de ajuste")) ///
    note("Fuente: Growth dataset, 1960-1995")
graph export "scatter_growth_trade_fit.png", replace




