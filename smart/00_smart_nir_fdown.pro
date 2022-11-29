;contact: e.jaekel@uni-leipzig.de

PRO selection_widget_event, event

COMMON share,info3
;COMMON share2, headd

COMPILE_OPT hidden

 WIDGET_CONTROL, event.TOP, GET_UVALUE=info3


  ; Test for button event to end application

  IF event.ID eq info3.doneButton $
    THEN BEGIN
        WIDGET_CONTROL, event.TOP, /DESTROY
    goto, EVENT_END
  ENDIF


  if event.ID eq info3.spectroButton then begin
    info3.id_spectroButton=event.VALUE
  endif


  if event.ID eq info3.rangeButton then begin
    info3.id_rangeButton=event.VALUE
  endif

  ;writing new values into widget_UserValues
  WIDGET_CONTROL, event.TOP, SET_UVALUE=info3

  EVENT_END:
END

;-------------------------------------------------------

; Define main event handler for plotting Widget.
PRO plotting_widget_event, ev

  COMPILE_OPT hidden

  WIDGET_CONTROL, ev.TOP, GET_UVALUE=info

  ; Test for button event to end application
  IF ev.ID eq info.doneButton $
    THEN BEGIN
    WIDGET_CONTROL, ev.TOP, /DESTROY
    goto, EVENT_END
  ENDIF

  ; Check event.ID, if time-slider is moved then return the value auf the slider to xscroll
  IF ev.ID eq info.slide_time THEN begin
  info.time_scroll=fix(ev.VALUE)
  endif

  ; Check event.ID, if wl1-slider is moved then return the value auf the slider to xscroll
  IF ev.ID eq info.slide_wl1 THEN begin
  info.wl1_scroll=fix(ev.VALUE)
  endif
  ; Check event.ID, if wl2-slider is moved then return the value auf the slider to xscroll
  IF ev.ID eq info.slide_wl2 THEN begin
  info.wl2_scroll=fix(ev.VALUE)
  endif

  ;writing new values into widget_UserValues
  WIDGET_CONTROL, ev.TOP, SET_UVALUE=info

  ;plotting with new values

  WSET, info.IDtime
  erase
  xyouts,2,2,('time = '+strtrim(string(format='(I2.2)',info.hh_all(info.time_scroll)),2)+':'+strtrim(string(format='(I2.2)',info.mm_all(info.time_scroll)),2)+':'+strtrim(string(format='(I2.2)',info.ss_all(info.time_scroll)),2)),/DEVICE

  WSET, info.IDwl1
  erase
  xyouts,2,2,'wl1 = '+strtrim(string(format='(f6.1)',info.wl(info.wl1_scroll)),2) + ' nm',/DEVICE

  WSET, info.IDwl2
  erase
  xyouts,2,2,'wl2 = '+strtrim(string(format='(f6.1)',info.wl(info.wl2_scroll)),2) + ' nm',/DEVICE

colo0=255+256L*(255+256L*255)  ;background colour (white)
colo1=0    ;main plotting colour (black)
colo2=255+150*255 ; blue plotting colour
colo3=255  ; red plotting colour

  WSET, info.IDplot1
  plot,info.wl,info.spec_all(info.time_scroll,*),xtitle='Wavelength [nm]',ytitle='[W m!e-2!n nm!e-1!n]',xstyle=1,yrange=[0,info.spec_max],ystyle=1,background=colo0,color=colo1
  oplot,[info.wl(info.wl1_scroll),info.wl(info.wl1_scroll)],[info.spec_max,0],color=colo3
  oplot,[info.wl(info.wl2_scroll),info.wl(info.wl2_scroll)],[info.spec_max,0],color=colo2


  WSET, info.IDplot3
  plot,info.time_all,info.spec_all(*,info.wl1_scroll),xtitle='Time [s]',ytitle='[W m!e-2!n nm!e-1!n]',xTICKFORMAT='(F6.0)',yrange=[0,info.spec_max],xstyle=1,ystyle=1,background=colo0,color=colo1
  oplot,info.time_all,info.spec_all(*,info.wl1_scroll),color=colo3
  oplot,info.time_all,info.spec_all(*,info.wl2_scroll),color=colo2
  oplot,[info.time_all(info.time_scroll),info.time_all(info.time_scroll)],[info.spec_max,0],color=colo1


  EVENT_END:
END

;-------------------------------------------------------
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
function dif_glo, llaammbbddaa,aaa,bbb,ccc
; calculate direct/diffuse fraction d_g     // thanks to Sebastian and Andre
 if llaammbbddaa lt 350 then d_g=ccc+aaa*exp(bbb*350.0)
 if llaammbbddaa ge 350 then d_g=ccc+aaa*exp(bbb*llaammbbddaa)
 ;if llaammbbddaa gt 900 then d_g=ccc+aaa*exp(bbb*0.9)
