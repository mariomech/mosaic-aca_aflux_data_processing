
! Here we do those processings after individual sensor calibrations,
! that involve data from different data stream.

! #define DOGPSINS            ! support INS data by GPS
  #define NASENMAST           ! 100 Hz: AD-Kanäle, INS must have been done.

  #define WRITE


  #define DATADIR    /isibhv/projects/polmet/Expeditionen/MOSAiC_ACA



#define PI180  (3.141592653589793/180.0)
#define EINS   1  ! bleibt immer gleich, für Plottingschalter



Loop flight Set   20200806_P5_01 20200830_P5_02 20200831_P5_03 20200831_P5_04 20200902_P5_05 20200904_P5_06 20200907_P5_07 20200908_P5_08 20200910_P5_09 20200911_P5_10 20200913_P5_11


#if DOGPSINS ! ========================================================== INSGPS

   ! ========================================================== INS-Daten lesen
   ! INS-Daten lesen, und mit GPS korrigieren. Diese werden dann als ...ins.prep
   ! abgelegt, da sie für den Nasenmast, wie auch die Strahlungsdaten gebraucht
   ! werden.


   Read  DATADIR/Preprep/{flight}_ins.preprep  t_ins  lon_ins lat_ins gs_ins ttrk_ins vns_ins vew_ins thdg_ins pit_ins roll_ins pitr_ins rolr_ins yawr_ins azg_ins axf_ins ayf_ins azf_ins miss_ins
   Read  DATADIR/Preprep/{flight}_gps.preprep  t_gps  lon_gps lat_gps gs_gps ttrk_gps vns_gps vew_gps w_gps h_gps miss_gps



   ! Kreuzkorrelation von INS und GPS -Geschwindigkeiten zeigt, dass
   ! INS wird um 0.07s gegenueber gps vorgezogen werden soll.
   !

