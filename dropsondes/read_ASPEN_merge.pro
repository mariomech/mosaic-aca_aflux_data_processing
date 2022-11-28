close,/all

tmax=[$
3000.,2800.,2900.,2900.,2900.,2900.,$														; 20200902a (6, 1 no GPS)
3000.,2830.,2890.,2850.,2810.,$																; 20200904a (7, 2 no launch detect -> 5)
2900.,2900.,2900.,3090.,3100.,3050.,3000.,3115.,3120.,3200.,2615.,2520.,2100.,2900.,$		; 20200907a (14)
2700.,2900.,2900.,2900.,2800.,2800.,2800.,$													; 20200908a (8, 1 no launch detect -> 7)
3500.,3500.,3400.,3536.,3600.,2885.,2800.,2760.,3150.,3400.,3750.,$ 						; 20200910a (11)
3070.,3100.,3200.,3200.,3200.,3030.,3200.,2800.,2900.,3100.,$								; 20200911a (10)
3000.,3040.,3500.,3500.,3575.,2860.,3500.$													; 20200913a (7)
]


windmax=[$
3000.,2800.,2900.,2900.,2900.,2900.,$														; 20200902a (6, 1 no GPS)
3000.,2900.,3000.,2900.,2850.,$																; 20200904a (7, 2 no launch detect -> 5)
2900.,2900.,2900.,3200.,3200.,3100.,3000.,3200.,3200.,3200.,2700.,2600.,2200.,2900.,$		; 20200907a (14)
2700.,2900.,2900.,2900.,2900.,2800.,2800.,$													; 20200908a (8, 1 no launch detect -> 7)
3500.,3500.,3400.,3500.,3600.,3000.,2800.,2900.,3200.,3400.,3800.,$							; 20200910a (11)
3200.,3100.,3200.,3200.,3200.,3100.,3200.,2800.,2900.,3100.,$								; 20200911a (10)
3000.,3100.,3500.,3500.,3700.,2900.,3500.$													; 20200913a (7)
]


factor =[$
1.035,1.03,1.025,1.045,1.015,1.0245,$														; 20200902a (6, 1 no GPS)
1.035,1.03,1.03,1.025,1.025,$																; 20200904a (7, 2 no launch detect -> 5)
1.05,1.045,1.045,1.035,1.04,1.06,1.035,1.045,1.03,1.05,1.025,1.025,1.04,1.025,$				; 20200907a (14)
1.03,1.02,1.02,1.035,1.025,1.03,1.025,$														; 20200908a (8, 1 no launch detect -> 7)
1.035,1.025,1.05,1.055,1.06,1.025,1.03,1.025,1.025,1.04,1.04,$								; 20200910a (11)
1.025,1.04,1.035,1.025,1.03,1.03,1.035,1.025,1.05,1.025,$									; 20200911a (10)
1.03,1.04,1.035,1.025,1.025,1.035,1.03$														; 20200913a (7)
]


dir1='/projekt_agmwend/data_raw/MOSAiC_ACA_S_raw/soundings/Dropsondes/ASPEN_full/'
dir2='/projekt_agmwend/data_raw/MOSAiC_ACA_S_raw/soundings/Dropsondes/ASPEN_without_time_response/'
dir3='/projekt_agmwend/data_raw/MOSAiC_ACA_S_raw/soundings/Dropsondes/ASPEN_merged/'

files=file_search(dir1,'*.dat')


for f=0,n_elements(files)-1 do begin

file_ds1=files(f)
filename=strmid(file_ds1,19,/reverse_offset)
file_ds2=dir2+filename
file_ds3=dir3+filename


print,file_ds1,f


openr,1,file_ds1
openr,2,file_ds2
openw,3,file_ds3
dummy=''
for i=0,13 do begin
	readf,1,dummy
	readf,2,dummy
	if i lt 10 then printf,3,dummy
	if i eq 4 then begin
	    index=strpos(dummy,'E')
	    if index ne -1 then lonstart=float(strmid(dummy,strpos(dummy,'E')+1,9))
	    index=strpos(dummy,'W')
	    if index ne -1 then lonstart=float(strmid(dummy,strpos(dummy,'W')+1,9))
		latstart=float(strmid(dummy,strpos(dummy,'N')+1,9))
		;stop
	endif
endfor

printf,3,'    Time_UTC GeoPoAlt   GPSALT         Lon         Lat     Press   T_Aspen    T_Milo  RH_Aspen   RH_Milo      Wspd       Dir  RH_Aspen   RH_Milo'
printf,3,'         sec        m        m         deg         deg       hPa         C         C         %         %       m/s       deg  corr   %   corr  %'
printf,3,'    --------  -------  -------  ----------  ----------   -------    ------    ------    ------   -------   -------   -------    ------   -------'

data1=fltarr(15,file_lines(file_ds1)-14)
data2=fltarr(15,file_lines(file_ds2)-14)
readf,1,data1
readf,2,data2
close,1
close,2