return,d_g
end
;----------------------------------------------------------------------------------------------

@01_sub_read_files_coras.pro

function read_myfile, file, template_file
; READ_ASCII with a template which is saved and has not to be re-entered each time
    common myblock, template


        case file_test(template_file, /READ) of
            0: begin
                thistemplate = ascii_template(file)
                save, thistemplate, FILENAME=template_file
            end
            1: restore, FILENAME=template_file
        endcase

    if file_test(file) eq 1 then return, read_ascii(file, TEMPLATE=thistemplate) else begin
    retstr={rets,field0:55555L}
    return,retstr
    endelse
end
;----------------------------------------------------------------------------------------------
;    Die FUNCTION RAD konvertiert Winkelmaße: DEG -> RAD:
      function RAD, w
      PI=acos(-1.)
      RADI=w*PI/180.
      return, RADI
      end
; ---------------------------------------------------------------------------
;    Die FUNCTION DEG konvertiert Winkelmaße: RAD -> DEG:
     function DEG, w
     PI=acos(-1.)
     degi=w*180./PI
     return,degi
     end
;------------------------------------------------------------------------------
;C    Die FUNCTION dek berechnet die Deklination = f(JD) in Grad
    function dek,JDay
    aa0=0.7896 & aa1=-23.2559 & aa2=-0.3915 & aa3=-0.1764
    bb1=0.1582 & bb2=0.0934 & bb3=0.4539
    PI=acos(-1.)
    deki=aa0/2.+aa1*cos(2.*PI*JDay/365.+bb1)+aa2*cos(2.*2.*$
    PI*JDay/365.+bb2)+aa3*cos(3.*2.*PI*JDay/365.+bb3)
    return, deki
    end
; ------------------------------------------------------------------------------

;PRO quicklook
; einlesen config_file

openr,1,'M:\campaigns\ac3\mosaic_aca\data\smart\idl\config_quicklook.txt'
line=strarr(5)
readf,1,line
idl_path=strmid(line[0],10)
data_path=strmid(line[1],11)
output_path=strmid(line[2],13)
calib_path=strmid(line[3],12)
quicklook_single=strmid(line[4],16)
close,1
; _________________________________________________


dummy=''

datum='200908'
sav_suffix='_fdw_210521_nir_diffus.sav'
cloud=1

restore, file='M:\campaigns\ac3\mosaic_aca\data\libradtran\'+datum+'\BBR_DirectFraction_Flight_20'+datum+'a_spectral_R0.sav'; dd, time_pos, lon_pos, lat_pos, fglo, wl
time_dg=time_pos

dg_fit=fltarr(n_elements(time_dg),9)

; select bands a) 750 - 770, b) 1300 - 1500, c) 1800 - 2000, d) 2500 - 2900

for i=0, n_elements(time_dg)-1 do begin

    dd_hilf=dd(i,*)

    finde=where(wl gt 295. and wl lt 750 or (wl gt 770 and wl lt 1300) or (wl gt 1500 and wl lt 1800) or (wl gt 2000 and wl lt 2500) and (finite(dd_hilf) eq 1))

    if finde(0) gt -1 then begin
        hilf=poly_fit(wl(finde),(1-dd(i,finde)),8)
        dg_fit(i,*)=hilf
    endif

endfor




hh_files=['12']

cd, idl_path

filename=file_search('T:\data_raw\MOSAiC_ACA_S_raw\Flight_20'+datum+'a\horidata\*.nav')

data=read_ascii(filename, data_start=4)
timepos=data.(0)[0,*]
lon=data.(0)[1,*]
lat=data.(0)[2,*]
alt=data.(0)[3,*]
pitch=data.(0)[5,*]
roll=data.(0)[6,*]
yawnav=data.(0)[7,*]

