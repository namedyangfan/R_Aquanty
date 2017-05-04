
###File list Bash commond:$ for F in *ts*; do echo \""$F"\",; done 
##ls -Q -m


rm(list = ls())
library(tools)

convert_hourly_to_daily<-function(file_name){
  
  d=read.csv(file_name,header = TRUE)#read in the gauge reading
  tes=tapply(d$GWElev,d$Date,mean)
  Date_daily=row.names(tes)
  
  op=data.frame(d$ID[1:length(tes)],d$PARAM[1:length(tes)],Date_daily,tes,d$WellElev[1:length(tes)],row.names = NULL)
  colnames(op)=colnames(d)[c(1,2,3,7,6)]
  
  write.csv(op,file=paste0(file_path_sans_ext(file_name),'_daily.csv'),quote = FALSE,sep="\t",row.names=FALSE,col.names=TRUE,append = FALSE) #write data
  
}



workdirectory<-("C:/Users/fyang/Desktop/TEST_hourly")
setwd(workdirectory)

filename_list=c("BLUCHER4.csv", "CONQUEST500.csv", "DALMENY.csv", "DucK1.csv", "DUCK2.csv", "GARDEN.csv",
                "GOODALE.csv", "HAGUE.csv", "INSTOW.csv", "SASKATOON.csv", "SHAUN.csv", "SHAUN2.csv", "Swanson.csv", "TYNER.csv",
                "VERLO.csv", "WARMAN2.csv")

lapply(filename_list,convert_hourly_to_daily)
