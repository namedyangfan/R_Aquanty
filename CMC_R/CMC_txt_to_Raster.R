rm(list = ls())
gc()

# file_lst<- list.files(pattern='\\.dat.gz$', full.names=TRUE) ############## This is to read your raster as a list
#
# gunzip('us_ssmv01025SlL00T0024TTNATS2003100105DP001.dat.gz',remove=FALSE,destname=("C:/Users/fyang/Desktop/"))

cmc_raster<-function(cmc_filename){
cell_size=707
file_length=length(readLines(cmc_filename))
num_day=file_length/cell_size
# x=read.table(file = ('cmc_analysis_1998.txt'), header = FALSE,skip = 1,dec = ".")



  for (i in 1:num_day) {
  
    # new_filename=read.table(file = (cmc_filename), header = FALSE,nrows = 1,skip = (i-1)*cell_size)
    # new_filecontent=read.table(file = (cmc_filename), header = FALSE,skip = 1+(i-1)*cell_size,nrows=(cell_size-1),dec = ".")
    # 
    # s=strsplit(as.character(new_filename),"")[[1]]
    # year=as.character(paste(s[1:4],collapse = ""))
    # m=as.character(paste(s[5:6],collapse = ""))
    # d=as.character(paste(s[7:8],collapse = ""))
    # 
    # fname=paste(year,m,d,sep = "_")
    # 
    # write(paste0("NCOLS 706","\n","NROWS 706","\n","XLLCORNER 353","\n","YLLCORNER 353","\n","CELLSIZE 23812.5","\n","NODATA_value -9999"), file=paste0(fname,'.asc'),append=FALSE) #write zone names
    # write.table(new_filecontent, file=paste0(fname,'.asc'),quote = FALSE,sep="\t",row.names=FALSE,col.names=FALSE,append=TRUE)
    # 
    print(i)
    print(cmc_filename)
    
  }

}

files=list.files("D:/ARB/ARB_WeatherStation/CMC_Snow/CMC_Raster",pattern = ".txt", full.names = TRUE,include.dirs = TRUE,recursive = TRUE)
lapply(files,cmc_raster)

directory=list.files("D:/ARB/ARB_WeatherStation/CMC_Snow/CMC_Raster", full.names = TRUE,include.dirs = TRUE,recursive = FALSE)