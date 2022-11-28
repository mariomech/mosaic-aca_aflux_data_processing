@milo_minD3_smooth.pro
@milo_calc_Ua.pro

close,/all



;files=file_search('/projekt_agmwend/data_raw/AFLUX_raw_only/DROPSONDES/tools/ASPEN/ASPEN_without_time_response/*.eol')
files=file_search('/projekt_agmwend/data_raw/MOSAiC_ACA_S/Soundings/Dropsondes/ASPEN_without_time_response/*PQC.eol')


for f=0,n_elements(files)-1 do begin

file_ds=files(f)
file_ds2=strmid(file_ds,0,108)+'.dat'


jjjj=strmid(file_ds,93,4)
mo=strmid(file_ds,97,2)
da=strmid(file_ds,99,2)
time=strmid(file_ds,102,6)

openr,1,file_ds
openw,2,file_ds2
dummy=''
for i=0,13 do begin
	readf,1,dummy
	printf,2,dummy
endfor
data=fltarr(17,file_lines(file_ds)-14)
readf,1,data
close,1


data=data(*,1:*)  ;remove first line with ambient measuremetns
;;index=where(data(4,*) ne -999.0) & index=index(0)  &   data=data(*,index:*)    ;remove all -999 lines in the begin
;;
;;index=indgen(fix(n_elements(data(0,*))/2.))*2 & data=data(*,index)    ;remove every second line with empty numbers


index=where(data(4,*) ne -999.0)  &   data=data(*,index)




time=data(0,*)
time_UTC=data(1,*)+data(2,*)/60.+data(3,*)/3600.
press=data(4,*)
temp=data(5,*)
dew=data(6,*)
rh=data(7,*)
wx=data(8,*)
wy=data(9,*)
ws=data(10,*)
wd=data(11,*)
dz=data(12,*)
alt1=data(13,*)
alt2=data(16,*)
lon=data(14,*)
lat=data(15,*)


index=where(alt2 ne -999.)
if (index(0) ne -1) then begin
	alt2_dummy=alt2(index)
	time_dummy=time_UTC(index)
	alt2=interpol(alt2_dummy,time_dummy,time_UTC)
endif




;=================================================================
; temperature
;=================================================================
;	- response time 4.0 sec
;=================================================================

tau_temp=1.3;4.0

index=where(temp ne -999.)
temp_dummy=temp(index)
time_dummy=time_UTC(index)


; Milo. approach
temp_s=milo_minD3_smooth(time_dummy*3600., temp_dummy, temp_dummy-2,temp_dummy+2)
temp_m=milo_calc_Ua(time_dummy*3600.,temp_s,tau_temp)

temp_m2=interpol(temp_m,time_dummy,time_UTC)
index=where(temp eq -999.)
if (index(0) ne -1) then begin
temp_m2(index)=-999.0
endif

;=================================================================
; rel. humidity
;=================================================================
;	- response time 5.0 sec
;=================================================================

tau_rh=1.6;5.0

index=where(rh ne -999.)
rh_dummy=rh(index)
time_dummy=time_UTC(index)


;Milo. approach
rh_s=milo_minD3_smooth(time_dummy*3600., rh_dummy, rh_dummy-5,rh_dummy+5)
rh_m=milo_calc_Ua(time_dummy*3600.,rh_s,tau_rh)

rh_m2=interpol(rh_m,time_dummy,time_UTC)
index=where(rh eq -999.)
if (index(0) ne -1) then begin
rh_m2(index)=-999.0
endif




index=where(rh ne -999.)

;window,2
;plot,temp,alt2
;oplot,temp_m,alt2(index),color=2555555
;oplot,temp_m2,alt2,color=255

;window,0
;plot,rh,alt2,xrange=[0,100]
;oplot,rh_m,alt2(index),color=2555555
;oplot,rh_m2,alt2,color=255


;R = GET_KBRD(1)


for i=0,n_elements(time)-1 do begin
printf,2,time(i), time_UTC(i)*3600.,press(i),temp_m2(i), dew(i), rh_m2(i), wx(i),wy(i), wd(i),ws(i),dz(i),alt1(i),lon(i),lat(i),alt2(i),format='(f8.2,f12.2,9(f8.2),f9.2,2(f12.6),f9.2)'
endfor

close,2

endfor




























end