############## This script calcualtes monthly snow accumulation raster
#it requires the functions in "snow_accumulation_melt_functions"
#the calculated raster can be read and plot using "PlotSnowRaster.R"
rm(list = ls())
library(raster)
library(parallel)

##the files below need to be provided
pcp_file_path=c("C:/Users/FYang/Desktop/SSRB_Daily/v5_10km/input/precip_10km") ##in m/s
crs=c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs")
weighted_temp_raster_directory = c("C:/Users/FYang/Desktop/SSRB_Daily/v5_10km/input")
weighted_temp_raster_folder_name = c("weighted_temp_raster")

upper_T_thresh=0.0
lower_T_thresh=0.0
## 1.157407e-07  ARB 300mm/month C  10mm/dayC   
## 5.787037e-08   5mm/dayC 
metlt_constant = 5.787037e-08
sublimation_constant=0.0
T_melt=0.0 ##melting temperature in degree C

setwd("C:/Users/FYang/Desktop/R_Aquanty/SnowAccumulation_R") #need to be changed
source_fucntion='snow_accumulation_melt_functions.R'
source(source_fucntion)

setwd("C:/Users/FYang/Desktop/SSRB_Daily/v5_10km/input")
mods = readLines("mods.txt")

lapply(mods[3:length(mods)],
          average_weighted_temp_raster,
          crs = crs,
          mods = mods,
          weighted_temp_raster_folder_path = weighted_temp_raster_directory,
          weighted_temp_raster_folder_name = weighted_temp_raster_folder_name,
          le=c(2)
          )

lapply(mods, potential_snow_accumulation_rain_accumulation,
          upper_T_thresh=upper_T_thresh,
          lower_T_thresh=lower_T_thresh,
          crs=crs,
          weighted_temp_raster_file_path=weighted_temp_raster_directory,
          pcp_file_path=pcp_file_path,
          temp_foldername = 'weighted_temp_raster')

lapply(mods, potential_snow_melt,
          T_melt=T_melt,
          crs=crs,
          metlt_constant=metlt_constant,
          work_directory=weighted_temp_raster_directory,
          temp_foldername = 'averaged_weighted_temperature')

integrate_potential_snowaccumulation_snow_melt(crs = crs,
                                               mods = mods,
                                               work_directory = weighted_temp_raster_directory,
                                               sublimation_constant)

lapply(mods, combine_rain_snow,
          save_filename='final_liquid_',
          work_directory=weighted_temp_raster_directory,
          crs=crs
)

lapply(mods, snow_depth_unit_conversion,
          save_filename= 'final_snowdepth_',
          work_directory=weighted_temp_raster_directory,
          crs=crs,
          conversion_factor = 86400 #m/s to m
)




