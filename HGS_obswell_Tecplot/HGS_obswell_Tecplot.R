rm(list = ls())
library(tools)
library(parallel)

#####This fucntion estimated the total number of layers in a given observation well input file
#####character_length: the length of the first characters that appears in the reference line.  eg.we use "zone" here
#####ref_line_num: the line number of the reference line. lines between the reference line and the matching character will be considered as the layer number



estimate_layer_number<-function(l,character_length=4,ref_line_num=3){
  
  disaggregate_l=substring(l, 1, character_length)
  
  match_line=which(disaggregate_l==disaggregate_l[ref_line_num])
  
  layernum=match_line[2]-match_line[1]-1
  
  return(layernum)
}



#this fucntion takes the observation well variables and returns a fucntion which requires the starting and ending nodes sheet as input 

make_chooselayer_func<-function(L,col_num,col_variable,ref_line_num=3,solutiontime_line=3){
  
  
  file_length=length(L)
  num_layer=estimate_layer_number(L)
  header_space=3 #number of lines in header 
  
  #this function below take a list of sheet number and return the variable value for those sheets 
  extract_layer_fromvariable<-function(observation_sheet){
    
    col_type=rep("NULL",length(col_variable))
    
    col_type[col_num]="character" #only assign the selected col num as character 
    
    wellscreen_layer=seq(min(observation_sheet),max(observation_sheet)) #all the layer within the range
    
    flip_layer_num=lapply(wellscreen_layer, function (x) ref_line_num+x) #the layer is counted from the bottom in HGS
    
    output_variable= lapply(flip_layer_num, function (x) read.table(textConnection(L[seq(x,file_length,num_layer+1)]), colClasses = col_type)) # extract the variable col
    
    output_time=read.table(textConnection(L[seq(solutiontime_line,file_length,num_layer+1)]),sep=" ") #extract the time by breaking down the header line
    
    output_time=(output_time[ncol(output_time)])
    
    output_table=cbind(output_time,output_variable) #combine time and variable
    
    tecplot_var_name=lapply(wellscreen_layer,function(x) paste0(col_variable[col_num],x)) #H1 Z1 H2 Z2 ...
    
    colnames(output_table) <-c("time",unlist(tecplot_var_name))
    
    return(output_table)
  }
  
}


obs_well_tecplot<-function (file_name_pattern,obs_Var,wellscreen_layer=c(1)){
  
  save_filename=paste0(file_name_pattern,".dat") #take the ID as the same file name
  
  col_variable=c("H","S","Q","Ho","Qo","X","Y","Z","Nodes") #list all the variables in the dat file
  
  col_num=match(obs_Var,col_variable) #match the variables with the selected one
  
  if (length(col_num)==0){
    print("not able to find match varibale:")
    print(col_variable)
  }
  
  file_name=list.files(pattern=file_name_pattern, full.names=FALSE)
  print(file_name)
  
  results = tryCatch({
    L=readLines(file_name) #read in file as line 
  }, error = function(e){
    print("not able to open file:")
    print(file_name_pattern)
  }
  )
  
  test_funtion=make_chooselayer_func(L,col_num,col_variable) #this return a function that takes the sheet number 
  
  tecplot_results=test_funtion(wellscreen_layer) #extract the data 
  
  
  #zone_name=file_path_sans_ext(file_name) # unused argument
  
  v_n=paste0(colnames(tecplot_results),collapse = '""') #takes the col_name and write in file
  
  tecplot_zone_name=c('variables=','"',v_n,'"')
  
  #save_filename=paste0(sapply(strsplit(file_path_sans_ext(file_name),'_'),tail,1),".dat")
  
  sink(save_filename)
  cat(tecplot_zone_name,"\n")
  cat('zone t="',file_path_sans_ext(save_filename),'"',"\n") # save_filename
  sink()
  
  
  #write(col_variable[col_num], file=save_filename,append=FALSE,sep = "_") #write variable names
  #write(paste("zone t=\"",zone_name,"\"\n"), file=save_filename,append=TRUE) #write zone names
  write.table(tecplot_results,file=save_filename,quote = FALSE,row.names=FALSE,col.names=FALSE,append = TRUE) #write data
  
} 


read_wellsheetsummary<-function(file_directory, summary_f,obs_Var=c("H"), parallel= FALSE){
  # summary_f: format of ID,Start_Sheet,End_Sheet
  # obs_Var: one or more of the following "H","S","Q","Ho","Qo","X","Y","Z","Nodes"
  
  setwd(file_directory)
  
  results = tryCatch({
    dt=read.csv(file = summary_f,header =TRUE,sep =',',colClasses = c("character","numeric","numeric"))
  }, error = function(e){
      print("not able to open summary file")
    }
  )

  if (parallel){
    no_cores<-detectCores()-2
    
    cl<-makeCluster(no_cores)
    
    clusterExport(cl=cl, varlist=c("dt","obs_Var","obs_well_tecplot","make_chooselayer_func","estimate_layer_number"),envir = environment())
    
    a<-clusterEvalQ(cl, library('tools'))
    
    system.time(parApply(cl,dt,1,function(x) obs_well_tecplot(file_name_pattern = x[1],obs_Var,wellscreen_layer=as.numeric( x[c(2,3)]))))
    
    stopCluster(cl)
  }
  else {
    apply(dt,1,function(x) obs_well_tecplot(file_name_pattern = x[1],obs_Var,wellscreen_layer=as.numeric( x[c(2,3)])))
  }
}


