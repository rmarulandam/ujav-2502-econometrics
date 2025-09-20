clear
set obs 100
gen double i = (_n - 50)/25
gen n = _n

* --- PDFs on the grid i ---
gen double d_norm  = normalden(i)      // φ(i), N(0,1)
gen double d_t1    = tden(1,   i)      // t with ν=1
gen double d_t5    = tden(5,   i)      // t with ν=5
gen double d_t100  = tden(100, i)      // t with ν=100

* --- Plot (overlay) ---
twoway ///
 (line d_norm  i, lpattern(solid)) ///
 (line d_t1    i, lpattern(dash))  ///
 (line d_t5    i, lpattern(shortdash)) ///
 (line d_t100  i, lpattern(dot)), ///
 title("PDFs: Normal(0,1) vs. t(ν)") ///
 xtitle("i") ytitle("Density") ///
 legend(order(1 "Normal(0,1)" 2 "t(1)" 3 "t(5)" 4 "t(100)"))
 
 *******************************************************
* Normal(0,1) vs t(1), t(5), t(100)
*******************************************************
clear all

set seed 12345

* ----- 1) Simulate 10,000 observations -----
set obs 10000

gen double x    = rnormal()                         // N(0,1)
gen double t1   = rnormal() / sqrt(rchi2(1)/1)      // t(1)  via Z / sqrt(Chi2/df)
gen double t5   = rnormal() / sqrt(rchi2(5)/5)      // t(5)
gen double t100 = rnormal() / sqrt(rchi2(100)/100)  // t(100)

* 2) Prepare result matrix: rows= dists, cols= sample & theoretical moments
matrix M = J(4, 8, .)
matrix colnames M = mean var skew kurt t_mean t_var t_skew t_kurt
matrix rownames M = Normal t1 t5 t100

* --- Normal(0,1) ---
quietly summarize x, detail
local m = r(mean)
local V = r(Var)
local s = r(skewness)
local k = r(kurtosis)
matrix M[1,1] = `m', `V', `s', `k', 0, 1, 0, 3

* --- t(1): theoretical moments undefined ---
quietly summarize t1, detail
local m = r(mean)
local V = r(Var)
local s = r(skewness)
local k = r(kurtosis)
matrix M[2,1] = `m', `V', `s', `k', ., ., ., .

* --- t(5) ---
quietly summarize t5, detail
local m = r(mean)
local V = r(Var)
local s = r(skewness)
local k = r(kurtosis)
matrix M[3,1] = `m', `V', `s', `k', 0, 5/(5-2), 0, 3*(5-2)/(5-4)

* --- t(100) ---
quietly summarize t100, detail
local m = r(mean)
local V = r(Var)
local s = r(skewness)
local k = r(kurtosis)
matrix M[4,1] = `m', `V', `s', `k', 0, 100/(100-2), 0, 3*(100-2)/(100-4)

display as text "== Sample and theoretical moments =="
matrix list M

* 3) Deviations: (sample - theoretical) for the moments
matrix D = M[.,1..4] - M[.,5..8]
matrix colnames D = d_mean d_var d_skew d_kurt
matrix rownames D = Normal t1 t5 t100

display as text "== Deviations (sample - theoretical) =="
matrix list D

* ----- 3) Histograms + Kernel density for each variable -----
twoway (hist x,    density bin(40)) (kdensity x),    ///
    title("x ~ Normal(0,1)") xtitle("x") ytitle("Density") ///
    name(gx, replace)
graph export "hist_x.png", replace

twoway (hist t1,   density bin(40)) (kdensity t1),   ///
    title("t(1)") xtitle("t1") ytitle("Density") ///
    name(gt1, replace)
graph export "hist_t1.png", replace

twoway (hist t5,   density bin(40)) (kdensity t5),   ///
    title("t(5)") xtitle("t5") ytitle("Density") ///
    name(gt5, replace)
graph export "hist_t5.png", replace

twoway (hist t100, density bin(40)) (kdensity t100), ///
    title("t(100)") xtitle("t100") ytitle("Density") ///
    name(gt100, replace)
graph export "hist_t100.png", replace

