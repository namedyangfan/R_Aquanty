

### the below create weighted temperature raster that can be used to determine snow accumulation
### the input raster required are "T_max", "T_min"

write_weighted_temp_raster<-function(crs,mods,tmax_file_path,tmin_file_path,weighted_temp_raster_file_path,weighted_coef){

  setwd(tmax_file_path)

  my_raster<- list.files(pattern=mods[1]) ############## This is to read your raster as a list
  
  Tmax<-raster(my_raster,  crs=crs)

  weighted_coef_accumulation_array=Tmax[]
  weighted_coef_accumulation_array[]=weighted_coef ##initialize the weighted coef array
  weighted_temp_raster=Tmax  ##initialize the weighted coef raster


     for (mod in mods){

      tmax<- list.files(path=tmax_file_path,pattern=mod)
      tmin<- list.files(path=tmin_file_path,pattern=mod)
      
      print(tmax)
      print(tmin)
      
      setwd(tmax_file_path)
      tmax_raster<- raster(tmax, crs = crs)
      setwd(tmin_file_path)
      tmin_raster<- raster(tmin, crs = crs)

      tmax_array=tmax_raster[]

      tmin_array=tmin_raster[]

      weighted_temp_array=tmin_array+weighted_coef_accumulation_array*(tmax_array-tmin_array)

      weighted_temp_raster[]=weighted_temp_array

      setwd(weighted_temp_raster_file_path)
      dir.create("weighted_temp_raster",showWarnings = FALSE)
      setwd("weighted_temp_raster")

      writeRaster(weighted_temp_raster, file=paste("final_05weightedtemperature_",mod, sep=""), format = "GTiff",overwrite=TRUE)

     }

}

average_weighted_temp_raster<-function(x,
                                       mods, 
                                       crs,
                                       weighted_temp_raster_folder_path,
                                       weighted_temp_raster_folder_name = "weighted_temp_raster",
                                       le = 2,
                                       ldebug = FALSE){
  
  
  file_path = file.path(weighted_temp_raster_folder_path,weighted_temp_raster_folder_name)
  if (!file.exists(file_path)){
    print(file_path)
    stop("ERROR: directory does not exist")
    }
  # f_names get all the files that match the modes in a sequential order
  f_names = sapply(mods, function(x){
                    list.files(path= file_path, pattern = x, full.names = TRUE )},
                    USE.NAMES = FALSE)
  
  #xindex: locate the index of file x, so we knew which other files are required to calcualte the average  
  x_index=which(mods == x)

    if ( length(x_index) ==0){ 
      stop("ERROR: Not able to match x in mods")
    }
    
    if ( x_index <= le){ 
      print("ERROR: There is not enough data to calculate the backward average of x:%s /n")
      print(paste("x_index:",x_index))
      print(paste("le:",le))
      stop("make sure le is smaller than the x_index/n")
    }
    
    stack_files = f_names[(x_index-le):x_index]
    
    if(ldebug){print(stack_files)}
    
    results <- tryCatch(
      {r_stack = stack(stack_files)
      }, error = function(err){
        print(stack_files)
        stop("unable to stack the above raster files")
      }
    )
    
    
    crs(r_stack) = crs
    
    r_mean = stackApply(r_stack,fun = mean, indices = rep(1, nlayers(r_stack)))
    
    setwd(weighted_temp_raster_folder_path)
    dir.create("averaged_weighted_temperature",showWarnings = FALSE)
    writeRaster(r_mean, 
                file=paste("./averaged_weighted_temperature/averaged_weighted_temp",x, sep=""), format = "ascii",overwrite=TRUE)
    return(TRUE)
}

