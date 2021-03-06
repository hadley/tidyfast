% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/count.R
\name{dt_count}
\alias{dt_count}
\title{Count}
\usage{
dt_count(dt_, ..., na.rm = FALSE, wt = NULL)
}
\arguments{
\item{dt_}{the data table to uncount}

\item{...}{groups}

\item{na.rm}{should any rows with missingness be removed before the count? Default is \code{FALSE}.}

\item{wt}{the wt assigned to the counts (same number of rows as the data)}
}
\value{
A data.table with counts for each group (or combination of groups)
}
\description{
Count the numbers of observations within groups
}
\examples{

library(data.table)
dt <- data.table(
  x = rnorm(1e5),
  y = runif(1e5),
  grp = sample(1L:3L, 1e5, replace = TRUE),
  wt = runif(1e5, 1, 100)
  )

dt_count(dt, grp)
dt_count(dt, grp, na.rm = TRUE)
dt_count(dt, grp, na.rm = TRUE, wt = wt)

}
