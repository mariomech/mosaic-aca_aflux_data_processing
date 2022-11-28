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
;============================================================================
;============================================================================
;
;
;
;
; INPUT:  xtime      ... has to be equidistant [s]
;	      xdatacon   ... data series as measured
;		  xrsp_time  ... 1/e response time of the sensor [s]
;         xfcut      ... Cut off frequenzy for noise filtering in [Hz]
;         xrm_length ... Window size of the running mean filter in [s]
;         xdt        ... Time step between two measurements [s]
;
; OUTPUT: xdata      ... deconvoluted data
;
; OPTIONAL OUTPUT: spectra_out      ...   The name of the variable to receive the fourier coefficients calculated within the routine.
;										  The output is an array containing following parameter
;											[0] ... frequency
;											[1] ... fourier coeff. of original data
;											[2] ... fourier coeff. of deconvolutetd data
;											[3] ... fourier coeff. of deconvolutetd data + cut if freq. applied
;											[4] ... fourier coeff. of deconvolutetd data + cut if freq. + running mean applied
;											[5] ... fourier coeff. of convolution function
;
; PARAMETERS:	/NO_RM				   ...  If set, the running mean filter is not applied
;				/show_spectra      ... can be specified to give a plot of the power spectra as calculated within the routine
;									   "ENTER" hast to be pressed to continue the calculation after the plot opened.
;				SIGMA=*.**           ... choose to apply the Lanczos sigma factor reducing the Gibbs-Phenomenon
;								        value given to SIGMA=*.**  is the max. frequency xfsigma for which Sigma-Approx. is applied

; ==> SIGMA is somehow redundant as the running mean makes nothing else than sigma approximation...

function decon_rt, xdatacon, xtime ,xrsp_time, xfcut, xrm_length, xdt, NO_RM=NO_RM, SIGMA=xfsigma,$
				   show_spectra = show_spectra, spectra_out=spectra


xdatacon=reform(xdatacon)
xtime=reform(xtime)

pi=4.d*atan(1.d)

xnt=n_elements(xtime)

if (xnt mod 2) eq 1 then xdatacon=xdatacon(1:*)
if (xnt mod 2) eq 1 then xtime=xtime(1:*)
if (xnt mod 2) eq 1 then xnt=xnt-1


;==============================================================================
; create convolution function
;==============================================================================


xfcon_all=1.d/xrsp_time*exp(-(lindgen((xnt))*xdt)/xrsp_time)


xt99=xrsp_time*alog(1.d/0.00001)  ; time when contribution is less then 99.999 %
ximax=fix(xt99/xdt)

if (ximax mod 2) eq 1 then ximax=ximax+1

xzero=fltarr(ximax)
xzero(*)=0.0
xfcon=[xfcon_all,xzero]




;==============================================================================
; Fouriertrafo of time series and convolution function
;==============================================================================


;add zeros to avoid wrap problem

xzero=fltarr(ximax)
xzero(*)=xdatacon(0)
xdataconzero=[xdatacon,xzero]


;fourier transformation
xftdatacon=fft(xdataconzero,/double)
;;xftfcon1=fft(xfcon,/double)*(xnt+ximax)*xdt;/(pi/2./xrsp_time)   ;scalierung funftioniert hier nicht richtig

xftfcon=fft(xfcon,/double)
xftfcon=xftfcon/xftfcon(0)

xntzero=xnt+ximax
xfreq = lindgen(xntzero/2)/xdt/xntzero


;=======================================================================================
; Calculate fourier transform of boxcar funftion (running mean window) analytically
;=======================================================================================

xftrm=xrm_length/xrm_length*sin(!pi*xrm_length*xfreq)/(!pi*xrm_length*xfreq)     ; "xrm_length/xrm_length"=1  but keep it as it is part of the equations, once in the fourier transform
																				 ;  and once in the normation of the weighting (boxcar function not 1 but 1/xrm_length)
xftrm(0)=1
xftrm=[xftrm,reverse(xftrm)]


;==============================================================================
; De-Convolution of fourier coefficients
;==============================================================================


xftdata0=xftdatacon/xftfcon
xftdata1=xftdata0

;filter noise of sensor by cutting off back transformation
xifcut=where(xfreq gt xfcut)
xifcut=xifcut(0)
if xifcut ne -1 then xftdata1(xifcut:(xntzero-xifcut))=dcomplex(0,0)


CASE (1) OF
KEYWORD_SET(NO_RM): BEGIN
	xftdata=xftdata1
	END
ELSE: $
    xftdata=xftdata1*xftrm
ENDCASE



;==============================================================================
; Backtransformation into time series
;==============================================================================


; apply Sigma-Approximation to minimize Gibbs-Phenomenon
CASE (1) OF
KEYWORD_SET(fsigma): BEGIN



;;x=indgen(100)/10.-5.
;;a=1
;;
;;lanczos=sin(!pi*x)/(!pi*x)*sin(!pi*x/a)/(!pi*x/a)
;;lanczos(50)=1
;;
;;plot,x,lanczos
;;



xisigma=where(xfreq gt xfsigma)
xisigma=xisigma(0)

if xisigma ne -1 then n2=xisigma

sigma=pi*((indgen(n2)+1)*1d)/n2
xftdata(1:n2)=xftdata(1:n2)*sin(sigma)/sigma
xftdata(xntzero-n2+1:*)=xftdata(xntzero-n2+1:*)*sin(reverse(sigma))/reverse(sigma)



END
ELSE: $
    xftdata=xftdata
ENDCASE




;==========================================

xdatazero=real_part(fft(xftdata,/inverse))
xdata=xdatazero(0:(xnt-1))


CASE (1) OF
KEYWORD_SET(show_spectra): BEGIN
	window,31,retain=1
	plot,xfreq,abs(xftdatacon),/ylog,/xlog,xrange=[xfreq(1),xfreq(n_elements(xfreq)-1)],xstyle=1
	oplot,xfreq,abs(xftdata0),color=255
	oplot,xfreq,abs(xftdata1),color=2555555
	oplot,xfreq,abs(xftdata),color=155555
	Result = GET_KBRD(1)
    END
ELSE: $
 print,'no spectra plotted'
ENDCASE

;CASE (1) OF
;KEYWORD_SET(spectra_out): BEGIN
	spectra=[[xfreq(0:*)],[abs(xftdatacon(1:n_elements(xfreq)))],[abs(xftdata0(1:n_elements(xfreq)))],[abs(xftdata1(1:n_elements(xfreq)))],[abs(xftdata(1:n_elements(xfreq)))],[abs(xftfcon(1:n_elements(xfreq)))]]
	spectra=transpose(spectra)
;	END
;ELSE: $
; print,''
;ENDCASE

return,xdata



end






