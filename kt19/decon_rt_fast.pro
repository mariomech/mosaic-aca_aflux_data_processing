;============================================================================
;============================================================================
; Deconvolution of a time series smoothed due to the respons time of the sensor
;
; - Deconvolution is applied via the convolution theorem using fourier transformation
; - see Numerical Recipies 13.1
;
; - additional filters are applied to reduce the influence of sensor noise
; 		- cuting off the fourier series at noise level
;       - additional running mean filter (rectangular window)
;
; - fast version cuts time series into smaller peaces 100 times larger than the inertia time
;   and puts the peaces together afterwards
;
;============================================================================
;============================================================================




; INPUT:  xtime      ... has to be equidistant [s]
;	      xdatacon   ... data series as measured
;		  xrsp_time  ... 1/e response time of the sensor [s]
;         xfcut      ... Cut off frequenzy for noise filtering in [Hz]
;         xrm_length ... Window size of the running mean filter in [s]
;         xdt        ... Time step between two measurements [s]

; OUTPUT: xdata      ... deconvoluted data

; PARAMETERS:	/NO_RM				   ...  If set, the running mean filter is not applied
;				/show_spectra      ... can be specified to give a plot of the power spectra as calculated within the routine
;									   "ENTER" hast to be pressed to continue the calculation after the plot opened.
;				SIGMA=*.**           ... choose to apply the Lanczos sigma factor reducing the Gibbs-Phenomenon
;								        value given to SIGMA=*.**  is the max. frequency xfsigma for which Sigma-Approx. is applied


function decon_rt_fast, xdatacon, xtime ,xrsp_time, xfcut, xrm_length, xdt, show_spectra = show_spectra,$
						NO_RM=NO_RM, SIGMA=xfsimga

xdatacon=reform(xdatacon)
xtime=reform(xtime)

uneven=0
if (n_elements(xtime) mod 2) eq 1 then begin
uneven=1
last_datacon=xdatacon(n_elements(xtime)-1)
last_time=xtime(n_elements(xtime)-1)

xdatacon=xdatacon(0:n_elements(xtime)-2)
xtime=xtime(0:n_elements(xtime)-2)
endif




pi=4*atan(1)

xnt=n_elements(xtime)
;xdt=xtime(1)-xtime(0)



;==============================================================================
; create convolution function
;==============================================================================


xfcon_all=1.d/xrsp_time*exp(-(lindgen((xnt))*xdt)/xrsp_time)


xt99=xrsp_time*alog(1.d/0.00001)  ; time when contribution is less then 99.999 %
ximax=fix(xt99/xdt)

if (ximax mod 2) eq 1 then ximax=ximax+1



;now cut time series into peaces 10 times larger than ximax
; overlap is 2 times ximax

xdata=xdatacon

for i=0l,xnt do begin
stopID=0

ia=0+i*ximax*6
ie=ximax*12-1 +(i+1)*ximax*6
if ie ge xnt-1 then begin
	ie=xnt-1
	stopID=1
endif

ptime=xtime(ia:ie)
pdatacon=xdatacon(ia:ie)


; check which additional parameter have to be used
parameter=[0,0,0]

CASE (1) OF
KEYWORD_SET(show_spectra): BEGIN
    parameter(0)=1
    END
ELSE: $
    parameter(0)=0
ENDCASE

CASE (1) OF
KEYWORD_SET(NO_RM): BEGIN
    parameter(1)=1
    END
ELSE: $
    parameter(1)=0
ENDCASE


CASE (1) OF
KEYWORD_SET(xfsimga): BEGIN
    parameter(2)=1
    END
ELSE: $
    parameter(2)=0
ENDCASE


if (parameter(0) eq 0) AND (parameter(1) eq 0) AND (parameter(2) eq 0) then pdata=decon_rt(pdatacon,ptime,xrsp_time,xfcut,xrm_length,xdt)
if (parameter(0) eq 0) AND (parameter(1) eq 0) AND (parameter(2) eq 1) then pdata=decon_rt(pdatacon,ptime,xrsp_time,xfcut,xrm_length,xdt,       SIGMA=xfsimga)
if (parameter(0) eq 0) AND (parameter(1) eq 1) AND (parameter(2) eq 0) then pdata=decon_rt(pdatacon,ptime,xrsp_time,xfcut,xrm_length,xdt,/NO_RM)
if (parameter(0) eq 0) AND (parameter(1) eq 1) AND (parameter(2) eq 1) then pdata=decon_rt(pdatacon,ptime,xrsp_time,xfcut,xrm_length,xdt,/NO_RM,SIGMA=xfsimga)

if (parameter(0) eq 1) AND (parameter(1) eq 0) AND (parameter(2) eq 0) then pdata=decon_rt(pdatacon,ptime,xrsp_time,xfcut,xrm_length,xdt,/show_spectra)
if (parameter(0) eq 1) AND (parameter(1) eq 0) AND (parameter(2) eq 1) then pdata=decon_rt(pdatacon,ptime,xrsp_time,xfcut,xrm_length,xdt,/show_spectra,       SIGMA=xfsimga)
if (parameter(0) eq 1) AND (parameter(1) eq 1) AND (parameter(2) eq 0) then pdata=decon_rt(pdatacon,ptime,xrsp_time,xfcut,xrm_length,xdt,/show_spectra,/NO_RM)
if (parameter(0) eq 1) AND (parameter(1) eq 1) AND (parameter(2) eq 1) then pdata=decon_rt(pdatacon,ptime,xrsp_time,xfcut,xrm_length,xdt,/show_spectra,/NO_RM,SIGMA=xfsimga)




if i ne 0 then icc=3*ximax &
if i eq 0 then icc=0
idd=9*ximax-1
ic=ia+icc
id=ia+idd

if stopID ne 1 then xdata(ic:id)=pdata(icc:idd)
if stopID eq 1 then xdata(ic:*)=pdata(icc:*)


if stopID eq 1 then i=xnt
endfor


if uneven eq 1 then begin
xdatacon=[xdatacon,last_datacon]
xdata=[xdata,last_datacon]
xtime=[xtime,last_time]
endif


return,xdata



end






