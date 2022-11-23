# AMALi processing chain

The included scripts create netcdf files of the cloud top heights derived from AMALi lidar of the Alfred-Wegener-Institute for Polar- and Marine Research.

AMALi is operated by a LabView program that outputs binary files. These are converted to netcdf format by amali_raw_to_netcdf.py and read_amali_raw.py. cloudtop_detection.R derives the cloud top heights and outputs csv files. csv2netcdf.py creates the PANGAEA netcdf files.

amali_raw_to_beta_att.py is not needed by the processing but included for completeness. It derives the attenuated back scattering from the measurements.

For details check comments in scripts.

For questions on the scripts and the input raw data contact Mario Mech - University of Cologne (mario.mech@uni-koeln.de).