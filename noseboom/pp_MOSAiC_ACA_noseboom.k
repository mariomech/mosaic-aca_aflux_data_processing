#!/home/jhartman/bin/kyss
!
! This is the preprep for MOSAiC_ACA.
!
! ------------------------------------------------------------------------------


!#define WRITE

!#define DOGPS                   1 Hz, 10 Hz
!#define DOINS                  50 Hz
 #define DONM                  100 Hz

! ------------------------------------------------------------------------------

Loop flight Set   20200806_P5_01 20200830_P5_02 20200831_P5_03 20200831_P5_04 20200902_P5_05 20200904_P5_06 20200907_P5_07 20200908_P5_08 20200910_P5_09 20200911_P5_10 20200913_P5_11

  #define DATADIR /isibhv/projects/polmet/Expeditionen/MOSAiC_ACA

! ------------------------------------------------------------------------------

! ------------------------------------------------------------------------------
! Nomenklatur:  aus DMS channeldumps                    .dat
!               direkter Wandel in binär, DMStoBin.k:   .bin
!               nach preprep:                           .preprep
!
! ------------------------------------------------------------------------------
#define EINS    1 ! bleibt immer gleich, für Plottingschalter
#define PI180   (3.141592653589793/180.0)
! ------------------------------------------------------------------------------
! ------------------------------------------------------------------------------