hilfe=strpos(filename,'\',/reverse_search)
date=strmid(filename, hilfe+8,7)

; ------------------ Einführen von Variablen ---------------------------

spec=0
spec_max=0


; Selection-Widget---------------------------------------------------------------------------


selection_base = WIDGET_BASE(XSIZE=650, YSIZE=300)
spectros=['Irradiance','Radiance','Pyrgeometer']
spectroButton = CW_BGROUP(selection_base,['Irradiance','Radiance','Pyrgeometer'], xoffset=50,yoffset=70,set_value=0,/column,/EXCLUSIVE)
rangeButton = CW_BGROUP(selection_base,['VIS','NIR'], xoffset=200,yoffset=70,set_value=0,/column,/EXCLUSIVE)

doneButton = WIDGET_BUTTON(selection_base,XSIZE=150, YSIZE=40,xoffset=450,yoffset=150, VALUE="Continue")

;   captions

header1=widget_text(selection_base,xsize=8,ysize=1,xoffset=60,yoffset=40,value='Instrument')
header2=widget_text(selection_base,xsize=13,ysize=1,xoffset=210,yoffset=40,value='Spectral Range')


; Realize the widgets.
WIDGET_CONTROL, selection_base, /REALIZE

WIDGET_CONTROL, spectroButton, get_value=id_spectroButton
WIDGET_CONTROL, rangeButton, get_value=id_rangeButton

info3={ doneButton:doneButton, $
        spectroButton:spectroButton, $
        rangeButton:rangeButton, $
        id_spectroButton:id_spectroButton, $
        id_rangeButton:id_rangeButton $
    }


    ;  Register the info3 structure in
    ;  the user value of the top-level base.
    ;
WIDGET_CONTROL, selection_base, SET_UVALUE=info3, /NO_COPY


  ; Call XMANAGER to manage the widgets.
  ;
XMANAGER, 'selection_widget',EVENT_HANDLER='selection_widget_event', selection_base

COMMON share, info2

id_spectrobutton=info2.id_spectroButton
if id_spectrobutton eq 0 then spectro='Irradiance'
if id_spectrobutton eq 1 then spectro='Radiance'
id_rangebutton=info2.id_rangeButton

if id_rangebutton eq 0 then begin
   pixel=1024
   darkpixel=15
endif

if id_rangebutton eq 1 then begin
    pixel=256
endif

if id_spectrobutton eq 2 then begin
;    goto,endegelaende
endif

TIMECOUNTER=0.0

;--------------- Setting Directory and Spectrometer ------------------------------------
data_dir=data_path
close,/ALL
; ymd=6-digit year-month-day date
ymd=strmid(data_dir,9,2,/REVERSE_OFFSET)+strmid(data_dir,11,2,/REVERSE_OFFSET)+strmid(data_dir,13,2,/REVERSE_OFFSET)

;------------------------------------------------------------------------------------------------


;----- File opening Menu and reading ----------------------------------------------------------------------------------

;I down (VIS B-Ch1, B1, 22, VIS3), I up (VIS B-Ch2, F2, ASP06…, VIS4)
;F down (VIS A-Ch1, NIR-A-CH1, NIR*.2.dat, VN7, 2b, VIS1, PGS1), F up (VIS A-Ch2, NIR-B-CH2, NIR*.1.dat, VN4, 9b, VIS2, PGS2)


if id_spectroButton eq 0 and id_rangebutton eq 0 then filters='*VIS-A_ch1*'; irradiance VIS

if id_spectroButton eq 1 and id_rangebutton eq 0 then filters='*VIS-b*.dat'; radiance VIS

if id_spectroButton eq 0 and id_rangebutton eq 1 then filters='*NIR*2.dat'; irradiance NIR

if id_spectroButton eq 1 and id_rangebutton eq 1 then filters='*NIR*2.dat'; nicht benutzt

if id_spectroButton eq 2 then filters='*pyrgeometer.dat'

;; --------------------------------------------------------------------------- hauptschleife über den tag

for hhfiles=0, n_elements(hh_files)-1 do begin

hhsuch=hh_files(hhfiles)
daystring1=strmid(ymd,4,2)+strmid(ymd,2,2)+strmid(ymd,0,2)
files=DIALOG_PICKFILE(path=data_dir,/multiple_files,Filter=filters,title='Choose data file(s)')

count_file=n_elements(files)

;----------------------------------------------------------------------------------------------------------------------------

if id_spectrobutton eq 2 then goto, sec_pyrgeometer

gesamtlauf=0
time_all=fltarr(10000)
spec_all=fltarr(10000,pixel)
hh_all=fltarr(10000)
mm_all=fltarr(10000)
ss_all=fltarr(60000)

height_all=fltarr(60000)
sza_all=fltarr(60000)
lat_all=fltarr(60000)
lon_all=fltarr(60000)
yaw_all=fltarr(60000)


for bigloop=0,count_file-1 do begin

filename1=files[bigloop]

Seconds0 = SYSTIME(1)
if id_rangebutton eq 0 then einlesen_vis_polar,filename1,hh,mm,ss,spec,tint
if id_rangebutton eq 1 then einlesen_pgs_polar,filename1,hh,mm,ss,spec,tint


finde=strpos(filename1,'NIR_')
yy=fix(strmid(filename1,finde+4,2))
month=fix(strmid(filename1,finde+6,2))
dd=fix(strmid(filename1,finde+8,2))


hh_offset=0. ; 23.5. local time -2

time=(hh+hh_offset)*3600+mm*60+ss



spec=transpose(spec)
Seconds2 = SYSTIME(1)
print,'time = ',seconds2-seconds0

T000=SYSTIME(1)

;-------- read Absolute-Calibration-file


directory_calib=calib_path


if id_rangebutton eq 0 then begin ; für das VIS

    TIMECOUNTER+=SYSTIME(1)-T000
    absfac=read_ASCII(calibfile,COMMENT_SYMBOL='#')
    T000=SYSTIME(1)
    absfac=absfac.(0)
    wl=absfac(0,*) & absfac=absfac(1,*)

endif

;----------------------------------------------------------------------------------------------------------------


;--------------     Calculate Average Offset Counts from 225 nm to 290 nm for VIS Spektrometer
;--------------     This offset includes mostly dark current, but also stray light
;--------------     and calcule flux densities --------------------------------------------------------------------------------

if id_rangebutton eq 0 then begin ; für VIS Spektro radiance or irradiance

    darkpixel=79 ;Pixelnummer bei lambda=290 nm
    ntotal=n_elements(tint)

    for i=0,ntotal-1 do begin
        darkcurrent=mean(spec[i,35:darkpixel])
        spec[i,*]=(spec[i,*]-darkcurrent)/(tint[i]/1000.)*absfac
    endfor

endif

; ---------------------- Offsetberechnung und Abs-kalibrierung NIR ------------------------------------------

delta=fltarr(pixel)

if id_rangebutton eq 1 then begin ; für NIR Spektro radiance or irradiance

    ntotal=n_elements(tint)
    for i=0,ntotal-1 do begin

if tint(i) eq 500. then calibfile=directory_calib+'calfac_fdn_NIR_500ms_210428_nachkalib.dat'

        absfac=read_ascii(calibfile, comment_symbol='#')
        wl=absfac.(0)[0,*]
        absfac=absfac.(0)[1,*]

       spec[i,*]=spec[i,*]*absfac[*]



    endfor
endif

; ***********************calculate SZA*********************************
year=yy
day=dd
s=0 ;falls es ein Schaltjahr ist
;----------------- calculate Julian Day ---------------------------------
if year MOD 4 eq 0 then s=1
if month eq 1 then  Jday=day
if month eq 2 then  Jday=day+31
if month eq 3 then  Jday=day+31+28+s
if month eq 4 then  Jday=day+31+28+s+31
if month eq 5 then Jday=day+31+28+s+31+30
if month eq 6 then Jday=day+31+28+s+31+30+31
if month eq 7 then Jday=day+31+28+s+31+30+31+30
if month eq 8 then Jday=day+31+28+s+31+30+31+30+31
if month eq 9 then Jday=day+31+28+s+31+30+31+30+31+31
if month eq 10 then Jday=day+31+28+s+31+30+31+30+31+31+30
if month eq 11 then Jday=day+31+28+s+31+30+31+30+31+31+30+31
if month eq 12 then Jday=day+31+28+s+31+30+31+30+31+31+30+31+30
;------------------------------------------------------------------------

MEZ=(time+1*3600)/3600*60

longitude=interpol(lon,timepos,time/3600.)
latitude=interpol(lat,timepos,time/3600.)

;    calculate tau:
MOZ=MEZ-4.*(15.-longitude)


a0=0.0132 & a1=7.3525 & a2=9.9359 & a3=0.3387
b1=1.4989 & b2=1.9006 & b3=1.8360

PI=acos(-1.)
Zg=a0/2.+a1*cos(2.*PI*Jday/365.+b1)+a2*cos(2.*2.*PI*Jday/365.+b2)+a3* $
cos(3.*2.*PI*Jday/365.+b3)


WOZ=Zg+MOZ

tau=(12.-WOZ/60.)*15.

;C    Berechnung Sonnenhöhenwinkel h, incl. DEG->RAD-Konvertierung:
h=asin(cos(RAD(latitude))*cos(RAD(dek(Jday)))*cos(RAD(tau))+sin(RAD(latitude))*sin(RAD(dek(Jday))))
;C    Berechnung Sonnenazimutwinkel h, incl. DEG->RAD-Konvertierung:
a=( sin(h)*sin(RAD(latitude))-sin(RAD(dek(Jday))) )/(cos(h)*cos(RAD(latitude)))

for i=0,ntotal-1 do begin
    if a[i] ge 1 then a[i]=1.
endfor
a=acos(a)

h=DEG(h)
a=DEG(a)

;C    --Normierung von a auf Windrichtungsgrade, d.h. 180°=SÜD:
for i=0,ntotal-1 do begin
    if WOZ[i] lt (12.*60.) then begin
        a[i]=-a[i]
    endif
    a[i]=180.+a[i]
endfor

;C    --Refraktionskorrektur für h (Näherungsformel,höhenabhängig,z[m],h[°]),
z=0
refkor=1./( exp(z/(27000.*0.3048))*tan(RAD(h)) ) / 60.
sza=90-(h+refkor)

;goto, ohnecosinus
; ********************** COSINE CORRECTION *****************************

if id_spectrobutton eq 0 then begin

; when Irradiance is selected!!!!


;SZA cosine correction for VN1 (head used for looking DOWN)
dc1=[1.00008,-1.51913E-3,-1.77407E-3,1.88173E-4,-1.16145E-5,4.64574E-7,-1.12763E-8,1.57656E-10,-1.16522E-12,3.52655E-15]
;SZA cosine correction for VN2 - evi neu 25.08.17
dc2=[1.00119, -0.00378, -4.11376E-4, 2.55452E-5, -4.47974E-7, 2.57825E-9]

;dc2=[0.999979 , 0.804389, -0.226432 ,0.0255385 , -0.00155690 ,5.72978e-005,-1.33211e-006, 1.97008e-008,-1.79733e-010 ,9.22148e-013,-2.03512e-015] ;nir
;SZA cosine correction for VN3 (head used for looking UP)
dc3=[1.00035,-4.28413E-4,-1.46922E-3,1.23741E-4,-6.78057E-6,2.77194E-7,-7.1114E-9,1.04082E-10,-7.94952E-13,2.4648E-15]
;SZA cosine correction for VN4
dc4=[1.00062,-6.23409E-3,7.53669E-4,-2.03238E-4,1.64781E-5,-6.34224E-7,1.35687E-8,-1.664E-10,1.09688E-12,-3.01255E-15]

;SZA cosine correction for VN7
dc7=[1.00001, -0.0354321, 0.00792755, -0.000783647, 3.92641e-005, -1.08366e-006,  1.70081e-008, -1.47701e-010,  6.29370e-013, -8.98245e-016]

;SZA cosine correction for irr_A
dc5=[1.0007751,-0.0024623398,0.00050426968,-4.6846136e-005,1.7536397e-006,-3.2466266e-008,3.0281530e-010,-1.1496403e-012,0,0]
dc5b=[2.9053093e-006,-8.7637245e-006,2.3766646e-006,-1.4847272e-007,4.9185853e-009,-8.9581840e-011,8.3403361e-013,-3.0776836e-015,0,0]
;SZA cosine correction for irr_B; für direkten Anteil noch nicht erneuert!!!
dc6=[1.0004038,-0.00075224725,0.00027338263,-2.2648301e-005,7.3107832e-007,-1.2803336e-008,1.2732464e-010,-5.5748569e-013,0,0]
dc6b=[1.5326359e-006,-3.8993142e-006,9.1934183e-007,-5.7338633e-008,2.1715740e-009,-4.5821117e-011,4.7736294e-013,-1.9003946e-015,0,0]

; Wavelength-polynome diffuse correction for VN1
fc1=[57.21578,-0.72207,4.02549E-3,-1.28145E-5,2.56777E-8,-3.35796E-11,2.86404E-14,-1.53473E-17,4.68167E-21,-6.18129E-25]
; Wavelength-polynome diffuse correction for VN2
;fc2=[-173.99899,2.29014,-0.01321,4.40291E-5,-9.3405E-8,1.3075E-10,-1.20752E-13,7.09461E-17,-2.40646E-20,3.59093E-24]

; Wavelength-polynome diffuse correction for VN3
fc3=[-68.65416,0.94979,-5.73549E-3,2.0065E-5,-4.47316E-8,6.58139E-11,-6.38495E-14,3.93632E-17,-1.39889E-20,2.18313E-24]
; Wavelength-polynome diffuse correction for VN4
fc4=[-41.22209,0.59364,-3.70303E-3,1.33568E-5,-3.06075E-8,4.61306E-11,-4.56888E-14,2.86646E-17,-1.03369E-20,1.63275E-24]
; Wavelength-polynome diffuse correction for irr_A
fc5=[0.93428464,0.00027259435,0,0,0,0,0,0,0]
; Wavelength-polynome diffuse correction for irr_B
;fc6=[0.95017256,0.00013842121,0,0,0,0,0,0,0]
fc6=[1.01533,0.000102124,0,0,0,0,0,0,0]; neue Faktoren von Frank Juni 2008
  case id_spectrobutton of

;----------SAMUM----------
;    0: sensor='VN3'  ; ALBEDO.1.dat - looking up - sensor UP=VN3
;    1: sensor='VN1'  ; ALBEDO.2.dat - looking down - sensor DOWN=VN1
;    2: begin
;        sensor='VN3' ; spec from ALBEDO.1.dat - looking up
;        sensor2='VN1'; spec2 from ALBEDO.2.dat - looking down
;       end
;---------HUBI KIEL----------
;    0: sensor='VN4'
;    1: sensor='RAD'
;;----------------------------
;;---------Polar / Verdi--------
;    0: sensor='VN2'
;    1: sensor='RAD' ; needs to be revised
;;----------------------------
;; -------ACLOUD-----------
;    0: sensor='VN2'
;;------------------------

; ---------- MOSAiC-ACA --------
    0: sensor='VN7'
;-------------------------------

   endcase

; DIRECT CORRECTION FUNCTION for upward-looking head only
;goto, diffuscorrection

dir_corr=findgen(ntotal,pixel)
dir_corr_help=findgen(ntotal,pixel)
dir_corr_help[*,*]=0.0;
dir_corr[*,*]=0.0  ;  default value

if sensor eq 'VN7' or sensor eq 'irr_A' then begin
    for i=0,ntotal-1 do begin


     dir_corr[i]=0.0 ; set to 0.0 because of += addition
     if sza[i] eq -9999 then begin
         dir_corr[i,*]=1.0
;         continue
     endif

     if sensor eq 'VN7' then begin
        for j=0,9 do begin
          dir_corr[i,*]+=dc7[j]*sza[i]^j
        endfor
     endif

   endfor
endif



; DIFFUSE CORRECTION FUNCTION

diff_corr=findgen(pixel)
diff_corr[*]=1.04 ;wie bei vis angenommen (lt. plot eher 0.985


; -----------------------------------

;goto,ohnecosinus

; Read actual data from files, where present. Otherwise use generic data.

if cloud eq 0 then begin
    d_g=fltarr(n_elements(time),256)

    ; dg_polyfit zeitlich finden
    for ii=0, n_elements(time)-1 do begin
        finde=where(abs(time_dg-time(ii)) eq min(abs(time_dg-time(ii))))
        for ipoly=0,8 do begin
            d_g(ii,*)=d_g(ii,*)+wl(*)^ipoly*dg_fit(finde(0), ipoly)
        endfor ; ipoly
        finde=where(d_g gt 1.0)
        if finde(0) gt -1 then d_g(finde)=1.0
    endfor

    if sensor eq 'VN7' or sensor eq 'irr_A' then begin
        for i=0,pixel-1 do begin
            spec[*,i]=(1-d_g[*,i])*spec[*,i]*dir_corr[*,i]+d_g[*,i]*spec[*,i]*diff_corr[i]
        endfor
    endif

endif


diffuscorrection:

if cloud eq 1 then begin
    if sensor eq 'VN7' then begin
        for i=0,pixel-1 do begin
            spec[*,i]*=diff_corr[i]
        endfor
    endif
endif



endif ; Irradiance correction Ende
; ----------------------- END COSINE correction ----------------------------


; ********************** OUTPUT THE CALIBRATED DATA *****************************
; ********************** wieder in minutenfiles anlegen *************************

ohnecosinus:

formatheader='(" WL ",'+strtrim(string(ntotal),2)+'(F9.2))'

formatstring='(F6.1," ",'+strtrim(string(ntotal),2)+'(E11.2))'


SecondsEnd=SYSTIME(1)



for i=0, ntotal-1 do begin
    time_all[gesamtlauf]=time[i]
    hh_all[gesamtlauf]=hh[i]
    mm_all[gesamtlauf]=mm[i]
    ss_all[gesamtlauf]=ss[i]
    spec_all[gesamtlauf,*]=spec[i,*]

    height=interpol(alt,timepos,time/3600.)
    longitude=interpol(lon,timepos,time/3600.)
    latitude=interpol(lat,timepos,time/3600.)
    yaw=interpol(yawnav,timepos,time/3600.)

    height_all(gesamtlauf)=height(i)
    lon_all(gesamtlauf)=longitude(i)
    lat_all(gesamtlauf)=latitude(i)
    yaw_all(gesamtlauf)=yaw(i)

    sza_all(gesamtlauf)=sza(i)

    gesamtlauf=gesamtlauf+1
endfor

endfor ; Schleife bigloop Ende

time_all=time_all[0:gesamtlauf-1]
hh_all=hh_all[0:gesamtlauf-1]
mm_all=mm_all[0:gesamtlauf-1]
ss_all=ss_all[0:gesamtlauf-1]
spec_all=spec_all[0:gesamtlauf-1,*]

lat_all=lat_all[0:gesamtlauf-1]
lon_all=lon_all[0:gesamtlauf-1]

sza_all=sza_all(0:gesamtlauf-1,*)
height_all=height_all(0:gesamtlauf-1,*)

outputfile=output_path+strtrim(string(min(time_all)/3600.),2)+'_'+strtrim(string(max(time_all)/3600.),2)+sav_suffix
save, file=outputfile, wl, time_all, spec_all, height_all, sza_all, lat_all, lon_all

;goto, endegelaende
;----------------- plotting ------------------------------------------------------------------


if id_rangebutton eq 0 then begin ; VIS Spektrometer
    wl2_scroll=318                         ;wl=450 nm
    wl1_scroll=722                   ;wl=780 nm
endif
if id_rangebutton eq 1 then begin ; NIR Spektrometer
    wl2_scroll=59                         ;wl=1250, nm
    wl1_scroll=39                        ;wl=1130,  nm
endif

ntotal_all=n_elements(hh_all)
if id_rangebutton eq 1 then spec_max=max(spec_all[0:ntotal_all-1,20:80])
if id_rangebutton eq 0 then spec_max=max(spec_all[0:ntotal_all-1,260:800])
spec_min=min(spec_all)

;spec_max=0.3


; Plotting-Widget---------------------------------------------------------------------------

  ; We need access to the image in both the widget creation routine
  ; and the event-handler routine. We use a COMMON block to make
  ; the variable available in both routines.
  ;


  ; Create the base widget.
  plotting_base = WIDGET_BASE(XSIZE=1272, YSIZE=740)

  ; Create the plot widgets.
  plot_time = WIDGET_DRAW(plotting_base,  $
    XSIZE=110, YSIZE=18,xoffset=445,yoffset=372, RETAIN=2)
  plot_wl1 = WIDGET_DRAW(plotting_base,  $
    XSIZE=110, YSIZE=18,xoffset=585,yoffset=372, RETAIN=2)
  plot_wl2 = WIDGET_DRAW(plotting_base,  $
    XSIZE=110, YSIZE=18,xoffset=725,yoffset=372, RETAIN=2)

  plot1 = WIDGET_DRAW(plotting_base,  $
    XSIZE=400, YSIZE=300,xoffset=0,yoffset=40, RETAIN=2)
  plot3 = WIDGET_DRAW(plotting_base,  $
    XSIZE=400, YSIZE=300,xoffset=440,yoffset=40, RETAIN=2)

  ;create the slider and end-Button
  slide_time=WIDGET_SLIDER(plotting_base,XSIZE=400,xoffset=440,yoffset=350, YSIZE=20,minimum=0,maximum=ntotal_all-1,frame=30,/SUPPRESS_VALUE,title='Time')
  slide_wl1=WIDGET_SLIDER(plotting_base,XSIZE=400,xoffset=0,yoffset=350, YSIZE=20,minimum=0,maximum=n_elements(wl)-1,frame=20,/SUPPRESS_VALUE,title='Wavelength (red)')
  slide_wl2=WIDGET_SLIDER(plotting_base,XSIZE=400,xoffset=0,yoffset=380, YSIZE=20,minimum=0,maximum=n_elements(wl)-1,frame=100,/SUPPRESS_VALUE,title='Wavelength (blue)')
  doneButton = WIDGET_BUTTON(plotting_base,XSIZE=250, YSIZE=80,xoffset=950,yoffset=650, VALUE="END")


  ;captions

if id_spectrobutton eq 0 then begin
   heading1=widget_text(plotting_base, $

     XSIZE=1, YSIZE=10,xoffset=407,yoffset=142,value=['I','R','R','A','D','I','A','N','C','E'],font="BOLD")
   heading3=widget_text(plotting_base, $
     XSIZE=10, YSIZE=1,xoffset=180,yoffset=17,value='Spectra')
   heading4=widget_text(plotting_base, $
     XSIZE=10, YSIZE=1,xoffset=630,yoffset=17,value='Time Series')
   textcomment=widget_text(plotting_base, $
     XSIZE=50, YSIZE=7,xoffset=880,yoffset=25,value=['Quicklook Window for Sensor =   '+ spectro ,'date = '+strtrim(string(dd),2)+'.'+strtrim(string(month),2)+'.'+strtrim(string(yy),2),'','','program version 29.03.2010'])
endif

  if id_spectrobutton eq 1 then begin
    heading1=widget_text(plotting_base, $
     XSIZE=1, YSIZE=8,xoffset=407,yoffset=142,value=['R','A','D','I','A','N','C','E'],font="BOLD")
   heading3=widget_text(plotting_base, $
     XSIZE=10, YSIZE=1,xoffset=180,yoffset=17,value='Spectra')
   heading4=widget_text(plotting_base, $
     XSIZE=10, YSIZE=1,xoffset=630,yoffset=17,value='Time Series')
   textcomment=widget_text(plotting_base, $
     XSIZE=50, YSIZE=7,xoffset=880,yoffset=25,value=['Quicklook Window for Sensor =   '+ spectro ,'date = '+strtrim(string(dd),2)+'.'+strtrim(string(month),2)+'.'+strtrim(string(yy),2),'','','program version 29.03.2010'])
endif


  ; Realize the widgets.
  WIDGET_CONTROL, plotting_base, /REALIZE


  ;set the sliders values

  time_scroll=0
  WIDGET_CONTROL,slide_time, SET_VALUE=time_scroll
  WIDGET_CONTROL,slide_wl1, SET_VALUE=wl1_scroll
  WIDGET_CONTROL,slide_wl2, SET_VALUE=wl2_scroll

  ; Retrieve the window ID from the plot widget.
  ; AND Set the plot widget as the current drawable area.

  WIDGET_CONTROL, plot_time, GET_VALUE=IDtime
  WSET, IDtime
  xyouts,2,2,('time = '+strtrim(string(format='(I2.2)',hh_all(time_scroll)),2)+':'+strtrim(string(format='(I2.2)',mm_all(time_scroll)),2)+':'+strtrim(string(format='(I2.2)',ss_all(time_scroll)),2)),/DEVICE

  WIDGET_CONTROL, plot_wl1, GET_VALUE=IDwl1
  WSET, IDwl1
  xyouts,2,2,'wl1 = '+strtrim(string(format='(f6.1)',wl(wl1_scroll)),2) + ' nm',/DEVICE

  WIDGET_CONTROL, plot_wl2, GET_VALUE=IDwl2
  WSET, IDwl2
  xyouts,2,2,'wl2 = '+strtrim(string(format='(f6.1)',wl(wl2_scroll)),2) + ' nm',/DEVICE

col0=255+256L*(255+256L*255)  ;background colour (white)
col1=0    ;main plot colour (black)
col2=255+150*255   ; second plot colour (blue)
col3=255  ; red plot colour



  WIDGET_CONTROL, plot1, GET_VALUE=IDplot1
  WSET, IDplot1
  plot,wl,spec_all(time_scroll,*),xtitle='Wavelength [nm]',ytitle='[W m!e-2!n nm!e-1!n]', $
                           yrange=[0,spec_max],xstyle=1,ystyle=1,background=col0,color=col1
  oplot,[wl(wl1_scroll),wl(wl1_scroll)],[spec_max,0],color=col3
  oplot,[wl(wl2_scroll),wl(wl2_scroll)],[spec_max,0],color=col2

  WIDGET_CONTROL, plot3, GET_VALUE=IDplot3
  WSET, IDplot3
  plot,time_all,spec_all(*,wl1_scroll),xtitle='Time [s]',ytitle='[W m!e-2!n nm!e-1!n]', $
                xTICKFORMAT='(F6.0)',yrange=[0,spec_max],xstyle=1,ystyle=1,background=col0,color=col1
  oplot,time_all,spec_all(*,wl1_scroll),color=col3
  oplot,time_all,spec_all(*,wl2_scroll),color=col2
  oplot,[time_all(time_scroll),time_all(time_scroll)],[spec_max,0],color=col1



info={   IDplot1:IDplot1, $              ; index to window 1
         IDplot3:IDplot3, $              ; index to window 3
         IDtime:IDtime, $      ; index to window_time
         spec_all:spec_all, $                ;spec_data
         wl:wl, $
         time_all:time_all, $
         hh_all:hh_all, $
         mm_all:mm_all, $
         ss_all:ss_all, $
         slide_time:slide_time, $
         slide_wl1:slide_wl1,  $
         slide_wl2:slide_wl2,  $
         doneButton:doneButton, $
         time_scroll:time_scroll, $
         wl1_scroll:wl1_scroll, $
         wl2_scroll:wl2_scroll, $
         spec_max:spec_max, $
         IDwl1:IDwl1, $
         IDwl2:IDwl2 $
    }

    ;  Register the info structure in
    ;  the user value of the top-level base.
    ;
    WIDGET_CONTROL, plotting_base, SET_UVALUE=info, /NO_COPY
;



  ; Call XMANAGER to manage the widgets.
  ;
  XMANAGER, 'plotting_widget', plotting_base

goto, endegelaende
;--------------------------------------------------------------------------------------------------
; --------------------- Pyrgeometerdaten darstellen ----------------------------
sec_pyrgeometer:

i=0
for i=0,count_file[i]-1 do begin
    filename=files[i]
    openr,1,filename
    print,filename

    line=''
    lines=0
    WHILE ~ EOF(1) DO BEGIN
       lines=lines+1
       readf,1,line
    endwhile
    close,1

    openr,1,filename
    data_pyr = fltarr(19,lines)
    readf,1,data_pyr
    close,1

    data_pyr=transpose(data_pyr)

    hh_pyr=data_pyr[*,0]
    mm_pyr=data_pyr[*,1]
    ss_pyr=data_pyr[*,2]

    time_pyr=hh_pyr*3600+mm_pyr*60+ss_pyr

    pyr1=data_pyr[*,5]
    pyr2=data_pyr[*,6]

    ymax=max(pyr2)+10
    ymin=min(pyr2)-10


    iplot,time_pyr,pyr2,title='Pyrgeometer data',color=[255,0,0],yrange=[ymin,ymax],xTICKFORMAT='(F6.0)',/no_saveprompt

endfor

;--------------------------------------------------------------------------------------------------
endegelaende:

endfor ; loop über alle hhfiles


if quicklook_single eq '1' then begin
    for i=0, n_elements(spec[*,1])-1 do begin
        plot, wl, spec_all[i,*],Title=string(time_all[i]),yrange=[0,spec_max]
        wait,0.3
    endfor
endif
end
