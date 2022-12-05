#!/home/jhartmann/bin/kyss


  #define GANZEFLUEGE        ! Fuer die Allgemeinheit.


  #define HF_DATEN           ! Fuer Pangaea, Datenpaper


  #define DATADIR        /isibhv/projects/polmet/Expeditionen/MOSAiC_ACA


#define PI180  (3.141592653589793/180.0)




! -------------------------------------------------- ganze Fluege, Sekundenwerte
#if GANZEFLUEGE


   Loop flight Set 20200806_P5_01 20200830_P5_02 20200831_P5_03 20200831_P5_04 20200902_P5_05 20200904_P5_06 20200907_P5_07 20200908_P5_08 20200910_P5_09 20200911_P5_10 20200913_P5_11


      Read  DATADIR/Prep/{flight}_turb.prep       t_nm    lon_a lat_a h_a  ps gs_a pit_ins roll_ins   T  u v w tas   ! rFHu steht vom Nasenmast nicht zur Verfuegung.
      Read  DATADIR/Preprep/{flight}_bmet.preprep t_bmet  rFHuB

      ta = max2(first(t_bmet))(first(t_nm))
      te = min2( last(t_bmet))( last(t_nm))


      #if HF_DATEN

         CorrSpike t_nm lon_a lat_a h_a  ps gs_a pit_ins roll_ins   T  u v w tas   method:omit  min:ta max:te

         Interpolate rFHuB  t_bmet t_nm

         Rename t_nm UTC

      #else

         Create  UTC  from: nint(ta+1) to: nint(te-1)  elements: nint(te-1)-nint(ta+1)+1

         Loop qq  Set  ps   T u v  roll_ins pit_ins
            NFilter  {qq}  n:101
         Endloop


         ! Auf gemeinsame Zeitachse interpolieren.
         !
         Loop qq Set    lon_a lat_a h_a  ps gs_a pit_ins roll_ins   T  u v w tas
            Interpolate  {qq}  t_nm   UTC
         Endloop
         Remove t_nm

         Interpolate rFHuB  t_bmet  UTC

      #endif

      Remove t_bmet


      Loop aa Set h_a    ps   lon_a    lat_a    gs_a   pit_ins  roll_ins   rFHuB
      .    bb Set h      p    lon      lat      gs     pitch    roll       rh
         Rename {aa} {bb}
      Endloop



      ! INS was not aligned, we simply zero the horizontal wind components.
      !
      If {flight} == 20190404_11_P5 Then

         u = u*0
         v = v*0
         w = w*0
      Endif



      Typlot
         Setup name: Flight_{flight}_data.ps
         Header      Flight_{flight}_data

         Abscissa    from:first(UTC) to:last(UTC)  units:s  label:UTC
         Default    start:first(UTC) deltax:0.01

         Series h        units:m        thick:6          from:0
         Series gs       units:m/s      thick:6          from:0
         Series pitch    units:"\260"           addabs:0
         Series roll     units:"\260"
         Series rh       units:"%"      thick:6          from:0 to:100
         Series T        units:"\260C"  thick:6 addabs:0
         Series u        units:m/s              addabs:0
         Series v        units:m/s              addabs:0
         Series w        units:m/s              addabs:0


#skip

   UTC   UTC-time in seconds (since midnight)
   h     height in metres    based on WGS84
   lon   longitude in degress based on WS84
   lat   latitude  in degress based on WS84
   p     static pressure in hpa
   gs    ground speed in m/s
   pitch pitch angle in degrees
   roll  roll  angle in degrees
   rh    relative humidity from Vaisala at noseboom
   T     temperature from PT100, corrected for adiabatic heating
   u     west-east   component of wind speed in m/s, positive towards east
   v     south-north component of wind speed in m/s, positive towards north
   tas   true air speed in m/s

#endskip


      #if HF_DATEN

          System rm    Flight_{flight}_100Hz.asc
          Print  file: Flight_{flight}_100Hz.asc Nocounter  %5.1 UTC  %4 h  %3.5 lon lat  %4.1 p  %3.2 gs   pitch   roll rh T  u v w tas
      #else

          System rm    Flight_{flight}_1s.asc
          Print  file: Flight_{flight}_1s.asc    Nocounter  %5.1 UTC  %4 h  %3.5 lon lat  %4.1 p  %3.2 gs   pitch   roll rh T  u v  tas
      #endif

      Remove   h  lon lat  p   gs  pitch  roll  rh T  u v w  UTC  tas

   Endloop
#endif



