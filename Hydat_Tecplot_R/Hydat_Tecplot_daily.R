################################################################
################################################################
###This script converts Hydat daily data to tecplot format
###It requires a lists of the Hydat data and a summary which
###described the station name and station ID
################################################################


rm(list = ls())
library(tools) 

CONVERT_YMD_EXCEL_DATE<-function(x,time_origin=c('19000101')){
  
  YMD_time=as.Date(x)
  EXCEL_DATE<-YMD_time-as.Date(time_origin,format="%Y%m%d")+2 #add two more day, one as 19000101, another one as leap year in Feb 1900
  
}

write_TECPLOT_column<-function(x,save_filename,tecplot_zone_name,tecplot_variable_name){
  
  tecplot_variable_name=c('variables=','"',tecplot_variable_name,'"')
  
  
  ###########Write the header for tecplot file
  sink(save_filename,append = TRUE)
  cat(tecplot_variable_name,"\n")
  cat('zone t="',tecplot_zone_name,'"',"\n")
  sink()
  
  write.table(x,file=save_filename,quote = FALSE,sep="\t",row.names=FALSE,col.names=FALSE,append = TRUE) #write data
  
  
}


hydat_tecplot<-function(filename_list,to_excel_time=TRUE, wdir){
### if the date is in %Y%M%D format, then "to_excel_time" should be TRUE
  
  setwd(wdir)
  
  
  filename=filename_list
  
  ncol <- max(count.fields(filename, sep = ","))
  
  d=read.csv(filename,header = TRUE)#read in the gauge reading
  
  n=read.csv(summary_file,header = FALSE,stringsAsFactors=FALSE)#read in the station summary
  
  #assign flow rate and date, convert tecplot date col.names = paste0("V", seq_len(ncol))
  
  #d_V3<- gsub(pattern="/",replacement="",d$V3,fixed=TRUE) # remove / (as.Data will still work with the /)
  
  
  #read flow rate and other variable
  
  import_var<-d[,c(4:ncol(d))]
  
  #replace missing data
  
  import_var[is.na(import_var)]<-missing_data_value
  
  
  ## calcualte the time different #assume the third column as date
  if (to_excel_time){d_V3_date=CONVERT_YMD_EXCEL_DATE(d[,3])}
  else {d_V3_date=d[,3]}
  
  
  
  #search for station name based on station number
  station_num=as.character(d[1,1])
  
  station_name_index=which(n[,1]==station_num)
  print(station_num)
  station_name=n[station_name_index,3]
  print(station_name)
  #save_filename<-paste(file_path_sans_ext(station_name),"dat",sep = ("."))
  zone_name<-paste("zone t=\"",station_name,"\"",sep = (""))
  
  ###########extract variable name
  var_name=paste0(colnames(d[,c(3:ncol(d))]),collapse = '""') #takes the col_name and write in file
  
  ##########Write the data
  write_TECPLOT_column(data.frame(d_V3_date,import_var),save_filename,station_name,var_name)
  
}


# workdirectory<-("C:/Users/fyang/Desktop/TEST_hourly/daily")
# 
# ###File list Bash commond:$ for F in *ts*; do echo \""$F"\",; done
# 
# filename=c(
#   "BLUCHER4_daily.csv", "CONQUEST500_daily.csv", "DALMENY_daily.csv", "DUCK1_daily.csv",
#   "DUCK2_daily.csv", "GARDEN_daily.csv", "GOODALE_daily.csv", "HAGUE_daily.csv", "INSTOW_daily.csv",
#   "SASKATOON_daily.csv", "SWANSON_daily.csv", "TYNER_daily.csv", "VERLO_daily.csv",
#   "WARMAN2_daily.csv","SHAUN_daily.csv"
#   
# )
# 
# missing_data_value=-999;
# summary_file=("All Stations.csv")
# save_filename=( "ORB_GWDAT.dat")
# file.remove(save_filename)         #Delete the preciouse run 
# lapply(filename,hydat_tecplot)






