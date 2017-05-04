############ small scripts to batch project your raster
###rm(list = ls())
library(raster) 
library(animation) ##library for animation
library(maptools)	##library for reading shapeshile
ani.options(convert = 'C:/Program Files (x86)/ImageMagick-7.0.2-Q8/convert.exe')##this is required for saveGIF, it 
##require the converter



setwd("C:/Users/fyang/Desktop/ARB_WeatherStation/Grided Data/Monthly_NorthAmerica_NRCan_Unzip/Summary/Clip_txt/Clip_UTM14_QGIS")

my_raster<- list.files(pattern='\\.asc$', full.names=TRUE) ############## This is to read your raster as a list

shape<-readShapeSpatial("C:/Users/fyang/Desktop/ARB_Share Data/ARB_Outline/ARB_Outline.shp") ####### read assiniboine outline



saveGIF({
for (i in 1:length(my_raster)){


	r <- raster(my_raster[i],crs="+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs") ######read the preciptation raster
      plot(r, xlab="Easting", ylab="Northing",useRaster=TRUE)
	plot(shape,add=TRUE)

}

})