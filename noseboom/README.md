These scripts process the INS, GPS and flow measurement data of the noseboom 
to arrive at the high frequency, 3-dimensional wind data to calculate
turbulence statistics.

All original raw data are available at <https://dship.awi.de/exportdisplay/>.

The first step is `pp_MOSAiC_ACA_noseboom.k`, which applies essential 
calibrations to the recorded data.

The second step is `prep_MOSAiC_ACA_noseboom.k`, performing the actual wind 
vector calibration based on the aircraft movement and the flow measurement 
in the aircraft coordinat sytem.

The final step is printASCII.k to generate the ASCII files from the 
data stored in binary format.





