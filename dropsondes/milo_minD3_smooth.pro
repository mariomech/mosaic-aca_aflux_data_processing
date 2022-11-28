function milo_minD3_smooth, time, RH1, RHlow1, RHhigh1

; 	Written by Larry Miloshevich

; Adjust RH pts between limits RHlow and RHhigh to minimize changes in the
; 2nd derivative.  The average result of smoothing RH forward and backward is
; used to account for competing interests of nearby pts.  The process is
; repeated iteratively using the new points, which have smoother initial values.
; Details and equations are in Appendix of Miloshevich et al. (2004, JTech).
; Time must be monotonically increasing (not checked here...checked in 'qc').

 	nrep = fix(6)  				; # iterations (nom 3-6)

	RH = RH1   &   RHlow = RHlow1   &   RHhigh = RHhigh1

; Check inputs.
	np = n_elements(time)
	if (np lt 5) then return, RH		; too few points to smooth

	ind = where(RHhigh lt RHlow, cnt)	; wrong order?
	if (cnt gt 0) then begin
	  tt=RHhigh[ind]   &   RHhigh[ind]=RHlow[ind]   &   RHlow[ind]=tt
	endif

; For endpoints, an array of evenly-spaced values within the RH range is needed.
	nRH = 100					; # choices for endpts
	dRHbeg = (RHhigh[0] - RHlow[0]) / (nRH-1)    	; dRH for beg pt
	dRHend = (RHhigh[np-1] - RHlow[np-1]) / (nRH-1)	; dRH for end pt
 	RH3beg = RHlow[0] + findgen(nRH)*dRHbeg		; beg pt choices
 	RH3end = RHlow[np-1] + findgen(nRH)*dRHend	; end pt choices

; For efficiency, define various time factors before the loop, which are
; calculated in both the forward and reverse time directions.
	dt = fltarr(np)   &   dt[1:np-1] = time[1:np-1] - time[0:np-2]
	timerev = reverse(time)
	dtrev = fltarr(np)  &  dtrev[1:np-1] = timerev[0:np-2] - timerev[1:np-1]
	dtfac = fltarr(np)
	dtfac[1:np-4] = dt[3:np-2] * (dt[2:np-3] + dt[3:np-2]) / dt[2:np-3]
	dtfacrev = fltarr(np)
	dtfacrev[1:np-4] = dtrev[3:np-2] * (dtrev[2:np-3] + dtrev[3:np-2]) / $
	                   dtrev[2:np-3]
	fac1 = fltarr(np)  &  fac1[1:np-4] = dt[3:np-2]^2 / dt[1:np-4]
	fac1rev=fltarr(np)  &  fac1rev[1:np-4] = dtrev[3:np-2]^2 / dtrev[1:np-4]
	denom = fltarr(np)  &  denom[1:np-4] = dt[2:np-3] + dtfac[1:np-4]
	denomrev=fltarr(np) & denomrev[1:np-4]= dtrev[2:np-3] + dtfacrev[1:np-4]

; Save other "forward" and "reverse" quantities for subsequent iterations.
	dtfwd = dt  &  dtfacfwd = dtfac  &  fac1fwd = fac1  &  denomfwd = denom
	RHlowfwd = RHlow   &   RHlowrev = reverse(RHlow)
	RHhighfwd=RHhigh   &   RHhighrev = reverse(RHhigh)
	RHctr = 0.5 * (RHlow + RHhigh)
	RHctrfwd = RHctr   &   RHctrrev = reverse(RHctr)

; Calculate RH[i+1] that minimizes D3[i+2] for fixed RH[i] and RH[i-1].
; If D3=0 for any RH[i+1] in its RH range, use it. Otherwise min D3 is either
; RHlow or RHhigh. The outer 'while' loop is the number of smoothing iterations.
; The inner 'j' loop smooths in forward direction when j=0 and reverse when j=1.

 	irep=1   &   RHsave=RH
	while (irep le nrep) do begin		; for each iteration
	  for j=0,1 do begin			; 1st loop fwd, 2nd loop rev
	    if (irep eq 1) then begin  	; aim for ctr of [i1] range
	      RHnext = RHctr
 	      RH[0:1] = RHctr[0:1]   &   RH[np-2:np-1] = RHctr[np-2:np-1]
	    endif else begin		; aim for [i1] from prev iter
	      RHnext = RH
	    endelse
	    term = fltarr(np)  &  term[1:np-4] = dt[2:np-3] * RHnext[3:np-2]

