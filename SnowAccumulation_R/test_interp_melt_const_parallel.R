library(parallel)
source('snow_accumulation_melt_functions.R', local=TRUE)

cwd= getwd()
mods = readLines("mods.txt")
crs = '+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs'

#Parallel
no_cores<-detectCores()

cl<-makeCluster(no_cores)

clusterExport(cl=cl,
              varlist=list('cwd',
                        'crs',
                        'mods',
                        'interp_melt_const',
                        'bicubic'),
              envir = environment())

a<-clusterEvalQ(cl, library(raster))

##

parLapply(cl, mods,
          write_weighted_temp_raster,
           crs = c("+proj=longlat +datum=WGS84 +no_defs"),
           tmax_file_path = file.path(cwd, 'test', 'tmax'),
           tmin_file_path = file.path(cwd, 'test', 'tmin'),
           weighted_temp_raster_file_path = file.path(cwd, 'test'),
           weighted_coef =0.5)

parLapply(cl, mods[3:length(mods)], 
       average_weighted_temp_raster, 
       mods = mods, 
       crs = crs, 
       weighted_temp_raster_folder_path = file.path(cwd, 'test'),
       weighted_temp_raster_folder_name = 'weighted_temp_raster',
       le=c(2))

parLapply(cl, mods[3:length(mods)], potential_snow_accumulation_rain_accumulation,
          upper_T_thresh=0,
          lower_T_thresh=0,
          crs=crs,
          weighted_temp_raster_file_path=file.path(cwd, 'test'),
          pcp_file_path=file.path(cwd, 'test', 'pcp'),
          temp_foldername = 'averaged_weighted_temperature')

parLapply(cl, mods[3:length(mods)], interp_melt_const_raster,
           work_directory = file.path(cwd, 'test'),
           table_directory = cwd,
           temp_folder_name="averaged_weighted_temperature", 
           crs = crs,
           format = 'ascii',
           mods_format = "%d_%m_%Y",
           conversion_factor = 1.15741e-8)


parLapply(cl, mods[3:length(mods)], potential_snow_melt,

          melt_const_folder = 'snow_melt_constant',
          crs=crs,
          work_directory=file.path(cwd, 'test'),
          temp_foldername = 'averaged_weighted_temperature')

integrate_potential_snowaccumulation_snow_melt(crs = crs,
                                               mods = mods[3:length(mods)],
                                               work_directory = file.path(cwd, 'test'),
                                               sublimation_constant = 0.0)

parLapply(cl, mods[3:length(mods)], combine_rain_snow,
          work_directory = file.path(cwd, 'test'),
          crs = crs)

parLapply(cl, mods[3:length(mods)], snow_depth_unit_conversion,
          save_filename = 'final_snowdepth_',
          work_directory = file.path(cwd, 'test'),
          crs=crs,
          conversion_factor = 86400 #m/s to m)
          )

stopCluster(cl)

