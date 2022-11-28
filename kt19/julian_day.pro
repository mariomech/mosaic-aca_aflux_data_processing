; **************  julian_day  ******************
; *
; * Returns the day of the year (julian_day) for a given date. Jan 1 = 1, Feb 1 = 32 etc.
; * consider leap years and the time of day
; *
; *** REQUIRED INPUT ***
; *
; *  year           The year (e.g. 2020)
; *  month          The month (1-12)
; *  day            The day (1-31)
; *  t0				Time in UTC (dezimal hours)
; *
; *** RETURN VALUE ***
; *
; *  jd				A value between 1 and 366, corresponding to the day of the year of year/month/day
; *
; ***   USE   ***
; *
; *	 jd=julian_day(year,month,day,t0)
; *
; *************************************************************


function julian_day,year,month,day,t0
 year=FIX(year)
 month=FIX(month)
 day=FIX(day)
 ; leap year -> s=1:
 s=0
 if year MOD 4 eq 0 then s=1
 if s eq 1 and year MOD 100 eq 0 and year MOD 400 ne 0 then s=0
 if month eq 1  then jd=day
 if month eq 2  then jd=day+31
 if month eq 3  then jd=day+31+28+s
 if month eq 4  then jd=day+31+28+s+31
 if month eq 5  then jd=day+31+28+s+31+30
 if month eq 6  then jd=day+31+28+s+31+30+31
 if month eq 7  then jd=day+31+28+s+31+30+31+30
 if month eq 8  then jd=day+31+28+s+31+30+31+30+31
 if month eq 9  then jd=day+31+28+s+31+30+31+30+31+31
 if month eq 10 then jd=day+31+28+s+31+30+31+30+31+31+30
 if month eq 11 then jd=day+31+28+s+31+30+31+30+31+31+30+31
 if month eq 12 then jd=day+31+28+s+31+30+31+30+31+31+30+31+30
 ;                          J  (F+s)M  A  M  J  J  A  S  O  N

 jd=jd + t0/24.  ;consider time of day (important for the hourly change of declination which can be large in spring/autum)

 return,jd
end
