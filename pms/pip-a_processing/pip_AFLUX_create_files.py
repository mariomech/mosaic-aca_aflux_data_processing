import os
import numpy as np
import pandas as pd
from datetime import datetime
import xarray as xr
os.chdir('.../processing/')
from Utility_MOSAiC_AFLUX_pms import save_icar_pip_aflux, import_1Hz_pip_files_as_pd, seconds_since_midnight, sv_per_bin, reject_numbers, oap_dmt_sa_centerin, import_1Hz_cip_files_as_pd_aflux, create_endbins, datetime_from_utcs, bin_df_from_edges, column_names,calc_LWC, calc_MVD, save_icar_cdp, get_dN, calc_ED,calc_IWC, save_icar_cip_mosaic

#data has to be processed by SODA before, see IDL script "soda_process_pip_aflux.pro"

#############################################################################
#start: create buffer data file, with active time = constant = 1

path_1Hz_pip_20190319 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F1 20190319\20190319')
path_1Hz_pip_20190321 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F2 20190321\20190321')
path_1Hz_pip_20190323 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F3 20190323\20190323')
path_1Hz_pip_20190324 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F4 20190324\20190324095046')
path_1Hz_pip_20190325 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F5 20190325\20190325')
path_1Hz_pip_20190330 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F6 20190330\20190330')
path_1Hz_pip_20190331 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F7 20190331\20190331')
path_1Hz_pip_20190401 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F8 20190401\20190401')
path_1Hz_pip_20190403 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F9 20190403\20190403')
path_1Hz_pip_20190404 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F10 20190404\20190404')
path_1Hz_pip_20190406 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F11 20190406\20190406')
path_1Hz_pip_20190407 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F12 20190407\20190407065205')
path_1Hz_pip_20190408 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F13 20190408\20190408085044')
path_1Hz_pip_20190411 = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F14 20190411\20190411')


