close,/all



;files=file_search('/projekt_agmwend/data_raw/AFLUX_raw_only/Dropsondes/tools/ASPEN/ASPEN_full/*.eol')
files=file_search('/projekt_agmwend/data_raw/MOSAiC_ACA_S/Soundings/Dropsondes/ASPEN_full/*PQC.eol')



for f=0,n_elements(files)-1 do begin

file_ds=files(f)
file_ds2=strmid(file_ds,0,91)+'.dat'


jjjj=strmid(file_ds,76,4)
mo=strmid(file_ds,80,2)
da=strmid(file_ds,82,2)
time=strmid(file_ds,85,6)

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


;if f eq 15 then index=where(data(0,*) ne 47.01) & data=data(*,index)	; times do not exist in ASPEN_without
;if f eq 35 then index=where(data(0,*) ne 39.25) & data=data(*,index)


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




for i=0,n_elements(time)-1 do begin
printf,2,time(i), time_UTC(i)*3600.,press(i),temp(i), dew(i), rh(i), wx(i),wy(i), wd(i),ws(i),dz(i),alt1(i),lon(i),lat(i),alt2(i),format='(f8.2,f12.2,9(f8.2),f9.2,2(f12.6),f9.2)'
endfor

close,2

endfor




























end