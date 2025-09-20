clear all

set seed 20250813

set obs 250
generate double x = rnormal(0,1)      // x_i ~ N(0,1)
generate double y = rchi2(5)          // y_i ~ chi-square with 5 degrees of freedom

summarize x y

* Hist & kernel for x
twoway (hist x, density bin(20)) (kdensity x), ///
    title("x ~ N(0,1): Histogram + Kernel") ///
    xtitle("x") ytitle("Density") name(gx, replace)

* Hist & kernel for y
twoway (hist y, density bin(20)) (kdensity y), ///
    title("y ~ Chi-square(5): Histogram + Kernel") ///
    xtitle("y") ytitle("Density") name(gy, replace)


* --- New variables W_i = a * x_i  and  Z_i = a + x_i ---
local a = 95 + 86 + 41   // = 222  (9+5+8+6+4+1 for the "sum of digits" interpretation)

gen double W = `a' * x
gen double Z = `a' + x

* Sample moments
summ W Z

graph export "hist_kern_x.png", name(gx) replace
graph export "hist_kern_y.png", name(gy) replace