def make_pip_pandas_aflux(year, month, day):
    dir_data = r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\PIP' + str('\\')+str(year)+str(month).zfill(2)+str(day).zfill(2)
    data_nc_name = str(month).zfill(2)+str(day).zfill(2)+str(year)+'_000001_PIP.pbp.nc'
    tas_file = r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\TAS_files'+ str('\\')+'tas_'+str(year)[-2:]+str(month).zfill(2)+str(day).zfill(2) +'.txt'
    
    os.chdir((dir_data).replace('\\', '/'))
    #data = Dataset(data_nc_name)
    ds = xr.open_dataset(data_nc_name, decode_times = False)
    df = ds.to_dataframe()
    df.index = df.time
    tas_file = pd.read_csv(((tas_file).replace('\\', '/')), names = ['utc','tas'],delimiter = ',' ,engine='python', na_values = 999.99)
    
    ###################################################
    #bins erstellen. Resolution muss angegeben werden:
    resolution = 103 #in mu m
    armwidth = 0.225 # in m
    endbind = create_endbins(resolution)
    
    bin_df_cali = bin_df_from_edges(endbind)
    #bin namen
    dNdD_names, dn_names = column_names(bin_df_cali)
    ##################################################
     #zeit ins richtige format bringen:
    time = df.time
    datetime = []
    for i in range(len(time)):
        datetime.append(datetime_from_utcs(year, month, day, time.iloc[i]))
    df.index = datetime
    
    #eine spalte in df einfügen in der die zeit gerundet auf eine sekunde stehen
    dataframe_1s = []
    for i in range(len(df)):
        dataframe_1s.append(df.index[i].replace(microsecond = 0))
    df['datetime_1s'] = dataframe_1s
    
    index_1s = np.unique(np.array(df['datetime_1s']),axis = 0)
    
    reject_number = reject_numbers(low_ar = 0, scatter_correct = 0, size_range = 0, all_in = 0, cluster = 0, water = 0, irr = 0, dof = 0)
    #df_not_corrected = df[~df.rejectionflag.isin(reject_number)]
    df_not_corrected = df
    #df_not_corrected = df_not_corrected[df_not_corrected.allin == 1]
    #df_not_corrected = df_not_corrected[df_not_corrected.dofflag == 0]
    
    reject_number = reject_numbers(low_ar = 1, scatter_correct = 1, size_range = 0, all_in = 1, cluster = 1, water = 0, irr = 0, dof = 0)
    df_corrected = df[~df.rejectionflag.isin(reject_number)]
    #df_corrected = df_corrected[df_corrected.allin == 1]
    #df_corrected = df_corrected[df_corrected.dofflag == 0]
    
    #input: pbp dataframe das 'diam' als eine spalte beinhaltet. Zählt dann die einträge pro bin!
    #input2: infos über die bins
    #geckeckt und sollte auch mit anderen größen wie xsize funktionieren :)
    def calc_diam_per_bin(dataframe, bin_df_cali, endbind):
        xsize_value_counts = dataframe['diam'].value_counts(bins = endbind, sort = False)
        data_n = pd.DataFrame(columns = dn_names)
        if len(xsize_value_counts) == 0:
            data_n.loc[0] = np.zeros(64)
            return data_n
        else:
            data_n.loc[0] = xsize_value_counts.values
            return data_n
            
    # hier die active time über das 1Hz file bestimmen:
    oap_1Hz = import_1Hz_pip_files_as_pd( eval('path_1Hz_pip_'+str(year)+str(month).zfill(2)+str(day).zfill(2)), year, month, day)
    
    data_df_1s = pd.DataFrame(columns= dn_names)
    data_df_1s['datetime_1s'] = []
    
    for i in range(len(index_1s)):
        df_1s_not_corrected = df_not_corrected[df_not_corrected.datetime_1s == index_1s[i]]
        count_all = df_1s_not_corrected.missed.sum(axis = 0) + len(df_1s_not_corrected)
        #count_images = df_1s_not_corrected.missed.sum(axis = 0)
        count_images = len(df_1s_not_corrected)
    
        df_1s_pbp = df_corrected[df_corrected.datetime_1s == index_1s[i]]
        df_1s = calc_diam_per_bin(df_1s_pbp,bin_df_cali , endbind)
        
        #dead time in sampling time = summe interarrival times, wenn mindestens einsd missed partikel
        dead_time = ((df_1s_not_corrected.missed > 0)*df_1s_not_corrected.inttime).sum(axis = 0)    
        active_time = 1 - dead_time
        active_time = max(0,active_time)
    
        df_1s['datetime_1s'] = index_1s[i]
        df_1s['missed'] = df_1s_not_corrected.missed.sum(axis=0)
        df_1s['active_time_aaron'] = active_time # ist die activetime berechnet nach SODA
        df_1s['count_all_pbp'] = count_all # hier sind die nicht corrected und alle missed particles dabei!
        df_1s['count_images'] = count_images # hier die nicht corrected aber ohne missed!
        #df_1s['missed_soda'] = df_1s['count_all_pbp']  - df_1s['count_images']
        df_1s['rejected'] = len(df_1s_not_corrected) - len(df_1s_pbp)
        df_1s['accepted'] = df_1s[dn_names].sum(axis=1)
        data_df_1s = data_df_1s.append(df_1s, sort=True)    
        if i%100 ==0:
            print('Making Pandas: (1/2)' ,int(i/len(index_1s)*100),'%')
    data_df_1s = data_df_1s.set_index('datetime_1s')
    
    #Sampling Volumen: 
    #makeing DF from TAS File:
    tas_file = tas_file
    timestamp = []
    for i in range(len(tas_file)):
        timestamp.append(datetime_from_utcs(year, month, day, tas_file.utc.iloc[i]))
    tas_file.insert(0, 'datetime',timestamp)
    tas_file.index = tas_file.datetime
    tas_file= tas_file.drop('datetime', axis=1)
    
    data_df_1s['datetime'] = data_df_1s.index
    data_df_1s.reset_index(drop=True, inplace=True)
    data_df_1s = pd.merge_asof(tas_file['tas'],data_df_1s, on = 'datetime' , tolerance=pd.Timedelta('1s'))
    data_df_1s = pd.merge_asof(oap_1Hz['count_all_1Hz'],data_df_1s, on = 'datetime' , tolerance=pd.Timedelta('1s'))
    
    data_df_1s['missed_GandL'] = data_df_1s['count_all_1Hz']  - data_df_1s['count_images']
    
    data_df_1s['dead_time_GandL_1Hz'] = 1-(data_df_1s['count_images']/data_df_1s['count_all_1Hz'])
    data_df_1s.loc[data_df_1s['dead_time_GandL_1Hz'] <0, 'dead_time_GandL_1Hz'] = 0
    data_df_1s['active_time_GandL_1Hz'] = 1-data_df_1s['dead_time_GandL_1Hz'] 
    data_df_1s['active_time_GandL_too_small_flag'] = (data_df_1s['active_time_GandL_1Hz']<0.1)
    data_df_1s.loc[data_df_1s['active_time_GandL_1Hz']<0.1,'active_time_GandL_1Hz' ]= np.nan # daten mit active time kleiner 0.1 seckunden werden entfernt --> nan
    data_df_1s.loc[data_df_1s['active_time_aaron']<0.1,'active_time_aaron' ]= np.nan
    
    data_df_1s.loc[data_df_1s['tas']<10,'tas' ]= np.nan
    
    data_df_1s.index = data_df_1s['datetime']
    
    #data_df_1s= data_df_1s.between_time('13:58', '14:08')
    sa = oap_dmt_sa_centerin(resolution, armwidth) #erstellen der samlingarea pro bin
    #berechnung der samlingvolumen pro bin pro sekunde
    #hier berechnung eines neuen dataframes dass dN/dN beinhaltet
    data_df_dNdD = pd.DataFrame(columns= dNdD_names)
    data_df_dNdD['datetime'] = []
    time_s = []
    for i in range(len(data_df_1s)):
        # hier ist actice time = 1
        #data_cache = np.array(data_df_1s[dn_names].iloc[i]/(sv_per_bin(sa,data_df_1s['tas'].iloc[i],1)+ 1e-16))/(resolution*1e-6)
        #hier ist active time = soda aaron
        #data_cache = np.array(data_df_1s[dn_names].iloc[i]/(sv_per_bin(sa,data_df_1s['tas'].iloc[i],data_df_1s.active_time_aaron.iloc[i])+ 1e-16))/(resolution*1e-6)
        #hier ist active time = active_time_GandL_1Hz
        data_cache = np.array(data_df_1s[dn_names].iloc[i]/(sv_per_bin(sa,data_df_1s['tas'].iloc[i],data_df_1s.active_time_GandL_1Hz.iloc[i])+ 1e-16))/(resolution*1e-6)
    
        dNdD = pd.DataFrame([data_cache],columns = dNdD_names)
        #dNdD.loc[0] = data_df_1s[dn_names].iloc[i]/(sv_per_bin(sa,data_df_1s['tas'].iloc[i],1)+ 1e-16)
        dNdD['datetime'] = data_df_1s['datetime'].iloc[i]
        data_df_dNdD = data_df_dNdD.append(dNdD)
        time_s.append(seconds_since_midnight(data_df_1s.datetime.iloc[i].hour,data_df_1s.datetime.iloc[i].minute, data_df_1s.datetime.iloc[i].second))
        if i%100 ==0:
            print('Making Pandas: (2/2)' ,int(i/len(data_df_1s)*100),'%')
    
    data_df_dNdD.index = data_df_dNdD['datetime']
    data_df_dNdD = data_df_dNdD.drop(columns = 'datetime')
    #einfügen in das richtige dataframe:
    data_df_1s = pd.concat([data_df_1s, data_df_dNdD], axis=1)
    
    data_df_1s['Time'] = time_s
    data_df_1s.insert(1, 'N', (data_df_1s[dNdD_names]*(resolution*1e-6)).sum(axis=1))
    data_df_1s.insert(2, 'MVD', calc_MVD(data_df_1s,bin_df_cali*1e-6))
    data_df_1s.insert(3, 'LWC', calc_LWC(get_dN(data_df_1s,bin_df_cali*1e-6), (bin_df_cali['bin_mid']*1e-6).to_numpy())[0]  )
    data_df_1s.insert(4, 'IWC', calc_IWC(get_dN(data_df_1s,bin_df_cali*1e-6), (bin_df_cali['bin_mid']*1e-6).to_numpy())[0]  ) 
    #data_df_1s.insert(5, 'ED', calc_ED(data_df_1s,bin_df_cali*1e-6))
    data_df_1s.insert(6, 'Applied PAS (m/s)', data_df_1s.tas)
    #data_df_1s = data_df_1s.fillna(0)
    #data_df_1s.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/PIP/prozessierung20210208/pandas_daten/' +  str(year)+str(month).zfill(2)+str(day).zfill(2) +'activetime_aaron_c818.pkl')
    print('done with flight:' +  str(year)+str(month).zfill(2)+str(day).zfill(2))
    ######################################################################################################
    return data_df_1s





