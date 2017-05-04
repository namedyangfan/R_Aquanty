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

Upper_lim=c(0.1)

for (j in 1:length(mods)){
  
  setwd("D:/ORB/monthly_SWE_snow/Averaged")
  
  my_raster<- list.files(pattern=mods[j])
    
  snow_SWE_raster<-raster(my_raster,  crs="+proj=longlat +datum=WGS84 +no_defs")
  
  
  # array=snow_SWE_raster[] 
  # 
  # index=which(array>Upper_lim)
  # 
  # array[index]=NaN
  # 
  # snow_SWE_raster[]=array
  
  
  brks =c(seq(0,0.025,by=0.005),seq(0.03,Upper_lim,by=0.01))
  nbrks <- length(brks)-1
  
  dir.create("swe_png",showWarnings = FALSE)
  setwd("swe_png")
  filename<- paste("swe_snow_monthly_avergae_2009_2013_",j,".png")
  png(file=filename)
  plot(snow_SWE_raster,xlim=c(-117, -109), ylim=c(49, 53),col=rev(terrain.colors(nbrks)),breaks=brks)
  title(main = paste("swe_snow_monthly_avergae at month",j,sep = ""))
  dev.off()
  
  
  setwd("D:/ORB/Test/final_accumulative_snow_accumulation_raster")
  month=c(31,28,31,30,31,30,31,31,30,31,30,31)
  my_raster<- list.files(pattern=mods[j])
  snow_calcualted_raster<-raster(my_raster,  crs="+proj=longlat +datum=WGS84 +no_defs")
  snow_calcualted_raster[]<-snow_calcualted_raster[]*month[j]*86400 ##m/month
  
  
  array=snow_calcualted_raster[]
  
  index=which(array>Upper_lim)
  
  array[index]=NaN
  
  snow_calcualted_raster[]=array
  
  
  setwd("D:/ORB/monthly_SWE_snow/Averaged")
  dir.create("estimated_png",showWarnings = FALSE)
  setwd("estimated_png")
  filename<- paste("estimated_snow_monthly_avergae_2009_2013_",j,".png")
  png(file=filename)
  plot(snow_calcualted_raster,xlim=c(-117, -109), ylim=c(49, 53),col=rev(terrain.colors(nbrks)),breaks=brks)
  title(main = paste("estimated_snow_monthly_avergae at month",j,sep = ""))
  dev.off()  
  


}