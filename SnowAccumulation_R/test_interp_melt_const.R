source('snow_accumulation_melt_functions.R')

cwd= getwd()
mods = readLines("mods.txt")
crs = '+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs'

# write_weighted_temp_raster(mods = mods,
#                            crs = c("+proj=longlat +datum=WGS84 +no_defs"),
#                            tmax_file_path = file.path(cwd, 'test', 'tmax'),
#                            tmin_file_path = file.path(cwd, 'test', 'tmin'),
#                            weighted_temp_raster_file_path = file.path(cwd, 'test'),
#                            weighted_coef =0.5)

lapply(mods[3:length(mods)],
          average_weighted_temp_raster,
          crs = crs,
          mods = mods,
          weighted_temp_raster_folder_path = file.path(cwd, 'test'),
          weighted_temp_raster_folder_name = 'weighted_temp_raster',
          le=c(2)
          )

potential_snow_accumulation_rain_accumulation(upper_T_thresh = 0,
                                              lower_T_thresh = 0,
                                              crs = crs,
                                              mods = mods[3:length(mods)],
                                              weighted_temp_raster_file_path = file.path(cwd, 'test'),
                                              pcp_file_path = file.path(cwd, 'test', 'pcp'),
                                              temp_foldername = 'averaged_weighted_temperature')

interp_melt_const_raster(mods = mods[3:length(mods)], 
                         work_directory = file.path(cwd, 'test'),
                         table_directory = cwd,
                         temp_folder_name="averaged_weighted_temperature", 
                         crs = crs,
                         format = 'ascii',
                         mods_format = "%d_%m_%Y")

potential_snow_melt(melt_const_folder='snow_melt_constant',
                    format="ascii",
                    crs =  crs,
                    mods = mods[3:length(mods)],
                    work_directory = file.path(cwd, 'test'),
                    temp_foldername = 'averaged_weighted_temperature'
                    )

integrate_potential_snowaccumulation_snow_melt(crs = crs,
                                               mods = mods[3:length(mods)],
                                               work_directory = file.path(cwd, 'test'),
                                               sublimation_constant = 0.0)

combine_rain_snow(mods = mods[3:length(mods)],
                  save_filename='final_liquid_',
                  work_directory = file.path(cwd, 'test'),
                  crs = crs)