data_pip_aflux1 = make_pip_pandas_aflux(2019, 3, 19)
data_pip_aflux2 = make_pip_pandas_aflux(2019, 3, 21)
data_pip_aflux3 = make_pip_pandas_aflux(2019, 3, 23)
data_pip_aflux4 = make_pip_pandas_aflux(2019, 3, 24)
data_pip_aflux5 = make_pip_pandas_aflux(2019, 3, 25)
data_pip_aflux6 = make_pip_pandas_aflux(2019, 3, 30)
data_pip_aflux7 = make_pip_pandas_aflux(2019, 3, 31)
data_pip_aflux8 = make_pip_pandas_aflux(2019, 4, 1)
data_pip_aflux9 = make_pip_pandas_aflux(2019, 4, 3)
data_pip_aflux10 = make_pip_pandas_aflux(2019, 4, 4)
data_pip_aflux11 = make_pip_pandas_aflux(2019, 4, 6)
data_pip_aflux12 = make_pip_pandas_aflux(2019, 4, 7)
data_pip_aflux13 = make_pip_pandas_aflux(2019, 4, 8)
data_pip_aflux14 = make_pip_pandas_aflux(2019, 4, 11)


aflux_pip = pd.DataFrame(columns = data_pip_aflux1.columns)
aflux_pip = aflux_pip.append(data_pip_aflux2)
aflux_pip = aflux_pip.append(data_pip_aflux3)
aflux_pip = aflux_pip.append(data_pip_aflux4)
aflux_pip = aflux_pip.append(data_pip_aflux5)
aflux_pip = aflux_pip.append(data_pip_aflux6)
aflux_pip = aflux_pip.append(data_pip_aflux7)
aflux_pip = aflux_pip.append(data_pip_aflux8)
aflux_pip = aflux_pip.append(data_pip_aflux9)
aflux_pip = aflux_pip.append(data_pip_aflux10)
aflux_pip = aflux_pip.append(data_pip_aflux11)
aflux_pip = aflux_pip.append(data_pip_aflux12)
aflux_pip = aflux_pip.append(data_pip_aflux13)
aflux_pip = aflux_pip.append(data_pip_aflux14)
aflux_pip.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/PIP/aflux_pip_at1.pkl')

