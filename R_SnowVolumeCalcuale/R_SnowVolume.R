rm(list = ls())
cat("\014") 
library(raster)



calcualteSnow<-function(snow_raster){
  
  r<-raster(snow_raster,crs="+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs")
  p <- spTransform(outline, crs(r)) #Make sure the raster and shapefile are in the same projection
  a=extract(r, p, weights = TRUE,small=TRUE,normalizeWeights=TRUE) #This gives the value of the raster cell, and also the nomalized ratio (Area of cell/Area of basin)
  print(a)
  output <- matrix(unlist(a), ncol = 2, byrow = FALSE)
  
}




###shapefile 
setwd("D:/ARB/Mesh Generation_AlgoMesh Tutorial/Mesh_QuAppelle/Simplified Outline and Rivers")                ##user define
outline <- shapefile("Outline_100tol_Edited.shp") ##user define


###raster
setwd("D:/ARB/HGS_Simulations/Qu_Appelle/20327Nodes/27-10-QRB_3D_Steady__20327Nodes_inflow/pcp")               ##user define
raster_lst<- list.files(pattern='\\.asc$', full.names=F) ##user define ############ This is to read your raster as a list


###calcualte snow 
basin_area=area(outline)
e<-lapply(raster_lst,calcualteSnow)
cell_value=lapply(e, function(x) {x[,1]*x[,2]} )
sum_cell_value=sapply(cell_value, sum )
vol_basin=basin_area*(sum_cell_value/1000)
cat("The volume equals to:\n",vol_basin,sep = " ")


# plot(r, legend=F)
# plot(p,add=T)
# text(r)

