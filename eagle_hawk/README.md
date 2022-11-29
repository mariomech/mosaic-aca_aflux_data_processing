`SaveEagleNCDF_xxx.pro` and `SaveHawkNCDF_xxx.pro` create netCDF files containing all *AisaEAGLE* or *AisaHAWK* files acquired within the same flight.
There is a separat program for each of the two instruments and the two campaigns *AFLUX* and *MOSAiC-ACA*.
The netCDF files further contain poition and attitude data derived from the inertial navigation system of the *SMART*-Albedometer.

To run the main program, three sub-programs are needed:

`read_eagle.pro` reads the calibrated *AisaEAGLE* and *AisaHAWK* files. 
`get_eagle_times.pro` is needed to read the time frames of the *AisaEAGLE* and *AisaHAWK* files for the collocation with the position data from the *SMART*-Albedometer.
`ncdf_rdwr.pro` generates the netCDF file

The programs are written in IDL 7.1.
