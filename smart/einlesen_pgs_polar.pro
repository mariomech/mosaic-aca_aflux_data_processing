pro einlesen_pgs_polar,filename,hh,mm,ss,spec,itime

data=read_ascii(filename)
timesec=data.(0)[0,*]
hh_all=data.field001(1,*)
mm_all=data.field001(2,*)
ss_all=data.field001(3,*)
itime_all=data.field001(260,*)
status=data.field001(264,*)
spec_all=data.field001(4:259,*)

status_dkl=where(status eq 0.)
status_glo=where(status eq 1.)


; find global measurements

von=intarr(n_elements(status_dkl)+1)
bis=intarr(n_elements(status_dkl)+1)

for i=0,n_elements(status_dkl) do begin
    if i eq 0 then begin
        von[i]=0
        bis[i]=status_dkl[i]-1
    endif
    if i gt 0 and i lt n_elements(status_dkl) then begin
       von[i]=status_dkl[i-1]+1
       bis[i]=status_dkl[i]-1
    endif
    if i eq n_elements(status_dkl) then begin
       von[i]=status_dkl[i-1]+1
       bis[i]=n_elements(status)-1
    endif
endfor

; --------------------------------------

; summarize dark current measurements

spec_dkl=fltarr(256,n_elements(von))

for i=0,n_elements(von)-2 do begin
    spec_dkl[*,i]=spec_all[*,status_dkl[i]]
endfor
spec_dkl[*,n_elements(von)-1]=spec_dkl[*,n_elements(von)-2]

; -------------------------------------

; correct for dark current

for i=0,n_elements(von)-1 do begin
    for j=0,n_elements(status-1) do begin
       if von[i] le j and j le bis [i] then begin
         spec_all[*,j]=spec_all[*,j]-spec_dkl[*,i]
       endif
    endfor
endfor

; --------------------

; exclude dark current spectra

hh=fltarr(n_elements(status_glo))
mm=fltarr(n_elements(status_glo))
ss=fltarr(n_elements(status_glo))
itime=fltarr(n_elements(status_glo))
spec_helf=fltarr(256,n_elements(status_glo))
spec=fltarr(256,n_elements(status_glo))

for i=0,n_elements(status_glo)-1 do begin
    hh[i]=hh_all[status_glo[i]]
    mm[i]=mm_all[status_glo[i]]
    ss[i]=ss_all[status_glo[i]]
    itime[i]=itime_all[status_glo[i]]
    spec_helf[*,i]=spec_all[*,status_glo[i]]
endfor
; ------------------------------
for i=0, 255 do begin
    spec[i,*]=spec_helf[i,*]
endfor

end
end