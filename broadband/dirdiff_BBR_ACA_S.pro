; .r dirdiff_BBR_AFLUX_Server.pro

;######################################################################################
; COMMENTS
;######################################################################################
; (1)
          ; Aerosol settings: "aerosol_species_file maritime_clean"

;(2)
          ; Albedo settings:  "jhu.becknic.water.snow.granular.82um.medium.spectrum_BBR.txt"
         
;(3)
          ; Wavelength: 290-3600

;(4)
          ; Time resolution: 1 min

;######################################################################################
;;######################################################################################


close,/all


date = [$
'20200830a'$
,'20200831a'$
,'20200831b'$
,'20200902a'$
,'20200904a'$
,'20200907a'$
,'20200908a'$
,'20200910a'$
,'20200911a'$
,'20200913a'$
]

For d=0, n_elements(date)-1 do begin
 
case date[d] of  ; OMI estimates from http://es-ee.tor.ec.gc.ca/e/ozone/Curr_allmap_g.htm or http://www.temis.nl/protocols/O3global.html
'20200830a': o3 = 325
'20200831a': o3 = 325
'20200831b': o3 = 325
'20200902a': o3 = 275
'20200904a': o3 = 275
'20200907a': o3 = 300
'20200908a': o3 = 275
'20200910a': o3 = 300
'20200911a': o3 = 325
'20200913a': o3 = 250
endcase

print,'** Data is read, starting day '+date[d]
atmosfiles = file_search('/projekt_agmwend/data_raw/MOSAiC_ACA_S_raw/soundings/Radiosondes/RS_for_libradtran','Libradtran_RS_NyAlesund_'+strmid(date[d],0,8)+'_*.dat')

for e=0,n_elements(atmosfiles)-1 do begin

atmosfile = atmosfiles(e)

datestring = strmid(date[d],0,4) + ' ' + strmid(date[d],4,2) + ' ' + strmid(date[d],6,2) + ' '

;gps_file = '/projekt_agmwend/data_raw/MOSAiC_ACA_S_raw/Flight_'+date[d]+'/AWI_nav/Data_GPS_P5_'+date(d)+'.dat'
;
;dummy=''
;openr,1, gps_file
;for i=0,3 do begin
;	readf,1,dummy
;endfor
;data_raw = strarr(1,file_lines(gps_file)-4)
;readf,1, data_raw
;close,1
;data =strarr(13,file_lines(gps_file)-4)
;for y=0,n_elements(data_raw)-1 do begin
;	data[*,y] = strsplit(data_raw[y],/extract)
;endfor
;
;sod =float(data(3,*))*3600.+float(data(4,*))*60. + float(data(5,*))
;h = float(data(3,*))
;m = float(data(4,*))
;s =float(data(5,*))
; 
;alt = float(data(10,*))
;
;lon = floor(float(data(6,*))/100.) + ( (float(data(6,*))/100.) - floor(float(data(6,*))/100.) )/0.6
;lat = floor(float(data(8,*))/100.) + ( (float(data(8,*))/100.) - floor(float(data(8,*))/100.) )/0.6
;
;Lon_dir = data(7,*)
;Lat_dir = data(9,*)
;lon[where(Lon_dir eq 'W')] = -lon[where(Lon_dir eq 'W')]
;lat[where(Lat_dir eq 'S')] = -lat[where(Lat_dir eq 'S')]


; GPS data from Meteo file
gps_file = '/projekt_agmwend/data/MOSAiC_ACA_S/Flight_'+date[d]+'/Meteo/Flight_'+date(d)+'_1s.asc'

dummy=''
openr,1, gps_file
readf,1,dummy
data = fltarr(13,file_lines(gps_file)-1)
readf,1, data
close,1


sod = data(0,*)
h = floor(sod/3600.)
m = floor((sod/3600. - floor(sod/3600.))*60.) 
s = floor(((sod/3600. - floor(sod/3600.))*60. - floor((sod/3600.-floor(sod/3600.))*60.))*60.)


