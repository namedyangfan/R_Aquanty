rm(list = ls())

library(raster)

mods=c('_1.asc',
       '_2.asc',
       '_3.asc',
       '_4.asc',
       '_5.asc',
       '_6.asc',
       '_7.asc',
       '_8.asc',
       '_9.asc',
       '_10.asc',
       '_11.asc',
       '_12.asc')

crs=c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs")

for (j in 1:length(mods)){
  
  setwd("C:/Users/fyang/Desktop/SSRB_Monthly_Norms/Input/potential_rain_accumulation")
  my_raster<- list.files(pattern=mods[j])
  rain_raster<-raster(my_raster,  crs=crs)
  rain_array<-rain_raster[]
  
  setwd("C:/Users/fyang/Desktop/SSRB_Monthly_Norms/Input/final_snow_melt_raster")
  my_raster<- list.files(pattern=mods[j])
  snowmelt_raster<-raster(my_raster,  crs=crs)
  snowmelt_array<-snowmelt_raster[]
  
  combine_rain_snowmelt_raster=rain_raster
  combine_rain_snowmelt_raster[]=snowmelt_raster[]+rain_raster[]
  
  setwd("../")
  dir.create("combine_rain_snowmelt",showWarnings = FALSE)
  setwd("combine_rain_snowmelt")
  writeRaster(combine_rain_snowmelt_raster, file=paste("combine_rain_snowmelt_",j, sep=""), format = "ascii",overwrite=TRUE)
  
  
}