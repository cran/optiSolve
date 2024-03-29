
"cop"<-function(f, max=FALSE, lb=NULL, ub=NULL, lc=NULL, ...){
  
  ### Separate rational and quadratic constraints and put ###
  ### them into different lists #############################
  qc <- list(...)

  rc <- list()
  if(length(qc)>0){
    for(i in (length(qc):1)){
      if(!("quadCon" %in% class(qc[[i]])) && !("ratioCon" %in% class(qc[[i]]))){
        stop("Additional arguments must be quadratic or rational constraints.\n")
      }
      if("quadCon" %in% class(qc[[i]])){
        class(qc[[i]])  <- "quadCon"
        }
      if("ratioCon" %in% class(qc[[i]])){
        class(qc[[i]]) <- "ratioCon"
        rc[[length(rc)+1]]<-qc[[i]]
        qc[[i]]<-NULL
      }
    }
  }
  
  
  ### Check class names #######################################
  if(!("linFun" %in% class(f)) && !("quadFun" %in% class(f)) && !("ratioFun" %in% class(f))){stop("Invalid class name of the objective function.")}
  class(f) <- intersect(class(f), c("linFun", "quadFun", "ratioFun"))[1]
  if(!is.logical(max)){stop("Argument max must be logical.")}
  if(!is.null(lb)){if("lbCon" %in% class(lb)){class(lb) <- "lbCon"}else{stop("Invalid class name of lower bound lb.")}}
  if(!is.null(ub)){if("ubCon" %in% class(ub)){class(ub) <- "ubCon"}else{stop("Invalid class name of upper bound ub.")}}
  if(!is.null(lc)){if("linCon" %in% class(lc)){class(lc)<- "linCon"}else{stop("Invalid class name of linear constraint lc.")}}
  
  ### Find the complete set of variables ######################
  ids <- f$id
  if(!identical(lc$id, f$id) && !is.null(lc$id)){
    ids <- c(ids, setdiff(ids, lc$id))
    }
  for(i in seq_along(qc)){
    if(!identical(qc[[i]]$id, f$id)){
      ids <- c(ids, setdiff(ids, qc[[i]]$id))
    }
  }
  for(i in seq_along(rc)){
    if(!identical(rc[[i]]$id, f$id)){
      ids <- c(ids, setdiff(ids, rc[[i]]$id))
    }
  }
  
  if(!is.null(lb)){
    if(!all(lb$id %in% ids)){stop("Some lb names are not variable names.")}
    lb$val <- lb$val[ids[ids %in% lb$id]]
    lb$id  <- ids[ids %in% lb$id]
  }
  if(!is.null(ub)){  
    if(!all(ub$id %in% ids)){stop("Some ub names are not variable names.")}
    ub$val <- ub$val[ids[ids %in% ub$id]]
    ub$id  <- ids[ids %in% ub$id]
  }
  
  ### Adjust constraints so that they include all variables ####
  
  if(!identical(ids,  f$id)){f  <- adjust(f, ids)}
  if(!identical(ids, lc$id)){lc <- adjust(lc,ids)}
  for(i in seq_along(qc)){
    if(!identical(ids, qc[[i]]$id)){qc[[i]] <- adjust(qc[[i]], ids)}
  }
  for(i in seq_along(rc)){
    if(!identical(ids, rc[[i]]$id)){rc[[i]] <- adjust(rc[[i]], ids)}
  }
  
  ### Return the optimization problem ###
  x  <- setNames(rep(NA, length(ids)), ids)
  storage.mode(x) <- "double"
  
  op <- list(f=f, max=max, lb=lb, ub=ub, lc=lc, qc=qc, rc=rc, x=x, id=ids, madeDefinite=FALSE)
  class(op) <- "coProblem"
  op
}