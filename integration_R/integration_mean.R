
rm(list = ls())
library(data.table)
library(ROC)
library(tools)

source("C:/Users/fyang/Desktop/R_clone/R_repository/integration_R/ts_analysis_hydat.R")

calcualte_monthly_flowrate_discharge<-function(file_name,a,b){
  setwd(workdirectory)
  print(file_name)  
  DT=read.csv(file=file_name,header = TRUE)#read in the station summary
  DT=data.table(DT)
  
  monthly_discharge=data.table(monthly_or_annual_integration(DT[,Date],DT[,Flow],a,b))
  
  
  annul_discharge=monthly_or_annual_integration(DT[,Date],DT[,Flow],a,b,int_step="year")
  #print(annul_discharge$flow)
  
  annul_flow=monthly_or_annual_mean_value(DT[,Date],DT[,Flow],a,b,mean_step = "year")
  
  flow_rate=monthly_or_annual_mean_value(DT[,Date],DT[,Flow],a,b)
  
  monthly_norm_discharge=monthly_normal_from_monthly_mean(monthly_discharge[,Date],
                                                          monthly_discharge[,Integration])
  
  monthly_norm_flow=monthly_normal_from_monthly_mean(flow_rate[,Date],
                                                     flow_rate[,mean_flow])
  
  save_filename=paste0(strsplit(file_path_sans_ext(file_name),'_')[[1]][1],'.csv')
  
  print(paste0("dimension of discharge: ",dim(monthly_discharge))[1])
  print(paste0("dimension of flow rate: ",dim(flow_rate))[1])
  
  DT=data.frame(DT[1:nrow(monthly_discharge),.(ID,PARAM)],
                Date=                    monthly_discharge$Date,
                monthlyDischarge=        monthly_discharge$Integration,
                monthlyFlow=             flow_rate$mean_flow,
                norm.monthlyFlow=        monthly_norm_flow$monthly_norm
                # norm.monthlyDischarge=   monthly_norm_discharge$monthly_norm,
                # norm.monthlyDischarge.SD=monthly_norm_discharge$monthly_sd,
                # annulDischarge=          annul_discharge$flow,
                # annulFlow=               annul_flow$annul_mean_flow,
                # average.annulFlow=       annul_flow$averge_annul_mean_flow
  )
  
  # DT=data.frame(Date=                    monthly_discharge$Date,
  #               norm.monthlyDischarge=   monthly_norm$monthly_norm,
  #               norm.monthlyDischarge.SD=monthly_norm$monthly_sd)
  
  setwd(file.path("./TEST"))
  
  write.table(DT,file=save_filename,quote = FALSE,row.names=FALSE,col.names=TRUE,append = FALSE,sep = ",") #write data
  
}


workdirectory<-("C:/Users/fyang/Desktop/TEST_Discharge")
setwd(workdirectory)

# stationID=c(
#   "05JF001",
#   "05JK002",
#   "05JK007",
#   "05JM001",
#   "05MD004",
#   "05MH005",
#   "05MJ001",
#   "05NB036",
#   "05NB001",
#   "05ND010",
#   "05NF012",
#   "05NG024",
#   "05NG001",
#   "05ME001",
#   "05JE006"
#   
#   
# )

stationID=c(
  
  "05JM001",
  "05JG006",
  "05JK007",
  "05JE006"
)

stationID=c(
  
    "05NB001",
    "05ND007",
    "05NF012",
    "05NG001"
)

file_list=lapply(stationID, function(x)list.files(pattern=x,full.names = TRUE))

a=c("1981/01/01")
b=c("2010/12/30")

r=lapply(file_list,calcualte_monthly_flowrate_discharge,a=a,b=b)




