
<!-- README.md is generated from README.Rmd. Please edit that file -->

# catr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R build
status](https://github.com/RandhirBilkhu/catr/workflows/R-CMD-check/badge.svg)](https://github.com/RandhirBilkhu/catr/actions)
[![Codecov test
coverage](https://codecov.io/gh/RandhirBilkhu/catr/branch/main/graph/badge.svg)](https://codecov.io/gh/RandhirBilkhu/catr?branch=main)
<!-- badges: end -->

The goal of catr is to help analysis of catastrophe model outputs.

## Installation

You can install the development version from
[GitHub](https://github.com/RandhirBilkhu/catr) with:

``` r
# install.packages("devtools")
devtools::install_github("RandhirBilkhu/catr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(catr)
## load a rawelt file

raw_elt <- catr::example_elt

raw_elt
#>     id rate  mean sdevi sdevc     exp
#>  1:  1 0.10   500   500   200  100000
#>  2:  2 0.10   200   400   100    5000
#>  3:  3 0.20   300   200   400   40000
#>  4:  4 0.10   100   300   500    4000
#>  5:  5 0.20   500   100   200    2000
#>  6:  6 0.25   200   200   500   50000
#>  7:  7 0.01  1000   500   600  100000
#>  8:  8 0.12   250   300   100    5000
#>  9:  9 0.14  1000   500   200    6000
#> 10: 10 0.00 10000  1000   500 1000000

## paramterise elt

elt <- create_elt(raw_elt, ann_rate="rate", mu="mean", sdev_i = "sdevi" , sdev_c = "sdevc", expval = "exp")

## generate a YLT 

ylt <- create_ylt(elt, sims=10 ,ann_rate = "rate" , event_id = "id", expval = "exp" , mu ="mean")

ylt
#>     Year         Loss Event
#>  1:    1 0.000000e+00  None
#>  2:    2 2.963659e+02     5
#>  3:    3 4.353146e-09     6
#>  4:    4 3.086963e+02     8
#>  5:    4 3.337206e+02     3
#>  6:    4 1.429257e-03     2
#>  7:    5 0.000000e+00  None
#>  8:    6 5.525234e+00     3
#>  9:    6 4.838321e+00     8
#> 10:    6 8.642469e+02     7
#> 11:    7 4.338468e+02     3
#> 12:    7 1.357392e+03     2
#> 13:    7 1.317510e+02     1
#> 14:    8 1.204985e+03     5
#> 15:    8 4.033199e+02     8
#> 16:    9 6.361959e-02     6
#> 17:   10 0.000000e+00  None

### calculate AAL and OEP

ann <-ylt[ ,Loss :=sum(Loss) , by=Year]

ep <- create_oep_curve(ann , y= "Year", z="Loss")
```

<a target="_blank" href="https://icons8.com/icons/set/hurricane">Hurricane
icon</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