alt = data(1,*)
lon = data(2,*)
lat = data(3,*)


 j=0L
 counter = 0L
 jindex = 0L
 check = long(sod[j])
 while j lt n_elements(sod)-50 do begin
    time_step = 60L;120L;120L
    if (j eq 0L) or (j eq n_elements(sod)-1) or (long(sod[j]) ge time_step + check) then begin
       if (j eq n_elements(sod)-1) then s[j]++  ; make sure last second is fully covered
			goto,libsim
			libsim:
       timestring = datestring + string(h[j],format='(I2.2)') + ' ' + string(m[j],format='(I2.2)') + ' ' + string(s[j],format='(I2.2)')
       
       print, timestring
       print, 'START Libradtran'

;       ;===============================================================================
            lib_file_path = '/projekt_agmwend/data/MOSAiC_ACA_S/00_tools/02_BBR/libradtran/'
            openw,1,lib_file_path+'dddd_dirdiff.inp'
            printf,1,'data_files_path /opt/libradtran/2.0.3/share/libRadtran/data            # location of internal libRadtran data'
            printf,1,'rte_solver twostr'
            printf,1,'pseudospherical'
            printf,1,'mol_abs_param lowtran' ;kato'
            printf,1,'atmosphere_file /opt/libradtran/2.0.3/share/libRadtran/data/atmmod/afglss.dat'
            printf,1,'radiosonde '+atmosfile+' H2O RH'
            printf,1,'time '+timestring
            if float(lat[j]) lt 0.0 then printf,1,'latitude S '+string(abs(float(lat[j])))
            if float(lat[j]) ge 0.0 then printf,1,'latitude N '+string(abs(float(lat[j])))
            if float(lon[j]) lt 0.0 then printf,1,'longitude W '+string(abs(float(lon[j])))
            if float(lon[j]) ge 0.0 then printf,1,'longitude E '+string(abs(float(lon[j])))
            printf,1,'altitude 0'
            printf,1,'zout '+string(alt[j]/1000.)
            printf,1,'wavelength 290 3600'
            printf,1,'source solar /projekt_agmwend/data/MOSAiC_ACA_S/00_tools/01_Fdw_dir_diff_sim/add_data/NewGuey2003_BBR.dat per_nm # extraterr. solar flux'
            printf,1,'output_user lambda sza edir edn'
            printf,1,'output_process integrate' ;sum'
            printf,1,'albedo_file  /projekt_agmwend/data/MOSAiC_ACA_S/00_tools/01_Fdw_dir_diff_sim/add_data/jhu.becknic.water.snow.granular.82um.medium.spectrum_BBR.txt'
            printf,1,'mol_modify O3 '+string(o3)+ '  DU'
            printf,1,'aerosol_default'
            printf,1,'aerosol_species_file maritime_clean'
            close,1
            cmd = 'uvspec < '+lib_file_path+'dddd_dirdiff.inp > '+lib_file_path+'dddd_dirdiff.out'
            spawn,cmd

;===============================================================================

       ofile=lib_file_path+'dddd_dirdiff.out'
	   if (j eq 0) then begin
           print,file_lines(ofile)
           dd1 = '';fltarr(4)
       endif
       openr,2,ofile
          readf,2,dd1
		  on_ioerror,ers		; if libradtran crashes, the output file is empty => idl error. This function forces the execution to continue at specified point (ers)
       ers: close,2
	   if dd1 eq '' then goto,libsim else dd0 = float(strsplit(dd1,/extract))		; if output file empty, the variable the data should be read into is still empty => repeat the simulation (goto,libsim (line 124))
       Fdwdummy = (dd0[2]+dd0[3])/1000. 			; clear sky irradiance
       ddummy = dd0[2] / (dd0[2]+dd0[3]) ; direct fraction
       if (j eq 0) then begin
          dd = ddummy
          Fdw = Fdwdummy
       endif else begin
          dd = [dd, ddummy]
          Fdw = [Fdw, Fdwdummy]
       endelse
       jindex = [jindex, j]
       counter++
       check = long(sod[j])
    endif

    if (long(sod[j]) gt time_step + check)  then check = long(sod[j])
    j++
 print,j,n_elements(sod)
 endwhile
 jindex=jindex[1:*]
 
 toolow = where(dd lt 0.0,nl)
 if nl gt 0 then dd[toolow]=-8.
 baddata = where(finite(dd) ne 1,nb)
 if nb gt 0 then dd[baddata]=-9.

 ; Finished working on this day; write results to file

 ; write direct fraction
 print,'Data output for  Flight:     Aircraft: P5'
 
 outfile_dir = '/projekt_agmwend/data/MOSAiC_ACA_S/Flight_'+date[d]+'/BBR/'
 if file_test(outfile_dir,/directory) eq 0 then file_mkdir, outfile_dir
 outfile = outfile_dir+'P5_BBR_DirectFraction_Flight_'+date[d]+'_R0.dat'

 openw,oo,outfile,/GET_LUN

   printf,oo,'36 1001'  ; number of total header lines, then '1001'
   printf,oo,'Wendisch, Manfred' ; PI
   printf,oo,'LIM, Leipzig University' ; Affil
   printf,oo,'Clear sky downward irradiance along flight track, calculated by libRadtran 2.0 using P5 nav data'
   printf,oo,'MOSAiC ACA-S Flight '+date[d]
   printf,oo,'1 1'  ; only one file
