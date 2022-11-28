# -*- coding: utf-8 -*-
import numpy as np
import datetime
import matplotlib
import matplotlib.dates as dates
import matplotlib.pyplot as plt
import glob
import netCDF4
import pandas as pd
from netCDF4 import Dataset

Day = [
'20200830a',
'20200831a', 
'20200831b', 
'20200902a',
'20200904a',
'20200907a',
'20200908a',
'20200910a',
'20200911a',
'20200913a',
]

Aircraft = 5

sigma = 5.67e-8

Unten = 0
Oben = 90000



############################
### LOOP through days and Aircraft
############################
for i,val in enumerate(Day): 
    print(Day[i])
    if (i >= 0):
#    if (i == 12):


        # Creat Daily NetCDF file
        f = Dataset("/projekt_agmwend/data/MOSAiC_ACA_S/Flight_"+Day[i]+"/BBR/ACA_"+Day[i]+"_Airborne_Broadband_Irradiance.nc","w")
        f.description = '############################### \n \
            General Information:\n \
            ############################### \n \
            Airborne measurements of broadband irradiance during the MOSAiC-ACA campaign: Svalbard, August/September 2020 \n \
            PI: Sebastian Becker (sebastian.becker@uni-leipzig.de)\n \
            Day: '+Day[i][0:4]+'-'+Day[i][4:6]+'-'+Day[i][6:8]+'\n \
            Involved Aircraft : Polar 5 \n \
            ############################### \n \
            Instruments:\n \
            Kipp&Zonen CMP22 pyranometer: solar irradiance (0.2 - 3.6 um) in W m-2 \n \
            Kipp&Zonen CGR4 pyrgeometer: terrestrial irradiance (4.5 - 42.0 um) in W m-2 \n \
            Heitronics KT19.85II: nadir brightness temperature: (9.6 - 11.5 um) in K \n \
            ############################### \n \
            Temporal Resolution: 20 Hz \n \
            ############################### \n \
            Applied Corrections: \n \
            Downward solar irradiance corrected for aircraft attitude, following the approach by Bannehr and Schwiesow (1993) and Boers et al. (1998), if irradiance is dominated by direct solar radiation. \n \
            Irradiance measurements corrected for instrument inertia time (1.8 s for pyranometers, 3.4 s for pyrgeometers) following the approach by Ehrlich and Wendisch (2015) \n \
            ############################### \n \
            Applied Flags: \n \
            Aircraft attitude flag: Aircraft roll and pitch angles larger than |5| degrees are flagged (1). These irradiance data must be interpreted with care or discarded. \n \
            Ambient temperature change rate flag: Pyranometers and pyrgeometer can be affected by rapid changes in ambient temperature due to different window (glass dome), body, and sensor temperatures (e.g. zero offset type B Kipp and Zonen) and Albrecht and Cox (1977) (https://doi.org/10.1175/1520-0450(1977)016<0190:PFIPP>2.0.CO;2). These roughly flagged irradiances (1) need to be interpreted with care. Based on the one minute backward running mean of the abosolute, smoothed air temperature gradient (> 0.5 K/min). However, problems of different window (glass dome), body, and sensor temperatures due to large temperature change rates during airborne observations are only poorly understood so far, uncertainties remain. \n \
            Aircraft stabilizer flag: While flying in the opposite direction of the sun (aircraft yaw angle (+- 180 degrees) == solar azimuth angle (+- 2 degrees)) and solar zenith angles plus aircraft pitch angle (nose down positive) larger than 75 degrees, the aircraft vertical stabilizer (at the tail) covers the direct downward irradiance. Time periods with those critical angles are flagged (1) and need to be interpreted with care (short dips in downward irradiance).\n \
            Icing Flags: \n \
            Pyranometers: Obvious icing influence on solar irradiance is flagged (1). During unflagged times, icing influence is unsuspicious, but can not be excluded by certainty (0). Exposed pyranometer glass dome susceptible to icing.  \n \
            ############################## \n \
            List of parameters:\n \
            Time seconds of day (UTC): "time" \n \
            Latitude (Degree): "Lat" \n \
            Longitude (Degree): "Lon" \n \
            Flight Altitude (m): "Alt" \n \
            Solar downward irradiance (W m-2): "Solar_F_dw" \n \
            Solar downward irradiance fully corrected (W m-2): "Solar_F_dw_full_corr" \n \
            Solar downward irradiance uncorrected (W m-2): "Solar_F_dw_uncorr" \n \
            Solar upward irradiance (W m-2): "Solar_F_up" \n \
            Terrestrial downward irradiance (W m-2): "Terr_F_dw" \n \
            Terrestrial upward irradiance (W m-2): "Terr_F_up" \n \
            Nadir Brightness Temperature (K): "KT19" \n \
            Attitude Flag: "Attitude_Flag" \n \
            Ambient Temp Flag: "Amb_T_Flag" \n \
            Aircraft Stabilizer flag: "Airc_Stab_flag" \n \
            Icing Flag: "Pyrano_Icing_Flag" (solar radiation) \n \
            Further details in the variable attributes. \n \
            ############################### \n \
            '

            #Ambient temperature change rate flag: Pyranometers and pyrgeometer can be affected by rapid changes in ambient temperature due to different window (glass dome), body, and sensor temperatures (e.g. zero offset type B Kipp and Zonen) and Albrecht and Cox (1977) (https://doi.org/10.1175/1520-0450(1977)016<0190:PFIPP>2.0.CO;2). These flagged irradiances (1) need to be interpreted with care. Based on the one minute backward running mean of the abosolute, smoothed air temperature gradient (> 0.5 K/min).  \n \
            #Pyrgeometers: Obvious icing influence on terrestrial irradiance is flagged (1). During unflagged times, icing influence is unsuspicious, but can not be excluded by certainty (0). Pyrgeometers were found iced less frequently (flat window). \n \
            #Icing Flag: "Pyrgeo_Icing_Flag" (terrestrial radiation) \n \

            
        #### READ FILES
        data_path = '/projekt_agmwend/data/MOSAiC_ACA_S/Flight_'+Day[i]+'/'
        data_path_raw = '/projekt_agmwend/data_raw/MOSAiC_ACA_S_raw/Flight_'+Day[i]+'/'
        
        Polar_files = glob.glob(data_path+'BBR/BBR_P'+str(Aircraft)+'*'+Day[i]+'*.dat')[0]
        INS_files = glob.glob(data_path_raw+'AWI_nav/Data_INS_P'+str(Aircraft)+'*'+Day[i]+'*.dat')[0]
        
        print(Polar_files)
        Polar5 = np.genfromtxt(Polar_files,skip_header=41)    
        
        SOD = Polar5[:,0]
        
        H = np.floor(SOD/3600.)
        Min = np.floor((SOD/3600.-np.floor(SOD/3600.))*60.)
        Sek = np.floor(((SOD/3600.-np.floor(SOD/3600.))*60. -np.floor((SOD/3600.-np.floor(SOD/3600.))*60.)) *60.)
        Ms = (((SOD/3600.-np.floor(SOD/3600.))*60. -np.floor((SOD/3600.-np.floor(SOD/3600.))*60.)) *60. - np.floor(((SOD/3600.-np.floor(SOD/3600.))*60. -np.floor((SOD/3600.-np.floor(SOD/3600.))*60.)) *60.) )*1000
        Time_final = np.empty(len(SOD))
        ISO_time = np.empty(len(SOD), dtype="S22") 
        for time_k,val in enumerate(SOD):
            ISO_time[time_k] = str(Day[i][0:4])+'-'+str(Day[i][4:6])+'-'+str(Day[i][6:8])+'T'+'{:02d}'.format(int(H[time_k]))+':'+'{:02d}'.format(int(Min[time_k]))+':'+'{:02d}'.format(int(Sek[time_k]))+'.''{:02d}'.format(int(np.ceil(Ms[time_k])))
            if (np.isnan(SOD[time_k]) == True ):
                Time_final[time_k] = np.nan
            else:
                Time_final[time_k] = dates.date2num(datetime.datetime(int(Day[i][0:4]),int(Day[i][4:6]),int(Day[i][6:8]),int(H[time_k]),int(Min[time_k]),int(Sek[time_k]),int(Ms[time_k])))
            
        Lat = Polar5[:,1]
        Lon = Polar5[:,2]
        Alt =  Polar5[:,3]
        Alt[Alt > 5500] = np.nan
        SZA = Polar5[:,4]
        SAA = Polar5[:,5]
        Solar_F_dw = Polar5[:,6]
        Solar_F_up = Polar5[:,7]
        Terr_F_dw= Polar5[:,8]
        Terr_F_up = Polar5[:,9]
        KT19 = Polar5[:,10]
        KT19[KT19 < -40] = np.nan
        Solar_F_dw_uncorr = Polar5[:,11]
        Solar_F_dw_fullcorr = Polar5[:,12]
        
        Solar_F_dw[np.where((Solar_F_dw >= 1000 ) | (Solar_F_dw <= 0))]=np.nan
        Solar_F_dw_uncorr[np.where((Solar_F_dw_uncorr >= 1000 ) | (Solar_F_dw_uncorr <= 0))]=np.nan
        Solar_F_dw_fullcorr[np.where((Solar_F_dw_fullcorr >= 1000 ) | (Solar_F_dw_fullcorr <= 0))]=np.nan
        Solar_F_up[np.where((Solar_F_up >= 1000 ) | (Solar_F_up <= 0))]=np.nan
        Terr_F_dw[np.where((Terr_F_dw >= 1000 ) | (Terr_F_dw <= 0))]=np.nan
        Terr_F_up[np.where((Terr_F_up >= 1000 ) | (Terr_F_up <= 0))]=np.nan       

        del(Polar5)
        
        Albedo = Solar_F_up/Solar_F_dw
        
        
        #####################################################
        #### INS DATA
        #####################################################
        print(INS_files)
        INS_P5 = np.genfromtxt(INS_files,skip_header=4)  #np.genfromtxt(data_path+'INS\\P'+str(Aircraft[k])+'\\Data_INS_P'+str(Aircraft[k])+'_2017'+Day[i]+'.dat',skip_header=4)
        
        INS_SOD = INS_P5[:,3]*3600. + INS_P5[:,4]*60. + INS_P5[:,5]
        H = INS_P5[:,3]
        Min = INS_P5[:,4]
        Sek = INS_P5[:,5]
        
        Roll = INS_P5[:,10]
        Pitch = -INS_P5[:,11]
        Yaw = INS_P5[:,12]   
        for y,val in enumerate(Yaw):
                    if (Yaw[y] < 0):
                        Yaw[y] = Yaw[y]+360


        Roll = np.interp(SOD, INS_SOD,Roll)
        Pitch = np.interp(SOD,INS_SOD,Pitch)
        Yaw = np.interp(SOD,INS_SOD,Yaw)
        del(INS_P5)

        Diff_azi = SAA-Yaw
        for j,val in enumerate(Diff_azi):
            if (Diff_azi[j] < 0):
                Diff_azi[j] = Diff_azi[j]+360
            if (Diff_azi[j] >= 360):
                Diff_azi[j] = Diff_azi[j]-360
        
        
        
        #####################################################
        #### Meteo Data DATA for temperature change rate flag
        #####################################################
        
        #######################################################################################      
        # READ THE TEMPS !!
        #######################################################################################        
        
        Meteo = np.genfromtxt(glob.glob(data_path+'Meteo/Flight_'+Day[i]+'*1s.asc')[0],skip_header=1)
        Temp = np.interp(SOD,Meteo[:,0],Meteo[:,9] )
        RH = np.interp(SOD,Meteo[:,0],Meteo[:,8] )
        del(Meteo)
        
        Simu = np.genfromtxt(glob.glob(data_path+'BBR/P'+str(Aircraft)+'_BBR_Fdn_*'+Day[i]+'*.dat')[0],skip_header=36)
        Simu_F_dw = np.interp(SOD,Simu[:,0],Simu[:,3] )
        del(Simu)
        
        
        ##### ICING STATUS after landing
        # 20200830a ...
                
    #zu aendern#################################################################################################################               
        if (Day[i] == '20200830a'): 
            Icing_likely_Unten = [80000]
            Icing_likely_Oben = [90000]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200831a'): 
            Icing_likely_Unten = [80000]
            Icing_likely_Oben = [90000]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200831b'): 
            Icing_likely_Unten = [80000]
            Icing_likely_Oben = [90000]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200902a'):
            Icing_likely_Unten = [80000]
            Icing_likely_Oben = [90000]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200904a'): 
            Icing_likely_Unten = [57200]
            Icing_likely_Oben = [60200]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200907a'): 
            Icing_likely_Unten = [44200]
            Icing_likely_Oben = [90000]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200908a'): 
            Icing_likely_Unten = [80000]
            Icing_likely_Oben = [90000]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200910a'): 
            Icing_likely_Unten = [50200]
            Icing_likely_Oben = [90000]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200911a'): 
            Icing_likely_Unten = [80000]#[39500]
            Icing_likely_Oben = [90000]#[41500]??
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        if (Day[i] == '20200913a'): 
            Icing_likely_Unten = [80000]
            Icing_likely_Oben = [90000]
            Icing_likely_Unten_Pyrgeometer = [80000]
            Icing_likely_Oben_Pyrgeometer = [90000]
        
        
        #### APPLY FLAGS
        #################################################
        
        Attitude_flag = np.empty((len(SOD)),dtype='int_')*0
        Temp_change_rate_flag = np.empty((len(SOD)),dtype='int_')*0
        Aircraft_Stabilizer_flag = np.empty((len(SOD)),dtype='int_')*0
        Icing_flag_Pyranometer = np.empty((len(SOD)),dtype='int_')*0
        Icing_flag_Pyrgeometer = np.empty((len(SOD)),dtype='int_')*0
        
        
        # ATTITUDE
        ##############
        for a,val in enumerate(SOD):
            if ((np.absolute(Roll[a]) > 5.0) | (np.absolute(Pitch[a]) > 5.0)):
                Attitude_flag[a] = 1
        
        ## ICING
        ##############
        for u,val in enumerate(Icing_likely_Unten):
            Icing_flag_Pyranometer[(SOD > Icing_likely_Unten[u]) & (SOD < Icing_likely_Oben[u])] = Icing_flag_Pyranometer[(SOD > Icing_likely_Unten[u]) & (SOD < Icing_likely_Oben[u])]*0+1        