!  t_ins = t_ins - 0.07  !  getestet fuer AirMethII
   t_ins = t_ins - 0.03  !  getestet fuer AirMethIV, passt besser, 20170502.


   ! --------------------------------------------------------------------------
   ! Überlappungsbereich von INS und GPS finden.

   zeit_a = max2 (first(t_ins)) (first(t_gps))  ! in Sekunden seit Mitternacht
   zeit_e = min2 (last(t_ins))  (last(t_gps))   ! in Sekunden seit Mitternacht


   ! ggf. INS auf gps Zeit kürzen

   CorrSpike  min:zeit_a max:zeit_e method:omit indicator:t_ins t_ins          lat_ins lon_ins gs_ins ttrk_ins thdg_ins vns_ins vew_ins pit_ins roll_ins pitr_ins rolr_ins yawr_ins azg_ins axf_ins ayf_ins azf_ins miss_ins


   Remove zeit_a zeit_e



   dt = 0.02
   ! Vertikalgeschwindigkeit w_ins aus azg_ins integrieren:
   ! WELMEC-Formel für Schwerebeschleunigung:
   g  = 9.780318 * (1 + 0.0053024 * sin(lat_ins*PI180)*sin(lat_ins*PI180) - 0.0000058 * sin(2*lat_ins*PI180) * sin(2*lat_ins*PI180) ) - 0.000003085 ! * h_gps



   w_ins = dt * int(azg_ins*g)



   ! ----------------------------------------------- GPS-Korrektur der INS-Daten

   ! gps auf INS interpolieren

   ! Da wir beim linearen Interpolieren von Richtungsgrößen bei Nord Fehler
   ! einfangen können, rechnen wir fortan mit sin, cos weiter.

   sinttrk_gps = sin(ttrk_gps*PI180)
   costtrk_gps = cos(ttrk_gps*PI180)

   Remove ttrk_gps
   Loop qq Set  gs_gps sinttrk_gps costtrk_gps vns_gps vew_gps  lon_gps lat_gps h_gps w_gps  miss_gps
      Interpolate {qq} t_gps t_ins  ! Avedble  ! Avedble wg. einiger Doubletten in der GPS-Datei.
   Endloop
   Remove t_gps


   #if EINS == 1
      Typlot
         Setup name:PLOT-{flight}_gps_ins.ps
         Header "gps (blue), ins (red), before correction of INS-components, {flight}"

         Series lon_gps  scale:innext colour:blue
         Series lon_ins  label:lon    colour:red

         Series lat_gps  scale:innext colour:blue
         Series lat_ins  label:lat    colour:red

         Series  gs_gps  scale:innext colour:blue
         Series  gs_ins  label:gs     colour:red
      Echo
   #endif


   ! ----------------- Check timing of ins and gps data.
   #if EINS == 0

   ! Dies könnte abschnittsweise geprüft werden, um zu sehen,
   ! ob sich der Lag mit der Flugzeit ändert.

   Loop ss Set  -20 -10 0 10  20

      vns_i = shift ({ss}) vns_ins
      vew_i = shift ({ss}) vew_ins

      vns_g =              vns_gps
      vew_g =              vew_gps

      #define OPTIONS lags:51 outlags:lag

      Loop qq Set vns_i vew_i vns_g vew_g
         FFilter {qq}  lowcut:0.001       dt:0.01
      Endloop

      Correlation cv =  vns_g vns_i OPTIONS
      Correlation cu =  vew_g vew_i OPTIONS

      Xyplot
         Setup  grid:fine Portrait name:PLOT-{flight}_lag_ins_gps.ps
         Legend 0.5 1.05 Above {flight}, shift:{ss}
         Xaxis  ttd:1 std:5 btd:10
         Yaxis ! to:1.001
         Curve  lag  cv  b:1
      !  Curve -lag  cv  b:1
         Curve  lag  cu  r:1
      !  Curve -lag  cu  r:1
         Keepopen  gppv:5

      Remove lag cv cu vns_i vew_i vns_g vew_g
   Endloop
   #endif
   ! ----------------- Timing of ins and gps data checked.


   FFilter w_ins dt:dt lowcut:1/(84*60)
   h_ins = dt * int(w_ins)
   Remove g


   ! Bei kleinen Pitchwinkeln (<2) scheint int(azg) zu negativen
   ! Vertikalgeschwindigkeiten zu fuehren. So jedenfalls bei ein
   ! paar Stichproben mit AirBASe-Daten.



   ! gps-Korrektur der INS-Geschwindigkeiten sowie lat, lon

   Loop qq Set lon lat vew vns gs h w
      FFilter  dd = {qq}_ins-{qq}_gps          dt:dt highcut:1/10
      {qq}_a = {qq}_ins - dd
      Remove dd
   Endloop



   ! Die GPS-stabilisierten INS-Daten heissen ab jetzt x_a, a fuer aircraft.

   Rename vns_a v_a
   Rename vew_a u_a


   #if EINS == 1
      Typlot
         Setup name:PLOT-{flight}_diff_gps_ins.ps
         Header "gps-correction of INS-components, {flight}"
         Header /size0.7 "graph shows high frequency part of INS"
         Series lon_gps-lon_a
         Series lat_gps-lat_a
         Series  gs_gps-gs_a
         Series vns_gps-v_a
         Series vew_gps-u_a
         Series h_gps-h_a
         Series w_gps-w_a
         Series pit_ins
         Series miss_ins    height:1 from:0 to:1.4 btd:1
         Series miss_gps    height:1 from:0 to:1.4 btd:1
   #endif



   ! gps-Korrektur des INS-TrueTrack. INS-ttrk unterliegt der Schulerschwingung,
   ! INS-THDG verhaelt sich anders, wie ein Vergleich aus GPS-thdg aus
   ! den Daten des Antennenarrays mit Hilfe von GrafMov zeigt.

   sinttrk_ins = sin(ttrk_ins*PI180)
   costtrk_ins = cos(ttrk_ins*PI180)

   ! Differenz zwischen INS und GPS TrueTrack

   diffsin = sinttrk_gps - sinttrk_ins
   diffcos = costtrk_gps - costtrk_ins

   ! Für geringe Geschwindigkeiten setzen wir die Richtungsdifferenz auf null.
   CorrSpike diffsin diffcos  new:0 indicator:gs_a min:30
   ! Low-pass Filter bei ca. 15min.
   FFilter   diffcos diffsin  dt:dt highcut:1/1000


   ! Wird addiert auf insttrk

   sinttrk_a = sinttrk_ins + diffsin
   costtrk_a = costtrk_ins + diffcos



   Remove ttrk_ins  sinttrk_ins costtrk_ins

   ttrk_a   = atan2 (-sinttrk_a)   (-costtrk_a)   / PI180 + 180
   ttrk_gps = atan2 (-sinttrk_gps) (-costtrk_gps) / PI180 + 180


   Remove lat_ins lon_ins gs_ins vew_ins vns_ins w_ins h_ins diffsin diffcos
   Remove lat_gps lon_gps gs_gps vew_gps vns_gps sinttrk_gps costtrk_gps ttrk_gps dt


   #IF WRITE Write DATADIR/Prep/{flight}_ins.prep d:t_ins pit_ins roll_ins pitr_ins rolr_ins yawr_ins azg_ins axf_ins ayf_ins azf_ins lon_a lat_a u_a v_a gs_a sinttrk_a costtrk_a ttrk_a thdg_ins h_a w_a h_gps w_gps c:miss_gps c:miss_ins
   Remove                                           t_ins pit_ins roll_ins pitr_ins rolr_ins yawr_ins azg_ins axf_ins ayf_ins azf_ins lon_a lat_a u_a v_a gs_a sinttrk_a costtrk_a ttrk_a thdg_ins h_a w_a h_gps w_gps   miss_gps   miss_ins

