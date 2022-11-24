
# PMS scripts

The provided set of scripts create Python DataFrame files and NASA-AMES Files for the DLR PMS in-situ cloud probes during ALFUX and MOSAiC-ACA.

Following folders include:
- cas-a_processing: Processing of CAS data during AFLUX
- cdp-m_processing: Processing of CDP data during MOSAiC-ACA
- cip-a_processing: Processing of CIP data during AFLUX, IDL-file for SODA processing settings
- cip-m_processing: Processing of CIP data during MOSAiC-ACA, IDL-file for SODA processing settings
- pip-a_processing: Processing of PIP data during AFLUX, IDL-file for SODA processing settings
- pip-m_processing: Processing of PIP data during MOSAiC-ACA, IDL-file for SODA processing settings
- combined-a_processing: Creating a combined file of CAS, CIP and PIP data during AFLUX
- combined-m_processing: Creating a combined file of CDP, CIP and PIP data during MOSAiC-ACA
- tas_aflux: TAS during AFLUX for sampling area calculations
- tas_mosaic: TAS during MOSAiC-ACA for sampling area calculations
- Utility_MOSAiC_AFLUX_pms.py: includes functions for the processing routines above.

In contrast to the PANGAEA data files, the provided scripts create NASA-AMES format. Nevertheless, the data are identical. 

For details, check comments in the scripts.
For Questions contact: Manuel Moser (<manuel.moser@dlr.de>), Christiane Voigt (<christiane.voigt@dlr.de>)