#        for o,val in enumerate(Icing_likely_Unten_Pyrgeometer):
#            Icing_flag_Pyrgeometer[(SOD > Icing_likely_Unten_Pyrgeometer[o]) & (SOD < Icing_likely_Oben_Pyrgeometer[o])] = Icing_flag_Pyrgeometer[(SOD > Icing_likely_Unten_Pyrgeometer[o]) & (SOD < Icing_likely_Oben_Pyrgeometer[o])]*0+1
        
        ### TEMPERATURE CHANGE RATE
        ##############
        #T_rate_param = pd.rolling_mean(np.absolute(np.gradient(pd.rolling_mean(Temp,window=1200,center=True,min_periods=600))*20*60),window=1200)
        T_rate_param = pd.Series(np.absolute(np.gradient(pd.Series(Temp).rolling(window=1200,center=True,min_periods=600).mean())*20*60)).rolling(window=1200).mean()
        Temp_change_rate_flag[T_rate_param > 0.5] = Temp_change_rate_flag[T_rate_param > 0.5]*0+1
        
        #### Aircraft_Stabilizer_flag
        ##############
        Oppos_SAA = np.empty((len(SAA)))
        for s,val in enumerate(SAA):
            if ((SAA[s]-180) < 0):
                Oppos_SAA[s] = 360 + (SAA[s]-180)
            else:
                Oppos_SAA[s] = SAA[s]-180
        for s,val in enumerate(SAA):
            if (SZA[s]+Pitch[s]  > 73 ) & ( ( ((Yaw[s] - Oppos_SAA[s]) > -2.0) & ((Yaw[s] - Oppos_SAA[s]) < 2.0)) | ((Yaw[s] - Oppos_SAA[s]) < -358.) | ((Yaw[s] - Oppos_SAA[s]) > 358.)) :
                Aircraft_Stabilizer_flag[s] = Aircraft_Stabilizer_flag[s]*0 + 1

        ###########################################################
        ## CUT START AND LANDING !!!
        ## KT19 opened
        ###################################
        if (Day[i] == '20200830a'): 
            Flight_time = (SOD > 29670) & (SOD < 32850)
            KT19_time = (SOD > 29870) & (SOD < 32059)
        if (Day[i] == '20200831a'): 
            Flight_time = (SOD > 37240) & (SOD < 39530)
            KT19_time = (SOD > 37481) & (SOD < 38863)
        if (Day[i] == '20200831b'): 
            Flight_time = (SOD > 45615) & (SOD < 53695)
            KT19_time = (SOD > 46073) & (SOD < 53197)
        if (Day[i] == '20200902a'): 
            Flight_time = (SOD > 24945) & (SOD < 44610)
            KT19_time = (SOD > 25133) & (SOD < 43951)
        if (Day[i] == '20200904a'): 
            Flight_time = (SOD > 43910) & (SOD < 63685)
            KT19_time = (SOD > 44551) & (SOD < 62991)
        if (Day[i] == '20200907a'): 
            Flight_time = (SOD > 30175) & (SOD < 50580)
            KT19_time = (SOD > 30653) & (SOD < 49459)
        if (Day[i] == '20200908a'): 
            Flight_time = (SOD > 28855) & (SOD < 50705)
            KT19_time = (SOD > 29092) & (SOD < 50084)
        if (Day[i] == '20200910a'): 
            Flight_time = (SOD > 30615) & (SOD < 53105)
            KT19_time = (SOD > 30924) & (SOD < 52510)
        if (Day[i] == '20200911a'): 
            Flight_time = (SOD > 29980) & (SOD < 50365)
            KT19_time = (SOD > 30180) & (SOD < 49299)
        if (Day[i] == '20200913a'): 
            Flight_time = (SOD > 33605) & (SOD < 54415)
            KT19_time = (SOD > 33859) & (SOD < 53993)
            
            

        #######################################################################################################################
        #######################################################################################################################
        ### Flight
        #######################################################################################################################
        # CUT THE FLIGHTS START TO LANDING  
        Time_final = Time_final[Flight_time]
        ISO_time = ISO_time[Flight_time]
        Lat = Lat[Flight_time]
        Lon = Lon[Flight_time]
        Alt = Alt[Flight_time]
        Pitch = Pitch[Flight_time]
        Roll = Roll[Flight_time]
        Solar_F_dw = Solar_F_dw[Flight_time]
        Solar_F_dw_fullcorr = Solar_F_dw_fullcorr[Flight_time]
        Solar_F_dw_uncorr = Solar_F_dw_uncorr[Flight_time]
        Solar_F_up = Solar_F_up[Flight_time]
        Terr_F_dw = Terr_F_dw[Flight_time]
        Terr_F_up = Terr_F_up[Flight_time]
        # KT19 opening
        KT19[~KT19_time] = KT19[~KT19_time]*np.nan
        KT19 = KT19[Flight_time]
        KT19 = KT19 + 273.15
        Attitude_flag = Attitude_flag[Flight_time]
        Temp_change_rate_flag = Temp_change_rate_flag[Flight_time]
        Aircraft_Stabilizer_flag = Aircraft_Stabilizer_flag[Flight_time]
        Icing_flag_Pyranometer = Icing_flag_Pyranometer[Flight_time]
        Icing_flag_Pyrgeometer = Icing_flag_Pyrgeometer[Flight_time]
        
        Temp = Temp[Flight_time]
        RH = RH[Flight_time]
        Simu_F_dw = Simu_F_dw [Flight_time]
        Br_Temp_up = (Terr_F_up/sigma)**0.25
        Albedo = Albedo[Flight_time]
        Diff_azi = Diff_azi[Flight_time]

        ####
        SOD = SOD[Flight_time]
        
        Auswahl = ((SOD >= Unten) & (SOD <= Oben))