#end: create buffer data file, with active time = constant = 1
#############################################################################






#############################################################################
#start: create dataframe and nasa ames files, with dead time correction (Gurganus and Lawsown, 2018)

def repair_time(data_df):
    #funktioniert nur bei einem dataframe mit zusammenhängenden 1Hz daten. (d.H. nur ein Flugtag!)
    #nimmt die Zeitreihe vom data_df und erstellt eine neue Zeitreihe mit konstantem Zeitschritt 1s
    # wird danach aufeinander gemerged
    # und 'Time' wieder hinzugefügt
    datetime = pd.date_range(data_df.datetime[0],data_df.datetime[-1], freq='1s')
    df_datetime = pd.DataFrame(data = datetime, columns = ['datetime'])
    combined = pd.merge_asof(df_datetime, data_df, on = 'datetime' , tolerance=pd.Timedelta('1s'))
    combined.index = combined.datetime
    combined.index.name = ''
    combined = combined.drop(columns = ['Time'])
    
    Time = []
    for i in range(len(combined)):
        Time.append(seconds_since_midnight(combined.datetime.iloc[i].hour, combined.datetime.iloc[i].minute, combined.datetime.iloc[i].second))
    combined.insert(0,'Time', Time)
    return combined

#####hier wird das PKL file eingelesen uns ein NASA Ames format daraus gemacht

