*******************************************************
* Correlations — z ~ N(0,1), y=5+z, w=5+3z
* Save as: simulate_corr.do
*******************************************************

clear all

set seed 12345

*---------------------------
* 1) Generate data
*---------------------------
set obs 500
generate double z = rnormal(0,1)     // z_i ~ N(0,1)
generate double y = 5 + z            // shift only
generate double w = 5 + 3*z          // shift + scale

* Quick checks
summarize z y w

*---------------------------
* 2) Histograms (frequencies)
*---------------------------
histogram z, frequency bin(20) normal ///
    title("Histogram of z ~ N(0,1) (n=500)") ///
    xtitle("z") ytitle("Frequency") name(h_z, replace)
graph export "hist_z.png", replace

histogram y, frequency bin(20) ///
    title("Histogram of y = 5 + z (shifted)") ///
    xtitle("y") ytitle("Frequency") name(h_y, replace)
graph export "hist_y.png", replace

histogram w, frequency bin(20) ///
    title("Histogram of w = 5 + 3z (shifted & scaled)") ///
    xtitle("w") ytitle("Frequency") name(h_w, replace)
graph export "hist_w.png", replace

*---------------------------
* 3) Correlations (Stata)
*---------------------------
display as text "Pairwise correlations from Stata:"
corr z y w