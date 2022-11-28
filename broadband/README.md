# Processing of broadband radiometer and KT19 data

This folder contains a script (`processing_BBR_MOSAIC.pro`) which processes the raw data acquired by the broadband radiometers. The conversion factors to calculate irradiances as well as the identified time constants and integration offsets are specified in the *P5_BBR_20Hz_ACA_S.ini* file.

Furthermore, the folder contains routines to perform the inertia and attitude corrections. For the attitude correction, the solar position is determined using the routines located in the same-named folder, while the direct fraction of the solar downward irradiance in cloud-free conditions is simulated using the file `dirdiff_BBR_ACA_S.pro`.

Finally, the file `ACA_BBR_Data_Publ.py` creates the NetCDF files and applies the icing, attitude, and temperature change flags.

Further information can be found as comments in the script. In case of questions, please contact Sebastian Becker (<sebastian.becker@uni-leipzig.de>) or André Ehrlich (<a.ehrlich@uni-leipzig.de>).