#        if (Day[i] == '0319'): 
#            Solar_F_dw= Solar_F_dw*np.nan
#            Solar_F_up= Solar_F_up*np.nan


        #marks = 1

        #fig, axs = plt.subplots(6, sharex=True,figsize=(15,20),constrained_layout=True)
        
        #fig.suptitle(Day[i], fontsize='xx-large')
        
        #l11 = axs[0].plot(SOD[Auswahl], Alt[Auswahl], marker='.', markersize=marks, linestyle='', color='blue')
        #axs[0].set_ylabel('Altitude [m]', fontsize='x-large')
        #axs[0].tick_params(axis='y', labelsize='x-large')
        
        #l21 = axs[1].plot(SOD[Auswahl], Solar_F_dw[Auswahl], marker='.', markersize=marks, linestyle='', color='red', label=r'$F^{\downarrow}_\mathrm{sol}$')
        #l22 = axs[1].plot(SOD[Auswahl][(Attitude_flag[Auswahl] == 1)], Solar_F_dw[Auswahl][(Attitude_flag[Auswahl] == 1)], marker='.', markersize=marks, linestyle='', color='yellow', label='attitude flag')
        #l23 = axs[1].plot(SOD[Auswahl], Simu_F_dw[Auswahl], marker='.', markersize=marks, linestyle='', color='black', label='Simulation')
        #l24 = axs[1].plot(SOD[Auswahl], Solar_F_up[Auswahl], marker='.', markersize=marks, linestyle='', color='blue', label=r'$F^{\uparrow}_\mathrm{sol}$')
        #l25 = axs[1].plot(SOD[Auswahl][(Icing_flag_Pyranometer[Auswahl] == 1)], Solar_F_up[Auswahl][(Icing_flag_Pyranometer[Auswahl] == 1)], marker='.', markersize=marks, linestyle='', color='green', label='icing flag')
        #axs[1].set_ylabel(r'$F_\mathrm{sol}\,\left[\mathrm{W\,m^{-2}}\right]$', fontsize='x-large')
        #axs[1].set_ylim(0,600)
        #axs[1].tick_params(axis='y', labelsize='x-large')
        #leg21 = matplotlib.lines.Line2D([], [], color='red', label=r'$F^{\downarrow}_\mathrm{sol}$')
        #leg22 = matplotlib.lines.Line2D([], [], color='yellow', label='attitude flag')
        #leg23 = matplotlib.lines.Line2D([], [], color='black', label='Simulation')
        #leg24 = matplotlib.lines.Line2D([], [], color='blue', label=r'$F^{\uparrow}_\mathrm{sol}$')
        #leg25 = matplotlib.lines.Line2D([], [], color='green', label='icing flag')
        #legend1 = axs[1].legend(handles=[leg21, leg22, leg24, leg25], bbox_to_anchor=(1.0, 1.05), loc=2, fontsize='x-large')
        #legend2 = axs[1].legend(handles=[leg23], loc=1, fontsize='x-large')
        #axs[1].add_artist(legend1)
        #axs[1].add_artist(legend2)
        
        ##l31 = axs[2].plot(SOD[Auswahl], Solar_F_up[Auswahl], marker='.', markersize=marks, linestyle='', color='red')
        ##l32 = axs[2].plot(SOD[Auswahl][(Icing_flag_Pyranometer[Auswahl] == 1)], Solar_F_up[Auswahl][(Icing_flag_Pyranometer[Auswahl] == 1)], marker='.', markersize=marks, linestyle='', color='yellow')
        ##axs[2].set_ylabel(r'$F^{\uparrow}_\mathrm{sol}$', fontsize='x-large')
        ##axs[2].tick_params(axis='y', labelsize='x-large')
        
        #l41 = axs[2].plot(SOD[Auswahl], Albedo[Auswahl], marker='.', markersize=marks, linestyle='', color='red')
        #l44 = axs[2].plot(SOD[Auswahl][(Icing_flag_Pyranometer[Auswahl] == 1) | (Attitude_flag[Auswahl] == 1)], Albedo[Auswahl][(Icing_flag_Pyranometer[Auswahl] == 1) | (Attitude_flag[Auswahl] == 1)], marker='.', markersize=marks, linestyle='', color='yellow', label='attitude/icing flag')
        #axs[2].axhline(1)
        #axs[2].set_ylabel('Albedo', fontsize='x-large')
        #axs[2].tick_params(axis='y', labelsize='x-large')
        #leg42 = matplotlib.lines.Line2D([], [], color='yellow', label='attitude/icing flag')
        #axs[2].legend(handles=[leg42], bbox_to_anchor=(1.0, 1.05), loc=2, fontsize='x-large')
        
        #l51 = axs[3].plot(SOD[Auswahl], Terr_F_dw[Auswahl], marker='.', markersize=marks, linestyle='', color='red', label=r'$F^{\downarrow}_\mathrm{terr}$')
        #l52 = axs[3].plot(SOD[Auswahl][(Temp_change_rate_flag[Auswahl] == 1)], Terr_F_dw[Auswahl][(Temp_change_rate_flag[Auswahl] == 1)], marker='.', markersize=marks, linestyle='', color='yellow', label='temp. change rate flag')
        #l61 = axs[3].plot(SOD[Auswahl], Terr_F_up[Auswahl], marker='.', markersize=marks, linestyle='', color='blue', label=r'$F^{\uparrow}_\mathrm{terr}$')
        #l62 = axs[3].plot(SOD[Auswahl][(Aircraft_Stabilizer_flag[Auswahl] == 1)], Terr_F_up[Auswahl][(Aircraft_Stabilizer_flag[Auswahl] == 1)], marker='.', markersize=marks, linestyle='', color='green', label='stabilizer flag')        
        #axs[3].set_ylabel(r'$F_\mathrm{terr}\,\left[\mathrm{W\,m^{-2}}\right]$', fontsize='x-large')
        #axs[3].tick_params(axis='y', labelsize='x-large')
        #leg51 = matplotlib.lines.Line2D([], [], color='red', label=r'$F^{\downarrow}_\mathrm{terr}$')
        #leg52 = matplotlib.lines.Line2D([], [], color='yellow', label='temp. change rate flag')
        #leg53 = matplotlib.lines.Line2D([], [], color='blue', label=r'$F^{\uparrow}_\mathrm{terr}$')
        #leg54 = matplotlib.lines.Line2D([], [], color='green', label='stabilizer flag')
        #axs[3].legend(handles=[leg51, leg52, leg53, leg54], bbox_to_anchor=(1.0, 1.05), loc=2, fontsize='x-large')
                
        #l71 = axs[4].plot(SOD[Auswahl], KT19[Auswahl], marker='.', markersize=marks, linestyle='', color='blue', label='KT19')
        #l72 = axs[4].plot(SOD[Auswahl], Br_Temp_up[Auswahl], marker='.', markersize=marks, linestyle='', color='red', label='CGR4')
        #axs[4].set_ylabel(r'$T_\mathrm{Br}\,\left[\mathrm{K}\right]$', fontsize='x-large')
        #axs[4].tick_params(axis='y', labelsize='x-large')
        #leg71 = matplotlib.lines.Line2D([], [], color='blue', label='KT19')
        #leg72 = matplotlib.lines.Line2D([], [], color='red', label='CGR4')
        #axs[4].legend(handles=[leg71, leg72], bbox_to_anchor=(1.0, 1.05), loc=2, fontsize='x-large')
        
        #l81 = axs[5].plot(SOD[Auswahl], Temp[Auswahl], marker='.', markersize=marks, linestyle='', color='blue', label='Temperature')
        #axs[5].axhline(0)
        #axs[5].set_ylabel(r'$T_\mathrm{air}\,\left[^{\circ}\mathrm{C}\right]$', fontsize='x-large')
        #axs[5].tick_params(axis='both', labelsize='x-large')
        #axs[5].set_xlabel('Time [SOD]', fontsize='x-large')
        #ax6 = axs[5].twinx()
        #ax6.set_ylabel('RH [%]', fontsize='x-large')
        #ax6.tick_params(axis='y', labelsize='x-large')
        #ax6.set_ylim(0,100)
        #l82 = ax6.plot(SOD[Auswahl], RH[Auswahl], marker='.', markersize=marks, linestyle='', color='green', label='RH')
        #lines = [l81, l82]
        #leg81 = matplotlib.lines.Line2D([], [], color='blue', label='Temperature')
        #leg82 = matplotlib.lines.Line2D([], [], color='green', label='RH')
        #axs[5].legend(handles=[leg81, leg82], bbox_to_anchor=(1.07, 1.05), loc=2, fontsize='x-large')
        ##axs[5].set_ylabel('SSA-yaw', fontsize='xx-large')
        ##axs[5].tick_params(labelsize='xx-large')
        ##axs[5].legend(lines, [l.get_label() for l in lines], bbox_to_anchor=(1.05, 1.0), fontsize='xx-large')
        
        ##l91 = axs[7].plot(SOD[Auswahl], Diff_azi[Auswahl], marker='.', markersize=marks, linestyle='', color='blue')
        ##axs[7].axhline(0)
        ##axs[7].axhline(90)
        ##axs[7].axhline(180)
        ##axs[7].axhline(270)
        ##axs[7].axhline(360)
        ##axs[7].set_xlabel('SOD', fontsize='x-large')
        ##axs[7].set_ylabel('SSA-yaw', fontsize='x-large')
        ##axs[7].tick_params(labelsize='x-large')
        
        #plt.savefig('/home/sbecker/Dokumente/BBR_MOSAiC/Dataset_for_publication/Quicklook'+Day[i]+'.png')
        ##plt.show()    


