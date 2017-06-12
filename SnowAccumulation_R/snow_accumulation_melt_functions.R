

### the below create weighted temperature raster that can be used to determine snow accumulation
### the input raster required are "T_max", "T_min"

write_weighted_temp_raster<-function(mods,crs,tmax_file_path,tmin_file_path,weighted_temp_raster_file_path,weighted_coef){

  setwd(tmax_file_path)

  my_raster<- list.files(pattern=mods[1]) ############## This is to read your raster as a list
  Tmax<-raster(my_raster,  crs)

  weighted_coef_accumulation_array=Tmax[]
  weighted_coef_accumulation_array[]=weighted_coef ##initialize the weighted coef array
  weighted_temp_raster=Tmax  ##initialize the weighted coef raster


     for (j in 1:length(mods)){

      tmax<- list.files(path=tmax_file_path,pattern=mods[j])
      tmin<- list.files(path=tmin_file_path,pattern=mods[j])

      setwd(tmax_file_path)
      tmax_raster<- raster(tmax, crs)
      setwd(tmin_file_path)
      tmin_raster<- raster(tmin, crs)

      tmax_array=tmax_raster[]

      tmin_array=tmin_raster[]

      weighted_temp_array=tmin_array+weighted_coef_accumulation_array*(tmax_array-tmin_array)

      weighted_temp_raster[]=weighted_temp_array

      setwd(weighted_temp_raster_file_path)
      dir.create("weighted_temp_raster",showWarnings = FALSE)
      setwd("weighted_temp_raster")

      writeRaster(weighted_temp_raster, file=paste("final_05weightedtemperature_",j, sep=""), format = "ascii",overwrite=TRUE)

     }

}

