;cd,'E:\ACLOUD\Dropsondes_for_PANGAEA'
;.r convert_for_PANGAEA_group_V2.pro

close,/all

factor =[$
1.035,1.03,1.025,1.045,1.015,1.0245,$														; 20200902a (6, 1 no GPS)
1.035,1.03,1.03,1.025,1.025,$																; 20200904a (7, 2 no launch detect -> 5)
1.05,1.045,1.045,1.035,1.04,1.06,1.035,1.045,1.03,1.05,1.025,1.025,1.04,1.025,$				; 20200907a (14)
1.03,1.02,1.02,1.035,1.025,1.03,1.025,$														; 20200908a (8, 1 no launch detect -> 7)
1.035,1.025,1.05,1.055,1.06,1.025,1.03,1.025,1.025,1.04,1.04,$								; 20200910a (11)
1.025,1.04,1.035,1.025,1.03,1.03,1.035,1.025,1.05,1.025,$									; 20200911a (10)
1.03,1.04,1.035,1.025,1.025,1.035,1.03$														; 20200913a (7)
]

files=file_search('/projekt_agmwend/data/MOSAiC_ACA_S/Soundings/Dropsondes/ASPEN_merged/','*.dat') ;D20100509_114803


flights=strmid(files,70,8)
index=uniq(flights)
flight_date=flights(index)

n_flights=n_elements(index)

index=[-1,index]
total_drops=index(1:*)-index

index=index+1


for d=0,n_flights-1 do begin

;=================================================================
;extract meta data from one DS file of the day
;    needed for creating correct NC file name
;=================================================================
file_ds=files(index(d))

jjjj=strmid(file_ds,70,4)
mo=strmid(file_ds,74,2)
da=strmid(file_ds,76,2)
time=strmid(file_ds,79,6)


;define and open NetCDF file
file_netcdf='/projekt_agmwend/data/MOSAiC_ACA_S/Soundings/Dropsondes/for_PANGAEA/DS_MOSAiC_ACA_Flight_'+flight_date(d)+'.nc'

fileID = NCDF_CREATE(file_netcdf, /NETCDF4_FORMAT,/CLOBBER) ;& NCDF_CLOSE, dsID ; Close the NetCDF file.
;NCDF_CONTROL, fileID, /FILL



drop_day=0

;=========================================================
;loop over all drop sondes of a flight
;=========================================================
for f=index(d),index(d+1)-1 do begin
drop_day=drop_day+1

file_ds=files(f)
print,file_ds

jjjj=strmid(file_ds,70,4)
mo=strmid(file_ds,74,2)
da=strmid(file_ds,76,2)
time=strmid(file_ds,79,6)


;read drop sonde data
openr,1,file_ds
dummy=''
for i=0,12 do begin
	readf,1,dummy
	if (i eq 5) then launch_time=strmid(dummy,57,8)
	;if (i eq 6) then stop
	if (i eq 6) then sond_id=strmid(dummy,43,9)
endfor
data=fltarr(14,file_lines(file_ds)-13)
readf,1,data
close,1


dsID = NCDF_GROUPDEF(fileID, 'Dropsonde_#'+string(drop_day,format='(I2.2)'))


zid = NCDF_DIMDEF(dsID, 'z', n_elements(data(0,*)))