; Main calculation of updated RH[i1].  Eq. (B1) in Appendix of paper.
 	    for i=1,np-4 do begin	; treat 2 pts at beg & end as fixed
  	      i1=i+1
              numer = (RH[i] - RH[i-1])*fac1[i] + (RH[i]*dtfac[i]) + term[i]
              RHi1D3zero = numer / denom[i]	; RH[i1] for D3[i2]=0, Eq (B1)
  	      RH[i1] = (RHi1D3zero > RHlow[i1]) < RHhigh[i1]
 	    endfor

	    if (j eq 0) then begin		; save fwd results then do rev
	      RHfwd = RH   &   RH = reverse(RHsave)
	      dt=dtrev  &  dtfac=dtfacrev  &  fac1=fac1rev  &  denom=denomrev
	      RHlow=RHlowrev   &   RHhigh=RHhighrev   &   RHctr=RHctrrev
	    endif else begin		; avg of forward and reverse results
 	      RH = 0.5 * (RHfwd + reverse(RH))
	    endelse
	  endfor

; Find min(D3) for the 2 pts at both ends, using the prev 2 new pts.
; For multiple choices of D3=0, choose the one with D2=0.
 	  RHpts = RH[np-4:np-1]  &  dt = dtfwd[np-4:np-1]  &  RH3arr = RH3end
	  RHlow = RHlowfwd[np-4:np-1]   &   RHhigh = RHhighfwd[np-4:np-1]

	  for j=0,1 do begin			; 1st loop fwd, 2nd loop rev
 	    Di1 = (RHpts[1] - RHpts[0]) / dt[1]
	    dtfac = dt[3] * (dt[2]+dt[3]) / dt[2]
	    numer = (Di1*dt[3]^2) + (dt[2]*RH3arr) + (RHpts[1]*dtfac)
	    denom = dt[2] + dtfac
	    RH2D3zero = numer / denom	; RH2 for D3[i3]=0 (see if within rng)
	    indzero = where((RH2D3zero ge RHlow[2]) and $
	                    (RH2D3zero le RHhigh[2]), nzero)
	    if (nzero gt 0) then begin  ; one or more D3[i3]=0 (find min abs(D2)
	      Di2 = (RH2D3zero[indzero] - RHpts[1]) / dt[2]
	      D2i2 = (Di2 - Di1) / dt[2]
	      D2i2min = min(abs(D2i2), imin)
	      RHpts[2] = RH2D3zero[indzero[imin]]
	      RHpts[3] = RH3arr[indzero[imin]]
	    endif else begin		; choose smallest abs(D3)
 	      RH2arr = (RH2D3zero > RHlow[2]) < RHhigh[2]
 	      Di2 = (RH2arr - RHpts[1]) / dt[2]
	      D2i2 = (Di2 - Di1) / dt[2]
              Di3 = (RH3arr - RH2arr) / dt[3]
	      D2i3 = (Di3 - Di2) / dt[3]
              D3i3 = (D2i3 - D2i2) / dt[3]
	      D3i3min = min(abs(D3i3), imin)
              RHpts[2] = RH2arr[imin]
              RHpts[3] = RH3arr[imin]
	    endelse

	    if (j eq 0) then begin			; 1st loop gives endpts
	      RH[np-2:np-1] = RHpts[2:3]		; new endpts
	      dt = dtrev[np-4:*]
	      RHpts = reverse(RH[0:3])   &   RH3arr = RH3beg
	      RHlow = RHlowrev[np-4:*]   &   RHhigh = RHhighrev[np-4:*]
	    endif else begin				; 2nd loop gives begpts
	      RH[0:1] = reverse(RHpts[2:3])		; new begpts
	    endelse
	  endfor

; Reset to forward direction for next iteration.
	  if (irep lt nrep) then begin
	    RHsave = RH   &   RHnext = RH
	    dt=dtfwd   &   dtfac=dtfacfwd   &   fac1=fac1fwd  &  denom=denomfwd
	    RHlow=RHlowfwd   &   RHhigh=RHhighfwd   &   RHctr=RHctrfwd
	  endif
	  irep = irep + 1
	endwhile

	return, RH
end