#if DOGPS ! ---------------------------------------------------------------- gps
! ******************************************************************************

   ! Novatel DL-V3  OEM V Manual om-20000119.pdf
   !
   ! We take the gps position (and velocity for cross-check) from gprmc
   ! as we have more digits there. From gpgga we really only need the height.
   ! Vertical and horizontal speeds we take from bestvel.

   from = 1
   If {flight} == 20200806_P5_01  from = 1650
   If {flight} == 20200811_P5_00  from =    1   !  Bodenlauf
   If {flight} == 20200830_P5_02  from = 1800
   If {flight} == 20200831_P5_03  from = 1000
   If {flight} == 20200831_P5_04  from =  800
   If {flight} == 20200902_P5_05  from =  700
   If {flight} == 20200904_P5_06  from =  850
   If {flight} == 20200907_P5_07  from = 1800
   If {flight} == 20200908_P5_08  from =  800
   If {flight} == 20200910_P5_09  from =  800
   If {flight} == 20200911_P5_10  from =  900
   If {flight} == 20200913_P5_11  from =  650


   Read DATADIR/Bin/{flight}_gps.bin  from: from    t_gpgga   t_gprmc t_dms_gpgga t_dms_gprmc lon_gprmc lat_gprmc h_gpgga gs_gprmc ttrk_gprmc
   Read DATADIR/Bin/{flight}_gps.bin  from: from*10 t_dms_bestvel  gs_bestvel ttrk_bestvel w_bestvel  latency_bestvel

   ! Diese -0.01 bei der Mindestbedingung von first(t_dms) ist, weil
   ! offensichtlich bei spaetem Start (21h UTC) der erste Wert beim Vergleich
   ! mit sich selbst dann doch schon rausfaellt. Da wir sekuendliche Werte
   ! haben, kann die Bedingung sogar schadlos auf x-0.5 gesetzt werden.
   ! However, now with BESTVELA we have 10Hz data !

   CorrSpike t_gpgga       min:first(t_gpgga)             method: replace new:t_gpgga+86400       rejectlimit:99  ! add 24h for flights running over midnight
   CorrSpike t_gprmc       min:first(t_gprmc)             method: replace new:t_gprmc+86400       rejectlimit:99  ! add 24h for flights running over midnight
   CorrSpike t_dms_gprmc   min:first(t_dms_gprmc)-0.01    method: replace new:t_dms_gprmc+86400   rejectlimit:99  ! add 24h for flights running over midnight
   CorrSpike t_dms_gpgga   min:first(t_dms_gpgga)-0.01    method: replace new:t_dms_gpgga+86400   rejectlimit:99  ! add 24h for flights running over midnight
   CorrSpike t_dms_bestvel min:first(t_dms_bestvel)-0.01  method: replace new:t_dms_bestvel+86400 rejectlimit:99  ! add 24h for flights running over midnight

   gs_gprmc   =    gs_gprmc * ( 1.852 / 3.6 )

   t_bestvel = t_dms_bestvel ! - latency_bestvel



   ! Da wir nun bestvel mit 10Hz haben, nehmen wir das als Basis
   ! und interpolieren alle gps-Daten auf die Zeit von bestvel.
   ! Fuer gpgga und gprmc die gps-Zeit nehmen.


   ! Fuer den missing-sample Indicator vor der Interpolation die Zeit ableiten:
   !
   dt_gpgga   = diff(t_gpgga)
   dt_gprmc   = diff(t_gprmc)
   dt_bestvel = diff(t_bestvel)

   #if EINS == 1
      ! This is essentially for finding the amount of data to be skipped at the beginning.
      Typlot
         Setup  name: PLOT-{flight}-gps_before_interpolation.ps
         Header      "PLOT-{flight}-gps_before_interpolation"

         Series    h_gpgga addabs:0  thick:5
         Series ttrk_gprmc Cyclic from:0 to:360  btd:90 std:30  ygrid:coarse
         Series   gs_gprmc addabs:0
         Series   dt_gprmc

         Default deltax:0.1
         Series  w_bestvel addabs:0
         Series dt_bestvel line:0 thick:6
   #endif



   ! find common time coverage
   !
   Cat zeit_a = (first(t_gpgga)) (first(t_gprmc)) (first(t_bestvel))
   Cat zeit_e =  (last(t_gpgga))  (last(t_gprmc))  (last(t_bestvel))

   Create  t_gps  from: nint(max(zeit_a)+1) to: nint(min(zeit_e)-1)  elements:   10*(nint(min(zeit_e)-1)-nint(max(zeit_a)+1))+1



   ! Auf gemeinsame Zeitachse inerpolieren.
   !
   ! Richtungsgroessen bekommen eine Sonderbehandlung
   !
   Loop qq Set gprmc bestvel
      sinttrk_{qq} = sin(ttrk_{qq}*PI180)
      costtrk_{qq} = cos(ttrk_{qq}*PI180)

      Interpolate  sinttrk_{qq}  t_{qq}  t_gps
      Interpolate  costtrk_{qq}  t_{qq}  t_gps

      ttrk_{qq} = atan2 (-sinttrk_{qq}) (-costtrk_{qq}) / PI180 + 180
      Remove sinttrk_{qq} costtrk_{qq}
   Endloop

   ! den Rest einfach linear interpolieren
   !
   Loop qq Set gs_bestvel w_bestvel dt_bestvel lon_gprmc lat_gprmc gs_gprmc dt_gprmc  h_gpgga  dt_gpgga
   .    tt Set  t_bestvel t_bestvel  t_bestvel   t_gprmc   t_gprmc  t_gprmc  t_gprmc  t_gpgga   t_gpgga

      Interpolate  {qq}  {tt}  t_gps
   Endloop
   Remove  zeit_?  t_dms_bestvel  t_dms_gpgga t_dms_gprmc t_bestvel t_gpgga t_gprmc



   ! missing-sample Indicator:
   !
   Indicator   i1        = dt_bestvel  max:0.21  ! wir lassen ein fehlendes Sample zu, ggf. halbe Samplerate
   Indicator   i2        = dt_gprmc    max:2.1   ! wir lassen ein fehlendes Sample zu, ggf. halbe Samplerate
   Indicator   i3        = dt_gpgga    max:2.1   ! wir lassen ein fehlendes Sample zu, ggf. halbe Samplerate
   Indicator   miss_gps  = i1+i2+i3    max:0.5   ! wenn nur einer der drei ein fehlendes Sample hat
   Remove i? dt_*


   Remove latency_bestvel  ttrk_gprmc  gs_gprmc

   Rename  lon_gprmc    lon_gps
   Rename  lat_gprmc    lat_gps
   Rename    h_gpgga      h_gps
   Rename   gs_bestvel   gs_gps
   Rename    w_bestvel    w_gps
   Rename ttrk_bestvel ttrk_gps


   #define  PI180  (3.141592653589793/180.0)
   vew_gps = gs_gps * sin(ttrk_gps*PI180)
   vns_gps = gs_gps * cos(ttrk_gps*PI180)


   #if EINS == 0
      Typlot
         Setup  name: PLOT-{flight}-gps.ps
         Header      "PLOT-{flight}-gps"
         Abscissa label: UTC units:s
         Default deltax:0.1 start:first(t_gps) thick:6

         Series  lat_gps units: "\260"
         Series  lon_gps units: "\260"

         Series ttrk_gps units: "\260" Cyclic      from:0  to:360  btd:90 std:30 ygrid:coarse  line:0

         Series  vew_gps               scale:innext      colour:brown
         Series  vns_gps units: m/s    addabs:0          colour:blue   label: "'vew (brown)'" label: "'vns (blue)'"

         Series    h_gps units: m                  from:0
         Series    w_gps units: m/s    addabs:0
         Series miss_gps               height:1    from:0 to:1.4 btd:1
   #endif


   #if EINS == 0
      Xyplot
         Setup width: 15 height:4 Portrait xmargin:0.1 csf:2 name:PLOT-{flight}-path.ps
         Xaxis unitmode:hhmm  label: " " btd:60 std:15 ttd:5
         Yaxis from:0 units:m label: " "
         Curve t_gps/60 h_gps thick:6 colourscale:h_gps/3000
         Keepopen x:0 y:1

      LLplot
         Setup width:15 height:20 xmargin:0 ymargin:0.1 ! scale:3500000 ! lat0:-67 lon0:-61  scale:1000000  scaleposx:0.5
         Xaxis label: " "
         Yaxis label: " "
         Curve lon_gps lat_gps  thick:6   Noclip colourscale:h_gps/3000
         Legend 0 1.02 Right  "GPS, {flight}"
   #endif

   ! Ascii Output, wenn waehrender der Kampagne eilige Leute schonmal die Daten wollen.
   ! If -e                 {flight}_gps.asc  System rm DATADIR/Preprep/{flight}_gps.asc
   ! Print Nocounter file: {flight}_gps.asc %6.3 t_gps  %4 h_gps %3.1 w_gps %3.1 gs_gps ttrk_gps %3.5 lat_gps lon_gps %3.1 vew_gps vns_gps

   #IF WRITE Write DATADIR/Preprep/{flight}_gps.preprep  d:t_gps h_gps gs_gps ttrk_gps lat_gps lon_gps vew_gps vns_gps w_gps c:miss_gps
   Remove                                                  t_gps h_gps gs_gps ttrk_gps lat_gps lon_gps vew_gps vns_gps w_gps   miss_gps

