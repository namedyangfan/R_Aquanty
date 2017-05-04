############ small scripts to batch project your raster
rm(list = ls())

library(raster)
library(tools)
library(data.table)

source( "C:/Users/fyang/Desktop/R_clone/R_repository/Burn_raster/Burn_landcover_func.R" )

setwd( "C:/Users/fyang/Desktop/depression_lc/mask9" ) #change folder

l<-shapefile( x = "900.shp" )  #change shapefile
l=spTransform(l, CRS=CRS( "+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs" ) )

my_raster<- ("corrected_landcover_800.asc") ############## This is to read your raster as a list
r <- raster( my_raster, crs = crs(l) )
burn_landcover_raster( polyline = l,
                       rasterfile = r,
                       burn_value = 1000,
                       thickenraster = FALSE,
                       savefilename= "corrected_landcover_burn_value"

                       )

my_raster = c( "corrected_landcover_burn_value.asc" )
r_nca <- raster( my_raster, crs = crs(l) )


zone_num = seq ( 801,817 ) #change numbering


temp = overland_add_zone ( r,
                           r_nca,
                           zone_num_list = zone_num,
                           toltal_zone_num = c(100), #may have to change the number
                           burn_value=c( 1000 )
                           )

writeRaster(temp,filename = "corrected_landcover_900",
            format = "ascii",
            overwrite = TRUE,
            NAflag = -9999
)
# change output filename



