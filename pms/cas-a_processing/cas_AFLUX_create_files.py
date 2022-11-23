import numpy as np
import pandas as pd
import os
from datetime import datetime
os.chdir('.../processing/')
from Utility_MOSAiC_AFLUX_pms import seconds_since_midnight, datetime_from_utcs, bin_df_from_edges, column_names, calc_LWC, calc_MVD, get_dN, calc_ED, save_icar_cas_aflux


#############################################################################
#start: create buffer ames files
#create NASA AMES files, give the date, dir for tas file, dir where CAS file ("01CASxxxx.csv") is saved, dir where NASA AMES files should be saved
#Hier in dieser Zelle die Anfangsparameter für jeden Flug einstellen:
date = datetime(2019, 3, 19)
tas_file = pd.read_csv(((r'.../processing/tas_aflux/tas_190319.txt').replace('\\', '/')), names = ['utc','tas'],delimiter = ',' ,engine='python', na_values = 999.99)
data_path = (r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\F1 20190319\20190319')
flight=999
#create NASA-AMES Files for CAS files:
#makeing DF from TAS File:
tas_file = tas_file
timestamp = []
for i in range(len(tas_file)):
    timestamp.append(datetime_from_utcs(date.year,date.month, date.day, tas_file.utc.iloc[i]))
tas_file.insert(0, 'datetime',timestamp)
tas_file.index = tas_file.datetime
tas_file= tas_file.drop('datetime', axis=1)
#making DF from CDP files
data_path = data_path
cdp_file = []
for root, dirs, files in os.walk(data_path):
    for file in files:
        if file.startswith("01CAS") and file.endswith(".csv") and not file.endswith("PBP.csv"):
            cdp_file.append(os.path.join(root, file).replace('\\', '/'))
cdp_df = pd.DataFrame()
for i in range(len(cdp_file)):
    cdp_df = cdp_df.append(pd.read_csv(cdp_file[i], delimiter = ',', header = 136 ,engine='python'))
timestamp = []
for i in range(len(cdp_df)):
    timestamp.append(datetime_from_utcs(date.year,date.month, date.day, cdp_df['End Seconds'].iloc[i]))
cdp_df.insert(0, 'datetime',timestamp)
cdp_df.index = cdp_df.datetime
cdp_df= cdp_df.drop('datetime', axis=1)    
#Merge DF TAS + CDP File:
cdp_df = pd.merge_asof(cdp_df,tas_file['tas'], on = 'datetime' , tolerance=pd.Timedelta('1s'))
cdp_df.index = cdp_df.datetime
cdp_df= cdp_df.drop('datetime', axis=1)    
#Samplingarea der cas: 0.3mm² pm 11% 
cdp_df['SV'] = cdp_df.tas * 3.0e-7 * 0.1 # hier 1 weil 1hz in m^3
cdp_df['SV'] = cdp_df['SV'].replace(0, np.nan)

################Bin width, mid, endpoints:
size_bin =np.array( [0.61,0.68,0.75,0.82,0.89,0.96,1.03,1.1,1.17,1.25,1.5,2,2.5,3,3.5,4,5,6.5,7.2,7.9,10.2,12.5,15,20,25,30,35,40,45,50])
all_bins = np.append(0.5,size_bin)
bin_df_cdp = bin_df_from_edges(all_bins)
#bin namen
dNdD_names, dn_names = column_names(bin_df_cdp)
#anzahlconc pro bin in m^-3
name = []
for i in cdp_df.columns:
    if i[:7] == 'CAS Bin':
        name.append(i)
data_df_cdp = pd.DataFrame()      
data_df_cdp[dn_names]=cdp_df[name]
data_df_cdp[dNdD_names] = data_df_cdp[dn_names].div(cdp_df.SV.values, axis = 0).div(bin_df_cdp.bin_width.values*1e-6, axis = 1)

data_df_cdp.insert(0,'Time', cdp_df['End Seconds'])
data_df_cdp.insert(1,'N',data_df_cdp[dn_names].div(cdp_df.SV.values, axis = 0).sum(axis=1, min_count = 1))
data_df_cdp.insert(2, 'MVD', calc_MVD(data_df_cdp,bin_df_cdp*1e-6))
data_df_cdp.insert(3, 'LWC', calc_LWC(get_dN(data_df_cdp,bin_df_cdp*1e-6), (bin_df_cdp['bin_mid']*1e-6).to_numpy())[0]  )
data_df_cdp.insert(4, 'ED', calc_ED(data_df_cdp,bin_df_cdp*1e-6))
data_df_cdp.insert(5, 'Applied PAS (m/s)', cdp_df.tas)

data_df_cdp[dn_names] = data_df_cdp[dn_names].astype(float)
data_df_cdp[dNdD_names] = data_df_cdp[dNdD_names].astype(float)
data_df_cdp = data_df_cdp.resample('1s').mean()
data_df_cdp = data_df_cdp[data_df_cdp.Time >0]

directory = r'C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CAS' # directory where NASA-Ames Files get saved
probe = 'CAS'
platform = 'Polar5'
t_start = data_df_cdp.index[0]
data_df = data_df_cdp
bin_df = bin_df_cdp
campaign = 'AFLUX'
save_icar_cas_aflux(data_df, bin_df, campaign, probe, platform, flight, directory)
#end: create buffer ames files
#############################################################################
    



#############################################################################
#start: create buffer dataframe from all buffer ames files
def read_nasa_ames(directory, data_name): 
    os.chdir(directory)
    f=open(data_name)
    lines=f.readlines()
    position_header = int(lines[0][0:-1][0:2])
    header = lines[position_header][0:-1]
    data = np.genfromtxt(data_name, skip_header = position_header, delimiter = ',')
    data_columns = np.genfromtxt(data_name, dtype = 'str',skip_header = position_header-1, skip_footer = len(data), delimiter = ',')
    df = pd.DataFrame(data=data, columns=data_columns, index = data[:,0])
    timestamp = []
    year = int(lines[6][0:4])
    month = int(lines[6][6:8])
    day = int(lines[6][10:12])
    for i in range(len(df.Time_start)):
        #timestamp.append(datetime_from_utcs(2015, 12, 13, df.Time.iloc[i]))
        timestamp.append(datetime_from_utcs(year, month, day, df.Time_start.iloc[i]))
    df.insert(0, 'datetime',timestamp)
    df.index = df.datetime    
    return df

def read_nasa_ames2(directory, data_name): 
    os.chdir(directory)
    f=open(data_name)
    lines=f.readlines()
    position_header = int(lines[0][0:-1][0:2])-1
    header = lines[position_header][0:-1]
    data = np.genfromtxt(data_name, skip_header = position_header+1, delimiter = ' ')
    data_columns = np.genfromtxt(data_name, dtype = 'str',skip_header = position_header, skip_footer = len(data), delimiter = ' ')
    df = pd.DataFrame(data=data, columns=data_columns, index = data[:,0])
    
    timestamp = []
    year = int(lines[6][0:4])
    month = int(lines[6][5:7])
    day = int(lines[6][8:10])
    for i in range(len(df.Time_start)):
        #timestamp.append(datetime_from_utcs(2015, 12, 13, df.Time.iloc[i]))
        timestamp.append(datetime_from_utcs(year, month, day, df.Time_start.iloc[i]))
    df.insert(0, 'datetime',timestamp)
    df.index = df.datetime
    return df

data_path = 'C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CAS/old'
nasa_files = []
for root, dirs, files in os.walk(data_path):
    for file in files:
        if file.startswith("AFLUX") and file.endswith(".1Hz"):
            nasa_files.append(os.path.join(root, file).replace('\\', '/'))

data_cas_aflux1 = read_nasa_ames(data_path, nasa_files[0][-35:])
data_cas_aflux2 = read_nasa_ames(data_path, nasa_files[1][-35:])
data_cas_aflux3 = read_nasa_ames(data_path, nasa_files[2][-35:])
data_cas_aflux4 = read_nasa_ames(data_path, nasa_files[3][-35:])
data_cas_aflux5 = read_nasa_ames(data_path, nasa_files[4][-35:])
data_cas_aflux6 = read_nasa_ames(data_path, nasa_files[5][-35:])
data_cas_aflux7 = read_nasa_ames(data_path, nasa_files[6][-35:])
data_cas_aflux8 = read_nasa_ames(data_path, nasa_files[7][-35:])
data_cas_aflux9 = read_nasa_ames(data_path, nasa_files[8][-35:])
data_cas_aflux10 = read_nasa_ames2(data_path, nasa_files[9][-35:])
data_cas_aflux10.columns = data_cas_aflux9.columns
data_cas_aflux11 = read_nasa_ames(data_path, nasa_files[10][-35:])
data_cas_aflux12 = read_nasa_ames(data_path, nasa_files[11][-35:])
data_cas_aflux13 = read_nasa_ames(data_path, nasa_files[12][-35:])
data_cas_aflux14 = read_nasa_ames(data_path, nasa_files[13][-35:])

aflux_cas = pd.DataFrame(columns = data_cas_aflux1.columns)
aflux_cas = aflux_cas.append(data_cas_aflux2)
aflux_cas = aflux_cas.append(data_cas_aflux3)
aflux_cas = aflux_cas.append(data_cas_aflux4)
aflux_cas = aflux_cas.append(data_cas_aflux5)
aflux_cas = aflux_cas.append(data_cas_aflux6)
aflux_cas = aflux_cas.append(data_cas_aflux7)
aflux_cas = aflux_cas.append(data_cas_aflux8)
aflux_cas = aflux_cas.append(data_cas_aflux9)
aflux_cas = aflux_cas.append(data_cas_aflux10)
aflux_cas = aflux_cas.append(data_cas_aflux11)
aflux_cas = aflux_cas.append(data_cas_aflux12)
aflux_cas = aflux_cas.append(data_cas_aflux13)
aflux_cas = aflux_cas.append(data_cas_aflux14)
#save buffer dataframe:
#aflux_cas.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CAS/aflux_cas.pkl')

#end: create buffer dataframe from all buffer ames files
#############################################################################


#############################################################################
#start: create dataframe from buffer nasa ames files

#alte cdp daten einlesen und daraus die anzahlconzentration pro bin berechnen!
cas_df = pd.read_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\CAS\old\aflux_cas.pkl')
bin_df_cdp =  bin_df_from_edges([0.5, 0.61,0.68,0.75,0.82,0.89,0.96,1.03,1.1,1.17,1.25,1.5,2,2.5,3,3.5,4,5,6.5,7.2,7.9,10.2,12.5,15,20,25,30,35,40,45,50])
dNdD_names_cdp, dn_names_cdp = column_names(bin_df_from_edges([0.5, 0.61,0.68,0.75,0.82,0.89,0.96,1.03,1.1,1.17,1.25,1.5,2,2.5,3,3.5,4,5,6.5,7.2,7.9,10.2,12.5,15,20,25,30,35,40,45,50]))
cas_df = cas_df.replace(-9999, np.nan)
tas = cas_df['Applied PAS (m/s)']
cas_df = cas_df[dNdD_names_cdp].mul(np.array(bin_df_cdp.bin_width*1e-6))
cas_df.columns = dn_names_cdp
##############################
#bin nummer 11 und 21 sind gainstage, deshalb auf 0 setzen: 
cas_df['dn_011'] = cas_df['dn_011'] * 0
cas_df['dn_021'] = cas_df['dn_021'] * 0

index = [0,1,2,3,4,5,6,7,8,9,11,12,14,16,21,22,23,24,25,26,27,28,29,30]
summ = []
for i in range(len(index)-1):
    summ.append(index[i+1]-index[i])
binning = np.cumsum(summ)

#rebinning: 
cas_df_rebin = pd.DataFrame()
#cas_df_rebin['dNdD_001'] = cas_df['dn_001'] # erster bin wird gelöst da untergrenze nicht genau bestimmt werden kann!
cas_df_rebin['dNdD_001'] = cas_df['dn_002']
cas_df_rebin['dNdD_002'] = cas_df['dn_003']
cas_df_rebin['dNdD_003'] = cas_df['dn_004']
cas_df_rebin['dNdD_004'] = cas_df['dn_005']
cas_df_rebin['dNdD_005'] = cas_df['dn_006']
cas_df_rebin['dNdD_006'] = cas_df['dn_007']
cas_df_rebin['dNdD_007'] = cas_df['dn_008']
cas_df_rebin['dNdD_008'] = cas_df['dn_009']
cas_df_rebin['dNdD_009'] = cas_df['dn_010']+cas_df['dn_011']#gainstage
cas_df_rebin['dNdD_010'] = cas_df['dn_012']
cas_df_rebin['dNdD_011'] = cas_df['dn_013']+cas_df['dn_014']
cas_df_rebin['dNdD_012'] = cas_df['dn_015']+cas_df['dn_016']
cas_df_rebin['dNdD_013'] = cas_df['dn_017']+cas_df['dn_018']+cas_df['dn_019']
cas_df_rebin['dNdD_014'] = cas_df['dn_022']+cas_df['dn_020']+cas_df['dn_021']#gainstage20,21
cas_df_rebin['dNdD_015'] = cas_df['dn_023']
cas_df_rebin['dNdD_016'] = cas_df['dn_024']
cas_df_rebin['dNdD_017'] = cas_df['dn_025']
cas_df_rebin['dNdD_018'] = cas_df['dn_026']
cas_df_rebin['dNdD_019'] = cas_df['dn_027']
cas_df_rebin['dNdD_020'] = cas_df['dn_028']
cas_df_rebin['dNdD_021'] = cas_df['dn_029']
cas_df_rebin['dNdD_022'] = cas_df['dn_030']

bin_edges = [0.606,  0.674,  0.746,  0.811,  0.884,  0.954,  1.022, 1.103, 1.166, 1.269,  2.687,  2.794,  4.95 ,  7.667,  9.984, 13.705, 18.613, 22.759, 27.454, 31.496, 36.522, 43.63 , 53.998]
#gerundet:
bin_edges = [0.61,  0.68,  0.75,  0.81,  0.89,  0.95,  1.02, 1.10, 1.17, 1.27,  2.69,  2.79,  4.95 ,  7.67,  9.98, 13.71, 18.61, 22.76, 27.45, 31.50, 36.52, 43.63 , 53.00]

bin_df_rebin = bin_df_from_edges(bin_edges)

dNdD_names_cdp, dn_names_cdp = column_names(bin_df_rebin)
cas_df_rebin[dNdD_names_cdp] = cas_df_rebin[dNdD_names_cdp].div(np.array(bin_df_rebin.bin_width*1e-6))

#neu ab dem 16.09.2021:
#rebinning: erst daten ab ca. 3 mu m verwenden:
bin_df_rebin = bin_df_from_edges(bin_edges[11:])
dNdD_names_cdp, dn_names_cdp = column_names(bin_df_rebin)
cas_df_rebin = cas_df_rebin.iloc[:,11:]
cas_df_rebin = cas_df_rebin.set_axis(dNdD_names_cdp, axis='columns', inplace = False)

cas_df_rebin.insert(0,'datetime',cas_df_rebin.index)
cas_df_rebin.insert(1,'N',(cas_df_rebin[dNdD_names_cdp]).mul(np.array(bin_df_rebin.bin_width*1e-6)).sum(axis = 1))
cas_df_rebin.insert(2, 'MVD', calc_MVD(cas_df_rebin,bin_df_rebin*1e-6))
cas_df_rebin.insert(3, 'LWC', calc_LWC(get_dN(cas_df_rebin,bin_df_rebin*1e-6), (bin_df_rebin['bin_mid']*1e-6).to_numpy())[0]  )
cas_df_rebin.insert(4, 'CWC', calc_LWC(get_dN(cas_df_rebin,bin_df_rebin*1e-6), (bin_df_rebin['bin_mid']*1e-6).to_numpy())[0]  )
cas_df_rebin.insert(5, 'ED', calc_ED(cas_df_rebin,bin_df_rebin*1e-6))
cas_df_rebin.insert(6, 'Applied PAS', tas)

cas_df_rebin.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CAS/aflux_cas_data_df.pkl')
bin_df_rebin.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CAS/aflux_cas_bin_df.pkl')
#end: create dataframe from buffer nasa ames files
#############################################################################





#############################################################################
#start: create NASA AMES files
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

cas_data_df = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CAS/aflux_cas_data_df.pkl')
cas_bin_df = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CAS/aflux_cas_bin_df.pkl')
#hier noch eine spalte mit den utc seconds hinzufügen: muss so sein damit das save_icar_cdp funktioniert
Time = []
for i in range(len(cas_data_df)):
    Time.append(seconds_since_midnight(cas_data_df.datetime.iloc[i].hour, cas_data_df.datetime.iloc[i].minute, cas_data_df.datetime.iloc[i].second))
cas_data_df.insert(0,'Time', Time)

#cas_data_df = cas_data_df.replace(np.nan, 0)
#cas_data_df = cas_data_df.replace(np.inf, 0)

#einzelnen tage herausfinden:
days_of_campaign = cas_data_df.resample('D').sum()[cas_data_df.resample('D').sum()['Time']>0].index

for i in range(len(days_of_campaign)):
    data_df = cas_data_df[(cas_data_df.index.year==days_of_campaign[i].year) & (cas_data_df.index.month==days_of_campaign[i].month) & (cas_data_df.index.day==days_of_campaign[i].day)]
    data_df = repair_time(data_df)
    directory = r'C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CAS/20210811_CAS_AMES_Files' # directory where NASA-Ames Files get saved
    probe = 'CAS'
    platform = 'Polar5'
    t_start = data_df.index[0]
    bin_df = cas_bin_df
    campaign = 'AFLUX'
    flight = None
    Time_start = data_df.datetime.iloc[0]
    t_start = data_df.index[0]
    columns = ['Time','N', 'CWC', 'ED'] + column_names(cas_bin_df)[0]
    save_icar_cas_aflux(data_df[columns], bin_df, campaign, probe, platform, flight, directory)
#end: create NASA AMES files
#############################################################################



