;====================================================================================================================================================
;Saves HAWK radiances to netcdf file
;====================================================================================================================================================
@/projekt_agmwend/home_rad/Micha/Messkampagnen/AFLUX/PANGEA_files/ncdf_rdwr.pro
@/projekt_agmwend/home_rad/Micha/Messkampagnen/AFLUX/PANGEA_files/get_eagle_times.pro
@/projekt_agmwend/home_rad/Micha/Messkampagnen/AFLUX/PANGEA_files/read_eagle.pro

CLOSE,/all

l = path_sep()

ncdf_path = '/projekt_agmwend/home_rad/Micha/Messkampagnen/AFLUX/PANGEA_files/NetCDF_files/Hawk/'

prefix_raw = '/projekt_agmwend/'


;flights = ['04','05','06','07','08','10','11','13','14','15','16','17','18','19','20','21','22','23','25']

dates   = ['20190321','20190323','20190324','20190325','20190330','20190331','20190401','20190403','20190404','20190406','20190407','20190408','20190411'];20190319



aflux_path = '/projekt_agmwend/data/AFLUX/'



flight_dirs = aflux_path + 'Flight_' + dates + '/AisaHAWK/'

FOR d=0,n_elements(flight_dirs)-1 DO BEGIN
;d=0

    parts = strsplit(flight_dirs(d),'/',/extract)


    ;NCDF FILE,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    ncdf_file = ncdf_path + parts(4) + '_' + parts(2) + '_' + parts(3) + '.nc'
    id = ncdf_create(ncdf_file,/clobber,/netcdf4_format)


    ;Smart navigation,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    raw_path = prefix_raw + 'data_raw/AFLUX_raw_only/'+ strjoin(parts(3)) + l

    smart_nav_path = raw_path + 'horidata/'
    smart_nav_file = file_search(smart_nav_path,'*.nav')

    openr,1,smart_nav_file
    dummy = ''
    FOR i = 0,2 DO readf,1,dummy
    data = fltarr(10,file_lines(smart_nav_file)-3)
    readf,1,data
    close,1

    time_nav = data(0,*)
    lon      = data(1,*)
    lat      = data(2,*)
    pitch    = data(5,*)
    roll     = data(6,*)
    yaw      = data(7,*)


    hawk_files = file_search(flight_dirs(d),'*radiance.dat')
    print,'Flight ' + dates(d) + ' has ' + string(n_elements(hawk_files)) + ' files'

    FOR f=0,n_elements(hawk_files)-1 DO BEGIN
    ;for f=0,1 do begin
    ;f=0
    print,'File (f) =',string(f)

       filename = strsplit(hawk_files(f),'/',/extract)

       filename = filename(5)

;       hour = strsplit(filename,'-',/extract)
;       hour = hour(1)
;       hour = strmid(hour,0,4)
;
;       IF flights(d) EQ '04' THEN  hour = string(float(hour)-200.,format='(I04)')



       ;NAVIGATION VBLES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
       parameters = strsplit(parts(3),'_',/EXTRACT)
;       flight_number = parameters(1)
       date  = parameters(1)
       year  = strmid(date,0,4)
       month = strmid(date,4,2)
       day   = strmid(date,6,2)



       raw_file = raw_path + 'AisaHAWK/' + strmid(filename,0,strlen(filename)-13)+'.raw'
       hdr_file = strmid(raw_file,0,strlen(raw_file)-4) + '.hdr'

       hawk_time = get_eagle_times(hdr_file) ;sod

