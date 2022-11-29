# Radar processing

The provided set of scripts create the netcdf files for the radar measurements as can be found on PANGAEA database.

The w-radar package <https://github.com/igmk/w-radar> is applied on the standard netcdf output of MiRAC-A radar as produced by Radiometer Physics GmbH standard radar software. To this output, scripts are applied that clean the data for disturbances as described in Mech et al., 2019 (Microwave Radar/radiometer for Arctic Clouds (MiRAC): first insights from the ACLOUD campaign) and transformed to nadir view. Finally, mirac-a_processing.py creates the netcdf files as they can be found in the PANGAEA database.

For details check comments in scripts.

For questions on the scripts and the input raw data contact Mario Mech - University of Cologne (mario.mech@uni-koeln.de).
