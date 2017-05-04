rm(list = ls())
library( data.table)

write_grok_landcover_zone <- function ( dt ){

  write_choose_zone_number<-function ( zone_number ){


    if ( any ( as.numeric ( zone_number )+100*layernum==unique_zone_num) ){

      # cat(match(as.numeric ( zone_number )+100*layernum,unique_zone_num))
      cat( " choose zone number \n " )
      cat( as.numeric ( zone_number )+100*layernum, "\n " )

      return(c(1))

    }
     else{

       return(c(0))

     }


  }

  for ( layernum in 1:9){



    property_name = dt [ 1 ]

    zone_number_list = dt[ 2:length( dt ) ]

    zone_number_list = zone_number_list[ ! is.na( zone_number_list ) ]


      sink( " additional_olf.inc " , append = TRUE )

      cat( "  clear chosen zones \n " )

      a=sapply( zone_number_list, write_choose_zone_number )

      if (sum(a)!=0){



        cat( " read properties \n ")

        cat( paste0 ( property_name,
                      "_",
                      layernum*100),
             " \n \n"
        )


      }

      sink()

      print(a)

  }

}


write_oprop <- function(x){

  for ( layernum in 1:9) {

    sink(save_filename,append = TRUE)
    cat( paste0 ( "!-----",
                  x[ "landcover"],
                  "_",
                  layernum*100),
                  " \n "
         )

    cat( paste0 ( x[ "landcover"],
                  "_",
                  layernum*100),
                  " \n "
         )

    cat(	"   ","x friction                   \n")
    cat(	"   ",x[ "xfriction" ],            "\n")
    cat(	"   ","y friction                   \n")
    cat(	"   ",x[ "yfriction" ],            "\n")
    cat(	"   ","obstruction storage height   \n")
    cat(	"   ","1e-3                         \n")
    cat(	"   ","rill storage height          \n")
    cat(	"   ",x[ paste0("layer",layernum)],"\n")
    cat(	"   ","coupling length              \n")
    cat(	"   ","0.2                          \n")
    cat(	"   ","snow density                 \n")
    cat(	"   ","1.0                          \n")
    cat(	"   ","melting constant             \n")
    cat(	"   ","1.0                          \n")
    cat(	"   ","sublimation constant         \n")
    cat(	"   ","0.0                          \n")
    cat(	"   ","threshold temperature        \n")
    cat(	"   ","0.0                          \n")
    cat(	"   ","initial snow depth           \n")
    cat(	"   ","0.0                          \n")
    cat(	"   ","END MATERIAL                 \n")
    cat(  "end material                    \n \n")
    sink()


  }


}





setwd( "C:/Users/fyang/Desktop/depression_lc" )



my_raster<- ("corrected_landcover_900.asc") ############## This is to read your raster as a list
r <- raster( my_raster, crs = ("+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs") )
unique_zone_num=unique(r)

summary_file =( "landcover_zone.csv" )
x = read.csv (summary_file, header = FALSE )
x= data.table(x)
# a=apply(x,1,write_grok_landcover_zone)

save_filename=("landcover_900.oprop")


summary_file =( "oprop_table.csv" )
x = data.table(
                read.csv (summary_file, header = TRUE )

                )
apply(x,1,write_oprop)





