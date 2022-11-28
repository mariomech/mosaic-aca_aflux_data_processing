;============================================================================
;============================================================================
; Attitude Correction for downward irradiance
;============================================================================
;============================================================================
;
;
; corrects downward irradiance for misalignment of the sensor (deviation from hoizontal alignment)
;   - only direct fraction of irradiance can be corrected by the equation, therefore a direct fraction (fdir) has to be provided
;   - please check correct definition of the attitude angle
;   - for differences between the sensor attitude and the attitude given by an INS the offset angles (p_off and r_off) can be defined.
;
;============================================================================
;============================================================================


; INPUT:  Fdw   ... downward radiance [W m-2] or [W m-2 nm-1]
;	   r     ... roll angle [deg]      		  - defined positive for left wing up
;	   p     ... pitch angle [deg]	  		  - defined positive for nose down
;	   y     ... yaw angle [deg]		  		  - defined clockwise with North=0°
;	   sza   ... solar zenith angle [deg]
;	   saa   ... solar azimuth angle [deg]	  - defined clockwise with North=0°
;	   r_off ... roll offset angle between INS and sensor [deg]   - defined positive for left wing up
;	   p_off ... pitch offset angle between INS and sensor [deg]  - defined positive for nose down
;	   fdir  ... fraction of direct radiation [0..1]; 0=pure diffuse, 1=pure direct

; OUTPUT: Fdw_corr       ... corrected downward radiance [W m-2] or [W m-2 nm-1]

; APPLY via: Fdw_corr=Fdw_attitude_correction(fdw,r,p,y,sza,saa,r_off,p_off,fdir)

function Fdw_attitude_correction, fdw, r,p,y,sza,saa,r_off,p_off,fdir

r=r+r_off
p=p+p_off

factor= sin((90.-sza)*!dpi/180.0)/$
       (cos((90.-sza)*!dpi/180.0)*sin(r*!dpi/180.0)*sin((saa-y)*!dpi/180.0) +$
        cos((90.-sza)*!dpi/180.0)*sin(p*!dpi/180.0)*cos(r*!dpi/180.0)*cos((saa-y)*!dpi/180.0) +$
        sin((90.-sza)*!dpi/180.0)*cos(p*!dpi/180.0)*cos(r*!dpi/180.0))
Fdw=fdir*Fdw*factor+(1-fdir)*Fdw


return,Fdw




end