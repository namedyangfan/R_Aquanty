library(scatterplot3d)
library(data.table, raster)
source('snow_accumulation_melt_functions.R')

file_direc = 'C:/Users/fyang/Desktop/R_clone/R_Aquanty/SnowAccumulation_R'
file_name = 'SnowMeltGrid_NoBlankLines_NoNegatives.txt'


## read in table
ref_file_path = file.path(file_direc, file_name)
melt_table <- read.table(ref_file_path, sep = "" , header = T ,
                     na.strings ="", stringsAsFactors= F, skip = 7)

df_org = melt_table[melt_table$X_temp == 12.25589226, ]

df_org2 = melt_table[melt_table$X_temp == 15.08417508, ]


## interp
x= 12.25589226
y = seq(1, 365)
x2 = 15.08417508
df_interp = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp=x, jday=y)
df_interp2 = interp_melt_const(ref_file_directory = file_direc, ref_file_name = file_name, temp=x2, jday=y)


png(filename="interp_versus.png")
plot(df_org2$Y_Jday,df_org2$Grid_pot,type="p",col="red", xlab="Jday", ylab="melting_const",)
lines(df_interp$y,df_interp$z, type = "p", col="green")
lines(df_interp2$y,df_interp2$z, type = "p", col="blue")
lines(df_org$Y_Jday,df_org$Grid_pot,type="p",col="black")
legend("topright", inset=.05, title="temperature",
  	c("15.08417508 (org)","12.25589226(interp)", "15.08417508 (interp)","15.08417508 (org)"), col=c('red','green', 'blue', 'black'),  horiz=FALSE, pch= 'o')
dev.off()

## interpolate a snow melt raster

