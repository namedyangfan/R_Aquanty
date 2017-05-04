rm(list = ls())

library(raster)

setwd("D:/ORB/Temp_Raster/min")

mods=c('final_tmin_monthly_average_1_',
       'final_tmin_monthly_average_2_',
       'final_tmin_monthly_average_3_',
       'final_tmin_monthly_average_4_',
       'final_tmin_monthly_average_5_',
       'final_tmin_monthly_average_6_',
       'final_tmin_monthly_average_7_',
       'final_tmin_monthly_average_8_',
       'final_tmin_monthly_average_9_',
       'final_tmin_monthly_average_10_',
       'final_tmin_monthly_average_11_',
       'final_tmin_monthly_average_12_')


for (j in 1:length(mods)){
  
  my_raster<- list.files(pattern=mods[j])
  
  RasterCombine=0
  
    for (i in 1:length(my_raster)){
      
     RasterTmin<-raster(my_raster[i],  crs="+proj=longlat +datum=WGS84 +no_defs")
     
     RasterCombine=RasterCombine+RasterTmin
     
     print(my_raster[i])
    }
  print(mods[j])
  RasterCombine<-RasterCombine/5
  writeRaster(RasterCombine, file=paste("D:/ORB/Temp_Raster/min/Averaged/final_tmax_2009_2013_average_",j, sep=""), format = "ascii",overwrite=TRUE)
}



##raster1<-raster(my_raster[1], crs="+proj=longlat +datum=WGS84 +no_defs")
