
PRO aflux03192019
  ;Processing details #1
  date='03192019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190319.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190319\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F1 20190319/20190319/imagefiles_pip/Imagefile_1PIP_20190319160345']   
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO aflux03212019
  ;Processing details #1
  date='03212019'     ;mmddyyyy
  starttime=35641               ;seconds
  stoptime=52201                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190321.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190321\'            ;Output directory
  fn=[$ 
  ;'E:/AFLUX/Daten/F2 20190321/20190321/imagefiles_pip/Imagefile_1PIP_20190321093624',$  ; mit diesem File funktioniert die Prozessierung nicht, aber das file ist zum glück uninteressant
  'E:/AFLUX/Daten/F2 20190321/20190321/imagefiles_pip/Imagefile_1PIP_20190321100311']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO aflux03232019
  ;Processing details #1
  date='03232019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190323.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190323\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F3 20190323/20190323/imagefiles_pip/Imagefile_1PIP_20190323111605',$ 
  'E:/AFLUX/Daten/F3 20190323/20190323/imagefiles_pip/Imagefile_1PIP_20190323141747']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO aflux03242019
  ;Processing details #1
  date='03242019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  ;pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190324.txt'                 ;Name of file with TAS data
  pthfile=''                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190324\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F4 20190324/imagefiles_pip/Imagefile_1PIP_20190324095046',$ 
  'E:/AFLUX/Daten/F4 20190324/imagefiles_pip/Imagefile_1PIP_20190324124223']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO aflux03252019
  ;Processing details #1
  date='03252019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190325.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190325\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F5 20190325/20190325/imagefiles_pip/Imagefile_1PIP_20190325094730',$ 
  'E:/AFLUX/Daten/F5 20190325/20190325/imagefiles_pip/Imagefile_1PIP_20190325125210']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO aflux03302019
  ;Processing details #1
  date='03302019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190330.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190330\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F6 20190330/20190330/imagefiles_pip/Imagefile_1PIP_20190330100132',$ 
  'E:/AFLUX/Daten/F6 20190330/20190330/imagefiles_pip/Imagefile_1PIP_20190330133042']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO aflux03312019
  ;Processing details #1
  date='03312019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190331.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190331\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F7 20190331/20190331/imagefiles_pip/Imagefile_1PIP_20190331084441']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END




PRO aflux04012019
  ;Processing details #1
  date='04012019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190401.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190401\'            ;Output directory
  fn=[$
    'E:/AFLUX/Daten/F8 20190401/20190401/imagefiles_pip/Imagefile_1PIP_20190401071843']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END



PRO aflux04032019
  ;Processing details #1
  date='04032019'     ;mmddyyyy
  starttime=38700                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190403.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190403\'            ;Output directory
  fn=[$
    'C:/Users/mose_mn/Documents/Kampagnen/AFLUX/F9 20190403/20190403/20190403095320/Imagefile_1PIP_20190403095320']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END



PRO aflux04042019
  ;Processing details #1
  date='04042019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190404.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190404\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F10 20190404/20190404/imagefiles_pip/Imagefile_1PIP_20190404083137']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO aflux04062019
  ;Processing details #1
  date='04062019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190406.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190406\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F11 20190406/20190406/imagefiles_pip/Imagefile_1PIP_20190406095639',$ 
  'E:/AFLUX/Daten/F11 20190406/20190406/imagefiles_pip/Imagefile_1PIP_20190406130035',$ 
  'E:/AFLUX/Daten/F11 20190406/20190406/imagefiles_pip/Imagefile_1PIP_20190406132522',$ 
  'E:/AFLUX/Daten/F11 20190406/20190406/imagefiles_pip/Imagefile_1PIP_20190406143718']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END



PRO aflux04072019
  ;Processing details #1
  date='04072019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190407.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190407\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F12 20190407/imagefiles_pip/Imagefile_1PIP_20190407065205']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END



PRO aflux04082019
  ;Processing details #1
  date='04082019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190408.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190408\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F13 20190408/imagefiles_pip/Imagefile_1PIP_20190408085044']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO aflux04112019
  ;Processing details #1
  date='04112019'     ;mmddyyyy
  starttime=1                ;seconds
  stoptime=80000                ;seconds
  pthfile='E:\AFLUX\Auswertung\NASA-AMES\TAS_files\tas_190411.txt'                 ;Name of file with TAS data
  outdir='E:\AFLUX\Auswertung\NASA-AMES\PIP\20190411\'            ;Output directory
  fn=[$ 
  'E:/AFLUX/Daten/F14 20190411/20190411/imagefiles_pip/Imagefile_1PIP_20190411092148']
  batch_process, fn, date, starttime, stoptime, pthfile, outdir
END