#endif ! DOGPS ------------------------------------------------------------- gps



#if DOINS ! --------------------------------------------------------------------
! ******************************************************************************

   insfrom = 4                                     ! gilt fuer die 50 Hz Daten.
   If {flight} == 20200806_P5_01  insfrom =  70000
   If {flight} == 20200830_P5_02  insfrom =  80000
   If {flight} == 20200831_P5_03  insfrom =  50000
   If {flight} == 20200831_P5_04  insfrom =  40000
   If {flight} == 20200902_P5_05  insfrom =  30000
   If {flight} == 20200904_P5_06  insfrom =  40000
   If {flight} == 20200907_P5_07  insfrom =  90000
   If {flight} == 20200908_P5_08  insfrom =  40000
   If {flight} == 20200910_P5_09  insfrom =  40000
   If {flight} == 20200911_P5_10  insfrom =  40000
   If {flight} == 20200913_P5_11  insfrom =  30000


   Read DATADIR/Bin/{flight}_ins.bin  from:insfrom/4   vew_*  vns_*   lon_*  lat_*
   Read DATADIR/Bin/{flight}_ins.bin  from:insfrom/2  thdg_*    h_*  ttrk_*   gs_*
   Read DATADIR/Bin/{flight}_ins.bin  from:insfrom     pit_* roll_*   azg_*    w_*
   Read DATADIR/Bin/{flight}_ins.bin  from:insfrom*2   axf_*  ayf_*   azf_* pitr_*  rolr_*  yawr_*


   Loop name Set axf ayf azf pitr rolr yawr  pit roll azg w  thdg h ttrk gs  vew vns lon lat
   .    dt   Set 1   1   1   1    1    1     2   2    2   2  4    4 4    4   8   8   8   8

      CorrSpike {name}_hh min:first({name}_hh) method: replace new:{name}_hh+24 rejectlimit:99  ! add 24h for flights running over midnight
         t_{name}_ins = {name}_hh*3600+{name}_mm*60+{name}_ss
         Remove {name}_hh {name}_mm {name}_ss
   Endloop


   #if EINS == 1

      ! Die Frequenzen 100, 50, 25, 12.5 Hz werden nicht ganz erreicht.

      Typlot
         Header      PLOT-{flight}-INS-Frequenz-1 /size0.7 "  base freq. 50Hz"
         Setup name: PLOT-{flight}-INS-Frequenz-1.ps

         !  50 Hz
         Series diff(t_pit_ins)
         Series diff(t_roll_ins)
         Series diff(t_azg_ins)
         Series diff(t_w_ins)

         ! 100 Hz
         Default deltax:0.5
         Series diff(t_axf_ins)
         Series diff(t_ayf_ins)
         Series diff(t_azf_ins)
         Series diff(t_pitr_ins)
         Series diff(t_rolr_ins)
         Series diff(t_yawr_ins)
      Echo
   #endif

   #if EINS == 1

      Typlot
         Header      PLOT-{flight}-INS-Frequenz-2 /size0.7 "  base freq. 50Hz"
         Setup name: PLOT-{flight}-INS-Frequenz-2.ps

         Default deltax:2
         Series diff(t_h_ins)
         Series diff(t_thdg_ins)
         Series diff(t_ttrk_ins)
         Series diff(t_gs_ins)

         Default deltax:4
         Series diff(t_vew_ins)
         Series diff(t_vns_ins)
         Series diff(t_lon_ins)
         Series diff(t_lat_ins)
      Echo
   #endif


   #if EINS == 1
      Xyplot
         Setup name: PLOT-{flight}-INS-timing.ps
         Legend 0.5 1.05 Above "{flight}, accummulated deviation from 50Hz, INS"
         Xaxis  label: t_ins units:s
         Yaxis  label: dt    units:s

         Loop qq Set axf ayf azf pitr rolr yawr pit roll azg w h thdg ttrk gs vew vns lon lat
         .    dt Set 1   1   1   1    1    1    2   2    2   2 4 4    4    4  8   8   8   8
            Curve  t_{qq}_ins t_{qq}_ins-first(t_{qq}_ins)-(create(nele(t_{qq}_ins))-1)*0.0{dt}
         Endloop
      Echo
   #endif



   #if EINS == 0
      ! Demo der Zeitpunkte der Samplenahme.

      ! Wir erstellen zu jeder der Zeitangaben eine Serie mit konstantem Wert.
      Loop qq Set axf ayf azf pitr rolr yawr pit roll azg w thdg h ttrk gs vew vns lon lat
      .    n  Count
         {qq}_n = t_{qq}_ins * 0 + {n}
      Endloop


      Xyplot
         Setup grid:fine  width: 22 xmargin:0.1
         Xaxis from:41013.7 to:41014.5

         Loop qq Set axf ayf azf pitr rolr yawr pit roll azg w thdg h ttrk gs vew vns lon lat
            Curve t_{qq}_ins {qq}_n  line:0  thick:12 colour:red
         Endloop
   #endif


   ! Fuer den missing-sample Indicator vor der Interpolation die Zeit ableiten:

   Loop qq Set axf ayf azf pitr rolr yawr pit roll azg w h thdg ttrk gs vew vns lon lat
      dt_{qq}_ins = diff(t_{qq}_ins)
   Endloop


   ! Erzeugen einer neuen Zeitbasis.
   ! Wir nehmen das erste Element der langsamsten Serie und addieren 2s.
   ! Und das letzte Element ... minus 2.
   ! Wenn dann trotzdem irgendwann Extrapolationsprobleme auftreten,
   ! koennen wir immer noch was geschickteres machen.

   t1 === first(t_lon_ins)+2 decimals:0
   t2 ===  last(t_lon_ins)-2 decimals:0
   Create  t_ins  from:t1 to:t2  elements: 50*(t2-t1)+1
   Remove t1 t2



   ! Interpolieren
   !
   ! lon, lat: Die Positionsgenauigkeit des INS ist ca. 1km,
   ! je nach Manöverintensität. Bei Unterschallgeschwindigkeiten reicht dann
   ! eine Positionsberechnung mit ca. 2Hz, und so wird es intern scheinbar auch
   ! gemacht. lon, lat werden aber mit 12.5Hz ausgegeben, was wohl mit
   ! Wiederholung der Werte realisiert wird. Das gibt Stufen und die sind
   ! manchmal unschoen. Daher interpolieren wir per stepint.
   ! vew und vns werden ebenfalls mit 12.5Hz ausgegeben und auch hier treten
   ! gelegentlich wiederholte Werte auf.
   ! Bei anderen Größen habe ich es bisher nicht beobachtet.
   !
   ! xx = stepint(vew_ins)
   ! Print from:150000 %4.6  lat_ins lon_ins  vns_ins   vew_ins   xx

   Loop qq Set axf ayf azf pitr rolr yawr pit roll azg w h gs
      Interpolate     {qq}_ins  t_{qq}_ins  t_ins  !  Avedble
      Interpolate  dt_{qq}_ins  t_{qq}_ins  t_ins  !  Avedble
      Remove t_{qq}_ins
   Endloop

   Loop qq Set  vew vns lon lat
      Interpolate     {qq}_ins = stepint({qq}_ins) t_{qq}_ins  t_ins  !  Avedble
      Interpolate  dt_{qq}_ins  t_{qq}_ins  t_ins  !  Avedble
      Remove t_{qq}_ins
   Endloop

   ! Richtungsgroessen bekommen eine Spezialbehandlung
   !

   sinthdg_ins = sin(thdg_ins*PI180)
   costhdg_ins = cos(thdg_ins*PI180)

   Interpolate  sinthdg_ins  t_thdg_ins  t_ins ! Avedble
   Interpolate  costhdg_ins  t_thdg_ins  t_ins ! Avedble
   Interpolate  dt_thdg_ins  t_thdg_ins  t_ins ! Avedble

   thdg_ins = atan2 (-sinthdg_ins) (-costhdg_ins) / PI180 + 180
   Remove sinthdg_ins costhdg_ins t_thdg_ins


   sinttrk_ins = sin(ttrk_ins*PI180)
   costtrk_ins = cos(ttrk_ins*PI180)

   Interpolate  sinttrk_ins  t_ttrk_ins  t_ins  ! Avedble
   Interpolate  costtrk_ins  t_ttrk_ins  t_ins  ! Avedble
   Interpolate  dt_ttrk_ins  t_ttrk_ins  t_ins  ! Avedble

   ttrk_ins = atan2 (-sinttrk_ins) (-costtrk_ins) / PI180 + 180
   Remove sinttrk_ins costtrk_ins t_ttrk_ins



   ! missing-sample Indicator:
   miss_ins = lon_ins*0
   Loop qq Set axf ayf azf pitr rolr yawr pit roll azg w  h  thdg ttrk gs vew  vns  lon  lat
   .    xx Set 100 100 100 100  100  100  50  50   50  50 25 25   25   25 12.5 12.5 12.5 12.5

      Indicator  ii = dt_{qq}_ins  max:2.1/{xx}  ! wir lassen ein fehlendes Sample zu, ggf. halbe Samplerate
      miss_ins = miss_ins + ii
   Endloop
   Remove ii
   Indicator   miss_ins    max:0.5   ! wenn nur einer der drei ein fehlendes Sample hat
   Remove dt_*_ins


   ! Umrechung in metrische SI-Einheiten
   gs_ins   =  gs_ins * (1852/3600) ! Umrechung (kt) in (m/s)
   vns_ins  = vns_ins * (1852/3600) ! Umrechung (kt) in (m/s)
   vew_ins  = vew_ins * (1852/3600) ! Umrechung (kt) in (m/s)


   #if EINS == 1
      Typlot
         Setup name: PLOT-{flight}-INS-interpolated-1.ps
         Header      PLOT-{flight}-INS-interpolated-1
         Abscissa to:200000

         Series vew_ins    addabs:0
         Series vns_ins    addabs:0
         Series gs_ins     from:0 ! to:150
         Series thdg_ins   colour:red scale:innext Cyclic
         Series ttrk_ins   from:0 to:360  btd:90 std:30 Cyclic
         Series roll_ins   addabs:0
         Series pit_ins    addabs:0
         Series miss_ins   height:1    from:0 to:1.4 btd:1  thick:6
   #endif

   #if EINS == 1
      Typlot
         Setup name: PLOT-{flight}-INS-interpolated-2.ps
         Header      PLOT-{flight}-INS-interpolated-2

         Series lon_ins
         Series lat_ins
         Series h_ins     addabs:0
         Series w_ins     addabs:0
         Series azg_ins
         Series miss_ins   height:1    from:0 to:1.4 btd:1  thick:6
   #endif

   #if EINS == 1
      Typlot
         Setup name: PLOT-{flight}-INS-interpolated-3.ps
         Header      PLOT-{flight}-INS-interpolated-3

         Series axf_ins    addabs:0
         Series ayf_ins    addabs:0
         Series azf_ins    addabs:0
         Series pitr_ins   addabs:0
         Series rolr_ins   addabs:0
         Series yawr_ins   addabs:0
         Series miss_ins   height:1    from:0 to:1.4 btd:1  thick:6
   #endif


   #if EINS == 1

      ! This is to check pitchrate against the derivative of pitch,
      ! in order to decide if d(pitch)/dt is sufficient for selecting
      ! data for the alpha calibration.
      ! It seems that pitch and the derivative thereof is more suitable.
      ! I understand that pitch is always defined with respect to the Earth horizon,
      ! whereas pitch rate seems to be defined in the aicraft's coordinate system.
      ! Thus d(pitch)/dt and pitch rate differ in turns.

      dpitchdt = diff(pit_ins)*50
      NFilter dpitchdt             n:351
      NFilter pitchrate = pitr_ins n:351

    ! TFilter dpitchdt  dt:0.02 pass:lp  cutoff: 1/7

      Typlot
         Setup name: PLOT-{flight}-INS-pitchratecheck.ps
         Header      PLOT-{flight}-INS-pitchratecheck

       ! Abscissa from: 335000 to:400000
         Series roll_ins           addabs:0
         Series dpitchdt            scale:innext  colour:blue
         Series pitchrate          addabs:0

         Series diff(pit_ins)*50-pitr_ins

         Series int(pitr_ins)*0.02 scale:innext   colour:blue
         Series pit_ins           addabs:0

      Remove dpitchdt pitchrate
   #endif


   #IF WRITE Write DATADIR/Preprep/{flight}_ins.preprep  d:t_ins lat_ins lon_ins gs_ins ttrk_ins thdg_ins vns_ins vew_ins pit_ins roll_ins pitr_ins rolr_ins yawr_ins axf_ins ayf_ins azf_ins azg_ins w_ins h_ins c:miss_ins
   Remove                                                  t_ins lat_ins lon_ins gs_ins ttrk_ins thdg_ins vns_ins vew_ins pit_ins roll_ins pitr_ins rolr_ins yawr_ins axf_ins ayf_ins azf_ins azg_ins w_ins h_ins   miss_ins

