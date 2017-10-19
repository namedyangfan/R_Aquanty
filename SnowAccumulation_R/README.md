# snow_accumulation_melt_funcions

The purpose of 'snow_accumulation_melt_funcions' is to estimate the winter processes. The script is developed primarily in supporting the SSRB HGS model. The algorithm is derived from degree day model. 
 
## Usage

* write_weighted_temp_raster: calculate the weighted temperature raster from *Tmax* and *Tmin* Raster. A folder *weighted_temp_raster* is automatically created to save the output.

* average_weighted_temp_raster: calcualte backward looking moving average of the weighted temprature raster. A folder *averaged_weighted_temperature* is automatically created to save the output.

* potential_snow_accumulation_rain_accumulation: determine the potential for snow and rain accumulation using temperature from either folder *write_weighted_temp_raster* or *average_weighted_temp_raster*. Two folders *potential_rain_accumulation* and *potential_snow_accumulation* are created to store the output rasters. potential_rain_accumulation indicates the amount of rain forms from precipitation. potential_snow_accumulation means the potential of snow formation. potential_rain_accumulation plus potential_snow_accumulation should equal to the given precipitation.

* potential_snow_melt: determine the potential for snow to melt. a folder *potential_snow_melt_raster* is automatically created to save the output. potential_snow_melt_raster indicates the potential for snow to melt assuming the amount of snow is infinite.

* integrate_potential_snowaccumulation_snow_melt: determine the true amount of snow melt and accumulation based on the potential values. This is done by integration of the results from *potential_snow_accumulation_rain_accumulation* and *potential_snow_melt*. This function looks for the folders *potential_snow_melt_raster* and *potential_snow_accumulation* in the given directory. The output of this function is saved in *final_accumulative_snow_accumulation_raster* and *final_snow_melt_raster*.

* combine_rain_snow: sum up the rain and snow melt raster for HGS model input. This function looks for the foders *potential_rain_accumulation* and *final_snow_melt_raster*. The output of this function is stored in *combine_rain_snowmelt*.

* snow_depth_unit_conversion: convert the unit of the snow depth raster by multiplyng a constant