potential_snow_accumulation_rain_accumulation<-function(upper_T_thresh,
                                                        lower_T_thresh,
                                                        crs,
                                                        mods,
                                                        weighted_temp_raster_file_path,
                                                        pcp_file_path){


      for (mod in mods){
        print(mod)
        wd=paste(weighted_temp_raster_file_path,"/weighted_temp_raster",sep="")

        setwd(wd)

        my_raster<- list.files(pattern=mod)
        print(my_raster)


        accumulation_weighted_temp_raster<-raster(my_raster, crs = crs )

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

        ###################### read pcp data
        setwd(pcp_file_path)
        pcp<- list.files(pattern=mod)
        print(pcp)
        pcp_raster<- raster(pcp, crs = crs)


        ###################### snow accumulation
        s_array[snow_index]=pcp_raster[snow_index]




        #####################  rain accumualtion
        r_array[rain_index]=pcp_raster[rain_index]



        #####################  snow rain mixed
        ##rain

        s_r_array[snow_rain_index]=pcp_raster[snow_rain_index]*((T_array[snow_rain_index]-lower_T_thresh)/(upper_T_thresh-lower_T_thresh))

        if(upper_T_thresh!=0&lower_T_thresh!=0){

          r_array2=r_array+s_r_array

        }
        else{

          print("upper T melt = lower T melt")

          r_array2=r_array

        }
        rain_accumulation_raster[]=r_array2




        ##snow
        s_r_array[snow_rain_index]=pcp_raster[snow_rain_index]-s_r_array[snow_rain_index]


        if(upper_T_thresh!=0&lower_T_thresh!=0){

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
        writeRaster(rain_accumulation_raster, file=paste("rain_accumulation_monthly_2009_2013_average_",mod, sep=""), format = "ascii",overwrite=TRUE)


        ##save potential snow accumulation raster
        setwd("../")
        dir.create("potential_snow_accumulation",showWarnings = FALSE)
        setwd("potential_snow_accumulation")
        writeRaster(snow_accumulation_raster, file=paste("snow_accumulation_monthly_2009_2013_average_",mod, sep=""), format = "ascii",overwrite=TRUE)

      }
}



potential_snow_melt<-function(metlt_constant,T_melt,crs,mods,saving_data_file_path){



  for (mod in mods){

    setwd(paste(saving_data_file_path,"/weighted_temp_raster",sep=""))

    my_raster<- list.files(pattern=mod)

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
    writeRaster(snow_accumulation_raster, file=paste("snow_depth_",mod, sep=""), format = "ascii",overwrite=TRUE)


    final_snow_melt_raster[]=final_snow_melt_array
    setwd("../")
    dir.create("final_snow_melt_raster",showWarnings = FALSE)
    setwd("final_snow_melt_raster")
    writeRaster(final_snow_melt_raster, file=paste("snow_melt_raster_",mod, sep=""), format = "ascii",overwrite=TRUE)

    snow_accumulation_sublimation_raster[]=final_snow_accumulation_array_1_mmonth*(1-sublimation_constant)
    setwd("../")
    dir.create("final_snow_accumulation_raster_sublimation",showWarnings = FALSE)
    setwd("final_snow_accumulation_raster_sublimation")
    writeRaster(snow_accumulation_sublimation_raster, file=paste("snow_melt_raster_sublimation_",mod, sep=""), format = "ascii",overwrite=TRUE)

  }





# plot --------------------------------------------------------------------


##below is  for water balance plot
  
  # monthly_rain=c()
  # 
  # accumulative_monthly_rain=c()
  # 
  # monthly_pcp=c()
  # 
  # accumulative_monthly_pcp=c()
  # 
  # monthly_temp=c()

  # for (j in 1:length(mods)){
  # 
  #   #calcualte the accumulative rain
  # 
  #   setwd(paste(saving_data_file_path,"/potential_rain_accumulation",sep=""))
  # 
  #   my_raster<- list.files(pattern=mods[j])
  # 
  #   monthly_rain_raster<-raster(my_raster, crs=crs)
  # 
  #   monthly_rain_array=monthly_rain_raster[]*0.001#*30*86400 #convert from m/s to m/month
  # 
  # 
  #   monthly_rain_array[which(monthly_rain_array<0)]=NA
  # 
  # 
  #   monthly_rain[j]=sum(monthly_rain_array, na.rm=TRUE)
  # 
  # 
  #   accumulative_monthly_rain[j]=sum(monthly_rain[1:j])
  # 
  #   # calcualte the accumualtive pcp
  # 
  #   setwd(pcp_file_path)
  # 
  #   my_raster<- list.files(pattern=mods[j])
  # 
  #   monthly_pcp_raster<-raster(my_raster, crs=crs)
  # 
  #   monthly_pcp_array=monthly_pcp_raster[]*0.001#*30*86400
  # 
  #   monthly_pcp_array[which(monthly_pcp_array<0)]=NA
  # 
  #   monthly_pcp[j]=sum(monthly_pcp_array, na.rm=TRUE)
  # 
  #   accumulative_monthly_pcp[j]=sum(monthly_pcp[1:j])
  # 
  #   # calcualte the average weighted temperature
  #   setwd(paste(saving_data_file_path,"/weighted_temp_raster",sep=""))
  # 
  #   my_raster<- list.files(pattern=mods[j])
  # 
  #   monthly_temp_raster<-raster(my_raster, crs=crs)
  # 
  #   monthly_temp_array=monthly_temp_raster[]
  # 
  #   monthly_temp_array[which(monthly_temp_array==-9999)]=NA
  # 
  #   monthly_temp[j]=mean(monthly_temp_array,na.rm=TRUE)
  # 
  # }
  # cat("accumulative_monthly_pcp\n")
  # print(accumulative_monthly_pcp)
  # cat("accumulative_monthly_rain\n")
  # print(accumulative_monthly_rain)
  # cat("snow melt\n")
  # print(sm_sum)
  # cat("sm depth\n")
  # print(sa)
  # #print(monthly_temp)
  # 
  # setwd(saving_data_file_path)


        # fname<-("Water Balance.png")
        # png(filename=fname)
        # par(mar = c(5.1, 4.1, 8.1, 8.1) + 0.3,xpd=TRUE,new= FALSE) ##control plotting area
        # plot(c(6,18),c(0,4730),type="n", xaxt = "n", xlab="month", ylab="SWE") #x,y limit
        # labellist=c(6,7,8,9,10,11,12,1,2,3,4,5)
        # axis(1,at=6:17,labels=labellist)
        # lines(6:17, accumulative_monthly_pcp, col="red")
        # lines(6:17, accumulative_monthly_rain, col="blue")
        # lines(6:17, sa*0.001, col="black") #snow depth
        # lines(6:17, sm_sum*0.001, col="orange") #snow melt
        # par(new = TRUE,xpd=TRUE)
        # plot(c(6,18),c(-30,30),type="n", axes = FALSE, bty = "n", xlab = "", ylab = "") #x,y limit
        # lines(6:17, monthly_temp, col="pink") #temperature
        # axis(side=4, at = pretty(range(-30,30)),col = "pink")
        # mtext("Temp (degree C)", side=4, line=3,col = "pink")
        # legend("topright",inset=c(0.0,-0.4), ##off set y
        #        title="Legend",
        #        c("accumulative Preciptation","accumulative Rain","Snow Depth(with melting)","accumulative snow melt","mean temp"),
        #        lty=c(1,1),
        #        col=c("red","blue","black","orange","pink"),
        #        bg="grey96")
        # dev.off()



        # fname<-("Accumulative monthly comparison.png")
        # png(filename=fname)
        # plot(c(6,18),c(0,0.06),type="n", xaxt = "n", xlab="month", ylab="SWE")
        # labellist=c(6,7,8,9,10,11,12,1,2,3,4,5)
        # axis(1,at=6:17,labels=labellist)
        # lines(6:17, st_sum, col="red")
        # lines(6:17, sa, col="blue")
        # lines(6:17, sm_sum, col="black")
        # legend("topright",
        #        title="Legend",
        #        c("Snow Depth (without melting)","Snow Depth(with melting)","accumulative snow melt"),
        #        lty=c(1,1),
        #        col=c("red","blue","black"),
        #        bg="grey96")
        # dev.off()

        #
        #
        # filename<- paste("monthly comparison",".png")
        # png(file=filename)
        # plot(c(6,18),c(0,0.06),type="n", xaxt = "n", xlab="month", ylab="SWE")
        # labellist=c(6,7,8,9,10,11,12,1,2,3,4,5)
        # axis(1,at=6:17,labels=labellist)
        # lines(6:17, st, col="red")
        # lines(6:17, sa, col="blue")
        # lines(6:17, sm, col="black")
        # legend("topright",
        #        title="Legend",
        #        c("monthly snow accumulation potential (without melting)","accumulative snow accumulation (with melting)","monthly snow melt"),
        #        lty=c(1,1),
        #        col=c("red","blue","black"),
        #        bg="grey96")
        # dev.off()


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
  
 







