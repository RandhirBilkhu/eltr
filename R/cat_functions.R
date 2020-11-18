#' Title
#'
#' @param x
#' @param Excess
#' @param Limit
#'
#' @return
#' @export
#'
#' @examples
Layer <- function(x, Excess, Limit){
  pmin(pmax(x - Excess, 0), Limit)
}

#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
ELT_ANALYSIS <- function(x) {

  colnames(x) <- c("EventID", "Rate", "MeanLoss","StdevI", "StDevC","ExpVal" , "Description", "Peril","SourceID" )

  as.numeric(x$Rate)->x$Rate
  as.numeric( x$MeanLoss)->x$MeanLoss
  as.numeric(x$StdevI)->x$StdevI
  as.numeric(x$StDevC)->x$StDevC
  as.numeric(x$ExpVal)->x$ExpVal

  x$MDr <- x$MeanLoss/x$ExpVal
  x$Stdev <- x$StdevI + x$StDevC
  x$COV <- (x$Stdev)/x$MeanLoss
  x$alpha <-((1-x$MDr)/(x$COV^2)) - x$MDr

  x$alpha[!is.finite(x$alpha)] <- 0
  x$beta <- (x$alpha*(1-x$MDr))/x$MDr

  lda <- sum(x$Rate)
  x$random_num <- x$Rate/lda

  x

}


#' Title
#'
#' @param x
#' @param sims
#'
#' @return
#' @export
#'
#' @examples
YLT <- function (x,  sims) {
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



#' Title
#'
#' @param Limit
#' @param Rate
#' @param RI
#' @param Reinst
#'
#' @return
#' @export
#'
#' @examples
RIP <- function( Limit, Rate, RI, Reinst){

  Prem <- Limit* Rate * RI *(Reinst>0)
  Prem

}


#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
Annual_loss <- function(x) {

  AnnLoss <- x[, lapply(.SD , sum, na.rm=T), by= x$Year, .SDcols = c("Loss", "Loss_LAE", "Loss_NetFHCF", "Layer1", "Layer2", "Layer3", "Layer4", "Layer5",  "Layer6")]
  AnnLoss
}
EP_Curve <-function(x, y, z){
  EP<- c(10000,5000,1000,500,250,200,100,50, 25,10,5 , 2)
  Max_Port <- x[,.(y,z)][, max(z) , by=y]
  OEP_Port<- sapply(1 - 1/EP, function(x) quantile(Max_Port$V1, x))
  OEP_Port

}

#' Title
#'
#' @param x
#' @param y
#'
#' @return
#' @export
#'
#' @examples
EL<- function( x, y){

  EL<- x[, lapply(.SD, mean, na.rm=T), by=x$Year , .SDCols = y]
  EL
}
#################################################
