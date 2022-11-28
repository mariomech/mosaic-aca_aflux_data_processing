; **************  get_saa  ******************
; *
; * Calculates the solar azimuth angles.
; * Requires julian_day,local_time,dec
; *
; *** REQUIRED INPUT ***
; *
; *  t0             Time in UTC (in decimal hours, i.e. 10.5 for 10h30min)
; *  lat            Latitude (North positive)
; *  lon            Longitude (East positive)
; *  year           The year  (e.g. 2020)
; *  month          The month (1-12)
; *  day            The day (1-31)
; *
; *** RETURN VALUE ***
; *
; *  azimuth			The solar azimuth angle (°)
; *
; *** USE ***
; *
; *		azimuth=get_saa2(t0,lat,lon,year,month,day)
; *
; *
; **************************************************************


function get_saa,t0,lat,lon,year,month,day
 pi=!DPI
 julian=julian_day(year,month,day,t0)
 t_loc =local_time(julian,t0,lon)
 tau   =(12.-t_loc)*15.
 height=asin(cos(pi/180.*lat)*cos(pi/180.*dec(julian,year))*cos(pi/180.*tau)+sin(pi/180.*lat)*sin(pi/180.*dec(julian,year)))
 azimuth=( sin(height)*sin(pi/180.*lat) - sin(pi/180.*dec(julian,year)) )/( cos(height)*cos(pi/180.*lat) )
 az1 = where(azimuth gt 1.,naz)
 if naz gt 0 then azimuth[az1] = 1.
 azimuth=acos(azimuth)
 tl12 = where(t_loc lt 12.,ntl)
 if ntl gt 0 then azimuth[tl12]=-azimuth[tl12]
 azimuth+=!DPI

 azimuth=azimuth*180./pi

 return,azimuth

end