case strmid(systime(/UTC),4,3) of
 'Jan': sysmonth='01'
 'Feb': sysmonth='02'
 'Mar': sysmonth='03'
 'Apr': sysmonth='04'
 'May': sysmonth='05'
 'Jun': sysmonth='06'
 'Jul': sysmonth='07'
 'Aug': sysmonth='08'
 'Sep': sysmonth='09'
 'Oct': sysmonth='10'
 'Nov': sysmonth='11'
 'Dec': sysmonth='12'
 ELSE: sysmonth='systime_error'
endcase
   printf,oo,'2020 '+strmid(date[d],4,2)+' '+strmid(date[d],6,2)+' '+strmid(systime(/UTC),20,4)+' '+sysmonth+' '+strmid(systime(/UTC),8,2)
   printf,oo,'0' ; data interval in seconds, 0 = n/a
   printf,oo,'sod (seconds of day; number of seconds from 0000 UTC)'
   printf,oo,'3' ; number of data columns, not counting time
   printf,oo,'1' ; Scale factor
   printf,oo,'-9' ; Missing data value
   printf,oo,'Latitude, in degrees, north positive'
   printf,oo,'Longitude, in degrees, east positive'
   printf,oo,'Direct fraction of broadband downward solar irradiance (0.29 um - 3.6 um)'
   printf,oo,'1' ; number of special comment lines following
   printf,oo,'Special comments: None.'
   printf,oo,'18'  ;number of comment lines following
   printf,oo,'PI_CONTACT_INFO: Address: LIM, Stephanstr.3, 04103 Leipzig, Germany. Email: m.wendisch@uni-leipzig.de'
   printf,oo,'PLATFORM: Polar 5 research aircraft, C-GAWI'
   printf,oo,'LOCATION: given in data'
   printf,oo,'ASSOCIATED_DATA: none'
   printf,oo,'INSTRUMENT_INFO: Model data'
   printf,oo,'DATA_INFO:  Dimensionless fractions.'
   printf,oo,'UNCERTAINTY: 1% (much more in case of overlying clouds which are not represented in the model)'
   printf,oo,'ULOD_FLAG: -7'
   printf,oo,'ULOD_VALUE: 1.0'
   printf,oo,'LLOD_FLAG: -8'
   printf,oo,'LLOD_VALUE: 0.0'
   printf,oo,'DM_CONTACT_INFO: Andre Ehrlich, a.ehrlich@uni-leipzig.de'
   printf,oo,'PROJECT_INFO: MOSAiC ACA-S Campaign, Longyearbyen, Svalbard, Norway.'
   printf,oo,'STIPULATIONS_ON_USE: Use of these data requires prior OK from the PI. The MOSAiC Data Protocol applies.'
   printf,oo,'OTHER_COMMENTS: none'
   printf,oo,'REVISION: R0'
   printf,oo,'R0: no comments'
   datatitle='sod         Lat(N)       Lon(E)     f_dir   '
   printf,oo,datatitle
   for k=0L, counter-1 do begin
       j=jindex[k]
       printf,oo,sod[j],lat[j],lon[j],dd[k],format='(I5.5,2F13.6,F15.7)'
   endfor ; k
   close,oo & free_lun,oo

 ; write Fwd clear sky
 print,'Data output for Flight:      Aircraft: P5'
 
 outfile = outfile_dir+'P5_BBR_Fdn_clear_sky_Flight_'+date[d]+'_R0.dat'

 openw,oo,outfile,/GET_LUN

   printf,oo,'36 1001'  ; number of total header lines, then '1001'
   printf,oo,'Wendisch, Manfred' ; PI
   printf,oo,'LIM, Leipzig University' ; Affil
   printf,oo,'Clear sky downward irradiance along flight track, calculated by libRadtran 2.0 using Polar 5 nav data'
   printf,oo,'ACLOUD Flight ';+Flight[d]
   printf,oo,'1 1'  ; only one file
