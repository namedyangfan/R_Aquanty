############## This script calcualtes monthly snow accumulation raster
#it requires the functions in "snow_accumulation_melt_functions"
#the calculated raster can be read and plot using "PlotSnowRaster.R"
rm(list = ls())
library(raster)


# mods=c('_6.asc',
#        '_7.asc',
#        '_8.asc',
#        '_9.asc',
#        '_10.asc',
#        '_11.asc',
#        '_12.asc',
#        '_1.asc',
#        '_2.asc',
#        '_3.asc',
#        '_4.asc',
#        '_5.asc')

##the files below need to be provided
tmax_file_path=c("D:/ARB/ARB_WeatherStation/CFS/Temperature/clip_wgs84/max")#need to be changed
tmin_file_path=c("D:/ARB/ARB_WeatherStation/CFS/Temperature/clip_wgs84/min")#need to be changed
pcp_file_path=c("C:/Users/fyang/Desktop/SSRB_Monthly_Norms/Input_Test/rainfall") ##in m/s
crs=c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs")


##the directory that you want to save your data to
saving_data_file_path=c("C:/Users/fyang/Desktop/SSRB_Monthly_Norms/Input_Test") #need to be changed
weighted_coef=0.5
upper_T_thresh=0
lower_T_thresh=0
metlt_constant=300 ##ARB 300mm/month C  10mm/dayC     ORB##2.0*0.001/86400 ##melting rate constnat in m/s (2mm/day) degree C
sublimation_constant=0.0
T_melt=0.0 ##melting temperature in degree C

setwd("C:/Users/fyang/Desktop/R_clone/R_repository/SnowAccumulation_R") #need to be changed
source("snow_accumulation_melt_functions.R")

setwd("C:/Users/fyang/Desktop/SSRB_Monthly_Norms")
mods = readLines("mods.txt")

# write_weighted_temp_raster(mods,
#                            crs,
#                            tmax_file_path,
#                            tmin_file_path,
#                            saving_data_file_path,
#                            weighted_coef)

# potential_snow_accumulation_rain_accumulation(upper_T_thresh,
#                                               lower_T_thresh,
#                                               crs,
#                                               mods,
#                                               weighted_temp_raster_file_path=saving_data_file_path,
#                                               pcp_file_path)
# 
# potential_snow_melt(metlt_constant,
#                     T_melt,
#                     crs,
#                     mods,
#                     saving_data_file_path)

# integrate_potential_snowaccumulation_snow_melt(crs,
#                                                mods,
#                                                saving_data_file_path,
#                                                pcp_file_path,
#                                                sublimation_constant)

combine_rain_snow(mods,
                  save_filename='final_liquid_',
                  saving_data_file_path,
                  crs=crs)
