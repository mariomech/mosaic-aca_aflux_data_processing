function milo_calc_Ua, time, RHm, tau

;	Written by Larry Miloshevich

; Input smoothed measurements RHm and humidity time-constant tau.  Return the
; profile RHtl that is corrected for sensor time-lag error.  The correction is
; given by Eq. (4) in Miloshevich et al. (2004), which assumes step-changes for
; each timestep.
; Ua(t2) = [Um(t2) - Um(t1)*X] / (1-X), where X = exp(-dt/tau), and dt = t2-t1

	np = n_elements(time)
	dt = fltarr(np)  &  dt[1:np-1]=time[1:np-1]-time[0:np-2]  & dt[0]=dt[1]
	tfac = dt / tau   &   X = exp(-tfac)

	RHtl = fltarr(np)
	RHminit = RHm[0]     ; assume constant (equilibrated) RHm before launch
	RHtl[0] = (RHm[0] - RHminit*X[0]) / (1. - X[0])
	term = RHm[0:np-2]*X[1:np-1]  		; RHm[i-1] aligned with X[i]
	RHtl[1:np-1]= (RHm[1:np-1] - term) /  (1.- X[1:np-1])

	return, RHtl
end