###############################################################################################################
###############################################################################################################
###
### EXPORT TO NETCDF  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
###
###############################################################################################################
###############################################################################################################

        

        f.createDimension("Time",len(SOD[:]))
        
        
        Temp_time = f.createVariable("time",'f',dimensions = ('Time'))
        Temp_time[:] = SOD[:]
        Temp_time.description =  'Seconds of day (UTC)'
        Temp_time.units ='Seconds since '+Day[i][0:4]+'-'+Day[i][4:6]+'-'+Day[i][6:8]+'T00:00:00' 

        Temp_Lon = f.createVariable("Lon",'f',dimensions = ('Time'))
        Temp_Lon[:] = Lon[:]
        Temp_Lon.description = 'Longitude'
        Temp_Lon.units = 'Degrees East'

        Temp_Lat = f.createVariable("Lat",'f',dimensions = ('Time'))
        Temp_Lat[:] = Lat[:]
        Temp_Lat.description = 'Latitude'
        Temp_Lat.units = 'Degrees North'
        
        Temp_Alt = f.createVariable("Alt",'f',dimensions = ('Time'))
        Temp_Alt[:] = Alt[:]
        Temp_Alt.description = 'Flight altitude'
        Temp_Alt.units = 'm'
        
        # Measured
        Temp_Solar_F_dw = f.createVariable("Solar_F_dw",'f',dimensions = ('Time'))
        Temp_Solar_F_dw[:]= Solar_F_dw[:]
        Temp_Solar_F_dw.description = 'Downward solar irradiance measured by pyranometer CMP22 (corrected for aircraft attitude only in case of dominating direct solar illumination).'
        Temp_Solar_F_dw.units = 'W m-2'
    
        Temp_Solar_F_dw = f.createVariable("Solar_F_dw_full_corr",'f',dimensions = ('Time'))
        Temp_Solar_F_dw[:]= Solar_F_dw_fullcorr[:]
        Temp_Solar_F_dw.description = 'Downward solar irradiance measured by pyranometer CMP22 (corrected for aircraft attitude also in case of diffuse illumination).'
        Temp_Solar_F_dw.units = 'W m-2'
        
        Temp_Solar_F_dw = f.createVariable("Solar_F_dw_uncorr",'f',dimensions = ('Time'))
        Temp_Solar_F_dw[:]= Solar_F_dw_uncorr[:]
        Temp_Solar_F_dw.description = 'Downward solar irradiance measured by pyranometer CMP22 (not corrected for aircraft attitude).'
        Temp_Solar_F_dw.units = 'W m-2'
        
        Temp_Solar_F_up = f.createVariable("Solar_F_up",'f',dimensions = ('Time'))
        Temp_Solar_F_up[:]= Solar_F_up[:]
        Temp_Solar_F_up.description = 'Upward solar irradiance measured by pyranometer CMP22.'
        Temp_Solar_F_up.units = 'W m-2'
        
        Temp_Terr_F_dw = f.createVariable("Terr_F_dw",'f',dimensions = ('Time'))
        Temp_Terr_F_dw[:]= Terr_F_dw[:]
        Temp_Terr_F_dw.description = 'Downward terrestrial irradiance measured by pyrgeometer CGR4.'
        Temp_Terr_F_dw.units = 'W m-2'
        
        Temp_Terr_F_up = f.createVariable("Terr_F_up",'f',dimensions = ('Time'))
        Temp_Terr_F_up[:] = Terr_F_up[:]
        Temp_Terr_F_up.description = 'Upward terrestrial irradiance measured by pyrgeometer CGR4.'
        Temp_Terr_F_up.units = 'W m-2'
        
        Temp_KT19 = f.createVariable("KT19",'f',dimensions = ('Time'))
        Temp_KT19[:] = KT19[:]
        Temp_KT19.description = 'IR Brightness Temperature, nadir direction, measured by Heitronics KT19.85II '
        Temp_KT19.units = 'K'
        
        Temp_Attitude_flag = f.createVariable("Attitude_Flag",'i1',dimensions = ('Time'))
        Temp_Attitude_flag[:] = Attitude_flag
        Temp_Attitude_flag.description = 'Aircraft roll and pitch angles larger than +- 5 degrees are flagged (1). Flagged irradiance data must be interpreted with care or discarded.'
        Temp_Attitude_flag.units = ''
        
        Temp_Temp_change_rate_flag = f.createVariable("Amb_T_Flag",'i1',dimensions = ('Time'))
        Temp_Temp_change_rate_flag[:] = Temp_change_rate_flag
        Temp_Temp_change_rate_flag.description = 'Pyranometers and pyrgeometer can be affected by rapid changes in ambient temperature (details general file header). These time periods are flagged (1) and need to be interpreted with care.'
        Temp_Temp_change_rate_flag.units = ''
        
        Temp_Aircraft_Stabilizer_flag = f.createVariable("Airc_Stab_flag",'i1',dimensions = ('Time'))
        Temp_Aircraft_Stabilizer_flag[:] = Aircraft_Stabilizer_flag
        Temp_Aircraft_Stabilizer_flag.description = 'The aircraft tail can cover the direct downward irradiance for certain aircraft attitude and solar position combinations (details general file header). Time periods with those critical combinations are flagged (1).'
        Temp_Aircraft_Stabilizer_flag.units = ''
        
        Temp_Icing_flag_Pyranometer = f.createVariable("Pyrano_Icing_Flag",'i1',dimensions = ('Time'))
        Temp_Icing_flag_Pyranometer[:] = Icing_flag_Pyranometer
        Temp_Icing_flag_Pyranometer.description = 'Obvious influence on the solar irradiance is flagged (1). During unflagged times, icing influence is unsuspicious, but can not be excluded by certainty (0).'
        Temp_Icing_flag_Pyranometer.units = ''
        
#        Temp_Icing_flag_Pyrgeometer = f.createVariable("Pyrgeo_Icing_Flag",'i1',dimensions = ('Time'))
#        Temp_Icing_flag_Pyrgeometer[:] = Icing_flag_Pyrgeometer
#        Temp_Icing_flag_Pyrgeometer.description = 'Obvious icing influence on the terrestrial irradiance is flagged (1). During unflagged times, icing influence is unsuspicious, but can not be excluded by certainty (0).'
#        Temp_Icing_flag_Pyrgeometer.units = ''
        

        f.close()





