library(raster)
library(tools)
library(data.table)

# Use Setwd() to set your working directory
#burn_value: the number that you wish to burn (zone number of water)
#unique_value:this value should be set as an unique value if thickenraster equals to true
burn_landcover_raster<-function( polyline,
                                 rasterfile,
                                 burn_value=1000,
                                 unique_value=1000,
                                 thickenraster=TRUE,
                                 savefilename="corrected_landcover_1.asc"){


  rpol <- rasterize(polyline, rasterfile, field = unique_value,update = TRUE)


  array=rpol[]
  temp_rpol=rpol
  index=which(array==unique_value)

  if (thickenraster){
    array[index-1]=array[index]
    array[index+1]=array[index]
    array[index-ncol(temp_rpol)]=array[index]
    array[index+ncol(temp_rpol)]=array[index]
  }

  array[which(array==unique_value)]=burn_value
  rpol[]=array

  writeRaster(rpol,filename = savefilename,format="ascii",overwrite=TRUE,NAflag=-9999)
}



#' Title This function compare the overland raster and the burned raster.
#' Assign new zone number to the overlaped cells
#'
#' @param r : overland raster which contains zone numbers
#' @param r_nca : burned raster ( with burned value). obtained from burn_landcover_raster
#' @param zone_num_list : zone number in r that need to be corrected
#' @param toltal_zone_num : corrected zone number = toltal_zone_num + zone_num
#' @param burn_value : what is the burned value in r_nca
#'
#' @return
#' @export
#'
#' @examples
overland_add_zone<-function(r,r_nca,zone_num_list,toltal_zone_num=c(100),burn_value){



  # find the index of the zone_num cells and the index of the burned value
  # give a new zone number to the same index

  add_zone_num<-function(zone_num){

    r_array = temp []

    #find the index of zone_num in r_array
    r_landcover_index = which ( r_array %in% zone_num )

    nca_landcover_index = intersect( nca_index, r_landcover_index )

    r_array[nca_landcover_index] = zone_num + toltal_zone_num

    temp[] = r_array

    return(temp)

  }


  temp = r

  r_nca_array = r_nca []

  nca_index= which ( r_nca_array == burn_value )

  for (i in 1 : length ( zone_num_list ) ){

    temp = add_zone_num ( zone_num_list [i] )

    print ( zone_num_list [i] )
  }

  return(temp)

}
