.datatable.aware= TRUE

#' Limited loss to the layer
#'
#' @param x event loss
#' @param Excess treaty retention
#' @param Limit treaty limit
#'
#' @return limited loss to the layer
#' @examples
#' layer_loss(5,2,6)
#' layer_loss(5,10,6)
#'
#' @export

layer_loss <- function(x, Excess, Limit){
  pmin(pmax(x - Excess, 0), Limit)
}



#' Create parameters for ELT simulation
#'
#' @param dt an ELT (Event Loss Table)
#' @param ann_rate a vector of annual rates for each event
#' @param mu a vector of mean event loss
#' @param sdev_i a vector of independent standard deviations
#' @param sdev_c a vector of correlated standard deviations
#' @param expval the total values exposed in each event
#'
#' @return a data.table object with mean damage ratio, total standard deviation and alpha/beta parameters
#' @export

create_elt <- function(dt, ann_rate, mu , sdev_i, sdev_c, expval) {

  mdr <- sdev <- cov <- alpha <- beta  <- random_num <- NULL # avoid the no visible binding for global variable when running R_CMD_CHECK


  dt[ , mdr := get(mu)/get(expval)]
  dt[, sdev := get(sdev_i) + get(sdev_c)]
  dt[, cov :=  sdev /get(mu) ]
  dt[, alpha := ( (1- mdr)/ (cov^2) - mdr) ]

  dt$alpha[!is.finite(dt$alpha)] <- 0

  dt[ , beta := (alpha * (1- mdr))/mdr  ]

  lda <- sum(dt[, get(ann_rate)] )

  dt[ , random_num := get(ann_rate)/ lda]


  data.table::data.table(dt)

}




#' Create a YLT from ELT via monte carlo simulation
#'
#' @param dt a data.table with modified ELT
#' @param sims number of years to simulate
#' @param ann_rate event frequency
#' @param event_id unique event identifier
#' @param expval total amount exposed
#' @param mu mean event loss
#'
#' @return a tidy data.table with Loss, Year and ID. Where a year simulated with zero events will show as "none"
#' @export

create_ylt <- function(dt, sims, ann_rate, event_id, expval, mu){

  Year <- NULL # avoid the no visible binding for global variable when running R_CMD_CHECK
  set.seed(1)
  yr<-1:sims
  lda <-  sum(dt[, get(ann_rate)])
  sim_events <- stats::rpois(n = sims, lambda = lda)

  row_port <- sample(x = 1:length(dt[,get(event_id)]), size = sum(sim_events), replace = TRUE, prob = dt$random_num)

  event_loss_port<- ifelse( dt$alpha[row_port]>0, stats::rbeta(length(row_port), dt$alpha[row_port], dt$beta[row_port])*dt[,get(expval)][row_port],dt[,get(mu)][row_port])

  lossNo_port <-  rep(yr, times= sim_events)

  event_loss_port <- data.table(EventID = dt[,get(event_id)][row_port], Loss= event_loss_port, Year=lossNo_port)

  zero_port <- yr[!(yr%in% lossNo_port)]

  try(zero_yrs_port <- data.table(Loss=0, Year=zero_port, Event="None"), silent = TRUE)

  EventDT_Port <- data.table(Year=lossNo_port,  Loss=event_loss_port$Loss, Event= dt[,get(event_id)][row_port])
  try(EventDT_Port <- rbind(EventDT_Port, zero_yrs_port), silent=TRUE)


  EventDT_Port <- EventDT_Port[order(Year)]

  EventDT_Port[]


}


#' OEP Curve
#'
#' @param dt aggregate annual YLT
#' @param y vector of year
#' @param z vector of loss amount
#' @param rp return period default points=  c(10000,5000,1000,500,250,200,100,50, 25,10,5 , 2)
#'
#' @return a vector of OEP at return periods as specified by the argument rp
#' @export

create_oep_curve <- function(dt, y, z, rp =  c(10000,5000,1000,500,250,200,100,50, 25,10,5 , 2)){


  Max_Port <- dt[, max(get(z)) , by=get(y)]

  data.table(return_period=rp, OEP=sapply(1 - 1/rp, function(x) stats::quantile(Max_Port$V1, x)) )

}









