% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cat_functions.R
\name{create_elt}
\alias{create_elt}
\title{Create parameters for ELT simulation}
\usage{
create_elt(dt, ann_rate, mu, sdev_i, sdev_c, expval)
}
\arguments{
\item{dt}{an ELT (Event Loss Table)}

\item{ann_rate}{a vector of annual rates for each event}

\item{mu}{a vector of mean event loss}

\item{sdev_i}{a vector of independent standard deviations}

\item{sdev_c}{a vector of correlated standard deviations}

\item{expval}{the total values exposed in each event}
}
\value{
a data.table object with mean damage ratio, total standard deviation and alpha/beta parameters
}
\description{
Create parameters for ELT simulation
}
\examples{
create_elt (eltr::example_elt, ann_rate="rate", mu="mean", 
           sdev_i = "sdevi" , sdev_c = "sdevc", expval = "exp")

}
