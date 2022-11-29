pro read_eagle, infile, img, xs, ys, nwl, type, offset, mapinfo, $
                wl, interleave, fodis, himg, tint, darkstart, date, tstart, tstop, fps, info=info

;
; Copyright (c) 2003,Institute of Photogrammetry and Remote Sensing, ;(IPF),
; Technical University of Vienna. Unauthorised reproduction prohibited.
;
;+
; NAME:
; read_envi_file
;
; PURPOSE:
; IDL program, which reads standard ENVI image files.
;
;
; CATEGORY:
; Input_Output
;
; CALLING SEQUENCE:
; read_eagle, infile, img, xs, ys, nwl, type, offset, mapinfo, wl, interleave, fodis, himg, tint, darkstart, date, tstart, tstop, fps
;
; INPUTS:
; infile - input file name
;
; OPTIONAL INPUTS:
; None
;
; KEYWORD PARAMETERS:
; /INFO  -  don't create data arrays and don't read data; only read the header information (if there's not enough memory for the data arrays)
;
; OUTPUTS:
; img - ENVI image file, 3D array
; xs - number of lines (data sets along flight track; equals number of measurement times)
; ys - number of samples (spatial pixels, cross-track)
; nwl - number of spectral pixels (number of wavelengths)
; type - image data type
; offset - headeroffset
; mapinfo - information on the projection used to create the data map (geo-referenced Caligeo output)
; wl - Wavelength array
; interleave - Array structure of the binary file, and of the output array (see below)
; fodis - y indices of fodix pixels (2-element array)
; himg - y indices of the image (2-element array)
; tint - Integration time in ms
; darkstart - starting line of the autodark measurement
; date - acquisition date, in format dd-mm-yyyy
; tstart - GPS Start Time string
; tstop - GPS Stop Time string
; fps - Frames per second (float)
;
; OPTIONAL OUTPUTS:
; None
;
; COMMON BLOCKS:
; none
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
; None
;
; PROCEDURE:
;
; EXAMPLE:
;
; REMARKS
; None
;
; MODIFICATION HISTORY:
; Written by: Carsten Pathe, cp@ipf.tuwien.ac.at
; Date: 25.08.2003
; 2011-02-24: EB - better filename tolerance; add wavelength array to output; add third dimension and interleave to img
; 2011-04-14: EB - added /INFO keyword
; 2011-04-19: EB - added more header variables
; 2011-06-08: EB - updated the mapinfo variable to contain all the projection information
; 2011-06-08: EB - added the second (lowercase) wavelength keyword with a different array format in header files for georeferenced Caligeo output files
;
;-

image = infile
fodis=0
if n_elements(info) eq 0 then info=0

if strmid(infile,strlen(infile)-3) eq 'dat' then header = strmid(infile,0,strlen(infile)-4)+'.hdr' else $
header = strmid(infile,0,strlen(infile)-4)+'.hdr'

openr, unit, header, /get_lun

header_line = ''

while not eof(unit) do begin

readf, unit, header_line
tmp = strtrim(strsplit(header_line[0], '=', /extract),2)
header_keyword = strsplit(tmp[0], ' ', /extract)

;print, header_keyword

if header_keyword[0] eq 'samples' then begin
     ys = long(tmp[1])
     if n_elements(himg) eq 0 then himg=[0,ys]
     endif
if header_keyword[0] eq 'lines' then xs = long(tmp[1])
if header_keyword[0] eq 'bands' then nwl = long(tmp[1])
if header_keyword[0] eq 'header' then offset = long64(tmp[1])
if header_keyword[0] eq 'data' then type = long(tmp[1])
if header_keyword[0] eq 'tint' then tint = float(tmp[1])
if header_keyword[0] eq 'fps' then fps = float(tmp[1])
if header_keyword[0] eq 'acquisition' then begin
   waste = strsplit(tmp[1],':',/EXTRACT)
   date = strtrim(waste[1],2)
   endif
if tmp[0] eq 'GPS Start Time' then tstart = tmp[1]
if tmp[0] eq 'GPS Stop Time' then tstop = tmp[1]

if header_keyword[0] eq 'fodis' then begin
   fodis0 = tmp[1]
   p1 = strpos(fodis0,'{')
   p2 = strpos(fodis0,'}')
   fodis1 = strmid(fodis0,p1+1,p2-p1-1)
   fodis2 = strsplit(fodis1,',',/extract)
   fodis = [long64(fodis2[0])-1, long64(fodis2[1])-1 ]
endif

if header_keyword[0] eq 'himg' then begin
   himg0 = tmp[1]
   p1 = strpos(himg0,'{')
   p2 = strpos(himg0,'}')
   himg1 = strmid(himg0,p1+1,p2-p1-1)
   himg2 = strsplit(himg1,',',/extract)
   himg = [ long64(himg2[0])-1, long64(himg2[1])-1 ]
endif

if header_keyword[0] eq 'autodarkstartline' then darkstart = long(tmp[1])

if header_keyword[0] eq 'interleave' then begin
  interleave = strlowcase(strtrim(tmp[1],2))
  if interleave ne 'bip' and interleave ne 'bsq' and interleave ne 'bil' then message,"Can't understand interleave"
  endif

if header_keyword[0] eq 'map' then begin

;; mapinfo for standard/raw files, not really needed!!
;  mapinfo_tmp=strsplit(tmp[1],'{',/extract,/PRESERVE_NULL)
;  mapinfo_tmp=strsplit(mapinfo_tmp[1],',',/extract)
;
;  mapinfo={ulx:0.,uly:0.,spacing:0.}
;  mapinfo.ulx=mapinfo_tmp[3]
;  mapinfo.uly=mapinfo_tmp[4]
;  mapinfo.spacing=mapinfo_tmp[5]

; This is the mapinfo for the full projection info needed for georeferenced Caligeo output files:
   bpos1 = strpos(header_line,'{')
   bpos2 = strpos(header_line,'}')
   mapinfo_temp = strmid(header_line,bpos1+1,bpos2-bpos1-1)
   mapinfo_tmp=strsplit(mapinfo_temp,',',/extract)
   mapinfo = { proj:'', ix:0, iy:0, easting:0d, northing:0d, xsize:0d, ysize:0d, zone:0, hemi:'', datum:'', units:'' }
   mapinfo.proj = mapinfo_tmp[0]
   mapinfo.ix   = long(mapinfo_tmp[1])
   mapinfo.iy   = long(mapinfo_tmp[2])
   mapinfo.easting  = double(mapinfo_tmp[3])
   mapinfo.northing = double(mapinfo_tmp[4])
   mapinfo.xsize    = double(mapinfo_tmp[5])
   mapinfo.ysize    = double(mapinfo_tmp[6])
   mapinfo.zone     = long(mapinfo_tmp[7])
   mapinfo.hemi     = mapinfo_tmp[8]
   mapinfo.datum    = mapinfo_tmp[9]
   mapinfo.units    = (strsplit(mapinfo_tmp[10],'=',/EXTRACT))[1]
endif

if header_keyword[0] eq 'Wavelength' then begin   ; wl array in raw files
  wl = 0d
  print,'wl 1'
  rei_next_wl:
  readf, unit, header_line
  if string(header_line) ne '}' then begin
     wl = [wl, double(header_line) ]
     goto,rei_next_wl
  endif
  wl = wl[1:*]
  if n_elements(wl) ne nwl then message,'Wavelength array does not match number of bands!!!'
endif

; Note that the keyword 'wavelength' is spelt with a lowercase w in the georeferenced caligeo output files, but with uppercase W in raw files
if header_keyword[0] eq 'wavelength' AND n_elements(header_keyword) eq 1 then begin   ; wl array in georeferenced caligeo files
  wl = 0d
  rei_next_wl_line:
  readf, unit, header_line
  if strpos(header_line,'}') eq -1 then begin
     wl = [wl, double(strsplit(header_line,',',/EXTRACT)  ) ]
     goto,rei_next_wl_line
  endif ; ELSE: This is the last wl line with the closing '}'
  wl = [wl, double(strsplit( strmid(header_line,0,strlen(header_line)-1) ,',',/EXTRACT)  ) ]
  wl = wl[1:*]
  if n_elements(wl) ne nwl then message,'Wavelength array does not match number of bands!!!'
endif

endwhile

close,unit & free_lun, unit



if (info eq 0) then begin   ; info=1: don't create arrays and don't read data (e.g. if not enough memory is available)

if interleave eq 'bsq' then begin
  case type of
  1:  img=bytarr(ys, xs, nwl)
  2:  img=intarr(ys, xs, nwl)
  3:  img=lonarr(ys, xs, nwl)
  4:  img=fltarr(ys, xs, nwl)
  12: img=uintarr(ys, xs, nwl)
  endcase
endif

if interleave eq 'bil' then begin
  case type of
  1:  img=bytarr(ys, nwl, xs)
  2:  img=intarr(ys, nwl, xs)
  3:  img=lonarr(ys, nwl, xs)
  4:  img=fltarr(ys, nwl, xs)
  12: img=uintarr(ys, nwl, xs)
  endcase
endif

if interleave eq 'bip' then begin
  case type of
  1:  img=bytarr(nwl, ys, xs)
  2:  img=intarr(nwl, ys, xs)
  3:  img=lonarr(nwl, ys, xs)
  4:  img=fltarr(nwl, ys, xs)
  12: img=uintarr(nwl, ys, xs)
  endcase
endif


openr, unit,image, /get_lun
point_lun, unit, offset
readu, unit, img
close, unit & free_lun, unit

endif  ; if info


end