## Prerequisites
### Install R
[R for Windows](https://cran.r-project.org/bin/windows/base/)
 * Rscript.exe may need to be added to the system path
### R library
* raster

# Tests
A set of tests are provided: `test.R`. Run the following command in terminal:
```
Rscript test.R
```

# Method

## write_weighted_temp_raster(crs,mods,tmax_file_path,tmin_file_path,weighted_temp_raster_file_path,weighted_coef)
* crs: projection of the raster. Assumes all the raster files are in the same projection
* mods: a list of matching patterns, this pattern is used to look for temperature files. Assuming *tmin* and *tmax* have the same matching pattern.
* tmax_file_path: folder directory of the maximum temperature raster 
* tmin_file_path: folder directory of the minimum temperature raster 
* weighted_temp_raster_file_path: the directory where the folder *weighted_temp_raster* can be created.
  * weighted_temp_raster: is created to contain all the weighted temperature output files.
* weighted_coef: the weighted temperature is calculated by: 
  > tmin + weighted_coef(tmax-tmin)
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    write_weighted_temp_raster(mods = c('_1.asc','_2.asc','_3.asc'),
                               crs = c("+proj=longlat +datum=WGS84 +no_defs"),
                               tmax_file_path = file.path(cwd, 'test', 'tmax'),
                               tmin_file_path = file.path(cwd, 'test', 'tmin'),
                               weighted_temp_raster_file_path = file.path(cwd, 'test'),
                               weighted_coef =0.5)
```

## average_weighted_temp_raster(x, mods, crs, weighted_temp_raster_folder_path, weighted_temp_raster_folder_name = "weighted_temp_raster", le = 2, ldebug = FALSE)
* x: a pattern that is used to match the temperature raster files. *x* is the starting point for the backward looking average method. There must be at least *le* number of elements in *mods* before *x*.
* mods: a list of patterns that is used to match all the temperature raster files. The order of mods determines which files are used to compute the backward average.
* weighted_temp_raster_folder_path: the directory where the folder *weighted_temp_raster* is created. *weighted_temp_raster* is a folder that contains the output from the function **write_weighted_temp_raster ()**. 
  * averaged_weighted_temperature: this folder is automaticly created to save the function output
* weighted_temp_raster_folder_name: the folder name of where the temperature raster files are located. weighted_temp_raster_folder_name is set to *weighted_temp_raster* by default.
* le: the number of files to look backward. For example, to calculate a three day backward average, le should be set as *2*.
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    average_weighted_temp_raster(x = '_3.tif',
                                 mods = c('_1.tif','_2.tif','_3.tif'),
                                 crs = c("+proj=longlat +datum=WGS84 +no_defs"),
                                 weighted_temp_raster_folder_path = file.path(cwd, 'test'),
                                 weighted_temp_raster_folder_name = "weighted_temp_raster",
                                 le = 2)
```



## potential_snow_accumulation_rain_accumulation (upper_T_thresh, lower_T_thresh, crs, mods, weighted_temp_raster_file_path, pcp_file_path, temp_foldername = 'weighted_temp_raster')
* upper_T_thresh: upper temperature threshold. rain is expected at temperature higher than this numer
* lower_T_thresh: lower temperature threshold. snow is expected at temperature lower than this number
* If the temperature is in between upper_T_thresh and lower_T_thresh, it is assumed that the precipitation is in a mixed form of snow and rain. The amount of rain can be estimated as: 

  > (T - lower_T_thresh) / (upper_T_thresh - lower_T_thresh) * precipitation

* crs: projection of the raster. Assumes all the raster files are in the same projection.
* mods: a list of matching patterns that is used to match all the temperature and precipitation raster files. The temperature and precipitation files have to share same matching pattern.
* weighted_temp_raster_file_path: the directory where the folder *weighted_temp_raster* is created. *weighted_temp_raster* is a folder that contains the output from the function **write_weighted_temp_raster()**. The function creates two folders automatically:
  * potential_rain_accumulation: rainfall raster
  * potential_snow_accumulation: potential snow accumulation raster. (This raster will be combined with the potential_snow_melt_raster to calcualte snow depth. See **integrate_potential_snowaccumulation_snow_melt** for more explanation)
* pcp_file_path: file path of the precipitation raster folder.
* temp_foldername: the folder name of where the temperature raster files are located. weighted_temp_raster_folder_name is set to *weighted_temp_raster* by default.
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    potential_snow_accumulation_rain_accumulation(upper_T_thresh = 0,
                                                  lower_T_thresh = 0,
                                                  crs = c("+proj=longlat +datum=WGS84 +no_defs"),
                                                  mods = c('_1.','_2.','_3.'),
                                                  weighted_temp_raster_file_path = file.path(cwd, 'test'),
                                                  pcp_file_path = file.path(cwd, 'test', 'pcp'),
                                                  temp_foldername = 'weighted_temp_raster')
```




## potential_snow_melt (metlt_constant, T_melt, crs, mods, work_directory, temp_foldername)
* metlt_constant: melt constant. eg: 5.787037e-08
* T_melt: melting begins when temperature reach or above this temperature

  > potential snow melt = metlt_constant * (Temperature - T_melt )

* crs: projection of the raster. Assumes all the raster files are in the same projection.
* mods: a list of matching patterns that is used to match all the temperature and precipitation raster files. The temperature and precipitation files must share same matching pattern.
* work_directory: the directory at where the folder *temp_foldername* is located. A new folder *potential_snow_melt_raster* is create to store the potential snow melt raster
  * potential_snow_melt_raster: the potential amount of snow melt. 
* temp_foldername: folder name of the temperature raster (either *weighted_temp_raster* or *averaged_weighted_temperature*)
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    potential_snow_melt(metlt_constant = 5.787037e-08,
                        T_melt = 0.0,
                        crs =  c("+proj=longlat +datum=WGS84 +no_defs"),
                        mods = c('_1.','_2.','_3.'),
                        work_directory = file.path(cwd, 'test'),
                        temp_foldername = "weighted_temp_raster")
```


## integrate_potential_snowaccumulation_snow_melt (crs, mods, work_directory, sublimation_constant)
* crs: projection of the raster. Assumes all the raster files are in the same projection.
* mods: a list of matching patterns that is used to match all the temperature and precipitation raster files. The temperature and precipitation files must share same matching pattern.
* work_directory: the directory at where the folders *potential_snow_melt_raster* and *potential_snow_accumulation* are located. The name of these two folders must not be changed. Two folders will be created in this directory to save the output:
  * final_accumulative_snow_accumulation_raster: snow depth raster
  * final_snow_melt_raster: snow melt raster
* sublimation_constant: this variable is first introduced to estimate the effects from sublimation, however removed in the later version of the code.
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    integrate_potential_snowaccumulation_snow_melt(crs = c("+proj=longlat +datum=WGS84 +no_defs"),
                                                   mods = c('_1.','_2.','_3.'),
                                                   work_directory = file.path(cwd, 'test'),
                                                   sublimation_constant = 0.0)
```


## combine_rain_snow (mods, save_filename='final_liquid_', work_directory, crs)
* mods: a list of matching patterns that is used to match all the *potential_rain_accumulation* and *final_snow_melt_raster* raster files.

* work_directory: the directory of where the folders *potential_rain_accumulation* and *final_snow_melt_raster* are located.
A folder *combine_rain_snowmelt* is created to store the output:
  * combine_rain_snowmelt: rain fall raster plus snow melt raster. This can be used as boundary condition in HGS.
* crs: projection of the raster. Assumes all the raster files are in the same projection.
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    combine_rain_snow(mods = c('_1.','_2.','_3.'),
                      save_filename='final_liquid_',
                      work_directory = file.path(cwd, 'test'),
                      crs = c("+proj=longlat +datum=WGS84 +no_defs"))
```
