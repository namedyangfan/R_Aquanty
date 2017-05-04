######################################################################
# This script reproject the CMC dataset form the north pole projection to 
# wgs84
#
#
#
#
#
#######################################################################
rm(list = ls())
library(raster)
library(tools)
library(parallel)


cmc_reproject<-function(cmc_files){
  
  setwd(dirname(cmc_files))
  
  
  r<-raster(cmc_files,crs="+proj=stere +lat_0=90 +lat_ts=60 +lon_0=10 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
  
  # e <- extent(-3000000,-1500000,-4200000,-2900000)
  # 
  # r_crop<-crop(r, e)
  
  setwd(savefile_dir)
  
  
  foldername<-basename(dirname(cmc_files))
  
  
  dir.create(foldername,showWarnings = FALSE)
  
  
  pr <- projectRaster(from = r,to=ref_raster,
                      filename = file.path (foldername, basename(cmc_files)),
                      method = "bilinear",
                      format="ascii",
                      overwrite = TRUE)
  
  
  # my_raster<- ("Potential_snow_melt_monthly_2009_2013_average_1.asc") ############## This is to read your raster as a list
  # 
  # r2<-raster(my_raster,crs="+proj=longlat +datum=WGS84 +no_defs")
  
  # e <- extent(-117.00,-104.00,48.00,53.90)
  
  #r_crop<-crop(pr,ref_raster,snap="in")
  
  #r_align<-alignExtent(pr,e,snap="near")
  
  
  
}

##set up the directory of the reference file 
setwd("C:/Users/fyang/Desktop")

##set up the reference raster file
ref_raster<-raster("pet_01.asc",crs="+proj=longlat +datum=WGS84 +no_defs")

##directory of the saved file
savefile_dir=c("C:/Users/fyang/Desktop/SouthNation")

#directory of the CMC data 
wd=c("D:/ARB/ARB_WeatherStation/CMC_Snow/CMC_Raster")

my_raster<- list.files(wd, pattern='\\.asc$', full.names=TRUE,include.dirs = TRUE,recursive = TRUE) ############## This is to read your raster as a list


no_cores<-detectCores()

cl<-makeCluster(no_cores)

clusterExport(cl=cl, varlist=c("my_raster","cmc_reproject","ref_raster","savefile_dir"),envir = environment())

a<-clusterEvalQ(cl, library('raster'))

system.time(parLapply(cl,my_raster,cmc_reproject))

stopCluster(cl)


















