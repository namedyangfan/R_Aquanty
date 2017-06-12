rm(list = ls())
library(tools)

write_TECPLOT_column<-function(x,save_filename,tecplot_zone_name,tecplot_variable_name){

  tecplot_variable_name=c('variables=','"',tecplot_variable_name,'"')


  ###########Write the header for tecplot file
  sink(save_filename,append = TRUE)
  cat(tecplot_variable_name,"\n")
  cat('zone t="',tecplot_zone_name,'"',"\n")
  sink()

  write.table(x,file=save_filename,quote = FALSE,sep="\t",row.names=FALSE,col.names=FALSE,append = TRUE) #write data
}

hydat_tecplot<-function(workdirectory,filename_list,summary_file,save_filename){

  setwd(workdirectory)
  time_origin<-('19000101') # set the reference date, here 1900Jan01 is the excel time

  for (i in 1:length(filename_list)) {

    filename=filename_list[i]
    ncol <- max(count.fields(filename, sep = ","))
    d=read.csv(filename,header = TRUE,stringsAsFactors=FALSE)#read in the gauge reading
    n=read.csv(summary_file,header = FALSE,stringsAsFactors=FALSE)#read in the station summary

    #assign flow rate and date, convert tecplot date
    d_V3<- gsub(pattern="-",replacement="",d$Date,fixed=TRUE) # remove --


    d_V3_day<-paste(d_V3,'01',sep="")# assume start from the first day of the month

    d_V3_date<-as.Date(as.character(d_V3_day),format="%Y%m%d")-as.Date(as.character(time_origin),format="%Y%m%d")+2 #add two more day
    #search for station name based on station number
    station_num=d$ID[1]
    station_name_index=which(n$V1==station_num)
    station_name=n$V3[station_name_index]
    #save_filename<-paste(file_path_sans_ext(station_name),"dat",sep = ("."))
    zone_name<-paste("zone t=\"",file_path_sans_ext(station_name),"\"",sep = (""))

    ###########extract variable name
    var_name=paste0(colnames(d[,c(3:ncol(d))]),collapse = '""') #takes the col_name and write in file
    print(paste0("number of variables equals to: ",ncol(d)))

    # if(i == 1){
    #   variable_name=c('variables=\"date\" \"discharge(m<sup>3</sup>/month)\" \"mean monthly discharge rate(m<sup>3</sup>/s)\" \"norm discharge rate(m<sup>3</sup>/s)\"')
    #   write(c(variable_name,"\n"), file=save_filename,append=FALSE) #write variable names
    # }

    # write(paste("zone t=\"",station_name,"\"\n"), file=save_filename,append=TRUE) #write zone names
    # write.table(data.frame(d_V3_date,d[,4:ncol(d)]),
    #             file=save_filename,quote = FALSE,sep="\t",row.names=FALSE,col.names=FALSE,append = TRUE) #write data
    write_TECPLOT_column(data.frame(d_V3_date,d[,4:ncol(d)]),
                         save_filename,
                         station_name,
                         var_name)
  }
  #X-AXIS: Date Y-AXIS:Flow rate
}

workdirectory<-("C:/Users/fyang/Desktop/TEST_Discharge/test")


filename=c(

  "05NB001.csv",
  "05ND007.csv",
  "05NF012.csv",
  "05NG001.csv"
)

summary_file=("All Stations.csv")
save_filename=( "Souris_HYDAT_discharge_monthly_1981_2010.dat")

hydat_tecplot(workdirectory,filename,summary_file,save_filename)
