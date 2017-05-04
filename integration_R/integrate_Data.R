
rm(list = ls())
library(data.table,ROC)

CONVERT_YMD_EXCEL_DATE<-function(x,time_origin=c('1900/01/01')){
  
  YMD_time=as.Date(x,origin=time_origin)
  EXCEL_DATE<-as.numeric(YMD_time-as.Date(time_origin)-1) #remove one more day
  
}




workdirectory<-("C:/Users/fyang/Desktop")
setwd(workdirectory)
DT=read.csv(file="05JE006_Daily_Flow_ts.csv",header = TRUE)#read in the station summary
DT=data.table(DT)

x=DT[,CONVERT_YMD_EXCEL_DATE(Date)]
x=x[which(!is.na(x))]


y=DT[,Flow]
y=y[which(!is.na(x))]

lower_lim=CONVERT_YMD_EXCEL_DATE("2001/06/01")
upper_lim=CONVERT_YMD_EXCEL_DATE("2001/06/30")

n=trapezint(x,y,lower_lim,upper_lim)*86400

i=which(x==lower_lim)
j=which(x==upper_lim)
mean(y[c(i:j)])*86400*30