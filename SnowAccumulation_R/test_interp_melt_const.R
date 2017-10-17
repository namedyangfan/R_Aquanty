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
x= 12.25589226
y = seq(1, 365, 10)
x2 = 15.55555556
x3 = 0.15712682
df_interp = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp=x, jday=y)
df_interp2 = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp=x2, jday=y)
df_interp3 = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp=x3, jday=y)

png(filename="interp_versus_table.png")
plot(df_org2$Y_Jday,df_org2$Grid_pot,type="p",col="red", xlab="Jday", ylab="melting_const", ylim=c(0, 80))
lines(df_interp2$y,df_interp2$z, type = "p", col="green")
lines(df_interp$y,df_interp$z, type = "p", col="blue")
lines(df_org$Y_Jday,df_org$Grid_pot,type="p",col="black", pch=18, cex = 1.0)
lines(df_interp3$y,df_interp3$z, type = "p", col="yellow")
lines(df_org3$Y_Jday,df_org3$Grid_pot,type="p",col="pink", pch=19, cex = 1.0)
legend("topright", inset=.05, title="temperature",
   c("15.55555556 (table)","15.55555556 (interp)","12.25589226(interp)", "12.25589226(table)", "0.0(interp)", "0.0 (table)"
    ), col=c('red','green', 'blue', 'black'),  horiz=FALSE, pch= 'o')
dev.off()

## interpolate a snow melt raster
# y = 110
# my_raster = './test/melt_const_raster/final_05weightedtemperature_4.asc'
# temp_raster<-raster(my_raster)
# ar = temp_raster[]
# ar_index = which(ar> 0)
# ar_notnull = ar[ar_index]
# interp = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp= ar_notnull, jday=y)

#  # interp = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp= i, jday=y)
#  # print(interp$z)
# temp_raster[ar_index] = interp$z
# writeRaster(temp_raster, 
#             file='./test/melt_const_raster/test_raster', 
#             format = "ascii",overwrite=TRUE)