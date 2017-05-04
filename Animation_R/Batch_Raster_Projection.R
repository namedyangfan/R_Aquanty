############ small scripts to batch project your raster
Library(raster)
# Use Setwd() to set your working directory

rm(list = ls())

setwd("C:/Users/fyang/Desktop/Clip_txt"

my_raster<- list.files(pattern='\\.asc$', full.names=TRUE) ############## This is to read your raster as a list


for (i in 1:length(my_raster)){

    r <- raster(my_raster[i], crs="+proj=longlat +datum=WGS84 +no_defs")

    pr <- projectRaster(from = r, res=9000,crs="+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs",
                      filename = file.path ("./reproj", my_raster[i]),
                      method = "bilinear",
                      format='ascii',
                      overwrite = TRUE)
}
