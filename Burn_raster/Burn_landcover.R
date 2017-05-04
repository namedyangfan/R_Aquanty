############ small scripts to batch project your raster
rm(list = ls())

library(raster)
library(tools)
# Use Setwd() to set your working directory
#burn_value is the number of the water zone
#unique_value:this value should be set as an unique value if thickenraster equals to true
burn_landcover_raster<-function(polyline, rasterfile, burn_value=100,unique_value=100,thickenraster=TRUE,thicken_cellsize=1,savefilename="corrected_landcover.asc"){

  thicken_raster<-function(x,array,temp_rpol,index){

    array[index-x]=array[index]
    array[index+x]=array[index]
    array[index-ncol(temp_rpol)*x]=array[index]
    array[index+ncol(temp_rpol)*x]=array[index]

    return(array)

  }


  rpol <- rasterize(polyline, rasterfile, field = unique_value,update = TRUE)


    array=rpol[]
    temp_rpol=rpol
    index=which(array==unique_value)

    if (thickenraster){

      for (i in 1:thicken_cellsize){

        array=thicken_raster(i,array,temp_rpol,index)

      }

    }

    array[which(array==unique_value)]=burn_value
    rpol[]=array

  writeRaster(rpol,filename = savefilename,format="ascii",overwrite=TRUE,NAflag=-9999)
}


setwd("C:/Users/fyang/Desktop/South_Nation_UTM18")
l<-shapefile(x="Int_Hyd_Stm_Strl7_3_Simp200_dis.shp")
my_raster<- list.files(pattern='\\.asc$', full.names=TRUE) ############## This is to read your raster as a list
my_raster<-("nalcms_250m_4hgs.asc")
r <- raster(my_raster, crs=crs(l))

burn_landcover_raster(polyline = l,
                      rasterfile = r,
                      burn_value=18,
                      thickenraster=TRUE,
                      thicken_cellsize=2,
                      savefilename="corrected_landcover1.asc")
