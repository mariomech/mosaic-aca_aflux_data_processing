;routines
@decon_rt_fast.pro
@decon_rt.pro
@Fdw_attitude_correction.pro
@solar_position/get_sza.pro
@solar_position/get_saa.pro
@solar_position/dec.pro
@solar_position/julian_day.pro
@solar_position/local_time.pro
@solar_position/refract.pro

; ---------------------------------------------
; COMMENTS 
; ---------------------------------------------

; check ini files in terms of Deconvolution settings
; => smoothing 
; => cut off frequenz 
; => tau

; if one temperature sensor fails, use the opposite one 
; => New formula: LW_Irr_up=c4*LW_Irr_up*1000.+d4 + sigma*LW_TEMP_DW^4.

; Attitude correction: The time periods for flying below/in clouds for setting the simulated direct fraction to 0 might be 
; done in a little bit more conservative way, because the clouds were often optically quite thin so a directional dependence is still given
; and pure diffuse assumption might lead to higher errors because of missing attitude correction... ??? 

; --------------------------------------------

close,/all

pi = 4.*atan(1.)
sigma = 5.67E-8

data_dir = '/projekt_agmwend/data/MOSAiC_ACA_S/Flight_'
data_raw_dir = '/projekt_agmwend/data_raw/MOSAiC_ACA_S_raw/Flight_'
ini_file='/projekt_agmwend/data/MOSAiC_ACA_S/00_tools/02_BBR/P5_BBR_20Hz_ACA_S.ini'


; ---------------------------------------------
; read ini-file
; ---------------------------------------------

openr,1,ini_file
dummy=''
for i=0,file_lines(ini_file)-1 do begin
readf,1,dummy
dummy2=strsplit(dummy,' ',/extract)
if dummy2(0) eq "aircraft" then aircraft=dummy2(1)
if dummy2(0) eq "roll_offset" then roll_offset=float(dummy2(1))
if dummy2(0) eq "pitch_offset" then pitch_offset=float(dummy2(1))

if dummy2(0) eq "Pyrano_Fdw_tau" then sw_Fdw_tau=float(dummy2(1))
if dummy2(0) eq "Pyrano_Fup_tau" then sw_Fup_tau=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fdw_tau" then lw_Fdw_tau=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fup_tau" then lw_Fup_tau=float(dummy2(1))

if dummy2(0) eq "Pyrano_Fdw_fcut" then sw_Fdw_fcut=float(dummy2(1))
if dummy2(0) eq "Pyrano_Fup_fcut" then sw_Fup_fcut=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fdw_fcut" then lw_Fdw_fcut=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fup_fcut" then lw_Fup_fcut=float(dummy2(1))

if dummy2(0) eq "Pyrano_Fdw_smooth" then sw_Fdw_smooth=float(dummy2(1))
if dummy2(0) eq "Pyrano_Fup_smooth" then sw_Fup_smooth=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fdw_smooth" then lw_Fdw_smooth=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fup_smooth" then lw_Fup_smooth=float(dummy2(1))

if dummy2(0) eq "Pyrano_Fdw_coeff_c" then sw_dw_c=float(dummy2(1))
if dummy2(0) eq "Pyrano_Fup_coeff_c" then sw_up_c=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fdw_coeff_c" then lw_dw_c=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fup_coeff_c" then lw_up_c=float(dummy2(1))

if dummy2(0) eq "Pyrano_Fdw_coeff_d" then sw_dw_d=float(dummy2(1))
if dummy2(0) eq "Pyrano_Fup_coeff_d" then sw_up_d=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fdw_coeff_d" then lw_dw_d=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fup_coeff_d" then lw_up_d=float(dummy2(1))

if dummy2(0) eq "Pyrano_Fdw_Thermistor_coeff_a" then sw_dw_a=float(dummy2(1))
if dummy2(0) eq "Pyrano_Fup_Thermistor_coeff_a" then sw_up_a=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fdw_Thermistor_coeff_a" then lw_dw_a=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fup_Thermistor_coeff_a" then lw_up_a=float(dummy2(1))

if dummy2(0) eq "Pyrano_Fdw_Thermistor_coeff_b" then sw_dw_b=float(dummy2(1))
if dummy2(0) eq "Pyrano_Fup_Thermistor_coeff_b" then sw_up_b=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fdw_Thermistor_coeff_b" then lw_dw_b=float(dummy2(1))
if dummy2(0) eq "Pyrgeo_Fup_Thermistor_coeff_b" then lw_up_b=float(dummy2(1))

if dummy2(0) eq "col_SW_temp_up" then col_SW_temp_up=float(dummy2(1))
if dummy2(0) eq "col_SW_temp_dw" then col_SW_temp_dw=float(dummy2(1))
if dummy2(0) eq "col_LW_temp_up" then col_LW_temp_up=float(dummy2(1))
if dummy2(0) eq "col_LW_temp_dw" then col_LW_temp_dw=float(dummy2(1))

