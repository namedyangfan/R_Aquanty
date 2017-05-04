############ small scripts to batch project your raster
rm(list = ls())

library(raster)
# Use Setwd() to set your working directory


setwd("C:/Users/fyang/Desktop/pcp_1981_2010")

my_raster<- list.files(pattern='\\.asc$', full.names=TRUE) ############## This is to read your raster as a list
      
e <- extent(-108, -96, 47, 53)


      for (i in 1:length(my_raster)){
        
        r <- raster(my_raster[i], crs="+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
        
        r_crop<-crop(r, e)
        
        
        writeRaster(r_crop, "outputFilename",filename = file.path ("./reproj", my_raster[i]), format='ascii', overwrite = TRUE)
        
        # pr <- projectRaster(from = r_crop, res=9000,crs="+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs",
        #                     filename = file.path ("./reproj", my_raster[i]),
        #                     method = "bilinear",
        #                     format='ascii',
        #                     overwrite = TRUE)
      }
      