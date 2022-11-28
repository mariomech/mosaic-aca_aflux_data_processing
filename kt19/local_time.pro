;**************     local_time     *****************************************
; * calculates the local solar time by accounting for
; *					- longitude
; *					- time equation (two version are implemented, one commented, both are almost identical)
; *
; *
; *** REQUIRED INPUT ***
; *
; *  	julian         julian day (day of year) as calculated with julian2.pro
; *  	t0             Time in UTC (in decimal hours, i.e. 10.5 for 10h30min)
; *		lon            Longitude (East positive)
; *
; *** RETURN VALUE ***
; *
; *  	corrected_local_time  			local solar time (in decimal hours, i.e. 10.5 for 10h30min)
; *
; *** USE ***
; *  	solar_local_time = local_time(julian,t0,lon)
; *
;*************************************************************************


function local_time,julian,t0,lon
 pi=!DPI
 mean_local_time_min=t0*60.+4.*lon
 fac=0.0132*0.5+7.3525*cos(2.*pi*julian/365.+1.4989) + 9.9359*cos(2.*2.*pi*julian/365.+1.9006) + 0.3387*cos(3.*2.*pi*julian/365.+1.8360)
;; ;alternative Option for the time equation
;; Gamma=2.*pi/365.*(julian-1+3)
;; fac=60.*24./2./pi*(0.000075 + 0.001868*cos(Gamma)- 0.032077*sin(Gamma)- 0.014615*cos(2*Gamma)- 0.040849*sin(2*Gamma))
 corrected_local_time=(mean_local_time_min+fac)/60.
 return,corrected_local_time
end
