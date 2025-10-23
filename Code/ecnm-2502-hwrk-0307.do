clear all

use WAGE2.RAW

gen lwage = log(wage)

// Part a
regress lwage educ exper tenure married black south urban

// Part b
gen exper2 = exper^2
gen tenure2 = tenure^2
regress lwage educ exper exper2 tenure tenure2 married black south urban
test exper2 tenure2

// Part c
gen black_educ = black * educ
regress lwage educ exper tenure married black south urban black_educ
test black_educ

// Part d
gen married_black = married * black
regress lwage educ exper tenure married black married_black south urban
lincom black + married_black