#endif ! DOGPSINS --------------------------------------------------------------




#if NASENMAST ! ====================================================== Nasenmast


   ! Nomenklatur
   ! qcN ist der fuer Sensoreigenschaften korrigierte dynamische Druck an der Position der Sonde.
   ! qc  ist der fuer Einbaufehler korrigierte Druck einer idealen Messung fernab des Flugzeugs.
   ! ThuN ist die Temperatur im Sensorgehauese
   ! Thu  ist die fuer Druckerhoehung korrigierte Temperatur.

   ! During Aflux we have no Vaisala humidity and temperature.
   ! I considered using the bmet data, but since the temperature was always
   ! well below zero and flights were often in clouds, where humidity
   ! measurements by the Vaisalas don't work anyway, I decided
   ! against using the humidity in the density calculation.

   Read DATADIR/Preprep/{flight}_nm.preprep     t_nm   miss_nm   qaN  qbN  qcN  psN  Te_N  TejN



   ! --------------------------------------------------------------------------
   ! 20210917, Christof will rFHuB in den Nasenmastdaten haben.

      Read DATADIR/Preprep/{flight}_bmet.preprep   t_bmet           rFHuB


      ta = max2(first(t_bmet))(first(t_nm))
      te = min2( last(t_bmet))( last(t_nm))


      Loop qq  Set  miss_nm   qaN  qbN  qcN  psN  Te_N  TejN t_nm

         CorrSpike  {qq}   min:ta max:te  indicator:t_nm  method:omit

      Endloop

      Interpolate rFHuB  t_bmet t_nm
      Remove t_bmet

   ! --------------------------------------------------------------------------



   ! ------------------------------------------------------------ alpha und beta


   If {flight} == 2020????_P5_?? Then

      ! Aflux 2019 -------------------------------------------------------------

      alpha = -1.3    + 10.0134 * qaN/qcN
      beta  =  0      + 10.0134 * qbN/qcN

         qc =   0.597 + 1.024 * qcN        ! 20190222: aktueller Stand mit Kalibrierung per Katalog_headingpairs_Acloud ...
         ps =     psN - 0.024 * qcN        ! dies koennen wir jetzt als ziemlich endgueltig ansehen.

      ! ---------------------------------------------------------------------------
   Else

      Stop
   Endif

   ! Vor den Start können die Druckverhältnisse an der 5-Lochsonde zu
   ! einem negativen Staudruck führen.

   CorrSpike qc min:0 new:0


   ! Gemaess der Empfehlung von Matthias setzen wir alpha, beta und
   ! probe_angle auf 0 für Staudrücke kleiner als 5 hpa.
   !
   CorrSpike alpha  beta  indicator: qc     min:5           method:replace new:0
   CorrSpike alpha  beta  indicator: alpha  min:-45 max:45  method:replace new:0
   CorrSpike alpha  beta  indicator: beta   min:-45 max:45  method:replace new:0


   #if EINS == 0

      Typlot
         Header      PLOT-{flight}_nm_pressure
         Setup  name:PLOT-{flight}_nm_pressure.ps

         Series ps          scale:innext              colour:black
         Series psN                                   colour:red

         Series qcN         scale:innext              colour:blue
         Series qc          addabs:0  from: -5 to:51  colour:black
         Legend 0.25 0.1 Right "blue: qcN"
         Legend 0.45 0.1 Right "black: qc"

         Series qaN         addabs:0 !from:   0 to:13
         Series qbN         addabs:0 !from:  -8 to: 8  ygrid:coarse

         Series alpha       addabs:0

         Series beta        addabs:0  from:  -5 to: 5  ygrid: coarse
   #endif


   ! Adiabatenformel zur Korrektur der bei Überdruck gemessenen Temperatur auf das ungestörte Druckniveau.


   T = (Te_N+273.15) * (psN/(psN+qcN))^0.2858964 -273.15   !  0.2858964 ist (R/cp)



   ! ---------------------------------------------------------------------- TAS
   !
   ! Staudruck q = 1/2 rho V^2, ==> V = sqrt ( 2 * q / rho ),
   ! q ist der Staudruck, rho wird aus p und T berechnet.

   rho  = ps / 287.058 / (T+273.15)

   tas  = sqrt ( 2 * qc / rho )


   #if EINS == 0

      Typlot
         Setup  name:PLOT-{flight}_nm_temperature.ps
         Header      PLOT-{flight}_nm_temperature

      !  Abscissa  from:1000000 to:1001000
         Series Te_N     scale:innext  colour:blue
         Series T        ygrid:fine
   #endif


   Remove  rho




   ! ---------------------------- Interpolation der INS-Daten auf die NM-Daten.
   Echo Interpolation der INS-Daten auf die NM-Daten. -------------------------

   Read DATADIR/Prep/{flight}_ins.prep
   Remove ttrk_a h_gps w_gps azg_ins  miss_gps


   sinthdg_a = sin(thdg_ins*PI180)
   costhdg_a = cos(thdg_ins*PI180)
   Remove thdg_ins


   ! Die Systeme werden unterschiedlich abgeschaltet und überlappen sich nicht 1:1.
   !
   tend   = min2 ( last(t_ins)) ( last(t_nm))
   tbegin = max2 (first(t_ins)) (first(t_nm))


   ! axf_ins ayf_ins azf_ins  nur fuer Matthias mitgeschleppt.
   CorrSpike t_ins miss_ins  method:omit min:tbegin max:tend indicator:t_ins  lat_a lon_a gs_a sinthdg_a costhdg_a sinttrk_a costtrk_a v_a u_a pit_ins roll_ins pitr_ins rolr_ins yawr_ins w_a h_a axf_ins ayf_ins azf_ins  ! ayf_ins
   CorrSpike t_nm  miss_nm   method:omit min:tbegin max:tend indicator:t_nm   qaN qbN   Te_N TejN alpha beta  ps qc T tas    rFHuB                    psN qcN


   Loop qq Set lat_a lon_a gs_a costhdg_a sinthdg_a costtrk_a sinttrk_a v_a u_a pit_ins roll_ins pitr_ins rolr_ins yawr_ins w_a h_a  axf_ins ayf_ins azf_ins miss_ins
      Interpolate {qq} t_ins t_nm
   Endloop

   miss_nm   = miss_nm + miss_ins
   Indicator   miss_nm    max:0.1   ! wenn nur einer der drei ein fehlendes Sample hat
   Remove      miss_ins

   Remove t_ins tend tbegin


   #if EINS == 0
   ! Im Mittel muß alpha = pitch sein.
      Xyplot
         Setup name:PLOT-{flight}_alpha_pitch.ps
         Setup width:22  xmargin:0  x0:2  height:8 ymargin:0  y0:1
       ! Yaxis from: -1 ! to: 4

         Curve t_nm  alpha    colour:blue   line:0
         Curve t_nm  pit_ins  colour:black  line:0

         Key 0.1 0.9 colour:blue  alpha
         Key 0.1 0.8 colour:black pitch

         Keepopen x:0  y:1

      Xyplot
         Setup width:22  xmargin:0  x0:2  height:8 ymargin:0  y0:1
         Curve t_nm  ps colour:blue   line:0
         Legend 0.5 1.1  Above "Für Horizontalflüge muß im Mittel alpha == pitch sein."
         Legend 0.5 1.05 Above {flight}
   #endif


   Remove axf_ins ayf_ins azf_ins

   ! ------------------------------------------------------------------- Wind
   ! u_a, v_a, w_a sind die GPS-korrigierten Geschwindigkeiten des Flugzeugs.
   ! (bei Artist ging's so:  Read /csys/met1/Expeditionen/ARTIST/aerodata/{file}.pos ua va wa)


   ! ICAO-Standardatmosphäre:

   Hicao =  288.15/0.0065 * ( (ps/1013.15) ^ (-287.05287*0.0065 / 9.80665)  -1  )


   ! WELMEC-Formel für Schwerebeschleunigung:
   g  = 9.780318 * (1 + 0.0053024 * sin(lat_a*PI180)*sin(lat_a*PI180) - 0.0000058 * sin(2*lat_a*PI180) * sin(2*lat_a*PI180) ) - 0.000003085 * Hicao

   ! Höhe unter Berücksichtigung der aktuellen Schichtung, ohne Bezugsniveau !
   hbaro = runsum ( 287.04*(T+273.15)/g * (ps-shift(-1)ps)/ps )


   #if EINS == 0

      Xyplot
         Setup name:PLOT-{flight}_h_a_hbaro.ps
         Yaxis units:m label: " " grid:zero
         Curve t_nm  hbaro   colour:blue
         Curve t_nm  h_a     colour:red
         Curve t_nm  Hicao   colour:black
         Key 0.8 0.9 colour:red  h_a
         Key 0.8 0.8 colour:blue hbaro
         Key 0.8 0.7 colour:blue hicao
         Keepopen gppv:2

      Xyplot
         Yaxis units:m label: " "
         Curve t_nm  h_a-hbaro
         Legend 0.5 0.9  Centre "h_a - hbaro"
         Legend 0.5 1.05 Above {flight}
         Keepopen gppv:2
   #endif



   mergefreq = 1/30      ! 1/Sekunden
   dt = 1/100            ! 100 Hz, interpoliert auf NM-Zeit

   dhdt = diff hbaro / dt


   Loop qq Set  lat_a lon_a gs_a costtrk_a sinttrk_a costhdg_a sinthdg_a u_a v_a  pit_ins roll_ins pitr_ins rolr_ins yawr_ins w_a h_a
      {qq} = shift (-16) {qq}
   Endloop


   Remove dhdt

   Echo Koordinatenrotation für Windberechnung. -------------------------------

   SINtheta =  sin(pit_ins  * PI180) ; COStheta =  cos(pit_ins  * PI180)
   SINphi   =  sin(roll_ins * PI180) ; COSphi   =  cos(roll_ins * PI180)
   SINalpha =  sin(alpha    * PI180) ; COSalpha =  cos(alpha    * PI180)
   SINbeta  =  sin(beta     * PI180) ; COSbeta  =  cos(beta     * PI180)



      prod1    =  COSalpha * COSbeta  * COStheta
      prod2    =  SINphi   * SINtheta
      prod3    =  SINalpha * COSbeta
      prod4    =  COSphi   * SINtheta



   ! Version für Polar5:
   vrxf     =  (pitr_ins *   1.65  - yawr_ins * (-0.41) ) * PI180
   vryf     =  (yawr_ins *   7.34  - rolr_ins *   1.65  ) * PI180
   vrzf     =  (rolr_ins * (-0.41) - pitr_ins *   7.34  ) * PI180

   uKg      =  v_a + vrxf * COStheta * costhdg_a                        &
                   + vryf * (prod2   * costhdg_a - COSphi * sinthdg_a)  &
                   + vrzf * (prod4   * costhdg_a + SINphi * sinthdg_a)

   vKg      =  u_a + vrxf * COStheta * sinthdg_a                        &
                   + vryf * (prod2   * sinthdg_a + COSphi * costhdg_a)  &
                   + vrzf * (prod4   * sinthdg_a - SINphi * costhdg_a)

   wKg      = -w_a - vrxf * SINtheta                                    &
                   + vryf * SINphi   * COStheta                         &
                   + vrzf * COSphi   * COStheta

   Remove vr?f
   Remove pitr_ins rolr_ins



   ug = tas   * (   prod1    * costhdg_a                                  &
                  + SINbeta  * (prod2 * costhdg_a - COSphi * sinthdg_a)   &
                  + prod3    * (prod4 * costhdg_a + SINphi * sinthdg_a) )

   vg = tas   * (   prod1    * sinthdg_a                                  &
                  + SINbeta  * (prod2 * sinthdg_a + COSphi * costhdg_a)   &
                  + prod3    * (prod4 * sinthdg_a - SINphi * costhdg_a) )

   wg = tas   * ( - COSalpha * COSbeta * SINtheta                         &
                  + SINbeta  * SINphi  * COStheta                         &
                  + prod3    * COSphi  * COStheta                 )
   Remove COS* SIN* prod?



   u =   vKg - vg  ! Aerodata nennt dies: uMetMP
   v =   uKg - ug  ! Aerodata nennt dies: vMetMP
   w = - wKg + wg  ! Aerodata nennt dies: wMetMP

   Remove ?Kg ?g


   thdg_a =  atan2(-sinthdg_a)(-costhdg_a) / PI180  + 180
   ttrk_a =  atan2(-sinttrk_a)(-costtrk_a) / PI180  + 180

   #if EINS == 1
      Typlot
         Setup   name:PLOT-{flight}_huvw.ps
         Header       PLOT-{flight}_huvw

         Series t_nm    addabs: 51543

         Series rFHuB
         Series h_a     addabs:0 ! from:-100  to:200
         Series u       addabs:0 ! from: -5  to: 5
         Series v       addabs:0 ! from: -5  to: 5
         Series w       addabs:0 ! from: -5  to: 5
         Series thdg_a             from:  0  to:360 Cyclic btd:90 std:30 thick:6
         Series miss_nm height:1   from:  0  to:1.4 thick:6
   #endif


   #if EINS == 0
      ! dies war um die Sinnrichtigkeit von beta beim Testflug in Bremen zu pruefen, ist ok.
      ! Fuer eine Nutzung der Schiebeuebungen fuer eine Kalibrierung muss man aber einigen Programmieraufwand treiben.
      ! Mit den Koeffizienten ... ca.10*qbN/qcN bleibt der Wind allerdings nicht ganz konstant waehrend der Uebung.
      ! Ich denke man muss ganz gezielt wenige Sekunden der Schiebeuebung rauspicken und einzeln untersuchen.
      Typlot
         Setup   name:PLOT-{flight}_huvw.ps
         Header       PLOT-{flight}_huvw

         Series rFHuB
         Series h_a     addabs:0 ! from:-100  to:200
         Series u       addabs:0   from: -10  to: 25
         Series v       addabs:0   from: -12  to: -2
         Series w       addabs:0 ! from: -5  to: 5
         Series thdg_a             from: 140  to:220  addabs:180
         Series roll_ins
         Series yawr_ins
         Series miss_nm height:1   from:  0  to:1.4 thick:6
   #endif


   Remove  sinthdg_a costhdg_a sinttrk_a costtrk_a
   Remove  g

   #IF WRITE Write  DATADIR/Prep/{flight}_turb.prep  d:t_nm c:miss_nm u v w T Hicao h_a ps qc tas gs_a lon_a lat_a u_a v_a w_a pit_ins roll_ins thdg_a hbaro ttrk_a Te_N TejN     rFHuB               qaN qbN qcN psN alpha beta
   Remove                                              t_nm   miss_nm u v w T Hicao h_a ps qc tas gs_a lon_a lat_a u_a v_a w_a pit_ins roll_ins thdg_a hbaro ttrk_a Te_N TejN     rFHuB               qaN qbN qcN psN alpha beta

#endif ! Nasenmast -------------------------------------------------------------


Endloop