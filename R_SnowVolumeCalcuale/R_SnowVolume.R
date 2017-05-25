rm(list = ls())
cat("\014") 
library(raster)
library(parallel)
library(data.table)
library(tools)


# Methods --------------------------------------------------------

calcualteSnow<-function(snow_raster){
  
  r<-raster(snow_raster,crs="+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs")
  p <- spTransform(outline, crs(r)) #Make sure the raster and shapefile are in the same projection
  a=extract(r, p, weights = TRUE,small=TRUE,normalizeWeights=TRUE) #This gives the value of the raster cell, and also the nomalized ratio (Area of cell/Area of basin)
  print(a)
  output <- matrix(unlist(a), ncol = 2, byrow = FALSE)
  
}

parallel_calcualteSnow<-function(outline,raster_lst){
  
  no_cores<-detectCores()
  
  cl<-makeCluster(no_cores)
  
  clusterExport(cl=cl, varlist=c("outline","raster_lst","calcualteSnow"),envir = environment())
  
  a<-clusterEvalQ(cl, library('raster'))
  
  cell_value=parLapply(cl,raster_lst,calcualteSnow)
  
  stopCluster(cl)
  
  return(cell_value)
  
}
  
  

# Main --------------------------------------------------------------------


###shapefile 

#setwd("D:/ARB/Mesh Generation_AlgoMesh Tutorial/Mesh_QuAppelle/Simplified Outline and Rivers")                ##user define
#outline <- shapefile("Outline_100tol_Edited.shp") ##user define
setwd("//AQFS1/Data/temp_data_exchange/Frey/ARB_R_WaterBal_Proj/WaterShed_Bounds")                ##user define
shapefile_name= "PFRA_Souris.shp"
outline <- shapefile(shapefile_name) ##user define


###raster

#setwd("D:/ARB/HGS_Simulations/Qu_Appelle/20327Nodes/27-10-QRB_3D_Steady__20327Nodes_inflow/pcp")               ##user define
setwd("//AQFS1/Data/temp_data_exchange/Frey/ARB_R_WaterBal_Proj/Rasters/era")
raster_lst<- list.files(pattern='\\.asc$', full.names=F) ##user define ############ This is to read your raster as a list


###calcualte snow 
basin_area=area(outline)
# e<-lapply(raster_lst,calcualteSnow)
e<-parallel_calcualteSnow(outline,raster_lst)
cell_value=lapply(e, function(x) {x[,1]*x[,2]} )
sum_cell_value=sapply(cell_value, sum )
#vol_basin=basin_area*(sum_cell_value*30.5)
vol_basin=sum_cell_value*30.5
dt=data.table(filename=file_path_sans_ext(raster_lst), rate_m_month=vol_basin)
write.csv(dt,file= file_path_sans_ext(shapefile_name), row.names = FALSE, quote=FALSE)

# plot(r, legend=F)
# plot(p,add=T)
# text(r)

