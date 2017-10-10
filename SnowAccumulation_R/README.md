# snow_accumulation_melt_funcions

The purpose of 'snow_accumulation_melt_funcions' is to estimate the winter processes. The script is developed primarily in supporting the SSRB hgs model. The algorithm is derived from degree day model. 
		
## Usage

* write_weighted_temp_raster: calculate the weighted temperature raster from Tmax and Tmin Raster 

* average_weighted_temp_raster: calcualte backward looking moving average of the weighted temprature raster

* potential_snow_accumulation_rain_accumulation: determine the potential for snow and rain accumulation. 

* potential_snow_melt: determine the potential for snow to melt 

* integrate_potential_snowaccumulation_snow_melt: determine the true amount of snow melt and accumulation based on the potential values

* combine_rain_snow: sum up the rain and snow melt raster for HGS model input

* snow_depth_unit_conversion: convert the unit of the snow depth raster by multiplyng a constant

# Method

## write_weighted_temp_raster(crs,mods,tmax_file_path,tmin_file_path,weighted_temp_raster_file_path,weighted_coef)
* crs: projection of the raster. Assumes all the raster files are in the same projection
* mods: a list of matching pattern, this pattern is used to look for temperature files. Assuming tmin and tmax have the same matching pattern.
* tmax_file_path: folder directory of the maximum temperature raster 
* tmin_file_path: folder directory of the minimum temperature raster 
* weighted_temp_raster_file_path: the directory where the folder *weighted_temp_raster* can be created. *weighted_temp_raster* is create to contain all the weighted temperature output files.
* weighted_coef: the weighted temperature is calcualted by ** tmin + weighted_coef(tmax-tmin) **
```
write_weighted_temp_raster(mods = c('_1.asc','_2.asc','_3.asc'),
                           crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                           tmax_file_path = c("D:/ARB/temp/max"),
                           tmin_file_path = c("D:/ARB/temp/min"),
                           saving_data_file_path = c("D:/ARB/temp/weighted"),
                           weighted_coef =0.5)

```

## average_weighted_temp_raster(x, mods, crs, weighted_temp_raster_folder_path, weighted_temp_raster_folder_name = "weighted_temp_raster", le = 2, ldebug = FALSE)
* x: a pattern that is used to match the temperature raster files. *x* is the starting point for the backward looking average method. There has to be at least *le* number of elements in *mods* before *x*.
* mods: a list of patterns that is used to match all the temperature raster files. The order of mods determines which files are used to compute the backward average.
* weighted_temp_raster_folder_path: the directory where the folder *weighted_temp_raster* is created. *weighted_temp_raster* is a folder that contains the output from the function **write_weighted_temp_raster()**.
* weighted_temp_raster_folder_name: the folder name of where the temperature raster files are located. weighted_temp_raster_folder_name is set to *weighted_temp_raster* by default.
* le: the numer of files to look backward. For example, to calcualte a three day backward average, le should be set as *2*.
```
average_weighted_temp_raster<-function(x = '_3.asc',
                                       mods = '_1.asc','_2.asc','_3.asc'
                                       crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                                       weighted_temp_raster_folder_path = c("D:/ARB/temp/weighted"),
                                       weighted_temp_raster_folder_name = "weighted_temp_raster",
                                       le = 2)
```


## potential_snow_accumulation_rain_accumulation (upper_T_thresh, lower_T_thresh, crs, mods, weighted_temp_raster_file_path, pcp_file_path, temp_foldername = 'weighted_temp_raster')
* upper_T_thresh: upper temperature threshold. rain is expected at temperature higher than this numer
* lower_T_thresh: lower temperature threshold. snow is expected at temperature lower than this number
* If the temperature is in between upper_T_thresh and lower_T_thresh, it is assumed that the preciptation is in a mixed form of snow and rain. The amount of rain can be estimated as: (T - lower_T_thresh) / (upper_T_thresh - lower_T_thresh) * preciptation
* crs: projection of the raster. Assumes all the raster files are in the same projection.
* mods: a list of matching patterns that is used to match all the temperature and preciptation raster files. The temperature and preciptation files have to share same matching pattern.
* weighted_temp_raster_file_path: the directory where the folder *weighted_temp_raster* is created. *weighted_temp_raster* is a folder that contains the output from the function **write_weighted_temp_raster()**.
* pcp_file_path: file path of the preciptation raster folder.
* temp_foldername: the folder name of where the temperature raster files are located. weighted_temp_raster_folder_name is set to *weighted_temp_raster* by default.
```
potential_snow_accumulation_rain_accumulation(upper_T_thresh = 0,
                                              lower_T_thresh = 0,
                                              crs = c("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"),
                                              mods = '_1.asc','_2.asc','_3.asc',
                                              weighted_temp_raster_file_path = c("D:/ARB/temp/weighted"),
                                              pcp_file_path = c("D:/ARB/pcp"),
                                              temp_foldername = 'weighted_temp_raster')
```