#endif ! DOINS ------------------------------------------------------------- ins


#if DONM ! ----------------------------------------------------------- Nasenmast
! ******************************************************************************

   ! Bei Aflux war das Vaisala am Nasemast ausgefallen.

   nmfrom = 100
   If {flight} == 20200806_P5_01  nmfrom = 120000
   If {flight} == 20200830_P5_02  nmfrom = 160000
   If {flight} == 20200831_P5_03  nmfrom = 100000
   If {flight} == 20200831_P5_04  nmfrom =  30000
   If {flight} == 20200902_P5_05  nmfrom =  10000
   If {flight} == 20200904_P5_06  nmfrom =  10000
   If {flight} == 20200907_P5_07  nmfrom = 100000
   If {flight} == 20200908_P5_08  nmfrom =  10000
   If {flight} == 20200910_P5_09  nmfrom =  10000
   If {flight} == 20200911_P5_10  nmfrom =  10000
   If {flight} == 20200913_P5_11  nmfrom =  10000


   Loop qq Set ps qa qb qc Tej Te_ Thu  rFHu
      Read DATADIR/Bin/{flight}_nm.bin from: nmfrom     {qq}N {qq}N_hh {qq}N_mm {qq}N_ss
      CorrSpike {qq}N_hh min:first({qq}N_hh) method: replace new:{qq}N_hh+24 rejectlimit:99  ! add 24h for flights running over midnight
      t_{qq}N = {qq}N_hh*3600+{qq}N_mm*60+{qq}N_ss
      Remove {qq}N_hh {qq}N_mm {qq}N_ss
   Endloop

      Read DATADIR/Bin/{flight}_nm.bin from: nmfrom/20  pssN pssN_hh pssN_mm pssN_ss
      CorrSpike pssN_hh min:first(pssN_hh) method: replace new:pssN_hh+24 rejectlimit:99     ! add 24h for flights running over midnight
      t_pssN = pssN_hh*3600+pssN_mm*60+pssN_ss
      Remove pssN_hh pssN_mm pssN_ss


   !  Check for missing samples based on time and frequency.

   #if EINS == 1

      Typlot
         Header      PLOT-{flight}-nm-Frequenz-1
         Setup name: PLOT-{flight}-nm-Frequenz-1.ps
      !  Abscissa    to:10000

         Series diff(t_psN)
         Series diff(t_qcN)
         Series diff(t_qaN)
         Series diff(t_qbN)
         Series diff(t_pssN)  deltax:20  ! 5Hz
   #endif

   #if EINS == 1

      Typlot
         Header      PLOT-{flight}-nm-Frequenz-2
         Setup name: PLOT-{flight}-nm-Frequenz-2.ps
       ! Default from:0

         Series diff(t_TejN)
         Series diff(t_Te_N)

   !  Echo ! This is the limiter for Typlot
   #endif


   #if EINS == 1
      ! accummulated differences to 100Hz
      Xyplot
         Setup  width:22 xmargin:0.1
         Legend 0.1 0.9 Right {flight}
         Xaxis  label: t_nm units:s
         Yaxis  label: dt   units:s ! from: 0

         Loop qq Set psN qcN qaN qbN        ThuN rFHuN TejN Te_N
         .    cc Count
            Curve  t_{qq}   t_{qq}-first(t_{qq})-(create(nele(t_{qq}))-1)*0.01       colour: {cc}
         Endloop
   #endif



   #if EINS == 1
      Typlot
         Header      PLOT-{flight}-nm-volts-1
         Setup name: PLOT-{flight}-nm-volts-1.ps

         Series pssN  deltax:20
         Series psN
         Series qcN  addabs:0
         Series qaN  addabs:0
         Series qbN  addabs:0
      Echo
   #endif

   #if EINS == 1
      Typlot
         Header      PLOT-{flight}-nm-volts-2
         Setup name: PLOT-{flight}-nm-volts-2.ps

         Series TejN
         Series Te_N
      Echo
   #endif


   ! Fuer den missing-sample Indicator vor der Interpolation die Zeit ableiten:

   Loop qq Set ps qa qb qc Tej Te_  pss
      dt_{qq}N = diff(t_{qq}N)
   Endloop



   ! Erzeugen einer neuen Zeitbasis.
   ! Wir nehmen den spaetesten Anfang und das frueheste Ende.
   !
   Loop qq Series t_*
      Append azeit first({qq})
      Append ezeit  last({qq})
   Endloop

   t1 === max(azeit)+1 decimals:0
   t2 === min(ezeit)-1 decimals:0
   Create  t_nm  from:t1 to:t2  elements: 100*(t2-t1)+1  !  100 Hz

   Remove t1 t2 azeit ezeit


   ! Interpolieren
   !

   Loop qq Set pssN psN qcN qaN qbN  TejN Te_N
      Interpolate    {qq}  t_{qq}  t_nm
      Interpolate dt_{qq}  t_{qq}  t_nm
      Remove t_{qq}
   Endloop


   ! missing-sample Indicator:
   miss_nm = psN*0
   Loop qq Set psN qcN qaN qbN TejN Te_N pssN
   .    xx Set 100 100 100 100 100  100  5

      Indicator  ii = dt_{qq}  max:2.1/{xx}  ! wir lassen ein fehlendes Sample zu, ggf. halbe Samplerate
      miss_nm = miss_nm + ii
   Endloop
   Remove ii
   Indicator   miss_nm    max:0.5   ! wenn nur einer der drei ein fehlendes Sample hat
   Remove dt_*N


   ! ---------------------------------------------------------------------------
   ! Volts to physical values.



   ! Polar 5 ---------------------------------------------------------------
   !                                                                                  -- file name ---  --- Manuels Liste ---
     psN = 500.02039    + 120.02213 * psN                                 ! 20170524  Setra278_5.SPF    SN:  6931473 SPF5
     qaN = -18.68344    +   3.73608 * qaN                                 ! 20170526  Setra239R_6.DPA   SN:  6937827 DPA3
     qbN = -18.70227    +   3.73749 * qbN                                 ! 20170526  Setra239R_7.DPB   SN:  6937826 DPB3
     qcN = -0.0132129   +   7.47140 * qcN                                 ! 20170526  Setra239R_8.DP    SN:  6937824 DP6
    TejN = -241.797692  + 2.3294279 * TejN + 0.00090811718 * TejN * TejN  ! 20130118  RM102EJ2BB_2.TATD SN:   14663E TATD2
    Te_N = -241.511754  + 2.3194197 * Te_N + 0.00096298917 * Te_N * Te_N  ! 20130119  RM102E102BV_1.TAT SN:    70511 TAT1
   !
   ! 20170608: Polar 5 Seriennummern anhand von Martins Fotos geprueft.


   #if EINS == 1
      Typlot
         Setup  name:PLOT-{flight}-nm-Druecke.ps
         Header      PLOT-{flight}-nm-Druecke

         Series psN   scale:innext           colour: black
         Series pssN label: Pstat units:hpa  colour: blue
         Legend 0.1  0.9 Right "blue: pssN, black: psN"

         Series pssN-psN   addabs:0 line:0

         Series qcN  addabs:0     units:hpa ! from: -5 to:50  colour:black  label:Pdyn label: "blue:qTd" units:hpa
         Series qaN  addabs:0     units:hpa ! from: -2 to:18
         Series qbN  addabs:0     units:hpa !  from: -1 to:1   !line:0 thick:6
   #endif


   #if EINS == 1
      Typlot
         Setup  name: PLOT-{flight}-nm-temp.ps
         Header       PLOT-{flight}-nm-temp

       ! Abscissa from:1000000 to:1000100

         Series Te_N       scale:innext colour:red
         Series TejN      addabs:0      colour:blue  label: TejN(blue)  label:Te_N(red) units: "\260 C"

         Series Te_N-TejN  addabs:0  ! from:-2 to:0.5
   #endif


   #IF WRITE Write DATADIR/Preprep/{flight}_nm.preprep d:t_nm pssN psN qcN qaN qbN  Te_N TejN c:miss_nm
   Remove                                                t_nm pssN psN qcN qaN qbN  Te_N TejN   miss_nm

#endif ! DONM --------------------------------------------------------------- nm


Endloop