PRO batch_process, fn, date, starttime, stoptime, pthfile, outdir
  ;Probe parameters, most are stored in soda2_probespecs
  probe=soda2_probespecs(name='DLR PIP (PADS) AFLUX')

  ;Processing details and options
  ;endbins=[0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.5, 17.5, 18.5, 19.5, 20.5, 21.5, 22.5, 23.5, 24.5, 25.5, 26.5, 27.5, 28.5, 29.5, 30.5, 31.5, 32.5, 33.5, 34.5, 35.5, 36.5, 37.5, 38.5, 39.5, 40.5, 41.5, 42.5, 43.5, 44.5, 45.5, 46.5, 47.5, 48.5, 49.5, 50.5, 51.5, 52.5, 53.5, 54.5, 55.5, 56.5, 57.5, 58.5, 59.5, 60.5, 61.5, 62.5, 63.5, 64.5]
  ; Resolution is 103! (from Calibration)
  endbins=[51.5, 154.5, 257.5, 360.5, 463.5, 566.5, 669.5, 772.5, 875.5, 978.5, 1081.5, 1184.5, 1287.5, 1390.5, 1493.5, 1596.5, 1699.5, 1802.5, 1905.5, 2008.5, 2111.5, 2214.5, 2317.5, 2420.5, 2523.5, 2626.5, 2729.5, 2832.5, 2935.5, 3038.5, 3141.5, 3244.5, 3347.5, 3450.5, 3553.5, 3656.5, 3759.5, 3862.5, 3965.5, 4068.5, 4171.5, 4274.5, 4377.5, 4480.5, 4583.5, 4686.5, 4789.5, 4892.5, 4995.5, 5098.5, 5201.5, 5304.5, 5407.5, 5510.5, 5613.5, 5716.5, 5819.5, 5922.5, 6025.5, 6128.5, 6231.5, 6334.5, 6437.5, 6540.5, 6643.5]
  arendbins=[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

  project='AFLUX' ;Project name
  rate=1               ;Averaging time
  smethod='fastcircle' ;Sizing method, default is 'fastcircle'
  particlefile=1       ;Flag to output particle-by-particle data
  savfile=1            ;Flag to output sav file
  inttime_reject=1     ;Flag to turn shattering correction on/off
  reconstruct=0        ;Flag to turn particle reconstruction on/off
  stuckbits=1          ;Flag to turn stuck bit detection on/off
  water=0              ;Flag to turn water processing on/off
  fixedtas=10         ;Use a fixed TAS (m/s)
  timeoffset=0.0       ;Time correction
  ; outdir=''            ;Output directory
  output_dir_images = outdir
  pthfile= pthfile          ;File with state variables
  stretchcorrect = 1
  ncdfparticlefile = 1
  juelichfilter = 1
  eawmethod = 'centerin'

  ;Build structure and process data
  ;Fields not specified here will be updated with defaults in soda2_update_op.pro
  op={fn:fn, date:date, starttime:starttime, stoptime:stoptime, project:project,$
    outdir:outdir, timeoffset:timeoffset, format:probe.format, $
    subformat:probe.subformat, probetype:probe.probetype, res:probe.res, $
    armwidth:probe.armwidth, numdiodes:probe.numdiodes, probeid:probe.probeid,$
    shortname:probe.shortname,  wavelength:probe.wavelength, $
    seatag:probe.seatag, endbins:endbins, arendbins:arendbins, rate:rate, $
    smethod:smethod, pth:pthfile, particlefile:particlefile, savfile:savfile, $
    inttime_reject:inttime_reject, reconstruct:reconstruct, stuckbits:stuckbits,stretchcorrect:stretchcorrect,$
    water:water, fixedtas:fixedtas, ncdfparticlefile:ncdfparticlefile, juelichfilter:juelichfilter, eawmethod:eawmethod}

  soda2_process_2d, op
END

;aflux03192019
;aflux03212019 
;aflux03232019
;aflux03242019 
;aflux03252019
;aflux03302019
;aflux03312019
;aflux04012019
;aflux04032019 
;aflux04042019
;aflux04062019
;aflux04072019
;aflux04082019
;aflux04112019 

restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\20190319\03192019_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\20190319\03192019_000001_PIP'+'.nc'

day = '21'
month = '03'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_095401_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_095401_PIP'+'.nc'

day = '23'
month = '03'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '24'
month = '03'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '25'
month = '03'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '30'
month = '03'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '31'
month = '03'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '01'
month = '04'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '03'
month = '04'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_104500_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_104500_PIP'+'.nc'

day = '04'
month = '04'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '06'
month = '04'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '07'
month = '04'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '08'
month = '04'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'

day = '11'
month = '04'
year = '2019'
restore, 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP.dat'
soda2_export_ncdf, data, outfile = 'E:\AFLUX\Auswertung\NASA-AMES\PIP\'+year+month+day+'\'+month+day+year+'_000001_PIP'+'.nc'


END