;create merged data set
data3=fltarr(14,n_elements(data2(0,*)))
data3(0,*)=data2(1,*)/3600.
data3(1,*)=data2(11,*)	;press altitude
data3(2,*)=data2(14,*)  ;gps altitude
data3(3,*)=data2(12,*)  ;lon
data3(4,*)=data2(13,*)	;lat
data3(5,*)=data2(2,*)	;press

data3(7,*)=data2(3,*)   ;temp with Milo

data3(9,*)=data2(5,*)   ;rh with Milo
data3(10,*)=data2(9,*)  ;wind speed
data3(11,*)=data2(8,*)	;wind dir

data3(6,*)=-999.		;temp ASPEN
data3(8,*)=-999.		;rh ASPEN
data3(12,*)=-999.
data3(13,*)=-999.

; correct rh Milo with factor
index9 = where(data3(9,*) ne -999.)
if index9(0) ne -1 then data3(13,index9)=data3(9,index9)*factor(f) else data3(13,*)=data(9,*)*factor(f)

;time for merging

;index=where(reform(data2(0,*)) eq min(data1(0,*)))
index=where(reform(data2(0,*)) eq data1(0,0))

data3(6,index(0):*)=data1(3,*)
data3(8,index(0):*)=data1(5,*)

; correct rh ASPEN with factor
index8 = where(data3(8,*) ne -999.)
if index9(0) ne -1 then data3(12,index8)=data3(8,index8)*factor(f) else data3(12,*)=data(8,*)*factor(f)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; old ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;altitude for mergin; A) using GSP altitude
;;if data2(14,0) ne -999.0 then begin
;;
;;index=where(reform(data2(14,*)) eq max(data1(14,*)))
;;
;;data3(6,index(0):*)=data1(3,*)
;;data3(8,index(0):*)=data1(5,*)
;;
;;endif
;;
;;;altitude for mergin; B) using pressure altitude
;;if data2(14,0) eq -999.0 then begin
;;
;;index=where(reform(data2(11,*)) lt max(data1(11,*)))
;;
;;adummy=max(data1(11,*))-data2(11,index(0))
;;bdummy=max(data1(11,*))-data2(11,index(0)-1)
;;
;;if abs(adummy) lt abs (bdummy) then begin
;;	data3(6,index(0):(index(0)+n_elements(index)-1))=data1(3,*)
;;	data3(8,index(0):(index(0)+n_elements(index)-1))=data1(5,*)
;;endif
;;
;;if abs(adummy) ge abs (bdummy) then begin
;;	data3(6,index(0)-1:(index(0)+n_elements(index)-1))=data1(3,*)
;;	data3(8,index(0)-1:(index(0)+n_elements(index)-1))=data1(5,*)
;;endif
;;
;;
;;endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;removing altitudes after drop for own deconvoluted profiles (Milo)

if data3(1,0) ne -999.0 then begin   ;use press altitude
	index=where(reform(data3(1,*)) gt tmax(f))
	label = 'Pressure Altitude (m)'
	h = 1
endif

if data3(1,0) eq -999.0 then begin   ;use gps altitude
	index=where(reform(data3(2,*)) gt tmax(f))
	label = 'GPS Altitude (m)'
	h = 2
endif

data3(7,index)=-999.0
data3(9,index)=-999.0
data3(13,index)=-999.0


;; Feinjustierung
;if f eq 13 then begin
;	index=where(reform(data3(1,*)) gt 3050.)
;	
;	data3(10,index)=-999.0
;	data3(11,index)=-999.0
;
;	data3(6,index)=-999.0
;	data3(7,index)=-999.0
;	data3(8,index)=-999.0
;	data3(9,index)=-999.0
;endif

;if f eq 17 then begin
;	index=where(reform(data3(1,*)) gt 2630.)
;	
;	data3(10,index)=-999.0
;	data3(11,index)=-999.0
;
;	data3(6,index)=-999.0
;	data3(7,index)=-999.0
;	data3(8,index)=-999.0
;	data3(9,index)=-999.0
;endif


white=255+256L*(255+256L*255)

; plotting

index1 = where(data3(7,*) ne -999.0)
index11 = where(data3(6,*) ne -999.0)
index2 = where(data3(9,*) ne -999.0)
index21 = where(data3(8,*) ne -999.0)
index3 = where(data3(10,*) ne -999.0)
index4 = where(data3(11,*) ne -999.0)

