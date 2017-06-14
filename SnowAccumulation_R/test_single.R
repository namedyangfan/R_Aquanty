############## This script calcualtes monthly snow accumulation raster
#it requires the functions in "snow_accumulation_melt_functions"
#the calculated raster can be read and plot using "PlotSnowRaster.R"
rm(list = ls())
library(raster)
library(parallel)

##the files below need to be provided
tmax_file_path=c("C:/Users/fyang/Desktop/SSRB_Daily/Temperature/max")#need to be changed
tmin_file_path=c("C:/Users/fyang/Desktop/SSRB_Daily/Temperature/min")#need to be changed
pcp_file_path=c("C:/Users/fyang/Desktop/SSRB_Daily/pcp") ##in m/s
crs=c("+proj=longlat +datum=WGS84 +no_defs")


##the directory that you want to save your data to
saving_data_file_path=c("C:/Users/fyang/Desktop/SSRB_Daily") #need to be changed
weighted_coef=0.5
upper_T_thresh=0
lower_T_thresh=0
## 1.157407e-07  ARB 300mm/month C  10mm/dayC   
## 5.787037e-08   5mm/dayC 
metlt_constant = 5.787037e-08
sublimation_constant=0.0
T_melt=0.0 ##melting temperature in degree C

setwd("C:/Users/fyang/Desktop/R_clone/R_Aquanty/SnowAccumulation_R") #need to be changed
source_fucntion='snow_accumulation_melt_functions.R'
source(source_fucntion)

setwd("C:/Users/FYang/Desktop/SSRB_Daily")
mods = readLines("mods.txt")


# Single file -------------------------------------------------------------

# write_weighted_temp_raster(mods,
#                            crs=crs,
#                            tmax_file_path = tmax_file_path,
#                            tmin_file_path = tmin_file_path,
#                            weighted_temp_raster_file_path = saving_data_file_path,
#                            weighted_coef = weighted_coef)

lapply(mods[3:length(mods)], average_weighted_temp_raster, mods = mods, crs = crs, weighted_temp_raster_file_path = saving_data_file_path)


average_weighted_temp_raster(x = '_4.asc',
                            mods = mods, 
                            crs = crs,
                            weighted_temp_raster_file_path = saving_data_file_path)

potential_snow_accumulation_rain_accumulation(upper_T_thresh,
                                              lower_T_thresh,
                                              crs=crs,
                                              mods,
                                              weighted_temp_raster_file_path=saving_data_file_path,
                                              pcp_file_path=pcp_file_path)

potential_snow_melt(metlt_constant,
                    T_melt,
                    crs,
                    mods,
                    saving_data_file_path)

integrate_potential_snowaccumulation_snow_melt(crs,
                                               mods,
                                               saving_data_file_path,
                                               pcp_file_path,
                                               sublimation_constant)

# Combine rain snow -------------------------------------------------------

no_cores<-detectCores()

cl<-makeCluster(no_cores)

clusterExport(cl=cl,
              varlist=c('upper_T_thresh',
                        'lower_T_thresh',
                        'crs',
                        'mods',
                        'saving_data_file_path',
                        'pcp_file_path'),
              envir = environment())

a<-clusterEvalQ(cl, library(raster))

# combine_rain_snow(mods,
#                   save_filename='final_liquid_',
#                   saving_data_file_path,
#                   crs=crs)
# 
parLapply(cl, mods, combine_rain_snow,
          save_filename='final_liquid_',
          saving_data_file_path=saving_data_file_path,
          crs=crs,
          conversion_factor = 86400 #m/s to m
)


# parLapply(cl, mods, snow_depth_unit_conversion,
#           save_filename= 'final_snowdepth_',
#           saving_data_file_path=saving_data_file_path,
#           crs=crs,
#           conversion_factor = 86400 #m/s to m
#           )



stopCluster(cl)




