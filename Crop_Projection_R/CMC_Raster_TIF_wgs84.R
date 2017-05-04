######################################################################
# This script stack multiple layers and extract at given coordinates
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


cmc_reproject<-function(cmc_files){
  
        setwd(dirname(cmc_files))

  
        r<-raster(cmc_files,res=23812.5,crs="+proj=stere +lat_0=90 +lat_ts=60 +lon_0=10 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
        
        # e <- extent(-3000000,-1500000,-4200000,-2900000)
        # 
        # r_crop<-crop(r, e)
  
        setwd("D:/ARB/ARB_WeatherStation/CMC_Snow/CMC_WGS84")
        
        
        foldername<-basename(dirname(cmc_files))
        
        
        dir.create(foldername,showWarnings = FALSE)
        
        
        # pr <- projectRaster(from = r,to=ref_raster,
        #                     filename = file.path (foldername, basename(cmc_files)),
        #                     method = "bilinear",
        #                     format='GTiff',
        #                     overwrite = TRUE)
        

        # my_raster<- ("Potential_snow_melt_monthly_2009_2013_average_1.asc") ############## This is to read your raster as a list
        # 
        # r2<-raster(my_raster,crs="+proj=longlat +datum=WGS84 +no_defs")
        
        # e <- extent(-117.00,-104.00,48.00,53.90)
        
        #r_crop<-crop(pr,ref_raster,snap="in")
        
        #r_align<-alignExtent(pr,e,snap="near")
        


}



setwd("C:/Users/fyang/Desktop")

ref_raster<-raster("pcp_03.asc",crs="+proj=longlat +datum=WGS84 +no_defs")

wd=c("D:/ARB/ARB_WeatherStation/CMC_Snow/CMC_Raster")

my_raster<- list.files(wd, pattern='\\.asc$', full.names=TRUE,include.dirs = TRUE,recursive = TRUE) ############## This is to read your raster as a list

lapply(my_raster,cmc_reproject)