if dummy2(0) eq "col_SW_Irr_up" then col_SW_Irr_up=float(dummy2(1))
if dummy2(0) eq "col_SW_Irr_dw" then col_SW_Irr_dw=float(dummy2(1))
if dummy2(0) eq "col_LW_Irr_up" then col_LW_Irr_up=float(dummy2(1))
if dummy2(0) eq "col_LW_Irr_dw" then col_LW_Irr_dw=float(dummy2(1))



endfor
close,1

flights = [$
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

for f=0,n_elements(flights)-1 do begin ; loop over all flights
	print,flights(f)
	; check if there were invalid flights
	;if (flights(f) eq '120417a' or flights(f) eq '120421a') then continue
	
	data_out_dir = '/projekt_agmwend/data/MOSAiC_ACA_S/Flight_'+flights(f)+'/BBR/'


	; ---------------------------------------------
	; read pyranometer and pyrgeometer data
	; ---------------------------------------------
	print,'read Pyranometer and Pyrgeometer data'
	
	bbr_file = data_raw_dir+flights(f)+'/BBR/BBR_20Hz_P5_'+flights(f)+'_raw.dat'
	openr,1,bbr_file
	dummy=''
	for i=0,3 do readf,1,dummy
	bbr_data = fltarr(14,file_lines(bbr_file)-4)
	readf,1,bbr_data
	close,1
	
	sod = bbr_data(3,*)*3600.+bbr_data(4,*)*60+bbr_data(5,*)
	
	Fdw_sw = bbr_data(col_SW_Irr_dw,*)
	Fup_sw = bbr_data(col_SW_Irr_up,*)
	Fdw_lw = bbr_data(col_LW_Irr_dw,*)
	Fup_lw = bbr_data(col_LW_Irr_up,*)
	
	Temp_dw_sw = bbr_data(col_SW_temp_dw,*)
	Temp_up_sw = bbr_data(col_SW_temp_up,*)
	Temp_dw_lw = bbr_data(col_LW_temp_dw,*)
	Temp_up_lw = bbr_data(col_LW_temp_up,*)
	

	index1=where(Fdw_sw eq 999999999.999999)
	index2=where(Fdw_sw ne 999999999.999999)
	if index1(0) ne -1 then Fdw_sw(index1) = interpol(Fdw_sw(index2),sod(index2),sod(index1))

	index3=where(Fup_sw eq 999999999.999999)
	index4=where(Fup_sw ne 999999999.999999)
	if index3(0) ne -1 then Fup_sw(index3) = interpol(Fup_sw(index4),sod(index4),sod(index3))
	
	index5=where(Fdw_lw eq 999999999.999999)
	index6=where(Fdw_lw ne 999999999.999999)
	if index5(0) ne -1 then Fdw_lw(index5) = interpol(Fdw_lw(index6),sod(index6),sod(index5))

	index7=where(Fup_lw eq 999999999.999999)
	index8=where(Fup_lw ne 999999999.999999)
	if index7(0) ne -1 then Fup_lw(index7) = interpol(Fup_lw(index8),sod(index8),sod(index7))
	
	; extraction of electronic peaks and set them to mean value of irradiance
	if max(Fdw_sw) gt 0.04 then Fdw_sw[where(Fdw_sw gt 0.02)] = mean(Fdw_sw[where(Fdw_sw lt 0.02)])
	if max(Fup_sw) gt 0.04 then Fup_sw[where(Fup_sw gt 0.02)] = mean(Fup_sw[where(Fup_sw lt 0.02)])
	if max(Fdw_lw) gt 0.04 then Fdw_lw[where(Fdw_lw gt 0.02)] = mean(Fdw_lw[where(Fdw_lw lt 0.02)])
	if max(Fup_lw) gt 0.04 then Fup_lw[where(Fup_lw gt 0.02)] = mean(Fup_lw[where(Fup_lw lt 0.02)])
		
	; inertia correction and calibration
	print,'Inertia correction and calibration'
	
	Fdw_sw = decon_rt_fast(Fdw_sw,sod,sw_Fdw_tau,sw_Fdw_fcut,sw_Fdw_smooth,0.05)
	Fup_sw = decon_rt_fast(Fup_sw,sod,sw_Fup_tau,sw_Fup_fcut,sw_Fup_smooth,0.05)
	Fdw_lw = decon_rt_fast(Fdw_lw,sod,lw_Fdw_tau,lw_Fdw_fcut,lw_Fdw_smooth,0.05)
	Fup_lw = decon_rt_fast(Fup_lw,sod,lw_Fup_tau,lw_Fup_fcut,lw_Fup_smooth,0.05)
	
	Temp_dw_sw = (-sw_dw_a + sqrt(sw_dw_a^2-4.*sw_dw_b*((-Temp_dw_sw/100.)+1.)))/(2.*sw_dw_b) + 273.15
	Temp_up_sw = (-sw_up_a + sqrt(sw_up_a^2-4.*sw_up_b*((-Temp_up_sw/100.)+1.)))/(2.*sw_up_b) + 273.15
	Temp_dw_lw = (-lw_dw_a + sqrt(lw_dw_a^2-4.*lw_dw_b*((-Temp_dw_lw/100.)+1.)))/(2.*lw_dw_b) + 273.15
	Temp_up_lw = (-lw_up_a + sqrt(lw_up_a^2-4.*lw_up_b*((-Temp_up_lw/100.)+1.)))/(2.*lw_up_b) + 273.15
	
	Fdw_sw = sw_dw_c*Fdw_sw*1000.+sw_dw_d
	Fup_sw = sw_up_c*Fup_sw*1000.+sw_up_d
	Fdw_lw = lw_dw_c*Fdw_lw*1000.+lw_dw_d + sigma*Temp_dw_lw^4
	Fup_lw = lw_up_c*Fup_lw*1000.+lw_up_d + sigma*Temp_up_lw^4
	
	BT_dw_lw = (Fdw_lw/sigma)^(0.25) - 273.15
	BT_up_lw = (Fup_lw/sigma)^(0.25) - 273.15
	
	;set missing values to -9999.
	Fdw_sw(index1) = -9999.
	Fup_sw(index3) = -9999.
	Fdw_lw(index5) = -9999.
	Fup_lw(index7) = -9999.
	
	; ---------------------------------------------
	; read KT19 data
	; ---------------------------------------------
	print,'read KT19 data, calibrate and interpolate'
	
	KT19_file = data_raw_dir+flights(f)+'/KT19/Data_P5_KT19_'+flights(f)+'_raw.dat'
	openr,1,KT19_file
	dummy=''
	for i=0,3 do readf,1,dummy
	KT19_data = fltarr(7,file_lines(KT19_file)-4)
	readf,1,KT19_data
	close,1
	
	KT19_time = KT19_data(3,*)*3600.+kt19_data(4,*)*60+kt19_data(5,*)
	KT19_temp = KT19_data(6,*)
	
	; calibration and interpolation
	KT19_temp = KT19_temp*1000.*6.25-75D
	KT19_temp = interpol(KT19_temp,KT19_time,sod)
	KT19_temp(where(KT19_temp le -70.)) = -9999.
	
	; ---------------------------------------------
	; read GPS and INS data
	; ---------------------------------------------
	print,'read GPS and INS data and interpolate'
	
	GPS_file = data_raw_dir+flights(f)+'/AWI_nav/Data_GPS_P5_'+flights(f)+'.dat'
	dummy=''
	openr,1,GPS_file
	for i=0,3 do begin
		readf,1,dummy
	endfor
	GPS_data_raw = strarr(1,file_lines(gps_file)-4)
	readf,1,GPS_data_raw
	close,1
	GPS_data =strarr(13,n_elements(GPS_data_raw[0,*]))
	for y=0,n_elements(GPS_data_raw[0,*])-1 do begin
		GPS_data[*,y] = strsplit(GPS_data_raw[0,y],/extract)
	endfor
	
	INS_file = data_raw_dir+flights(f)+'/AWI_nav/Data_INS_P5_'+flights(f)+'.dat'
	openr,1,INS_file
	dummy=''
	for i=0,3 do readf,1,dummy
	INS_data = fltarr(13,file_lines(INS_file)-4)
	readf,1,INS_data
	close,1
	
	INS2_file = data_raw_dir+flights(f)+'/horidata/Polar5_'+flights(f)+'.nav'	; INS SMART to replace bad roll, pitch, yaw values from INS
	openr,1,INS2_file
	dummy=''
	for i=0,2 do readf,1,dummy
	INS_data2 = fltarr(10,file_lines(INS2_file)-3)
	readf,1,INS_data2
	close,1
	
	time_GPS = float(GPS_data(3,*))*3600 + float(GPS_data(4,*))*60. +float(GPS_data(5,*))
	alt_GPS = float(GPS_data(10,*))
	lon_GPS = floor(float(GPS_data(6,*))/100.) + ( (float(GPS_data(6,*))/100.) - floor(float(GPS_data(6,*))/100.) )/0.6
	lat_GPS = floor(float(GPS_data(8,*))/100.) + ( (float(GPS_data(8,*))/100.) - floor(float(GPS_data(8,*))/100.) )/0.6
	lon_dir = GPS_data(7,*)
	lat_dir = GPS_data(9,*)
	for y=0,n_elements(lat_dir)-1 do begin
		if lon_dir(y) eq 'W' then lon_GPS(y) = -lon_GPS(y)
		if lat_dir(y) eq 'S' then lat_GPS(y) = -lat_GPS(y)
	endfor
	
	time_INS = INS_data(3,*)*3600. + INS_data(4,*)*60. + INS_data(5,*)
	lat_INS = INS_data(8,*)
	lon_INS = INS_data(9,*)
	roll = INS_data(10,*)
	pitch = -INS_data(11,*)
	yaw = INS_data(12,*)
	
	index = where(yaw lt 0.)
	yaw(index) = yaw(index) + 360.
	
	time_INS2 = INS_data2(0,*)*3600
	lat_INS2 = INS_data2(2,*)
	lon_INS2 = INS_data2(1,*)
	alt_INS2 = INS_data2(3,*)
	roll2 = INS_data2(6,*)
	pitch2 =INS_data2(5,*)
	yaw2 = INS_data2(7,*)
	sza = INS_data2(8,*)
	saa = INS_data2(9,*)
	
	yaw2 = 90.-yaw2
	index = where(yaw2 lt 0.)
	yaw2(index) = yaw2(index) + 360.
	
	; interpolation
	
	lon_GPS = interpol(lon_GPS,time_GPS,sod)
	lat_GPS = interpol(lat_GPS,time_GPS,sod)
	alt_GPS = interpol(alt_GPS,time_GPS,sod)
	
	lat_INS = interpol(lat_INS,time_INS,sod)
	lon_INS = interpol(lon_INS,time_INS,sod)
	roll = interpol(roll,time_INS,sod)
	pitch = interpol(pitch,time_INS,sod)
	yaw = interpol(yaw,time_INS,sod)
	
	lat_INS2 = interpol(lat_INS2,time_INS2,sod)
	lon_INS2 = interpol(lon_INS2,time_INS2,sod)
	roll2 = interpol(roll2,time_INS2,sod)
	pitch2 = interpol(pitch2,time_INS2,sod)
	yaw2 = interpol(yaw2,time_INS2,sod)
	sza = interpol(sza,time_INS2,sod)
	saa = interpol(saa,time_INS2,sod)
	
	; merge INS data
	
	index=where(roll gt 25.)
	if index(0) ne -1 then roll(index) = roll2(index)+0.59
	index=where(pitch lt -15.)
	if index(0) ne -1 then pitch(index) = pitch2(index)
	index=where(yaw gt 360.)
	if index(0) ne -1 then yaw(index) = yaw2(index)
	
	; ---------------------------------------------
	; read lon/lat from Meteo data
	; ---------------------------------------------
	print,'read Meteo Data'

	Meteo_file = data_dir+flights(f)+'/Meteo/Flight_'+flights(f)+'_1s.asc'
	Meteo = read_ascii(Meteo_file, data_start=1)
	
	time_Meteo = reform(Meteo.(0)(0,*))
	alt_Meteo = reform(Meteo.(0)(1,*))
	lon_Meteo = reform(Meteo.(0)(2,*))
	lat_Meteo = reform(Meteo.(0)(3,*))
	pitch3 = -reform(Meteo.(0)(6,*))
	roll3 = reform(Meteo.(0)(7,*))
	
	alt_Meteo = interpol(alt_Meteo,time_Meteo,sod)
	lon_Meteo = interpol(lon_Meteo,time_Meteo,sod)
	lat_Meteo = interpol(lat_Meteo,time_Meteo,sod)
	pitch3 = interpol(pitch3,time_Meteo,sod)
	roll3 = interpol(roll3,time_Meteo,sod)
	
	; ---------------------------------------------
	; read simulation data
	; ---------------------------------------------
	print,'read simulation data (Fdw_cs and f_dir) and interpolate'
	
	; read direct fraction
	f_dir_file = data_dir+flights(f)+'/BBR/P5_BBR_DirectFraction_Flight_'+flights(f)+'_R0.dat'
	openr,1,f_dir_file
	dummy=''
	for i=0,35 do readf,1,dummy
	f_dir_data = fltarr(4,file_lines(f_dir_file)-36)
	readf,1,f_dir_data
	close,1
	
	; read simulated clear sky Fdw_sw
	Fdw_cs_file = data_dir+flights(f)+'/BBR/P5_BBR_Fdn_clear_sky_Flight_'+flights(f)+'_R0.dat'
	openr,1,Fdw_cs_file
	dummy=''
	for i=0,35 do readf,1,dummy
	Fdw_cs_data = fltarr(4,file_lines(Fdw_cs_file)-36)
	readf,1,Fdw_cs_data
	close,1
	
	time_f_dir = f_dir_data(0,*)
	f_dir = f_dir_data(3,*)
	
	time_Fdw_cs = Fdw_cs_data(0,*)
	Fdw_cs = Fdw_cs_data(3,*)
	
	; interpolation
	f_dir = interpol(f_dir,time_f_dir,sod)
	Fdw_cs = interpol(Fdw_cs,time_Fdw_cs,sod)


	; ---------------------------------------------
	; calculate solar zenith and azimuth angles
	; ---------------------------------------------
	print,'calculate solar zenith and azimuth angles'
	
	sza = fltarr(n_elements(sod))
	saa = fltarr(n_elements(sod))

	yy = fix(strmid(flights(f),0,4))
	mo = fix(strmid(flights(f),4,2))
	dd = fix(strmid(flights(f),6,2))
	
	for i=0L,n_elements(sod)-1 do begin
		sza(i) = get_sza(sod(i)/3600.,lat_Meteo(i),lon_Meteo(i),yy,mo,dd,1020,-10)
		saa(i) = get_saa(sod(i)/3600.,lat_Meteo(i),lon_Meteo(i),yy,mo,dd)
	endfor

	; ---------------------------------------------
	; correct Fdw_sw for aircraft attitude
	; ---------------------------------------------
	print,'correct Fdw_sw for aircraft attitude'
	
	time = sod/3600.
	
	; change direct fraction for flights below/inside clouds to 0 -> flight protocols, quicklooks
	;index=0
	
	if flights(f) eq '20200830a' then index=where((time lt 8.72) OR (time gt 8.74))
	if flights(f) eq '20200831a' then index=where(((time gt 10.29) AND (time lt 10.40)) OR ((time gt 10.42) AND (time lt 10.49)) OR ((time gt 10.52) AND (time lt 10.64)) OR ((time gt 10.645) AND (time lt 10.65)) OR ((time gt 10.66) AND (time lt 10.76)) OR (time gt 10.77))
	if flights(f) eq '20200831b' then index=where((time lt 13.63) OR ((time gt 13.76) AND (time lt 13.775)) OR ((time gt 13.79) AND (time lt 13.805)) OR ((time gt 14.085) AND (time lt 14.10)) OR ((time gt 14.35) AND (time lt 14.37)) OR ((time gt 14.55) AND (time lt 14.615)) OR (time gt 14.70))
	if flights(f) eq '20200902a' then index=where((time lt 7.16) OR ((time gt 7.205) AND (time lt 7.23)) OR ((time gt 8.66) AND (time lt 8.70)) OR ((time gt 9.025) AND (time lt 9.085)) OR ((time gt 9.095) AND (time lt 9.27)) OR ((time gt 9.34) AND (time lt 9.56)) OR  ((time gt 11.70) AND (time lt 11.74)) OR (time gt 11.77))
	if flights(f) eq '20200904a' then index=where((time lt 12.29) OR ((time gt 13.11) AND (time lt 13.36)) OR ((time gt 13.43) AND (time lt 13.445)) OR ((time gt 14.34) AND (14.715)) OR ((14.75) AND (time lt 15.67)) OR ((time gt 15.71) AND (time lt 12.75)) OR ((time gt 15.77) AND (time lt 15.96)) OR (time gt 16.40))
	if flights(f) eq '20200907a' then index=where((time lt 8.47) OR ((time gt 10.85) AND (time lt 11.00)) OR ((time gt 11.20) AND (time lt 12.41)) OR ((time gt 13.925) AND (time lt 13.98)) OR (time gt 13.99))
	if flights(f) eq '20200908a' then index=where(((time gt 9.98) AND (time lt 11.00)) OR ((time gt 11.05) AND (time lt 12.59)) OR ((time gt 12.95) AND (time lt 13.70)))
	if flights(f) eq '20200910a' then index=where(((time gt 8.51) AND (time lt 8.63)) OR ((time gt 8.64) AND (time lt 8.65)) OR ((time gt 8.66) AND (time lt 8.685)) OR ((time gt 8.705) AND (time lt 9.00)) OR ((time gt 10.09) AND (time lt 10.94)) OR ((time gt 11.02) AND (time lt 11.11)) OR ((time gt 11.23) AND (time lt 11.335)) OR ((time gt 11.73) AND (time lt 11.89)) OR ((time gt 11.925) AND (time lt 12.30)) OR ((time gt 12.33) AND (time lt 12.67)) OR ((time gt 12.72) AND (time lt 13.05)) OR ((time gt 13.09) AND (time lt 13.33)) OR ((time gt 13.925) AND (time lt 13.98)) OR (time gt 14.425))
	if flights(f) eq '20200911a' then index=where((time lt 8.47) OR ((time gt 9.59) AND (time lt 11.5790)) OR ((time gt 11.6100) AND (time lt 11.6300)) OR ((time gt 11.6530) AND (time lt 11.6700)) OR ((time gt 11.7000) AND (time lt 11.7215)) OR ((time gt 11.7425) AND (time lt 11.7840)) OR ((time gt 11.8315) AND (time lt 11.8910)) OR ((time gt 11.9070) AND (time lt 11.9540)) OR ((time gt 12.0040) AND (time lt 12.91)) OR ((time gt 13.775) AND (time lt 12.787)) OR ((time gt 13.80) AND (time lt 13.82)) OR (time gt 13.92))
	if flights(f) eq '20200913a' then index=where((time lt 9.42) OR ((time gt 9.48) AND (time lt 9.65)) OR ((time gt 10.26) AND (time lt 10.28)) OR ((time gt 10.97) AND (time lt 11.01)) OR ((time gt 11.22) AND (time lt 11.87)) OR ((time gt 11.89) AND (time lt 12.4500)) OR ((time gt 12.4755) AND (time lt 12.715)) OR ((time gt 12.80) AND (time lt 12.84)) OR ((time gt 12.88) AND (time lt 12.98)) OR ((time gt 13.05) AND (time lt 14.02)) OR ((time gt 14.13) AND (time lt 14.19)) OR ((time gt 14.215) AND (time lt 14.225)) OR ((time gt 14.23) AND (time lt 14.69)) OR (time gt 14.98))
	
	f_dir2 = f_dir
	f_dir(index)=0.0

	Fdw_sw1 = Fdw_sw
	Fdw_sw2 = Fdw_sw
	for i=0L,n_elements(sod)-1 do begin
		Fdw_sw(i) = Fdw_attitude_correction(Fdw_sw1(i),roll(i),pitch(i),yaw(i),sza(i),saa(i),roll_offset,pitch_offset,f_dir(i))
		Fdw_sw2(i) = Fdw_attitude_correction(Fdw_sw1(i),roll(i),pitch(i),yaw(i),sza(i),saa(i),roll_offset,pitch_offset,f_dir2(i))
	endfor
	
	; filter out unrealistic values
	Fdw_sw([index1,where(Fdw_sw le 0. or Fdw_sw gt 1000.)]) = -9999.
	Fdw_sw1([index1,where(Fdw_sw1 le 0. or Fdw_sw1 gt 1000.)]) = -9999.
	Fdw_sw2([index1,where(Fdw_sw2 le 0. or Fdw_sw2 gt 1000.)]) = -9999.
	
	; ---------------------------------------------
	; write data
	; ---------------------------------------------
	print,'write data to output file'
	
	output_file = data_out_dir+'BBR_P5_'+flights(f)+'_R0.dat'
	openw,1,output_file
	printf,1,'41 1001'
	printf,1,'Ehrlich, Andre'
	printf,1,'Leipzig Institute for Meteorology (LIM), Leipzig University'
	printf,1,'1 | Polar 5 | BBR'
	printf,1,'MOSAiC ACA-S Flight '+flights(f)+''
	printf,1,'2020 '+strmid(flights(f),4,2)+' '+strmid(flights(f),6,2)+''
	printf,1,'0.0'
	printf,1,'SOD: seconds of day (number of seconds from 0000 UTC)'
	printf,1,'1 1'
	printf,1,'1. 1. 1. 1. 1. 1. 1. 1. 1. 1. 1. 1.'
	printf,1,'-9999. -9999. -9999. -9999. -9999. -9999. -9999. -9999. -9999. -9999. -9999. -9999.'
	printf,1,'Lat: latitude (deg)'
	printf,1,'Lon: longitude (deg)'
	printf,1,'Alt: altitude (m)'
	printf,1,'SZA: solar zenith angle (deg)'
	printf,1,'SAA: solar azimuth angle (deg) (0 deg North)'
	printf,1,'F_dw_sw: solar (shortwave) downward irradiance (W m^-2), pyranometer 0.2-3.6 um'
	printf,1,'F_uw_sw: solar (shortwave) upward irradiance (W m^-2), pyranometer 0.2-3.6 um'
	printf,1,'F_dw_lw: terrestrial (longwave) downward irradiance (W m^-2), pyrgeometer 4.5-42.0 um'
	printf,1,'F_uw_lw: terrestrial (longwave) upward irradiance (W m^-2), pyrgeometer 4.5-42.0 um'
	printf,1,'Temp_KT-19: nadir brightness temperature (deg C), KT19 9.6-11.5 um'
	printf,1,'F_dw_sw_uncorr: shortwave downward irradiance (W m^-2) not corrected for aircraft attitude'
	printf,1,'F_dw_sw_fullcorr: shortwave downward irradiance (W m^-2) corrected for aircraft attitude for all illumination conditions'
	printf,1,'1'
	printf,1,'Special comments: None.'
	printf,1,'PROJECT_INFO: MOSAiC ACA-S campaign, Longyearbyen, Svalbard, Norway, Aug/Sept 2020'
	printf,1,'PLATFORM: AWI research aircraft POLAR 5'
	printf,1,'LOCATION: given in data'
	printf,1,'ASSOCIATED_DATA: none'
	printf,1,'INSTRUMENT_INFO: Kipp&Zonen Pyranometer CMP22 and Pyrgeometer CGR4, Heitronics KT19.85II'
	printf,1,'DATA_INFO: 20 Hz data! Units given in column descriptions above.'
	printf,1,'DATA_INFO: Solar downward irradiance (F_dw_sw) is corrected for aircraft attitude in case of direct solar illumination. But not screened for icing!'
	printf,1,'DATA_INFO: All irradiances are deconvoluted for their interia time (pyranometer: 1.4s, pyrgeometer: 3.6s).'
	printf,1,'UNCERTAINTY: For radiation quantities: < 10 W m^-2, Brightness temperature < 1 K'
	printf,1,'DM_CONTACT_INFO: Andre Ehrlich, LIM, Leipzig University. Email: a.ehrlich@uni-leipzig.de'
	printf,1,'PI_CONTACT_INFO: Address: LIM, Stephanstr.3, 04103 Leipzig, Germany. a.ehrlich@uni-leipzig.de'
	printf,1,'STIPULATIONS_ON_USE: Use of these data requires prior OK from the PI. The MOSAiC Data Protocol applies.'
	printf,1,'OTHER_COMMENTS: none'
	printf,1,'RENIRION: R0'
	printf,1,'R0: No comments.'
	printf,1,'SOD               Lat          Lon          Alt          SZA          SAA      F_dw_sw      F_uw_sw      F_dw_lw      F_uw_lw   Temp KT-19   F_dw_sw_uncorr F_dw_sw_fullcorr'
	for i=0L,n_elements(sod)-1 do begin
		printf,1, sod(i), lat_Meteo(i), lon_Meteo(i), alt_GPS(i), sza(i), saa(i), Fdw_sw(i), Fup_sw(i), Fdw_lw(i), Fup_lw(i), KT19_temp(i), Fdw_sw1(i), Fdw_sw2(i), format='((f8.2),12(" ",f12.5))'
	endfor
	close,1


white=255+256L*(255+256L*255)
black=0
	set_plot,'x'
	; ---------------------------------------------
	; plot SW uncoor, corr and clear sky simulated
	; ---------------------------------------------
	;psfile = data_out_dir+'BBR_P5_SW_Fdw_'+flights(f)+'.ps'
	;set_plot,'ps'
	;device,filename=psfile,xsize=15,ysize=10,/color
	window,1,retain=2
	loadct,39
	plot, time, Fdw_sw1, /nodata, color=0, background=white, xtitle = 'Time (UTC)', ytitle = 'Shortwave Downward Irradiance (W m!E-2!N)', xrange=[min(time),max(time)], yrange=[0,1000], xstyle=1, ystyle=1, thick=1.5, ythick=2, xthick=2, charthick=2, charsize=2.0
	oplot, time, Fdw_sw1, color=0, psym=3, thick=1.5
	oplot, time, Fdw_sw, color=255,psym=3, thick=1.5
	oplot, time, Fdw_cs, color=255550,psym=3, thick=1.5
	sa = (max(time) - min(time))
	sb = min(time)
	oplot, [0.02*sa+sb,0.1*sa+sb], [1030,1030], color=0, thick=2,/noclip
	oplot, [0.32*sa+sb,0.4*sa+sb], [1030,1030], color=255, thick=2,/noclip
	oplot, [0.02*sa+sb,0.1*sa+sb], [1090,1090], color=255550, thick=2,/noclip
	oplot, [0.72*sa+sb,0.8*sa+sb], [1030,1030], color=2200000, thick=2,/noclip
	xyouts, 0.11*sa+sb, 1018, 'uncorrected', charsize=2.0, color=0,/noclip
	xyouts, 0.41*sa+sb, 1018, 'corrected', charsize=2.0, color=0,/noclip
	xyouts, 0.11*sa+sb, 1078, 'clear sky simulated', charsize=2.0, color=0,/noclip
	xyouts, 0.81*sa+sb, 1018, 'Altitude', charsize=2.0, color=0,/noclip
	axis,max(time),yaxis=1,xrange=[min(time),max(time)],yrange=[0.0,4.],ytitle='Altitude (km)',color=0, ystyle=1, xstyle=1, ythick=2, charthick=2, charsize=2.0
	oplot, time, alt_GPS/4000.*1000., color=2200000,psym=3, thick=1.5,/noclip
	xyouts, 0.02*sa+sb, 1150, 'P5 Flight '+flights(f), charthick=2, charsize=1.4,/noclip
	;device,/close
	p=tvrd(true=1)
	write_png,data_out_dir+'BBR_P5_SW_Fdw_'+flights(f)+'.png',p
	;write_png,'/projekt_agmwend/home_rad/Sebastian/BBR/MOSAiC_Airborne/Quicklook_MOSAiC/BBR_P5_SW_Fdw_'+flights(f)+'.png',p
	; ---------------------------------------------
	; plot all
	; ---------------------------------------------
	;psfile = data_out_dir+'BBR_P5_all_'+flights(f)+'.ps'
	;set_plot,'ps'
	;device,filename=psfile,xsize=15,ysize=10,/color
	window,2,retain=2
	loadct,39
	plot, time, Fup_sw, /nodata, color=0, background=white, xtitle = 'Time (UTC)', ytitle = 'Broadband Irradiance (W m!E-2!N)', xrange=[min(time),max(time)], yrange=[0,1000], xstyle=1, ystyle=1, thick=1.5, ythick=2, xthick=2, charthick=2, charsize=2.0
	oplot, time, Fup_sw, psym=3, color=0, thick=1.5
	oplot, time, Fdw_sw, psym=3, color=255550, thick=1.5
	oplot, time, Fup_lw, psym=3, color=251020550, thick=1.5
	oplot, time, Fdw_lw, psym=3, color=255, thick=1.5
	sa = (max(time) - min(time))
	sb = min(time)
	oplot, [0.02*sa+sb,0.1*sa+sb], [1030,1030], color=0, thick=2,/noclip
	oplot, [0.32*sa+sb,0.4*sa+sb], [1030,1030], color=251020550, thick=2,/noclip
	oplot, [0.02*sa+sb,0.1*sa+sb], [1090,1090], color=255550, thick=2,/noclip
	oplot, [0.32*sa+sb,0.4*sa+sb], [1090,1090], color=255, thick=2,/noclip
	oplot, [0.72*sa+sb,0.8*sa+sb], [1030,1030], color=2200000, thick=2,/noclip
	xyouts, 0.11*sa+sb, 1018, 'SW upward', charsize=2.0, color=0,/noclip
	xyouts, 0.41*sa+sb, 1018, 'LW upward', charsize=2.0, color=0,/noclip
	xyouts, 0.11*sa+sb, 1078, 'SW downward', charsize=2.0, color=0,/noclip
	xyouts, 0.41*sa+sb, 1078, 'LW downward', charsize=2.0, color=0,/noclip
	xyouts, 0.81*sa+sb, 1018, 'Altitude', charsize=2.0, color=0,/noclip
	axis,max(time),yaxis=1,xrange=[min(time),max(time)],yrange=[0.0,4.],ytitle='Altitude (km)',color=0, ystyle=1, xstyle=1, ythick=2, charthick=2, charsize=2.0
	oplot, time, alt_GPS/4000.*1000., psym=3, color=2200000, thick=1.5,/noclip
	xyouts, 0.02*sa+sb, 1150, 'P5 Flight '+flights(f), charthick=2, charsize=1.4,/noclip
	;device,/close
	p=tvrd(true=1)
	write_png,data_out_dir+'BBR_P5_all_'+flights(f)+'.png',p
	;write_png,'/projekt_agmwend/home_rad/Sebastian/BBR/MOSAiC_Airborne/Quicklook_MOSAiC/BBR_P5_all_'+flights(f)+'.png',p
	
	tmin=-15.
	tmax=10.
	; ---------------------------------------------
	; plot brightness temperature
	; ---------------------------------------------
	;psfile = data_out_dir+'BrTemp_P5_'+flights(f)+'.ps'
	;set_plot,'ps'
	;device,filename=psfile,xsize=15,ysize=10,/color
	window,3,retain=2
	loadct,39
	plot, time, KT19_temp, /nodata, color=0, background=white, xtitle = 'Time (UTC)', ytitle = 'Brightness Temperatures ('+string(176B)+'C)', xrange=[min(time),max(time)], yrange=[tmin,tmax], xstyle=1, ystyle=1, thick=1.5, ythick=2, xthick=2, charthick=2, charsize=2.0
	oplot, time, KT19_temp, psym=3, color=0, thick=1.5
	oplot, time, BT_up_lw, psym=3, color=255, thick=1.5
	sa = (max(time) - min(time))
	sb = min(time)
	oplot, [0.02*sa+sb,0.1*sa+sb], [1.03*(tmax-tmin)+tmin,1.03*(tmax-tmin)+tmin], color=0, thick=2,/noclip
	oplot, [0.32*sa+sb,0.4*sa+sb], [1.03*(tmax-tmin)+tmin,1.03*(tmax-tmin)+tmin], color=255, thick=2,/noclip
	oplot, [0.72*sa+sb,0.8*sa+sb], [1.03*(tmax-tmin)+tmin,1.03*(tmax-tmin)+tmin], color=2200000, thick=2,/noclip
	xyouts, 0.11*sa+sb, 1.018*(tmax-tmin)+tmin, 'KT19', charsize=2.0, color=0,/noclip
	xyouts, 0.41*sa+sb, 1.018*(tmax-tmin)+tmin, 'CGR4', charsize=2.0, color=0,/noclip
	xyouts, 0.81*sa+sb, 1.018*(tmax-tmin)+tmin, 'Altitude', charsize=2.0, color=0,/noclip
	axis,max(time),yaxis=1,xrange=[min(time),max(time)],yrange=[0.0,4.],ytitle='Altitude (km)',color=0, ystyle=1, xstyle=1, ythick=2, charthick=2, charsize=2.0
	oplot, time, alt_GPS/4000.*(tmax-tmin)+tmin, psym=3, color=2200000, thick=1.5,/noclip
	xyouts, 0.02*sa+sb, 1.15*(tmax-tmin)+tmin, 'P5 Flight '+flights(f), charthick=2, charsize=1.4,/noclip
	;device,/close
	p=tvrd(true=1)
	write_png,data_out_dir+'BrTemp_P5_'+flights(f)+'.png',p

	
	print,flights(f)+' DONE!' & wait,0.1
	
endfor ; loop over all flights

print,'DONE!'
exit

end