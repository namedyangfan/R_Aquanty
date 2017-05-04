library(data.table,ROC)
library(tools)
library(roxygen2)

#This function converts YYYYMMDD to excel time
#x is data column

#' Title
#'
#' @param x
#' @param time_origin
#'
#' @return
#' @export CONVERT_YMD_EXCEL_DATE
#'
#' @examples
#' d=c("1900/01/02")
#' a=CONVERT_YMD_EXCEL_DATE(d)
CONVERT_YMD_EXCEL_DATE<-function(x,time_origin=c('1900/01/01')){

  YMD_time=as.Date(x)
  EXCEL_DATE<-as.numeric(YMD_time-as.Date(time_origin)+1) #remove one more day

}

##trapz integration
##take X as Date and Y as flow
##return a fucntion that reqire upper and lower integration limit
##remove missing data

#' Title
#'
#' @param x
#' @param y
#' @param missing_data
#'
#' @return
#' @export ts_trapezint
#'
#' @examples
#' x=seq(as.Date("1900/1/1"), as.Date("1900/1/03"), "day")
#' y=rep(2,length(x))
#' a=ts_trapezint(x,y)
#' result=a(as.Date("1900/1/1"),as.Date("1900/1/03"))
ts_trapezint<-function(x,y,missing_data=FALSE){
#commnet test
  x=CONVERT_YMD_EXCEL_DATE(as.Date(x))


  ##remove NA data
  if (missing_data==TRUE){

    x=x[which(!is.na(y))]
    y=y[which(!is.na(y))]
  }

  ts_trapezint_ab<-function(a,b){
    #print(data.frame(a,b))

    ##convert limit from date to number
    lower_lim=CONVERT_YMD_EXCEL_DATE(a)

    upper_lim=CONVERT_YMD_EXCEL_DATE(b)

    n=trapezint(x,y,lower_lim,upper_lim)
  }

}


#calculate the monthly mean of data'y'
#a:starting date
#b:ending date
#' Title
#'
#' @param time_series
#' @param y
#' @param a
#' @param b
#' @param mean_step
#'
#' @return
#' @export monthly_or_annual_mean_value
#'
#' @examples
#' x=seq(as.Date("1900/1/1"), as.Date("2090/1/03"), "day")
#' y=rnorm(length(x))
#' r=monthly_or_annual_mean_value(x,y,c("1900/1/1"),c("2090/01/01"))
monthly_or_annual_mean_value<-function(time_series,y,a,b,mean_step="month"){

  i=which(as.Date(time_series)==as.Date(a))
  j=which(as.Date(time_series)==as.Date(b))

  print( "a and b exists in x and y" )

  #format the date as YYYYMM
  Date_YM=format(as.Date(time_series[i:j]),"%Y-%m")
  DT=data.table(Date_YM,y=y[i:j])
  write.table(levels(factor(Date_YM)),file="ft",quote = FALSE,row.names=FALSE,col.names=TRUE,append = FALSE,sep = ",")
  DT=DT[,.(mean_flow=mean(y)),by=(Date=Date_YM)]


  if(mean_step=="year"){

    DT[,Date_year:=tstrsplit(Date,"-")[1]]

    DT[,annul_mean_flow:=mean(mean_flow),by=(Date_year)]

    DT[,averge_annul_mean_flow:=mean(annul_mean_flow)]
  }
  DT
}

#
monthly_normal_from_monthly_mean<-function(time_series,y){

  fc=sapply(time_series,function(x)unlist(tstrsplit(as.character(x),"-"))[2])

  DT=data.table(Date=time_series,fc=fc,value=y)

  DT=DT[,.(Date,monthly_norm=mean(value),monthly_sd=sd(value,na.rm = TRUE)),by=fc]

  print(paste0("dimension of norm flow rate: ",dim(DT))[1])

  DT=DT[order(Date)]

}

monthly_or_annual_integration<-function(time_series,y,a,b,int_step="month"){

  x=as.Date(time_series)
  ##assume the data is contineaus
  #break down a b to monthly segnment and integrate
  #can NOT handel data gap eg.b does not exist in time_series
  if (int_step=="month"){

    seq_a=seq(as.Date(a),as.Date(b),by=int_step)
    seq_b=lapply(seq_a,function(x)seq(x,by="+1 month",length=2)[2]-1)
    seq_b=do.call("c",seq_b)
    ab=data.frame(seq_a,seq_b)


    trapezint_equation=ts_trapezint(x,y,missing_data = TRUE)
    integrat=apply(ab,1,function(x)trapezint_equation(x[1],x[2]))*86400
    data.frame(Date=format(seq_a, "%Y-%m"),Integration=integrat)

  }

  else if (int_step=="year"){

    seq_a=seq(as.Date(a),as.Date(b),by="month")
    seq_a_year=format(seq_a, "%Y")

    seq_a_trapz=as.Date(paste(as.character(seq_a_year),"-01-01",sep=""))
    seq_b_trapz=as.Date(paste(as.character(seq_a_year),"-12-31",sep=""))
    #print(seq_b_trapz)
    #print(seq_a_trapz)

    DT_MOAI=data.table(seq_a,seq_a_trapz,seq_b_trapz)

    trapezint_equation=ts_trapezint(x,y,missing_data = TRUE)

    DT_MOAI=DT_MOAI[,.(flow=trapezint_equation(seq_a_trapz,seq_b_trapz)*86400),by=(Date=seq_a)]
    #verification below
    # seq_a=seq(as.Date(a),as.Date(b),by=int_step)
    # seq_b=lapply(seq_a,function(x)seq(x,by="+1 year",length=2)[2]-1)
    # seq_b=do.call("c",seq_b)
    # ab=data.frame(seq_a,seq_b)
    #
    # integrat=apply(ab,1,function(x)trapezint_equation(x[1],x[2]))*86400*365
    # print(integrat)

  }

}
