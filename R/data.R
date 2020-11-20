#' Example ELT Data
#'
#' This is a mock up of an ELT to help show case the typical structure of the data set and attributes
#'
#' @format a data.table with 10 rows and 6 variables:
#' \describe{
#'   \item{id}{ unique event identifier}
#'   \item{rate}{ the expected annual frequency of occurence of each event}
#'   \item{mean}{the mean event loss if it occurs}
#'   \item{sdevi}{independent component of standard deviation of event loss if it occurs}
#'   \item{sdevc}{correlated component of standard deviation of event loss if it occurs }
#'   \item{exp}{maximum loss equivalent to total limit exposed}
#'   }
"example_elt"
