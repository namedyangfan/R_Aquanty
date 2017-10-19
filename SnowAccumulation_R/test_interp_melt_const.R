library(scatterplot3d)
library(data.table)
library(raster)
source('snow_accumulation_melt_functions.R')

file_direc = 'C:/Users/fyang/Desktop/R_clone/R_Aquanty/SnowAccumulation_R'
file_name = 'SnowMeltGrid_NoBlankLines_NoNegatives.txt'


# read in table
ref_file_path = file.path(file_direc, file_name)
melt_table <- read.table(ref_file_path, sep = "" , header = T ,
                     na.strings ="", stringsAsFactors= F, skip = 7)

df_org = melt_table[melt_table$X_temp == 12.25589226, ]

df_org2 = melt_table[melt_table$X_temp == 15.55555556, ]

df_org3 = melt_table[melt_table$X_temp == 0.15712682, ]


## interp
# x= 12.25589226
# y = seq(1, 365)
# x2 = 15.55555556
# x3 = 0.15712682
# df_interp = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp=x, jday=y)
# df_interp2 = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp=x2, jday=y)
# df_interp3 = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp=x3, jday=y)

# png(filename="interp_versus_table.png")
# plot(df_org2$Y_Jday,df_org2$Grid_pot,type="p",col="red", xlab="Jday", ylab="melting_const", ylim=c(0, 80))
# lines(df_interp2$y,df_interp2$z, type = "p", col="green")
# lines(df_interp$y,df_interp$z, type = "p", col="blue")
# lines(df_org$Y_Jday,df_org$Grid_pot,type="p",col="black", pch=18, cex = 1.0)
# lines(df_interp3$y,df_interp3$z, type = "p", col="brown")
# lines(df_org3$Y_Jday,df_org3$Grid_pot,type="p",col="pink", pch=19, cex = 0.5)
# legend("topright", inset=.05, title="temperature",
#    c("15.55555556 (table)","15.55555556 (interp)","12.25589226(interp)", "12.25589226(table)", "0.15712682 (interp)", "0.15712682 (table)"
#     ), col=c('red','green', 'blue', 'black', 'b rown', 'pink'),  horiz=FALSE, pch= 'o')
# dev.off()

## interpolate a snow melt raster
cwd= getwd()
# write_weighted_temp_raster(mods = c('_1.asc','_2.asc','_3.asc'),
#                            crs = c("+proj=longlat +datum=WGS84 +no_defs"),
#                            tmax_file_path = file.path(cwd, 'test', 'tmax'),
#                            tmin_file_path = file.path(cwd, 'test', 'tmin'),
#                            weighted_temp_raster_file_path = file.path(cwd, 'test'),
#                            weighted_coef =0.5)

potential_snow_accumulation_rain_accumulation(upper_T_thresh = 0,
                                              lower_T_thresh = 0,
                                              crs = c("+proj=longlat +datum=WGS84 +no_defs"),
                                              mods = c('01_04_2009','02_04_2009','03_04_2009', '04_04_2009'),
                                              weighted_temp_raster_file_path = file.path(cwd, 'test'),
                                              pcp_file_path = file.path(cwd, 'test', 'pcp'),
                                              temp_foldername = 'weighted_temp_raster')


interp_melt_const_raster(mods = c('01_04_2009','02_04_2009','03_04_2009', '04_04_2009'), 
                         work_directory = file.path(cwd, 'test'),
                         table_directory = cwd,
                         temp_folder_name="weighted_temp_raster", 
                         crs='+proj=longlat +datum=WGS84 +no_defs',
                         format = 'ascii',
                         mods_format = "%d_%m_%Y")

potential_snow_melt(melt_const_folder='snow_melt_constant',
                    format="ascii",
                    crs =  c("+proj=longlat +datum=WGS84 +no_defs"),
                    mods = c('01_04_2009','02_04_2009','03_04_2009', '04_04_2009'),
                    work_directory = file.path(cwd, 'test'),
                    temp_foldername = 'weighted_temp_raster'
                    )

integrate_potential_snowaccumulation_snow_melt(crs = c("+proj=longlat +datum=WGS84 +no_defs"),
                                               mods = c('01_04_2009','02_04_2009','03_04_2009', '04_04_2009'),
                                               work_directory = file.path(cwd, 'test'),
                                               sublimation_constant = 0.0)
