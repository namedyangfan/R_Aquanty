######################################################################
# Clip CMC_SNOW to desired extent. It takes a raster as the clip platform
#
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


cmc_wgs84_batchcrop<-function(cmc_files){
  
  
  
  r<-raster(cmc_files,crs=cmc_prj)
  
  
  setwd(save_file_directory)
  
  
  foldername<-basename(dirname(cmc_files))
  
  
  dir.create(foldername,showWarnings = FALSE)
  
  
  pr <- projectRaster(from = r,to=ref_raster,
                      filename = file.path (foldername, basename(cmc_files)),
                      method = "bilinear",
                      format='ascii',
                      overwrite = TRUE)
  
  
  # my_raster<- ("Potential_snow_melt_monthly_2009_2013_average_1.asc") ############## This is to read your raster as a list
  # 
  # r2<-raster(my_raster,crs="+proj=longlat +datum=WGS84 +no_defs")
  
  # e <- extent(-117.00,-104.00,48.00,53.90)
  
  #r_crop<-crop(pr,ref_raster,snap="in")
  
  #r_align<-alignExtent(pr,e,snap="near")
  
  
  
}


setwd("C:/Users/fyang/Desktop")

##set up the reference raster file
ref_raster<-raster("final_pcp_monthly_ave_2009_2013_12.asc",crs="+proj=longlat +datum=WGS84 +no_defs")

#directory of the CMC data 
wd=c("D:/ARB/ARB_WeatherStation/CMC_Snow/CMC_WGS84")

my_raster<- list.files(wd, pattern='\\.tif$', full.names=TRUE,include.dirs = TRUE,recursive = TRUE) ############## This is to read your raster as a list

#projection of the cmc data 
cmc_prj=("+proj=longlat +datum=WGS84 +no_defs")

#directory of file that need to be saved
save_file_directory=c("C:/Users/fyang/Desktop/CMC_SSRB")




#below is setting up the slaves, and pass variable, environment, and packages 
no_cores<-detectCores()-4

cl<-makeCluster(no_cores)

clusterExport(cl=cl, varlist=c("my_raster","cmc_wgs84_batchcrop","ref_raster","save_file_directory","cmc_prj"),envir = environment())

a<-clusterEvalQ(cl, library('raster'))

system.time(parLapply(cl,my_raster,cmc_wgs84_batchcrop))

stopCluster(cl)