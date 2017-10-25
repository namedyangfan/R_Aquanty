# snow_accumulation_melt_funcions

The purpose of 'snow_accumulation_melt_funcions' is to estimate the winter processes. The script is developed primarily in supporting the SSRB HGS model. The algorithm is derived from degree day model. 
 
## Usage

* [write_weighted_temp_raster](#wwtr): calculate the weighted temperature raster from *Tmax* and *Tmin* Raster. A folder *weighted_temp_raster* is automatically created to save the output.

* [average_weighted_temp_raster](#awtr): calculate backward looking moving average of the weighted temperature raster. A folder *averaged_weighted_temperature* is automatically created to save the output.

* [potential_snow_accumulation_rain_accumulation](#psara): determine the potential for snow and rain accumulation using temperature from either folder *write_weighted_temp_raster* or *average_weighted_temp_raster*. Two folders *potential_rain_accumulation* and *potential_snow_accumulation* are created to store the output raster. potential_rain_accumulation indicates the amount of rain forms from precipitation. potential_snow_accumulation means the potential of snow formation. potential_rain_accumulation plus potential_snow_accumulation should equal to the given precipitation.

* [interp_melt_const_raster](#imcr): interpolate melt constant based on the temperature and Julian day. A folder *snow_melt_constant* is automatically created to save the output. This function requires *SnowMeltGrid_NoBlankLines_NoNegatives.txt*. The output of this function can be used in [potential_snow_melt](#psm).

* [potential_snow_melt](#psm): determine the potential for snow to melt. The function could read melt constant either as a constant value or spatial raster. a folder *potential_snow_melt_raster* is automatically created to save the output. potential_snow_melt_raster indicates the potential for snow to melt assuming the amount of snow is infinite.

* [integrate_potential_snowaccumulation_snow_melt](#ipssm): determine the true amount of snow melt and accumulation based on the potential values. This is done by integration of the results from *potential_snow_accumulation_rain_accumulation* and *potential_snow_melt*. This function looks for the folders *potential_snow_melt_raster* and *potential_snow_accumulation* in the given directory. The output of this function is saved in *final_accumulative_snow_accumulation_raster* and *final_snow_melt_raster*. *final_accumulative_snow_accumulation_raster* means snow depth. *final_snow_melt_raster* means snow melt.

* [combine_rain_snow](#crs): sum up the rain and snow melt raster for HGS model input. This function looks for the foders *potential_rain_accumulation* and *final_snow_melt_raster*. The output of this function is stored in *combine_rain_snowmelt*.

* [snow_depth_unit_conversion](#sduc): convert the unit of the raster files in *final_accumulative_snow_accumulation_raster* by multiplying a user specified conversion factor.


## Prerequisites
### Install R
[R for Windows](https://cran.r-project.org/bin/windows/base/)
 * Rscript.exe may need to be added to the system path
### R library
* sp
* rgdal
* raster
* akima
* parallel

# Tests
A set of tests are provided: *test.R*. Run the following command in terminal:
```
Rscript test.R
```
It would be convinient to read **mods** from a text file. *test_interp_melt_const.R* provides this solution by reading **mods** from *mods.txt*. Notice *mods.txt* has to be located at the same directory as this scrip. To run *test_mods.R*:
```
Rscript test_interp_melt_const.R
```
A paralleled version of *test_interp_melt_const.R* is avaliable as *test_interp_melt_const_parallel.R*:
```
Rscript test_interp_melt_const_parallel.R
```
**It is recommonded to delete intermediate folders before each testing**
# Method

## <a name="wwtr"></a>write_weighted_temp_raster(crs,mods,tmax_file_path,tmin_file_path,weighted_temp_raster_file_path,weighted_coef)
* crs: projection of the raster. Assumes all the raster files are in the same projection
* mods: a list of matching patterns, this pattern is used to look for temperature files. Assuming *tmin* and *tmax* have the same matching pattern. It is recommended to use *date* as the matching pattern for the temperature file.
* tmax_file_path: folder directory of the maximum temperature raster 
* tmin_file_path: folder directory of the minimum temperature raster 
* weighted_temp_raster_file_path: the directory where the folder *weighted_temp_raster* can be created.
  * weighted_temp_raster: is created to contain all the weighted temperature output files.
* weighted_coef: the weighted temperature is calculated by: 
  > tmin + weighted_coef(tmax-tmin)
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    write_weighted_temp_raster(mods = c('01_04_2009','02_04_2009','03_04_2009'),
                               crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                               tmax_file_path = file.path(cwd, 'test', 'tmax'),
                               tmin_file_path = file.path(cwd, 'test', 'tmin'),
                               weighted_temp_raster_file_path = file.path(cwd, 'test'),
                               weighted_coef =0.5)
```

## <a name="awtr"></a>average_weighted_temp_raster(x, mods, crs, weighted_temp_raster_folder_path, weighted_temp_raster_folder_name = "weighted_temp_raster", le = 2, ldebug = FALSE)
* x: a pattern that is used to match the temperature raster files. *x* is the starting point for the backward looking average method. There must be at least *le* number of elements in *mods* before *x*.
* mods: a list of patterns that is used to match all the temperature raster files. The order of mods determines which files are used to compute the backward average. It is recommended to use *date* as the matching pattern for the temperature file.
* weighted_temp_raster_folder_path: the directory where the folder *weighted_temp_raster* is created. *weighted_temp_raster* is a folder that contains the output from the function **write_weighted_temp_raster ()**. 
  * averaged_weighted_temperature: this folder is automatically created to save the function output
* weighted_temp_raster_folder_name: the folder name of where the temperature raster files are located. weighted_temp_raster_folder_name is set to *weighted_temp_raster* by default.
* le: the number of files to look backward. For example, to calculate a three day backward average, le should be set as *2*.
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    average_weighted_temp_raster(x = '03_04_2009',
                                 mods = c('01_04_2009','02_04_2009','03_04_2009'),
                                 crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                                 weighted_temp_raster_folder_path = file.path(cwd, 'test'),
                                 weighted_temp_raster_folder_name = "weighted_temp_raster",
                                 le = 2)
```



## <a name="psara"></a>potential_snow_accumulation_rain_accumulation (upper_T_thresh, lower_T_thresh, crs, mods, weighted_temp_raster_file_path, pcp_file_path, temp_foldername = 'weighted_temp_raster')
* upper_T_thresh: upper temperature threshold. rain is expected at temperature higher than this numer
* lower_T_thresh: lower temperature threshold. snow is expected at temperature lower than this number
* If the temperature is in between upper_T_thresh and lower_T_thresh, it is assumed that the precipitation is in a mixed form of snow and rain. The amount of rain can be estimated as: 

  > (T - lower_T_thresh) / (upper_T_thresh - lower_T_thresh) * precipitation

* crs: projection of the raster. Assumes all the raster files are in the same projection.
* mods: a list of matching patterns that is used to match all the temperature and precipitation raster files. The temperature and precipitation files have to share same matching pattern. It is recommended to use *date* as the matching pattern.
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
                                                  crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                                                  mods = c('01_04_2009','02_04_2009','03_04_2009'),
                                                  weighted_temp_raster_file_path = file.path(cwd, 'test'),
                                                  pcp_file_path = file.path(cwd, 'test', 'pcp'),
                                                  temp_foldername = 'weighted_temp_raster')
```

## <a name="imcr"></a>interp_melt_const_raster (mods, work_directory, table_directory, temp_folder_name, crs, format = "ascii", mods_format = "%Y%m%d", conversion_factor = 1.15741e-8)
* mods: a list that indicates the **date** of the temperature files. It is also used to match the temperature files. To make sure mods can be correctly convert to Julian day, it is recommended to name the temperature files as the format:
 > [foo]_date: averaged_weighted_temp_20171019
* mods_format: the format for date in mods. The default format is **%Y%m%d** which corresponds to year month and day. Please refer to the [as.Date](https://stat.ethz.ch/R-manual/R-devel/library/base/html/as.Date.html) documentation.
* work_directory: the directory where 'temp_folder_name' is located. A new folder *snow_melt_constant* is created in this directory to save the output.
* table_directory: the directory where *SnowMeltGrid_NoBlankLines_NoNegatives.txt* is located.
* temp_folder_name: the folder name of the temperature raster. Either result from [average_weighted_temp_raster](#awtr) or [write_weighted_temp_raster](#wwtr) can be used.
* crs: projection of the raster. Assumes all the raster files are in the same projection.
* format: output raster format. Please refer to the [writeRaster](https://www.rdocumentation.org/packages/raster/versions/2.5-8/topics/writeRaster) documentation for more format options
* conversion_factor: a constant multiplier. The melt constant from *SnowMeltGrid_NoBlankLines_NoNegatives.txt* has a unit of mm/day. This unit may be different from the precipitation raster, therefore a unit conversion is required. e.g: a precipitation raster with unit *mm/day* would require a conversion_factor of *1.15741e-8* to convert the melt constant to the same unit.
 
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    interp_melt_const_raster(mods = c('01_04_2009','02_04_2009','03_04_2009'),
                             work_directory = file.path(cwd, 'test'),
                             table_directory = cwd,
                             temp_folder_name="weighted_temp_raster", 
                             crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                             format = 'ascii',
                             mods_format = "%d_%m_%Y",
                             conversion_factor = 1.15741e-8)
```

## <a name="psm"></a>potential_snow_melt(mods, metlt_constant=NULL, T_melt=NULL, melt_const_folder=NULL, format="GTiff", crs, work_directory, temp_foldername)
*potential_snow_melt* estiamte the potential for snow to melt. The melt constant can either be a constant number or spatial varying raster. For the constant number option, *metlt_constant* and *T_melt* need to be specified. Potential snow melt is calcualted as:
  >potential snow melt = metlt_constant * (Temperature - T_melt )
  
For the spatial varying raster option, *melt_const_folder* need to be specified. Potential snow melt is calculated as:
  >potential snow melt = metlt_constant * Temperature

* mods: a list of matching patterns that is used to match all the temperature and precipitation raster files. The temperature and precipitation files must share same matching pattern. It is recommended to use *date* as the matching pattern.
* metlt_constant: melt constant. eg: 5.787037e-08
* T_melt: melting begins when temperature reach or above this temperature
* melt_const_folder: folder name of the melt constant raster
* format: output raster format. Please refer to the [writeRaster](https://www.rdocumentation.org/packages/raster/versions/2.5-8/topics/writeRaster) documentation for more format options
* crs: projection of the raster. Assumes all the raster files are in the same projection.
* work_directory: the directory where the folder *temp_foldername* is located. A new folder *potential_snow_melt_raster* is create to store the potential snow melt raster. *potential_snow_melt_raster* means the potential amount of snow melt. 
* temp_foldername: folder name of the temperature raster (either *weighted_temp_raster* or *averaged_weighted_temperature*)
```
    ## example of using a single number for melt constant
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    potential_snow_melt(metlt_constant = 5.787037e-08,
                        T_melt = 0.0,
                        crs =  c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                        mods = c('01_04_2009','02_04_2009','03_04_2009'),
                        work_directory = file.path(cwd, 'test'),
                        temp_foldername = "weighted_temp_raster")
```

```
    ## example of using a spatial varying raster for melt constant
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    potential_snow_melt(melt_const_folder='snow_melt_constant',
                        format="GTiff",
                        crs =  c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                        mods = c('01_04_2009','02_04_2009','03_04_2009'),
                        work_directory = file.path(cwd, 'test'),
                        temp_foldername = 'weighted_temp_raster'
                        )
```

## <a name="ipssm"></a>integrate_potential_snowaccumulation_snow_melt (crs, mods, work_directory, sublimation_constant)
* crs: projection of the raster. Assumes all the raster files are in the same projection.
* mods: a list of matching patterns that is used to match all the temperature and precipitation raster files. The temperature and precipitation files must share same matching pattern. It is recommended to use *date* as the matching pattern.
* work_directory: the directory at where the folders *potential_snow_melt_raster* and *potential_snow_accumulation* are located. The name of these two folders must not be changed. Two folders will be created in this directory to save the output:
  * final_accumulative_snow_accumulation_raster: snow depth raster
  * final_snow_melt_raster: snow melt raster
* sublimation_constant: this variable is first introduced to estimate the effects from sublimation, however removed in the later version of the code.
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    integrate_potential_snowaccumulation_snow_melt(crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                                                   mods = c('01_04_2009','02_04_2009','03_04_2009'),
                                                   work_directory = file.path(cwd, 'test'),
                                                   sublimation_constant = 0.0)
```


## <a name="crs"></a>combine_rain_snow (mods, save_filename='final_liquid_', work_directory, crs)
* mods: a list of matching patterns that is used to match all the *potential_rain_accumulation* and *final_snow_melt_raster* raster files.
* save_filename: prefix of the saving file name
* work_directory: the directory of where the folders *potential_rain_accumulation* and *final_snow_melt_raster* are located.
A folder *combine_rain_snowmelt* is created to store the output:
* combine_rain_snowmelt: rain fall raster plus snow melt raster. This can be used as boundary condition in HGS.
* crs: projection of the raster. Assumes all the raster files are in the same projection.
```
    source("snow_accumulation_melt_functions.R")
    cwd = getwd()
    combine_rain_snow(mods = c('01_04_2009','02_04_2009','03_04_2009'),
                      save_filename='final_liquid_',
                      work_directory = file.path(cwd, 'test'),
                      crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"))
```

## <a name="crs"></a>snow_depth_unit_conversion (mods, save_filename = 'final_snowdepth_', work_directory, crs, conversion_factor=86400)
* mods: a list of matching patterns that is used to match all the *final_accumulative_snow_accumulation_raster* raster file.
* save_filename: prefix of the saving file name
* workdirectory: directory of where the folders *final_accumulative_snow_accumulation_raster*
* crs: projection of the raster. Assumes all the raster files are in the same projection.
* conversion_factor: a constant multiplier. e.g: to convert snow depth from *m/s* to *m* for daily simulation, *conversion_factor* should be set to 86400.
```
    snow_depth_unit_conversion(mods = c('01_04_2009','02_04_2009','03_04_2009'),
                              save_filename = 'final_snowdepth_',
                              work_directory = file.path(cwd, 'test'),
                              crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                              conversion_factor = 86400 )
```