#holy file, mit verschiedenen auswerte routinen wie Samplingtime GandL, Soda etc...
pip_data_df = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/PIP/aflux_pip_at1.pkl')

#hier die zeit auf 1 sekunde gekürzt: 
datetime = []
for i in range(len(pip_data_df)):
    datetime.append(datetime_from_utcs(pip_data_df.datetime.iloc[i].year, pip_data_df.datetime.iloc[i].month, pip_data_df.datetime.iloc[i].day, pip_data_df.Time.iloc[i]))
pip_data_df.index = datetime
pip_data_df.datetime = datetime
#############



#########cip:
resolution_pip = 103 #in mu m
pip_bin_df = bin_df_from_edges(create_endbins(resolution_pip))
dNdD_names_pip, dn_names_pip = column_names(bin_df_from_edges(create_endbins(resolution_pip)))
#active time anpassen: 
t_factor = pip_data_df.active_time_GandL_1Hz
t_factor = np.power(pip_data_df.active_time_GandL_1Hz.replace(np.nan, 0.1), 1- 0.5) # die 0.5 sind educated guess
pip_data_df[dNdD_names_pip + ['N', 'LWC', 'IWC']] = pip_data_df[dNdD_names_pip + ['N', 'LWC', 'IWC']].div(t_factor, axis=0) 


#weitere Parameter hinzufügen: 
pip_data_df.insert(5, 'ED', calc_ED(pip_data_df,pip_bin_df*1e-6))




#pkl files:
directory = r'C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/PIP/20210811_PIP_AMES_Files' # directory where NASA-Ames Files get saved
pip_data_df[['datetime','N', 'LWC', 'IWC', 'MVD', 'ED'] + dNdD_names_pip].to_pickle(directory+'/aflux_pip_data_df.pkl')
pip_bin_df.to_pickle(directory+'/aflux_pip_bin_df.pkl')




#hier die berechneten variablen angeben die ins file sollen, IWC, LWC kann hinzugefügt, bzw berechnet werden:
pip_data_df = pip_data_df[['datetime','N', 'IWC' ,'ED']+dNdD_names_pip]

#hier noch eine spalte mit den utc seconds hinzufügen: muss so sein damit das save_icar_cdp funktioniert
Time = []
for i in range(len(pip_data_df)):
    Time.append(seconds_since_midnight(pip_data_df.datetime.iloc[i].hour, pip_data_df.datetime.iloc[i].minute, pip_data_df.datetime.iloc[i].second))
pip_data_df.insert(0,'Time', Time)


#pip_data_df = cip_data_df.replace(np.nan, 0)
#pip_data_df = cip_data_df.replace(np.inf, 0)


#einzelnen tage herausfinden:
days_of_campaign = pip_data_df.resample('D').sum()[pip_data_df.resample('D').sum()['Time']>0].index


for i in range(len(days_of_campaign)):
    data_df = pip_data_df[(pip_data_df.index.year==days_of_campaign[i].year) & (pip_data_df.index.month==days_of_campaign[i].month) & (pip_data_df.index.day==days_of_campaign[i].day)]
    data_df = repair_time(data_df)
    directory = directory
    probe = 'PIP'
    platform = 'Polar5'
    t_start = data_df.index[0]
    bin_df = pip_bin_df
    campaign = 'AFLUX'
    flight = None
    Time_start = data_df.datetime.iloc[0]
    t_start = data_df.index[0]
    save_icar_pip_aflux(data_df, bin_df, campaign, probe, platform, flight, directory)
    
#end: create dataframe and nasa ames files, with dead time correction (Gurganus and Lawsown, 2018)
#############################################################################