potential_snow_accumulation_rain_accumulation<-function(upper_T_thresh,
                                                        lower_T_thresh,
                                                        crs,
                                                        mods,
                                                        weighted_temp_raster_file_path,
                                                        pcp_file_path,
                                                        temp_foldername = 'weighted_temp_raster',
                                                        ldebug = FALSE){


      for (mod in mods){
        if (ldebug){print(mod)}
        
        wd=file.path(weighted_temp_raster_file_path,temp_foldername)
        setwd(wd)

        my_raster<- list.files(pattern=mod)
        if (ldebug){print(my_raster)}

        accumulation_weighted_temp_raster<-raster(my_raster, crs = crs )
        if (ldebug){print("able to open raster")}

        snow_accumulation_raster=accumulation_weighted_temp_raster   ##initialize snow accumulation raster

        rain_accumulation_raster=accumulation_weighted_temp_raster   ##initialize rain accumulation raster

        T_array=accumulation_weighted_temp_raster[] #array for weighted temp

        s_array=snow_accumulation_raster[] #array for potential snow accumulation

        r_array=snow_accumulation_raster[] #array for potential rain accumulation

        r_array[]=0

        s_array[]=0

        s_r_array=s_array #array for snow rain mixed

        rain_index=which(T_array>upper_T_thresh)

        snow_index=which(T_array<=(lower_T_thresh))

        snow_rain_index=which(T_array>=(lower_T_thresh) & T_array<=upper_T_thresh)
        
        if (ldebug){print("able to get rain and snow index")}

        ###################### read pcp data
        setwd(pcp_file_path)
        pcp<- list.files(pattern=mod)
        if (ldebug){print(pcp)}
        pcp_raster<- raster(pcp, crs = crs)
        if (ldebug){print("able to open the pcp raster")}


        ###################### snow accumulation
        s_array[snow_index]=pcp_raster[snow_index]

        #####################  rain accumualtion
        r_array[rain_index]=pcp_raster[rain_index]

        #####################  snow rain mixed
          ##rain

          s_r_array[snow_rain_index]=pcp_raster[snow_rain_index]*((T_array[snow_rain_index]-lower_T_thresh)/(upper_T_thresh-lower_T_thresh))
  
          # if upper_T_thresh does not equal to lower_T_thresh
          if(upper_T_thresh != lower_T_thresh){
  
            r_array2=r_array+s_r_array
  
          }
          else{
  
            print("upper T melt = lower T melt")
  
            r_array2=r_array
  
          }
          rain_accumulation_raster[]=r_array2


          ##snow
          s_r_array[snow_rain_index]=pcp_raster[snow_rain_index]-s_r_array[snow_rain_index]
  
  
          if(upper_T_thresh != lower_T_thresh){
  
            s_array2=s_array+s_r_array
  
          }
          else{
  
            s_array2=s_array
  
          }
  
          snow_accumulation_raster[]=s_array2


        ##save potential rain accumulation raster
        setwd(weighted_temp_raster_file_path)
        dir.create("potential_rain_accumulation",showWarnings = FALSE)
        setwd("potential_rain_accumulation")
        writeRaster(rain_accumulation_raster, file=paste("rain_accumulation_",mod, sep=""), format = "GTiff",overwrite=TRUE)


        ##save potential snow accumulation raster
        setwd("../")
        dir.create("potential_snow_accumulation",showWarnings = FALSE)
        setwd("potential_snow_accumulation")
        writeRaster(snow_accumulation_raster, file=paste("snow_accumulation_",mod, sep=""), format = "GTiff",overwrite=TRUE)

      }
}



potential_snow_melt<-function(metlt_constant,T_melt,crs,mods,work_directory, temp_foldername, ldebug=TRUE){

  for (mod in mods){
    
    temp_file_dirc=paste(work_directory,"/",temp_foldername,sep="")
    
    if (!file.exists(temp_file_dirc)){
      print(temp_file_dirc)
      stop("ERROR: directory does not exist")
    }

    setwd(temp_file_dirc)
    my_raster<- list.files(pattern=mod)
    
    if(ldebug){print(my_raster)}
    
    if(length(my_raster)==0){
      stop(paste("ERROR: no file matches the pattern in the folder:", temp_file_dirc))
    }
    
    accumulation_weighted_temp_raster<-raster(my_raster,  crs=crs)
    
    T_array=accumulation_weighted_temp_raster[] #array for weighted temp

    potential_snow_melt_raster=accumulation_weighted_temp_raster ##initialize the potential snow melt raster

    potential_snow_melt_raster[]=0

    melt_index=which(T_array>T_melt)

    potential_snow_melt_raster[melt_index]=metlt_constant*(T_array[melt_index]-T_melt)

    setwd("../")

    dir.create("potential_snow_melt_raster",showWarnings = FALSE)

    setwd("potential_snow_melt_raster")

    writeRaster(potential_snow_melt_raster, file=paste("Potential_snow_melt_",mod, sep=""), format = "GTiff",overwrite=TRUE)

  }


}


