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

wd=c("D:/ORB/IMS Snow/2011/TIF")

setwd("C:/Users/fyang/Desktop")

ref_raster<-raster("Potential_snow_melt_monthly_2009_2013_average_1.asc",crs="+proj=longlat +datum=WGS84 +no_defs")


setwd(wd)

my_raster<- list.files(pattern='\\.tif$', full.names=TRUE) ############## This is to read your raster as a list

for ( i in 1:length(my_raster)) {
  
  
        setwd(wd)


        r<-raster(my_raster[i],res=4000)
        
        e <- extent(-3000000,-1500000,-4200000,-2900000)
        
        r_crop<-crop(r, e)
        
        dir.create("clip_wgs84",showWarnings = FALSE)
        
        setwd("clip_wgs84")
  
        pr <- projectRaster(from = r_crop,to=ref_raster,method = "ngb",filename = file_path_sans_ext(my_raster[i]),format='ascii',overwrite = TRUE)
        
        
        # my_raster<- ("Potential_snow_melt_monthly_2009_2013_average_1.asc") ############## This is to read your raster as a list
        # 
        # r2<-raster(my_raster,crs="+proj=longlat +datum=WGS84 +no_defs")
        
        # e <- extent(-117.00,-104.00,48.00,53.90)
        
        #r_crop<-crop(pr,ref_raster,snap="in")
        
        #r_align<-alignExtent(pr,e,snap="near")
        

        
        # pr <- projectRaster(from = r_crop,res=0.0083333,crs="+proj=longlat +datum=WGS84 +no_defs",
        #                     filename = file_path_sans_ext(my_raster[i]),
        #                     method = "ngb",
        #                     format='ascii',
        #                     overwrite = TRUE)
        
        
        
        # my_raster<- ("Potential_snow_melt_monthly_2009_2013_average_1.asc") ############## This is to read your raster as a list
        # 
        # r2<-raster(my_raster,crs="+proj=longlat +datum=WGS84 +no_defs")
        
        # plot(pr)
}
