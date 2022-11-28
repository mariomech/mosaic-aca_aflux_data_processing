# Dropsonde Processing

The dropsondes were processed using the ASPEN software (Version 3.4.4) in two different configurations: the predefined research-dropsonde and the user-defined withoutdynamic (no correction for response time of the temperature sensor). The ASPEN output was further processed using the files `read_ASPEN_full.pro` and` read_ASPEN_without.pro`, respectively. The latter calls routines for an own correction of the time constants for temperature and relative humidity.

`read_ASPEN_merge.pro` combines the two differently processed data sets, cuts off altitudes, where the sensors did not yet adapt to the environmental conditions, and corrects the dry bias during MOSAiC-ACA. Finally, `convert_for_PANGAEA_group_V2.pro` creates the NetCDF files.

Further information can be found as comments in the script. In case of questions, please contact Sebastian Becker (<sebastian.becker@uni-leipzig.de>) or André Ehrlich (<a.ehrlich@uni-leipzig.de>).