integrate_potential_snowaccumulation_snow_melt<-function(crs,
                                                         mods,
                                                         saving_data_file_path,
                                                         pcp_file_path,
                                                         sublimation_constant){

  

  sa=c()
  sm=c()
  st=c()
  st_sum=c()
  sm_sum=c()
  print(mods)
  
  #initilize snow carried over from last month (final_snow_accumulation_array_1)
  final_snow_accumulation_array_1=0 

  for (mod in mods){

    ##read in the potential snow melt raster
    setwd(paste(saving_data_file_path,"/potential_snow_melt_raster",sep=""))

    my_raster<- list.files(pattern=mod)
    
    print(my_raster)


    potential_snow_Melt_raster<-raster(my_raster,  crs=crs)

    potential_snow_Melt_array=potential_snow_Melt_raster[]


    ##read in the snow accumulation raster
    setwd(paste(saving_data_file_path,"/potential_snow_accumulation",sep=""))

    my_raster<- list.files(pattern=mod)
    
    print(my_raster)

    snow_accumulation_raster<-raster(my_raster,  crs=crs)

    final_snow_melt_raster<-snow_accumulation_raster #initialize snow melt

    snow_accumulation_sublimation_raster<-snow_accumulation_raster #initialize snow sublimation

    snow_accumulation_array=snow_accumulation_raster[]


    ##set up the current month accumulative snow accumulation array
    ##final_snow_accumulation_array_2 combines the snow potential for this month
    ##and snow carried over from last month (final_snow_accumulation_array_1)

    final_snow_accumulation_array_2=snow_accumulation_array+final_snow_accumulation_array_1
    final_snow_melt_array=final_snow_accumulation_array_2


    ##find the index for over melting and under melting

    over_melt_index=which(potential_snow_Melt_array>=final_snow_accumulation_array_2)

    under_melt_index=which(potential_snow_Melt_array<final_snow_accumulation_array_2)


    ##assign over melt index equals to 0
    final_snow_accumulation_array_2[over_melt_index]=0


    ##calcualte the amount to snow after melting
    final_snow_accumulation_array_2[under_melt_index]=final_snow_accumulation_array_2[under_melt_index]-potential_snow_Melt_array[under_melt_index]
    final_snow_melt_array[under_melt_index]=potential_snow_Melt_array[under_melt_index]



    ##set up the previouse month accumulative snow accumulation array
    final_snow_accumulation_array_1=final_snow_accumulation_array_2

    # st[j]=sum(snow_accumulation_array) ##monthly snow depth without melting
    # st_sum[j]=sum(st[1:j])##snow depth without melting
    # sa[j]=sum(final_snow_accumulation_array_2) ##snow depth with melting
    # sm[j]=sum(final_snow_melt_array)##monthly snow melt
    # sm_sum[j]=sum(sm[1:j])## snow melt


    # filename<- paste("accumulative_snow_accumulation_monthly_2009_2013_",labellist[j],".png")
    # png(file=filename)
    # plot(snow_accumulation_raster)
    # title(main = paste("accumulative snow accumulation at month",labellist[j],sep = " "))
    # dev.off()
    final_snow_accumulation_array_1_mmonth=final_snow_accumulation_array_1 ##*30*86400 if the pcp is in m/s, can be converted to m/month

    snow_accumulation_raster[]=final_snow_accumulation_array_1_mmonth
    setwd("../")
    dir.create("final_accumulative_snow_accumulation_raster",showWarnings = FALSE)
    setwd("final_accumulative_snow_accumulation_raster")
    writeRaster(snow_accumulation_raster, file=paste("snow_depth_",mod, sep=""), format = "GTiff",overwrite=TRUE)


    final_snow_melt_raster[]=final_snow_melt_array
    setwd("../")
    dir.create("final_snow_melt_raster",showWarnings = FALSE)
    setwd("final_snow_melt_raster")
    writeRaster(final_snow_melt_raster, file=paste("snow_melt_raster_",mod, sep=""), format = "GTiff",overwrite=TRUE)

    # snow_accumulation_sublimation_raster[]=final_snow_accumulation_array_1_mmonth*(1-sublimation_constant)
    # setwd("../")
    # dir.create("final_snow_accumulation_raster_sublimation",showWarnings = FALSE)
    # setwd("final_snow_accumulation_raster_sublimation")
    # writeRaster(snow_accumulation_sublimation_raster, file=paste("snow_melt_raster_sublimation_",mod, sep=""), format = "GTiff",overwrite=TRUE)

  }
}



# combine rain snow -------------------------------------------------------


combine_rain_snow <- function(mods,
                              save_filename='final_liquid_',
                              saving_data_file_path,
                              crs,
                              conversion_factor=1){
  
  for (mod in mods){
    
    p = file.path(saving_data_file_path, 'potential_rain_accumulation' )
    setwd(p)
    print(p)
    my_raster<- list.files( path = p, pattern=mod)
    print(my_raster)
    rain_raster<-raster(my_raster,  crs=crs)
    rain_array<-rain_raster[]
    
    p = file.path(saving_data_file_path, 'final_snow_melt_raster' )
    setwd(p)
    my_raster<- list.files( path = p, pattern=mod)
    snowmelt_raster<-raster(my_raster,  crs=crs)
    snowmelt_array<-snowmelt_raster[]
    
    combine_rain_snowmelt_raster=rain_raster
    combine_rain_snowmelt_raster[]=snowmelt_raster[] + rain_raster[]
    
    setwd("../")
    dir.create("combine_rain_snowmelt",showWarnings = FALSE)
    setwd("combine_rain_snowmelt")
    writeRaster(combine_rain_snowmelt_raster, 
                file=paste(save_filename,mod, sep=""), 
                format = "ascii",overwrite=TRUE)
    
    
  }
  
  
}

snow_depth_unit_conversion <- function(mod,
                                       save_filename = 'final_snowdepth_',
                                       saving_data_file_path,
                                       crs,
                                       conversion_factor=1){
  
  p = file.path(saving_data_file_path, 'final_accumulative_snow_accumulation_raster' )
  setwd(p)
  print(p)
  my_raster<- list.files( path = p, pattern=mod)
  print(my_raster)
  snowdepth_raster<-raster(my_raster, crs=crs)
  snowdepth_array<-snowdepth_raster[]
  
  
  snowdepth_raster[] = snowdepth_array * conversion_factor # convert the unit of snow depth
  
  setwd("../")
  dir.create("final_snowdepth_unit_conversion",showWarnings = FALSE)
  setwd("final_snowdepth_unit_conversion")
  
  writeRaster(snowdepth_raster, 
              file=paste(save_filename,mod, sep=""), 
              format = "ascii",overwrite=TRUE)
  
}