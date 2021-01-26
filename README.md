
<!-- README.md is generated from README.Rmd. Please edit that file -->

# eltr <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R build
status](https://github.com/RandhirBilkhu/eltr/workflows/R-CMD-check/badge.svg)](https://github.com/RandhirBilkhu/eltr/actions)
[![Codecov test
coverage](https://codecov.io/gh/RandhirBilkhu/eltr/branch/main/graph/badge.svg)](https://codecov.io/gh/RandhirBilkhu/eltr?branch=main)
\[![cran version](https://www.r-pkg.org/badges/version/eltr)\]
\[![downloads](https://cranlogs.r-pkg.org/badges/grand-total/eltr)\]
<!-- badges: end -->

The goal of eltr is to help analysis of catastrophe model outputs.

## Installation

You can install the version on
[Cran](https://cran.r-project.org/web/packages/eltr/index.html) with:

``` r
install.packages("eltr")
```

You can install the development version from
[GitHub](https://github.com/RandhirBilkhu/eltr) with:

``` r
# install.packages("devtools")
devtools::install_github("RandhirBilkhu/eltr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(eltr)
## load a rawelt file

raw_elt <- eltr::example_elt

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
#> Warning in stats::rbeta(length(row_port), dt$alpha[row_port],
#> dt$beta[row_port]): NAs produced

ylt
#>     Year         Loss Event
#>  1:    1 1.735283e+03     8
#>  2:    1 2.100043e+00     8
#>  3:    2 0.000000e+00  None
#>  4:    3 7.703610e+01     5
#>  5:    4 1.000000e+02     4
#>  6:    4 3.327224e+02     8
#>  7:    5 0.000000e+00  None
#>  8:    6 4.105593e+01     6
#>  9:    6 4.615862e-10     6
#> 10:    7 7.318917e+02     5
#> 11:    7 5.438283e+03     6
#> 12:    7 1.207238e+01     1
#> 13:    7 4.462111e+00     8
#> 14:    7 5.294585e+02     9
#> 15:    8 1.156734e+02     6
#> 16:    8 7.081805e+00     3
#> 17:    8 1.000000e+02     4
#> 18:    9 1.188404e+03     9
#> 19:   10 0.000000e+00  None

### calculate AAL and OEP

ann <-ylt[ ,Loss :=sum(Loss) , by=Year]

ep <- create_oep_curve(ann , y= "Year", z="Loss")
```

<a target="_blank" href="https://icons8.com/icons/set/hurricane">Hurricane
icon</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
