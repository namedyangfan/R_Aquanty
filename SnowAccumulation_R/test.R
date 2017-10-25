source("snow_accumulation_melt_functions.R")
cwd = getwd()

write_weighted_temp_raster(mods = c('01_04_2009','02_04_2009','03_04_2009'),
                           crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                           tmax_file_path = file.path(cwd, 'test', 'tmax'),
                           tmin_file_path = file.path(cwd, 'test', 'tmin'),
                           weighted_temp_raster_file_path = file.path(cwd, 'test'),
                           weighted_coef =0.5)

average_weighted_temp_raster(x = '03_04_2009',
                             mods = c('01_04_2009','02_04_2009','03_04_2009'),
                             crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                             weighted_temp_raster_folder_path = file.path(cwd, 'test'),
                             weighted_temp_raster_folder_name = "weighted_temp_raster",
                             le = 2)

potential_snow_accumulation_rain_accumulation(upper_T_thresh = 0,
                                              lower_T_thresh = 0,
                                              crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                                              mods = c('01_04_2009','02_04_2009','03_04_2009'),
                                              weighted_temp_raster_file_path = file.path(cwd, 'test'),
                                              pcp_file_path = file.path(cwd, 'test', 'pcp'),
                                              temp_foldername = 'weighted_temp_raster')

interp_melt_const_raster(mods = c('01_04_2009','02_04_2009','03_04_2009'),
                         work_directory = file.path(cwd, 'test'),
                         table_directory = cwd,
                         temp_folder_name="weighted_temp_raster", 
                         crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                         format = 'ascii',
                         mods_format = "%d_%m_%Y",
                         conversion_factor = 1.15741e-8)

potential_snow_melt(metlt_constant = 5.787037e-08,
                    T_melt = 0.0,
                    crs =  c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                    mods = c('01_04_2009','02_04_2009','03_04_2009'),
                    work_directory = file.path(cwd, 'test'),
                    temp_foldername = "weighted_temp_raster")

potential_snow_melt(melt_const_folder='snow_melt_constant',
                    format="GTiff",
                    crs =  c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                    mods = c('01_04_2009','02_04_2009','03_04_2009'),
                    work_directory = file.path(cwd, 'test'),
                    temp_foldername = 'weighted_temp_raster'
                    )

integrate_potential_snowaccumulation_snow_melt(crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                                               mods = c('01_04_2009','02_04_2009','03_04_2009'),
                                               work_directory = file.path(cwd, 'test'),
                                               sublimation_constant = 0.0)

combine_rain_snow(mods = c('01_04_2009','02_04_2009','03_04_2009'),
                  save_filename='final_liquid_',
                  work_directory = file.path(cwd, 'test'),
                  crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"))

snow_depth_unit_conversion(mods = c('01_04_2009','02_04_2009','03_04_2009'),
                          save_filename = 'final_snowdepth_',
                          work_directory = file.path(cwd, 'test'),
                          crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                          conversion_factor = 86400 )