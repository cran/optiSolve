
"getSolver"<-function(op, quiet=FALSE){
  if(inherits(op$f, "quadFun")){ solver <- "cccp"}
  if(inherits(op$f, "ratioFun")){solver <- "slsqp"}
  if(inherits(op$f, "linFun")){  solver <- "cccp2"}
  if(inherits(op$f, "linFun") && is.null(op$lb) && is.null(op$ub) && !is.null(op$qc)){solver <- "alabama"}

  solver
}