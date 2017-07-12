library(raster)
library(tools)
library(data.table)

# Use Setwd() to set your working directory
#burn_value: the number that you wish to burn (zone number of water)
#unique_value:this value should be set as an unique value if thickenraster equals to true

burn_raster<-function(dem_file_path,
                      surface_dem_file,
                      bedrock_dem_file,
                      surface_crs = "+proj=longlat +datum=WGS84 +no_defs",
                      bedrock_crs = "+proj=longlat +datum=WGS84 +no_defs",
                      savefilename="corrected_bedrock.asc",
                      correct_const = c(3),
                      reference_raster_bedrock=TRUE,
                      ldebug = FALSE
                      ){
  
  suface_dem = file.path(dem_file_path, surface_dem_file)
  
  bedrock_dem = file.path(dem_file_path, bedrock_dem_file)
  
  if (ldebug){
    print(file.exists(suface_dem))
    print(file.exists(bedrock_dem))
  }
  
  
  surface_r = raster(suface_dem, crs=surface_crs)
  bedrock_r = raster(bedrock_dem, crs=bedrock_crs)
  
    
  if(reference_raster_bedrock){
    ### bedrock raster as reference 
    surface_r<- projectRaster(from = surface_r,to=bedrock_r,
                                  method = "bilinear",
                                  filename = "surface_reproj",
                                  format='ascii',
                                  overwrite = TRUE)
  }
  else{
    ### surface raster as reference 
    bedrock_r<- projectRaster(from = bedrock_r,to = surface_r,
                                  method = "bilinear",
                                  filename = "bedrock_reproj",
                                  format='ascii',
                                  overwrite = TRUE)
  }

  surface_array = surface_r[]
  
  surface_array = surface_array - correct_const
  
  bedrock_array = bedrock_r[]
  
  overlap_index = which(bedrock_array >= surface_array)
  
  bedrock_array[overlap_index] = surface_array[overlap_index]
  
  bedrock_r[] = bedrock_array
  
  writeRaster(bedrock_r, file.path(dem_file_path, savefilename), format = "ascii")
  
}