case strmid(systime(/UTC),4,3) of
 'Jan': sysmonth='01'
 'Feb': sysmonth='02'
 'Mar': sysmonth='03'
 'Apr': sysmonth='04'
 'May': sysmonth='05'
 'Jun': sysmonth='06'
 'Jul': sysmonth='07'
 'Aug': sysmonth='08'
 'Sep': sysmonth='09'
 'Oct': sysmonth='10'
 'Nov': sysmonth='11'
 'Dec': sysmonth='12'
 ELSE: sysmonth='systime_error'
endcase
   printf,oo,'2020   '+strmid(date[d],4,2)+' '+strmid(date[d],6,2)+' '+strmid(systime(/UTC),20,4)+' '+sysmonth+' '+strmid(systime(/UTC),8,2)
   printf,oo,'0' ; data interval in seconds, 0 = n/a
   printf,oo,'sod (seconds of day; number of seconds from 0000 UTC)'
   printf,oo,'3'; number of data columns, not counting time
   printf,oo,'1' ; Scale factor
   printf,oo,'-9' ; Missing data value
   printf,oo,'Latitude, in degrees, north positive'
   printf,oo,'Longitude, in degrees, east positive'
   printf,oo,'Broadband solar clear sky downward irradiance (0.29 um - 3.6 um)'
   printf,oo,'1' ; number of special comment lines following
   printf,oo,'Special comments: None.'
   printf,oo,'18'  ;number of comment lines following
   printf,oo,'PI_CONTACT_INFO: Address: LIM, Stephanstr.3, 04103 Leipzig, Germany. Email: m.wendisch@uni-leipzig.de'
   printf,oo,'PLATFORM: Polar 5 research aircraft, C-GAWI'
   printf,oo,'LOCATION: given in data'
   printf,oo,'ASSOCIATED_DATA: none'
   printf,oo,'INSTRUMENT_INFO: Model data'
   printf,oo,'DATA_INFO: Irradiance in W m-2.'
   printf,oo,'UNCERTAINTY: 1% (little more in case of dark surfaces as sea ice is assumed in the model)'
   printf,oo,'ULOD_FLAG: -7'
   printf,oo,'ULOD_VALUE: 1.0'
   printf,oo,'LLOD_FLAG: -8'
   printf,oo,'LLOD_VALUE: 0.0'
   printf,oo,'DM_CONTACT_INFO: Andre Ehrlich, a.ehrlich@uni-leipzig.de'
   printf,oo,'PROJECT_INFO: MOSAiC ACA-S Campaign, Longyearbyen, Svalbard, Norway'
   printf,oo,'STIPULATIONS_ON_USE: Use of these data requires prior OK from the PI. The MOSAiC Data Protocol applies.'
   printf,oo,'OTHER_COMMENTS: none'
   printf,oo,'REVISION: R0'
   printf,oo,'R0: no comments'
   datatitle='sod         Lat(N)       Lon(E)     F_dw'
   printf,oo,datatitle
   for k=0L, counter-1 do begin
       j=jindex[k]
       printf,oo,sod[j],lat[j],lon[j],Fdw[k],format='(I5.5,2F13.6,F15.7)'
   endfor ; k
   close,oo & free_lun,oo

endfor

endfor;loop over days

exit

end