; Define variables:
a1id = NCDF_VARDEF(dsID, 'GPS_Alt', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, a1id, 'long_name', 'GPS Altitude'
	NCDF_ATTPUT, dsID, a1id, 'units', 'm'
	NCDF_ATTPUT, dsID, a1id, '_FillValue', -999.0
a2id = NCDF_VARDEF(dsID, 'Baro_Alt', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, a2id, 'long_name', 'Barometric altitude'
	NCDF_ATTPUT, dsID, a2id, 'units', 'm'
	NCDF_ATTPUT, dsID, a2id, '_FillValue', -999.0
timeid= NCDF_VARDEF(dsID, 'Time', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, timeid, 'long_name', 'Time UTC'
	NCDF_ATTPUT, dsID, timeid, 'units', 'decimal hours'
latid = NCDF_VARDEF(dsID, 'Lat', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, latid, 'long_name', 'Latitude (North positive)'
	NCDF_ATTPUT, dsID, latid, 'units', 'degree'
lonid = NCDF_VARDEF(dsID, 'Lon', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, lonid, 'long_name', 'Longitude (East positive)'
	NCDF_ATTPUT, dsID, lonid, 'units', 'degree'
pid = NCDF_VARDEF(dsID, 'Pressure', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, pid, 'long_name', 'Air pressure'
	NCDF_ATTPUT, dsID, pid, 'units', 'hPa'
	NCDF_ATTPUT, dsID, pid, '_FillValue', -999.0
t1id = NCDF_VARDEF(dsID, 'Temp', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, t1id, 'long_name', 'Air temperature'
	NCDF_ATTPUT, dsID, t1id, 'units', 'degC'
	NCDF_ATTPUT, dsID, t1id, 'comment', ' as processed by ASPEN software V.3.4.4 (config: research-dropsonde)'
	NCDF_ATTPUT, dsID, t1id, '_FillValue', -999.0
t2id = NCDF_VARDEF(dsID, 'Temp_recon', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, t2id, 'long_name', 'Air temperature reconstructed'
	NCDF_ATTPUT, dsID, t2id, 'units', 'degC'
	NCDF_ATTPUT, dsID, t2id, 'comment', 'reconstructed temperature following Miloshevich et al. (2004) with tau=1.3 sek'
	NCDF_ATTPUT, dsID, t2id, '_FillValue', -999.0
h1id = NCDF_VARDEF(dsID, 'RHum', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, h1id, 'long_name', 'Relative humidity'
	NCDF_ATTPUT, dsID, h1id, 'units', '%'
	NCDF_ATTPUT, dsID, h1id, 'comment', ' as processed by ASPEN software V.3.4.4 (config: research-dropsonde)'
	NCDF_ATTPUT, dsID, h1id, '_FillValue', -999.0
h2id = NCDF_VARDEF(dsID, 'RHum_recon', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, h2id, 'long_name', 'Relative humidity reconstructed'
	NCDF_ATTPUT, dsID, h2id, 'units', '%'
    NCDF_ATTPUT, dsID, h2id, 'comment', 'reconstructed relative humidity following Miloshevich et al. (2004) with tau=1.6 sek'
    NCDF_ATTPUT, dsID, h2id, '_FillValue', -999.0
wsid = NCDF_VARDEF(dsID, 'Wind_vel', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, wsid, 'long_name', 'Horizontal wind velocity'
	NCDF_ATTPUT, dsID, wsid, 'units', 'm s-1'
	NCDF_ATTPUT, dsID, wsid, 'comment', ' as processed by ASPEN software V.3.4.4 (config: research-dropsonde)'
	NCDF_ATTPUT, dsID, wsid, '_FillValue', -999.0
wdid = NCDF_VARDEF(dsID, 'Wind_dir', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, wdid, 'long_name', 'Horizontal wind direction'
	NCDF_ATTPUT, dsID, wdid, 'units', 'degree'
	NCDF_ATTPUT, dsID, wdid, 'comment', ' as processed by ASPEN software V.3.4.4 (config: research-dropsonde)'
	NCDF_ATTPUT, dsID, wdid, '_FillValue', -999.0
h3id = NCDF_VARDEF(dsID, 'RHum_corr', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, h3id, 'long_name', 'Relative humidity corrected'
	NCDF_ATTPUT, dsID, h3id, 'units', '%'
	NCDF_ATTPUT, dsID, h3id, 'comment', ' as processed by ASPEN software V.3.4.4 (config: research-dropsonde) & multiplied by a factor of '+strmid(strtrim(string(factor(f)),2),0,5)+' to correct for the ageing of the sensor as described by  George et al. (2021) to reach the saturation level of 100% inside clouds'
	NCDF_ATTPUT, dsID, h3id, '_FillValue', -999.0
h4id = NCDF_VARDEF(dsID, 'RHum_recon_corr', [zid], /FLOAT)
	NCDF_ATTPUT, dsID, h4id, 'long_name', 'Relative humidity reconstructed and corrected'
	NCDF_ATTPUT, dsID, h4id, 'units', '%'
	NCDF_ATTPUT, dsID, h4id, 'comment', ' reconstructed relative humidity following Miloshevich et al. (2004) with tau=1.6 sek & multiplied by a factor of '+strmid(strtrim(string(factor(f)),2),0,5)+' to correct for the ageing of the sensor as described by  George et al. (2021) to reach the saturation level of 100% inside clouds'
	NCDF_ATTPUT, dsID, h4id, '_FillValue', -999.0
	
	
if drop_day eq 1 then begin
NCDF_ATTPUT, fileID, /GLOBAL, 'Title', 'Dropsonde Measurements of MOSAiC ACA-S campaign'
;NCDF_ATTPUT, fileID, /GLOBAL, 'Research_Flight_Number', long(flight_nr(d))
NCDF_ATTPUT, fileID, /GLOBAL, 'Flight on Day', jjjj+' '+mo+' '+da
NCDF_ATTPUT, fileID, /GLOBAL, 'Total_dropsondes_of_flight', long(total_drops(d))
NCDF_ATTPUT, fileID, /GLOBAL, 'Comment', 'The relative humidity was corrected for the ageing of the sensor as described by George et al. (2021) to reach the saturation level of 100% inside clouds. The correction factor was determined individually for all dropsondes and was about 1.025 for the majority of sondes.'
endif

NCDF_ATTPUT, dsID, /GLOBAL,  'Dropsonde_number_of_flight', long(drop_day)
NCDF_ATTPUT, dsID, /GLOBAL,  'Launch_Time_UTC', launch_time
NCDF_ATTPUT, dsID, /GLOBAL,  'Sonde_ID', sond_id






; Put file in data mode:
NCDF_CONTROL, fileID, /ENDEF


NCDF_VARPUT, dsID, a1id, reform(data(2,*))
NCDF_VARPUT, dsID, a2id, reform(data(1,*))
NCDF_VARPUT, dsID, timeid, reform(data(0,*))
NCDF_VARPUT, dsID, latid, reform(data(4,*))
NCDF_VARPUT, dsID, lonid, reform(data(3,*))
NCDF_VARPUT, dsID, pid, reform(data(5,*))
NCDF_VARPUT, dsID, t1id,  reform(data(6,*))
NCDF_VARPUT, dsID, t2id,  reform(data(7,*))
NCDF_VARPUT, dsID, h1id,  reform(data(8,*))
NCDF_VARPUT, dsID, h2id,  reform(data(9,*))
NCDF_VARPUT, dsID, wsid,  reform(data(10,*))
NCDF_VARPUT, dsID, wdid,  reform(data(11,*))
NCDF_VARPUT, dsID, h3id,  reform(data(12,*))
NCDF_VARPUT, dsID, h4id,  reform(data(13,*))


; Put file in define mode:
NCDF_CONTROL, fileID, /REDEF

endfor



NCDF_CLOSE, fileID ; Close the NetCDF file.



;;;
;;;;manual quality check...
;;;
;;;if f eq 50 then begin
;;;
;;;print,file_ds
;;;
;;;ialt=0
;;;
;;;plot,data(1,*),data(ialt,*),title='alt'  & R = GET_KBRD(1)
;;;plot,data(2,*),data(ialt,*),title='time'  & R = GET_KBRD(1)
;;;plot,data(3,*),data(ialt,*),title='lat'  & R = GET_KBRD(1)
;;;plot,data(4,*),data(ialt,*),title='lon'  & R = GET_KBRD(1)
;;;
;;;plot,data(8,*),data(ialt,*),title='p'  & R = GET_KBRD(1)
;;;plot,data(5,*),data(ialt,*),title='t1'  & R = GET_KBRD(1)
;;;plot,data(6,*),data(ialt,*),title='t2'  & R = GET_KBRD(1)
;;;plot,data(9,*),data(ialt,*),title='h1'  & R = GET_KBRD(1)
;;;plot,data(10,*),data(ialt,*),title='h2'  & R = GET_KBRD(1)
;;;
;;;plot,data(12,*),data(ialt,*),title='w'  & R = GET_KBRD(1)
;;;plot,data(13,*),data(ialt,*),title='wdir'  & R = GET_KBRD(1)
;;;
;;;endif


endfor





;;
;;d=indgen(3,/LONG)                                           ;number of required dimensions
;;;   Set Dimensions
;;d[0]=ncdf_dimdef(fid,'x',n_elements(time_sel2))
;;d[1]=ncdf_dimdef(fid,'y',n_elements(wl2))
;;d[2] = NCDF_DIMDEF(fid, 'string_length', Max(StrLen(date)))
;;
;;
;;;Define variables to be stored
;;;assign a variable id to access the writing
;;var_id_fdn=ncdf_vardef(fid,'fdn',[d[0],d[1]],/FLOAT)
;;var_id_fup=ncdf_vardef(fid,'fup',[d[0],d[1]],/FLOAT)
;;var_id_sza=ncdf_vardef(fid,'sza',[d[0]],/FLOAT)
;;var_id_time=ncdf_vardef(fid,'time',[d[0]],/FLOAT)
;;var_id_alt=ncdf_vardef(fid,'altitude',[d[0]],/short)
;;var_id_lon=ncdf_vardef(fid,'longitude',[d[0]],/FLOAT)
;;var_id_lat=ncdf_vardef(fid,'latitude',[d[0]],/FLOAT)
;;var_id_wl=ncdf_vardef(fid,'wavelength',[d[1]],/FLOAT)
;;var_id_date=ncdf_vardef(fid,'date',[d[2]],/char)




end