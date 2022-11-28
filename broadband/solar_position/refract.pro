;**************     refract     *****************************************
; * correction of the the solar elevation angle for refraction
; *	reference: J.Meeus, Astronomical Algorithms, 1991, pp102
; *
; *** REQUIRED INPUT ***
; *
; *  	elv:  solar elevation [rad];
; *  	pres: station pressure [hPa]
; *		temp: station temperature [°C]
; *
; *** RETURN VALUE ***
; *
; *  	refcor  			refraction correction offset [rad]: needs to be applied afterwards corrected_elv=elv+refcor
; *
; *** USE ***
; *  	refcor = refract(elv,pres,temp)
; *
;*************************************************************************





function refract,elv,pres,temp
 pi=!DPI
 h=elv/pi*180.0
 refcor=1.02 /tan((h + 10.3/(h+5.11))*2*pi/360.0)*(pres/1010.0)*283.0/(273.0+temp)
 refcor=refcor/60.0 * pi/180.0
 return, refcor
end
