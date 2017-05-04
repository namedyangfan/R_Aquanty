rm(list = ls())
library(tools) 

hydat_tecplot<-function(workdirectory,filename_list,summary_file,save_filename){

  setwd(workdirectory)
  time_origin<-('19000101') # set the reference date, here 1900Jan01 is the excel time

    for (i in 1:length(filename_list)) {
      
        filename=filename_list[i]
        ncol <- max(count.fields(filename, sep = ","))
        d=read.csv(filename,header = TRUE,col.names = paste0("V", seq_len(ncol)),stringsAsFactors=FALSE)#read in the gauge reading
        n=read.csv(summary_file,header = FALSE,stringsAsFactors=FALSE)#read in the station summary
        
        #assign flow rate and date, convert tecplot date 
        d_V3<- gsub(pattern="--",replacement="",d$V3,fixed=TRUE) # remove --
        flow_rate<-(d$V4)
        d_V3_day<-paste(d_V3,'01',sep="")# assume start from the first day of the month
        d_V3_date<-as.Date(as.character(d_V3_day),format="%m%Y%d")-as.Date(as.character(time_origin),format="%Y%m%d")+1 #add one more day
        
        #search for station name based on station number 
        station_num=d$V1[1]
        station_name_index=which(n$V1==station_num)
        station_name=n$V3[station_name_index]
        #save_filename<-paste(file_path_sans_ext(station_name),"dat",sep = ("."))
        zone_name<-paste("zone t=\"",file_path_sans_ext(station_name),"\"",sep = (""))
        
        
        if(i == 1){
          variable_name=c('variables=\"date\"\"flow rate\"')
          write(c(variable_name,"\n"), file=save_filename,append=FALSE) #write variable names
        }
        
        write(paste("zone t=\"",station_name,"\"\n"), file=save_filename,append=TRUE) #write zone names
        write.table(data.frame(d_V3_date,flow_rate),file=save_filename,quote = FALSE,sep="\t",row.names=FALSE,col.names=FALSE,append = TRUE) #write data
    }
#X-AXIS: Date Y-AXIS:Flow rate
}

workdirectory<-("D:/ORB/hydrograph/HYDAT Hydrograph")

filename=c(
  "05AA024_Monthly_MeanFlow_ts.csv",
  "05AC003_Monthly_MeanFlow_ts.csv",
  "05AD007_Monthly_MeanFlow_ts.csv",
  "05AD028_Monthly_MeanFlow_ts.csv",
  "05AE006_Monthly_MeanFlow_ts.csv",
  "05AE027_Monthly_MeanFlow_ts.csv",
  "05AG006_Monthly_MeanFlow_ts.csv",
  "05AJ001_Monthly_MeanFlow_ts.csv",
  "05BB001_Monthly_MeanFlow_ts.csv",
  "05BH004_Monthly_MeanFlow_ts.csv",
  "05BJ001_Monthly_MeanFlow_ts.csv",
  "05BL024_Monthly_MeanFlow_ts.csv",
  "05BN012_Monthly_MeanFlow_ts.csv",
  "05CA009_Monthly_MeanFlow_ts.csv",
  "05CC002_Monthly_MeanFlow_ts.csv",
  "05CE001_Monthly_MeanFlow_ts.csv",
  "05CK004_Monthly_MeanFlow_ts.csv",
  "05HD039_Monthly_MeanFlow_ts.csv",
  "05HG001_Monthly_MeanFlow_ts.csv"
)


summary_file=("All Stations.csv")
save_filename=( "ORB_HYDAT.dat")

hydat_tecplot(workdirectory,filename,summary_file,save_filename)

