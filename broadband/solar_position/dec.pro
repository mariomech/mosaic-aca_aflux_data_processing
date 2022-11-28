;*******************    dec     *****************************************
; * declination calculated after Michalsky, J.  1988.
; *	reference: Michalsky, J.  1988. The Astronomical Almanac's algorithm for approximate solar position (1950-2050).  Solar Energy 40 (3), pp. 227-235.
; *
; *** REQUIRED INPUT ***
; *
; *  	julian         julian day (day of year) as calculated with julian2.pro
; *  	year           The year (e.g., 2020)
; *
; *** RETURN VALUE ***
; *
; *  	dec  			declination in (°)
; *
; *** USE ***
; *  	delcination = dec(julian,year)
; *
;*************************************************************************


function dec,julian,year
 pi=!DPI
 rad=pi/180.



;get the current julian date (actually add 2,400,000 for jd)
      delta=year-1949.
      leap=fix(delta/4.)
      julian_zero=32916.5+delta*365.+leap+julian
;1st no. is mid. 0 jan 1949 minus 2.4e6; leap=leap days since 1949
;the last yr of century is not leap yr unless divisible by 400
      if (((year mod 100.) eq 0.0) and ((year mod 400.) ne 0.0)) then julian_zero=julian_zero-1.



;calculate ecliptic coordinates
      time=julian_zero-51545.0


;force mean longitude between 0 and 360 degs
      mnlong=280.460+.9856474*time
      mnlong=(mnlong mod 360.)
      if(mnlong lt 0.) then mnlong=mnlong+360.

;mean anomaly in radians between 0 and 2*pi
      mnanom=357.528+.9856003*time
      mnanom=(mnanom mod 360.)
      if(mnanom lt 0.) then mnanom=mnanom+360.
      mnanom=mnanom*rad


;compute the ecliptic longitude and obliquity of ecliptic in radians
eclong=mnlong+1.915*sin(mnanom)+.020*sin(2.*mnanom)
eclong=(eclong mod 360.)
if(eclong lt 0.) then eclong=eclong+360.
oblqec=23.439-.0000004*time
eclong=eclong*rad
oblqec=oblqec*rad

dec=asin(sin(oblqec)*sin(eclong)) /rad


return,dec
end
