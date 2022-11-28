; **************  get_sza  ******************
; *
; * Calculates the solar zenith angles.
; * Requires julian_day,local_time,dec,refract
; *
; *** REQUIRED INPUT ***
; *
; *  t0             Time in UTC (in decimal hours, i.e. 10.5 for 10h30min)
; *  lat            Latitude (North positive)
; *  lon            Longitude (East positive)
; *  year           The year  (e.g. 2020)
; *  month          The month (1-12)
; *  day            The day (1-31)
; *  pres           Surface Pressure in hPa (for refraction correction)
; *  temp           Surface Temperature in deg C (for refraction correction)
; *
; *** RETURN VALUE ***
; *
; *  sza			The solar zenith angle (°)
; *
; *
;Calculation of solar zenith angle
;Copyright by Sebastian Schmidt
;
;changes by André Ehrlich:   - new declination parametrization after Michalsky, J.  1988. The Astronomical Almanac's algorithm for approximate solar position (1950-2050).  Solar Energy 40 (3), pp. 227-235.
;							 - refraction correction algorithm from Meeus,1991
;                            - check: for SZA >95 no refraction correction
;


function get_sza,t0,lat,lon,year,month,day,pres,temp
 pi=!DPI
 julian=julian_day(year,month,day,t0)
 t_loc =local_time(julian,t0,lon)
 tau   =(12.-t_loc)*15.
 height=asin(cos(pi/180.*lat)*cos(pi/180.*dec(julian,year))*cos(pi/180.*tau)+sin(pi/180.*lat)*sin(pi/180.*dec(julian,year)))
 ; correction for refraction
 refcor = fltarr(n_elements(height))
 h1 = where(height ge -0.087,nh1)  ;corrects only for angles > -5°
 if nh1 gt 0 then refcor[h1]=refract(height[h1],pres,temp)

 sza=90.-(height+refcor)*180./pi

 return,sza
end
