#' Limited event loss to the layer
#'
#' @param x event loss mean
#' @param Excess treaty retention
#' @param Limit treaty limit
#'
#' @return limited loss to the layer
#' @export

layer_loss <- function(x, Excess, Limit){
  pmin(pmax(x - Excess, 0), Limit)
}



#' Create an Event Loss Table with parameters for simulation
#'
#' @param dt a data.table
#'
#' @return ELT
#' @export

create_elt <- function(dt) {

  colnames(dt) <- c("EventID", "Rate", "MeanLoss","StdevI", "StDevC","EdtpVal" , "Description", "Peril","SourceID" )

  as.numeric(dt$Rate)->dt$Rate
  as.numeric( dt$MeanLoss)->dt$MeanLoss
  as.numeric(dt$StdevI)->dt$StdevI
  as.numeric(dt$StDevC)->dt$StDevC
  as.numeric(dt$ExpVal)->dt$ExpVal

  dt$MDr <- dt$MeanLoss/dt$ExpVal
  dt$Stdev <- dt$StdevI + dt$StDevC
  dt$COV <- (dt$Stdev)/dt$MeanLoss
  dt$alpha <-((1-dt$MDr)/(dt$COV^2)) - dt$MDr

  dt$alpha[!is.finite(dt$alpha)] <- 0
  dt$beta <- (dt$alpha*(1-dt$MDr))/dt$MDr

  lda <- sum(dt$Rate)
  dt$random_num <- dt$Rate/lda

  dt

}


#' Create a Year loss table in tidy format
#'
#' @param x a data.table of elt  with parameters
#' @param sims number of years to simulate
#'
#' @return YLT
#' @export

create_ylt <- function (x,  sims) {

  Yr<-1:sims
  lda_Port <- sum(x$Rate)
  x_Port <- rpois(n = sims, lambda = lda_Port)

  row_Port <- sample(x = 1:length(x$EventID), size = sum(x_Port), replace = TRUE, prob = x$random_num)

  event_loss_Port<- ifelse( x$alpha[row_Port]>0, rbeta(length(row_Port), x$alpha[row_Port], x$beta[row_Port])*x$ExpVal[row_Port],x$MeanLoss[row_Port])

  rep(Yr, times= x_Port)->lossNo_Port

  event_loss_Port<- data.table(EventID = x$EventID[row_Port], Loss= event_loss_Port, Year=lossNo_Port, Peril=x$Peril[row_Port])

  zero_Port<- Yr[!(Yr%in% lossNo_Port)]

  try(ZeroYrs_Port<-data.table(Loss=0, Year=zero_Port, Peril="No Loss", Event="None"), silent = T)

  EventDT_Port<-data.table(Year=lossNo_Port,  Loss=event_loss_Port$Loss, Peril= x$Peril[row_Port], Event=x$EventID[row_Port])
  try(EventDT_Port<-rbind(EventDT_Port, ZeroYrs_Port), silent=T)
  EventDT_Port[order(Year)]->EventDT_Port

  EventDT_Port

}





#' Aggregate annual loss by year
#'
#' @param x a YLT
#'
#' @return a data.table with rows = sims
#' @export

annual_loss <- function(x) {

  x[, lapply(.SD , sum, na.rm=T), by= x$Year, .SDcols = c("Loss", "Loss_LAE", "Loss_NetFHCF", "Layer1", "Layer2", "Layer3", "Layer4", "Layer5",  "Layer6")]

}






#' Calculate Occurrence Exceedance Probability
#'
#' @param x a annual loss table
#' @param y a years
#' @param z the loss amount
#'
#' @return ep curve
#' @export

create_ep_curve <-function(x, y, z){
  EP<- c(10000,5000,1000,500,250,200,100,50, 25,10,5 , 2)
  Max_Port <- x[,.(y,z)][, max(z) , by=y]
  OEP_Port<- sapply(1 - 1/EP, function(x) quantile(Max_Port$V1, x))
  OEP_Port

}