## potential_snow_melt (metlt_constant, T_melt, crs, mods, work_directory, temp_foldername)
* metlt_constant: melt constant. eg: 5.787037e-08
* T_melt: melting begins when temperature reach or above this temperature
```
potential snow melt = metlt_constant * ( Temperature - T_melt )
```
* crs: projection of the raster. Assumes all the raster files are in the same projection.
* mods: a list of matching patterns that is used to match all the temperature and preciptation raster files. The temperature and preciptation files have to share same matching pattern.
* weighted_temp_raster_file_path: the directory where the folder *weighted_temp_raster* is created. *weighted_temp_raster* is a folder that contains the output from the function **write_weighted_temp_raster()**.
* pcp_file_path: file path of the preciptation raster folder.
* temp_foldername: the folder name of where the temperature raster files are located. weighted_temp_raster_folder_name is set to *weighted_temp_raster* by default.











### compare_gw. **read_raw_obs()**
read the *.observation_well_flow.* file generated by HGS.

### compare_gw. **reorder_raw2column(*var_names = ['H', 'S', 'Z'], start_sheet = None, end_sheet = None*)**
reorder the *.observation_well_flow.* data to column format

- var_names: a list of variables read from the *.observation_well_flow.* file. The default read *H*,*S*, and *Z*.
		
- start_sheet/end_sheet: HGS models usually have multiple sheets. The variables from *start_sheet* to *end_sheet* are extracted. Note: the layer numbering in HGS counts from the botom. Sheet 1 means bottom layer.


### compare_gw. **head_to_depth()**

calcualte the depth of groundwater head. The elevation of the top sheet is used to calcualte depth from head. *end_sheet* from compare_gw. **reorder_raw2column()** should be set as the number of the top sheet.

### compare_gw. **to_realtime(t0 = '2002-01-01T00:00:00Z')**

convert simulation time to real time. 
- t0: the starting date of the simulation in ISO8601 format

### compare_gw. **avg_weekly(date_format = None)**
take the weekly average of all the variables. 

if date_format is provided, the following variables are produced:
- date_mid_week: [Gregorian Calender](https://www.staff.science.uu.nl/~gent0113/calendar/isocalendar.htm) year month and mid of week
- date_mid_week_numeric: date_mid_week expressed in Excel date format
```
compare_gw.avg_weekly(date_format= 'YYYYMMDD')

output:
"date_mid_week" : 20020102
"date_mid_week_numeric": 37258
```
### compare_gw. op(op_folder, zone_name = None, float_format = '%.6f')
output the data in Tecplot format
- op_folder: a directory of the output.
- zone_name: output file name, also zone name in Tecplot
- float_format: digit number for float

# Examples
## reorder *.observation_well_flow.*
```
file_directory = r'./test_data/Obs_well_hgs'
file_name = 'ARB_QUAPo.observation_well_flow.Baildon059.dat'
test = Obs_well_hgs( file_directory = file_directory, file_name=file_name)
# read 'ARB_QUAPo.observation_well_flow.Baildon059.dat'
test.read_raw_obs()
# extract variables H, Z, and S from sheet 3 to sheet 6. Then reorder the data to column format
test.reorder_raw2column(var_names = ['H', 'Z', 'S'], start_sheet = 3, end_sheet = 6, ldebug=False)
# save data in tecplot format
test.op(op_folder = r'./test_data/Obs_well_hgs/output', zone_name = 'Baildon059_reorder')
```
## convert head(H) to depth 
```
file_directory = r'./test_data/Obs_well_hgs'
file_name = 'ARB_QUAPo.observation_well_flow.Baildon059.dat'
test = Obs_well_hgs( file_directory = file_directory, file_name=file_name)
test.read_raw_obs()
test.reorder_raw2column(var_names = ['H', 'Z', 'S'], start_sheet = 3, end_sheet = 6, ldebug=False)
test.head_to_depth()
test.op(op_folder = r'./test_data/Obs_well_hgs/output', zone_name = 'Baildon059_head_2_depth')
```
## convert simulation time to real time
```
file_directory = r'./test_data/Obs_well_hgs'
file_name = 'ARB_QUAPo.observation_well_flow.Baildon059.dat'
test = Obs_well_hgs( file_directory = file_directory, file_name= file_name)
test.read_raw_obs()
test.reorder_raw2column(var_names = ['H', 'Z', 'S'], start_sheet = 3, end_sheet = 6, ldebug=False)
test.to_realtime(t0 = '2002-01-01T00:00:00Z')
test.op(op_folder = r'./test_data/Obs_well_hgs/output', zone_name = 'Baildon059_realtime')
```
## take weekly average of soil moisture
```
file_directory = r'./test_data/Obs_well_hgs'
file_name = 'ARB_QUAPo.observation_well_flow.Baildon059.dat'
test = Obs_well_hgs( file_directory = file_directory, file_name= file_name)
test.read_raw_obs()
test.reorder_raw2column(var_names = ['H', 'Z', 'S'], start_sheet = 5, end_sheet = 6, ldebug=False)
test.to_realtime(t0 = '2002-01-01T00:00:00Z')
test.avg_weekly(date_format= 'YYYYMMDD')
test.op(op_folder = r'./test_data/Obs_well_hgs/output', zone_name = 'Baildon059_weekly_soil_moisture')
```

## Tests
A set of tests are provided: `test_compare_gw.py`. These are based on a set of output files from the Qu'Appelle sub-basin model.