set_plot,'x'
;psfile = '/projekt_agmwend/data_raw/MOSAiC_ACA_S/Soundings/Dropsondes/Quicklooks/'+strmid(filename,1,15)+'_temp_rh.ps'
;set_plot,'ps'
;device,filename=psfile,xsize=10,ysize=15,/color
window,1,retain=2,xsize=600,ysize=900
loadct,13
plot, reform(data3(7,index1)),reform(data3(h,index1))/1000.,/nodata, background=white, color=0, xtitle = 'Temperature ('+string(176B)+'C)', ytitle = label, xrange=[-15,15], yrange=[0,max(reform(data3(h,*))/1000.)], xstyle=1, ystyle=1, thick=1.5, ythick=2, xthick=2, charthick=2, charsize=2, ygridstyle=1,yticklen=1.0,ytickinterval=0.2
oplot, reform(data3(6,index11)),reform(data3(h,index11)/1000.), color=0, thick=2, linestyle=2
oplot, reform(data3(7,index1)),reform(data3(h,index1)/1000.), color=0, thick=2
axis, xaxis=1,xrange=[0,110],xtitle='Relative Humidity ('+string(37B)+')',color=251020550, ystyle=1, xstyle=1, xthick=2, charthick=2, charsize=2
oplot, reform(data3(12,index21))*3./11.-15.,reform(data3(h,index21)/1000.), color=255, thick=2, linestyle=2
oplot, reform(data3(13,index2))*3./11.-15.,reform(data3(h,index2)/1000.), color=255, thick=2
oplot, reform(data3(8,index21))*3./11.-15.,reform(data3(h,index21)/1000.), color=251020550, thick=2, linestyle=2
oplot, reform(data3(9,index2))*3./11.-15.,reform(data3(h,index2)/1000.), color=251020550, thick=2
oplot, [100.*3./11.-15.,100.*3./11.-15.],[0,4000], color=0, linestyle=3, thick=2
oplot, [-15,-13], [-0.5,-0.5], color=0, thick=2,/noclip
oplot, [7,9], [-0.5,-0.5], color=0, thick=2, linestyle=2,/noclip
xyouts, -12.5, -0.52, 'Milo', color=0, charsize=2,/noclip
xyouts, 9.5, -0.52, 'ASPEN', color=0, charsize=2,/noclip
;device,/close
p=tvrd(true=1)
write_png,'/projekt_agmwend/data/MOSAiC_ACA_S/Soundings/Dropsondes/Quicklooks/'+strmid(filename,1,15)+'_temp_rh.png',p


;psfile = '/projekt_agmwend/data_raw/MOSAiC_ACA_S/Soundings/Dropsondes/Quicklooks/'+strmid(filename,1,15)+'_wind.ps'
;set_plot,'ps'
;device,filename=psfile,xsize=10,ysize=15,/color
window,2,retain=2,xsize=600,ysize=900
loadct,13
plot, reform(data3(10,index3)),reform(data3(h,index3))/1000.,/nodata, background=white, color=0, xtitle = 'Wind Speed (m/s)', ytitle = label, xrange=[0,25], yrange=[0,max(reform(data3(h,*))/1000.)], xstyle=1, ystyle=1, thick=1.5, ythick=2, xthick=2, charthick=2, charsize=2, ygridstyle=1,yticklen=1.0,ytickinterval=0.2
oplot, reform(data3(10,index3)),reform(data3(h,index3)/1000.), color=0, thick=2
axis, xaxis=1,xrange=[0,360],xtitle='Wind Direction ('+string(176B)+')', color=255, ystyle=1, xstyle=1, xthick=2, charthick=2, charsize=2
oplot, reform(data3(11,index4))*25./360.,reform(data3(h,index4)/1000.), color=255, symsize=0.5, psym=1
xyouts, -4, -0.4, 'Dropsonde '+strmid(filename,1,15), charthick=2, charsize=1.5,/noclip
;device,/close
p=tvrd(true=1)
write_png,'/projekt_agmwend/data/MOSAiC_ACA_S/Soundings/Dropsondes/Quicklooks/'+strmid(filename,1,15)+'_wind.png',p

;R = GET_KBRD(1)


;cut rh at 100% and 0%

index=where(reform(data3(8,*)) gt 100.0)
if index(0) ne -1 then data3(8,index)=100.
index=where(reform(data3(9,*)) gt 100.0)
if index(0) ne -1 then data3(9,index)=100.
index=where(reform(data3(12,*)) gt 100.0)
if index(0) ne -1 then data3(12,index)=100.
index=where(reform(data3(13,*)) gt 100.0)
if index(0) ne -1 then data3(13,index)=100.

index=where( (reform(data3(8,*)) lt 0.0) AND (reform(data3(8,*)) ne -999.0) )
if index(0) ne -1 then data3(8,index)=0.
index=where( (reform(data3(9,*)) lt 0.0) AND (reform(data3(9,*)) ne -999.0) )
if index(0) ne -1 then data3(9,index)=0.
index=where( (reform(data3(12,*)) lt 0.0) AND (reform(data3(12,*)) ne -999.0) )
if index(0) ne -1 then data3(12,index)=0.
index=where( (reform(data3(13,*)) lt 0.0) AND (reform(data3(13,*)) ne -999.0) )
if index(0) ne -1 then data3(13,index)=0.


;fill lon lat

for i=0,n_elements(data3(0,*))-1 do begin
if data3(3,i) eq -999. then begin
	if i eq 0 then begin
		data3(3,i)=lonstart
		data3(4,i)=latstart
	endif
	if i ne 0 then begin
		data3(3,i)=data3(3,i-1)
		data3(4,i)=data3(4,i-1)
	endif
endif
endfor



;index=where(data(4,*) ne -999.0)  &   data=data(*,index)





for i=0,n_elements(data3(0,*))-1 do begin
printf,3,data3(*,i),format='(f12.6,2(f9.2),2(f12.6),9(f10.2))'
endfor

close,3







endfor








exit



















end