;       IF flights(d) EQ '04' THEN  hawk_time = hawk_time - 2.

       tstart = min(hawk_time)
       minute = (tstart - fix(tstart)) * 60.
       hour = string(fix(tstart),format='(I02)') + string(fix(minute),format='(I02)')



       hawk_lat   = interpol(lat,time_nav,hawk_time)
       hawk_lon   = interpol(lon,time_nav,hawk_time)
       hawk_roll  = interpol(roll,time_nav,hawk_time)
       hawk_pitch = interpol(pitch,time_nav,hawk_time)
       hawk_yaw   = interpol(yaw,time_nav,hawk_time)


       IF f GT 0 THEN ncdf_control,id,/REDEF

       ;RADIANCE VARIABLE,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
       read_eagle,hawk_files(f), img_hawk, xs, ys, nwl_hawk, type, offset, mapinfo, hawk_wl, interleave, fodis,$
                  himg, tint, darkstart,date, tstart, tstop, fps


       img_hawk = fix(img_hawk,type=12) ;Radiance hyperspectral cube saved as unsigned integer


       ;WRITING NETCDF,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

       ;Dimensions...............................
       IF f EQ 0 THEN dim0 = ncdf_dimdef(id,'nwl_hawk',nwl_hawk) ;Number of wl
       ;dim0 = ncdf_dimdef(id,'nwl_hawk',nwl_hawk)

       IF f EQ 0 THEN dim1 = ncdf_dimdef(id,'ys',ys) ;Cross-track
       ;dim1 = ncdf_dimdef(id,'ys',ys)

       dim2 = ncdf_dimdef(id,'xs_' + hour,xs) ;Long-track


       ;Variables id definition..................................
       IF f EQ 0 THEN BEGIN

           ncdf_attput,id,/GLOBAL,'Institution','Leipzig Institute for Meteorology (LIM) - University of Leipzig'

          ncdf_attput,id,/GLOBAL,'Variable name','Each variable name indicates the measurement start time in hhmm UTC'

           ncdf_attput,id,/GLOBAL,'Comment','Michael Schaefer ' + systime()
;

              varID_wl = ncdf_vardef(id,'wavelength',[dim0])
              ncdf_attput, id, VarId_wl, 'Long name', 'Wavelength'
              ncdf_attput, id, VarId_wl, 'Units','nm'
       ENDIF


       IF max(img_hawk) LT 32767 THEN varID_img = ncdf_vardef(id,'radiance_' + hour,[dim1,dim0,dim2],/short) $
       ELSE varID_img = ncdf_vardef(id,'radiance_' + hour,[dim1,dim0,dim2],/long)

       ncdf_attput, id, VarId_img, 'Long name', 'Upwards radiance'
       ncdf_attput, id, VarId_img, 'Units','1E-4 W m-2 sr-1 nm-1'


       varID_time = ncdf_vardef(id,'time_' + hour,[dim2])
       ncdf_attput, id, VarId_time, 'Long name', 'Decimal time'
       ncdf_attput, id, VarId_time, 'Units','UTC hour'


       varID_lat = ncdf_vardef(id,'lat_' + hour,[dim2])
       ncdf_attput, id, VarId_lat, 'Long name', 'Latitude'
       ncdf_attput, id, VarId_lat, 'Units','Degrees'

       varID_lon = ncdf_vardef(id,'lon_' + hour,[dim2])
       ncdf_attput, id, VarId_lon, 'Long name', 'Longitude'
       ncdf_attput, id, VarId_lon, 'Units','Degrees'

       varID_roll = ncdf_vardef(id,'roll_' + hour,[dim2])
       ncdf_attput, id, VarId_roll, 'Long name', 'Roll angle'
       ncdf_attput, id, VarId_roll, 'Units','Degrees'

       varID_pitch = ncdf_vardef(id,'pitch_' + hour,[dim2])
       ncdf_attput, id, VarId_pitch, 'Long name', 'Roll angle'
       ncdf_attput, id, VarId_pitch, 'Units','Degrees'

       varID_yaw = ncdf_vardef(id,'yaw_' + hour,[dim2])
       ncdf_attput, id, VarId_yaw, 'Long name', 'Yaw angle'
       ncdf_attput, id, VarId_yaw, 'Units','Degrees'



      ;Leave definition mode and enter data write mode
      ncdf_control,id,/ENDEF
      print,'I am working for f=',f

      IF f EQ 0 THEN ncdf_varput,id,varID_wl,hawk_wl

      ;ncdf_varput,id,varID_wl,hawk_wl

      ncdf_varput,id,varID_img ,img_hawk
      ncdf_varput,id,varID_time,hawk_time
      ncdf_varput,id,varID_lat ,hawk_lat
      ncdf_varput,id,varID_lon,hawk_lon
      ncdf_varput,id,varID_roll,hawk_roll
      ncdf_varput,id,varID_pitch,hawk_pitch
      ncdf_varput,id,varID_yaw,hawk_yaw

      ;ncdf_control,id,/REDEF


    ENDFOR


ncdf_close,id

ENDFOR

END