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

setwd("C:/Users/fyang/Desktop/pet_1981_2010")

#B is the points matrix 
B = matrix( c(-100, 50), 
            nrow=1, 
            ncol=2)

for (i in 1:12){
  
  my_raster<- list.files(pattern='\\.asc$', full.names=TRUE) ############## This is to read your raster as a list
  
  pet_raster<-raster(my_raster[i],  crs="+proj=longlat +datum=WGS84 +no_defs")
  
  if (i==1){
    stack_pet_raster=pet_raster
  }
  
  else{
    stack_pet_raster=stack(stack_pet_raster,pet_raster)
  }
  

}



extract(stack_pet_raster,B)