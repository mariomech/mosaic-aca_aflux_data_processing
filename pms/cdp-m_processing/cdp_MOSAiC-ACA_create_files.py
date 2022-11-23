#script übernommen von MOSAiC auswetung für die CDP: Veränderunen nur die Sampling area!
import numpy as np
import pandas as pd
import os
from datetime import datetime
os.chdir('C:/Users/mose_mn/Documents/Python Scripts/git/python/Object')
from Data_object import Data 
os.chdir('.../processing/')
from Utility_MOSAiC_AFLUX_pms import seconds_since_midnight, datetime_from_utcs, bin_df_from_edges, column_names, calc_LWC, calc_MVD, get_dN, calc_ED, save_icar_cdp




#############################################################################
#start: create buffer ames 1hz-files

#Hier in dieser Zelle die Anfangsparameter für jeden Flug einstellen:
date = datetime(2020, 9, 13)
tas_file = r'.../processing/tas_mosaic'+ str('\\')+str(date.year)+str(date.month).zfill(2)+str(date.day).zfill(2) +'_TAS.txt'
tas_file = pd.read_csv(((tas_file).replace('\\', '/')), names = ['utc','tas'],delimiter = ',' ,engine='python', na_values = 999.99)   
data_path = (r'C:\Users\mose_mn\Documents\Kampagnen\MOSAiC_ACAS\Daten\20200913_F11_ice_next_to_Greenland')
flight=None

#create NASA-AMES Files for CDP files:    
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
        if file.startswith("01CDP PBP") and file.endswith(".csv") and not file.endswith("PBP.csv"):
            cdp_file.append(os.path.join(root, file).replace('\\', '/'))
cdp_df = pd.DataFrame()
for i in range(len(cdp_file)):
    cdp_df = cdp_df.append(pd.read_csv(cdp_file[i], delimiter = ',', header = 57 ,engine='python'))
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
#Samplingarea der cdp: 0.27mm² pm 10% 
cdp_df['SV'] = cdp_df.tas * 2.7e-7 * 1 # hier 1 weil 1hz in m^3
cdp_df['SV'] = cdp_df['SV'].replace(0, np.nan)

################Bin width, mid, endpoints:
size_bin =np.array( [3,4,5,6,7,8,9,10,11,12,13,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50])
all_bins = np.append(2,size_bin)
bin_df_cdp = bin_df_from_edges(all_bins)

#bin namen
dNdD_names, dn_names = column_names(bin_df_cdp)

#anzahlconc pro bin in m^-3
name = []
for i in cdp_df.columns:
    if i[:7] == 'CDP Bin':
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

directory = r'C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/nasa_ames_aus_1hz_file' # directory where NASA-Ames Files get saved
probe = 'CDP'
platform = 'Polar5'
t_start = data_df_cdp.index[0]
data_df = data_df_cdp
bin_df = bin_df_cdp
campaign = 'MOSAiC-ACA-S'
save_icar_cdp(data_df, bin_df, campaign, probe, platform, flight, directory)

#end: create buffer ames 1hz-files   
#############################################################################


#############################################################################
#start: create buffer 1hz-datafile   
def read_nasa_ames(directory, data_name): 
    os.chdir(directory)
    f=open(data_name)
    lines=f.readlines()
    position_header = int(lines[0][0:-1][0:2])
    position_header = 56
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

data_path = 'C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/nasa_ames_aus_1hz_file'
nasa_files = []
for root, dirs, files in os.walk(data_path):
    for file in files:
        if file.startswith("MOSAiC") and file.endswith(".1Hz"):
            nasa_files.append(os.path.join(root, file).replace('\\', '/'))

data_cas_aflux1 = read_nasa_ames(data_path, nasa_files[0][-37:])
data_cas_aflux2 = read_nasa_ames(data_path, nasa_files[1][-37:])
data_cas_aflux3 = read_nasa_ames(data_path, nasa_files[2][-37:])
data_cas_aflux4 = read_nasa_ames(data_path, nasa_files[3][-37:])
data_cas_aflux5 = read_nasa_ames(data_path, nasa_files[4][-37:])
data_cas_aflux6 = read_nasa_ames(data_path, nasa_files[5][-37:])
data_cas_aflux7 = read_nasa_ames(data_path, nasa_files[6][-37:])
data_cas_aflux8 = read_nasa_ames(data_path, nasa_files[7][-37:])
data_cas_aflux9 = read_nasa_ames(data_path, nasa_files[8][-37:])

aflux_pip = pd.DataFrame(columns = data_cas_aflux1.columns)
aflux_pip = aflux_pip.append(data_cas_aflux2)
aflux_pip = aflux_pip.append(data_cas_aflux3)
aflux_pip = aflux_pip.append(data_cas_aflux4)
aflux_pip = aflux_pip.append(data_cas_aflux5)
aflux_pip = aflux_pip.append(data_cas_aflux6)
aflux_pip = aflux_pip.append(data_cas_aflux7)
aflux_pip = aflux_pip.append(data_cas_aflux8)
aflux_pip = aflux_pip.append(data_cas_aflux9)

aflux_pip = aflux_pip.replace(-9999.0, np.nan)
aflux_pip.to_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\MOSAiC_ACAS\Auswertung\NASA-AMES\CDP\20210804_CDP_AMES_Files\nasa_ames_aus_1hz_file\mosaic_cdp.pkl')
bin_df.to_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\MOSAiC_ACAS\Auswertung\NASA-AMES\CDP\20210804_CDP_AMES_Files\nasa_ames_aus_1hz_file\mosaic_cdp_bin_df.pkl')
#end: create buffer 1hz-datafile   
#############################################################################




#############################################################################
#start: create final cdp datafile
#########cdp 1Hz data:
cdp_1Hz_data = pd.read_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\MOSAiC_ACAS\Auswertung\NASA-AMES\CDP\20210804_CDP_AMES_Files\nasa_ames_aus_1hz_file\mosaic_cdp.pkl')
bin_df_cdp =  bin_df_from_edges([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50])
dNdD_names_cdp, dn_names_cdp = column_names(bin_df_from_edges([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50]))

# alle cdp pbp files finden: 
#inputs:
data_path = (r'C:\Users\mose_mn\Documents\Kampagnen\MOSAiC_ACAS\Daten')
cdp_files = []
for root, dirs, files in os.walk(data_path):
    for file in files:
        if file.startswith("01CDP PBP") and file.endswith("PBP.csv") and not file.endswith("aaa.csv"):
            cdp_files.append(os.path.join(root, file).replace('\\', '/'))
'''
#for processing details please contact the author. 
#alle cdp files mit Dataobject prozessieren und als pkl file abspeichern: 
for i in range(len(cdp_files)):
    print('calculating file number: ' +str(i) +' out of '+str(len(cdp_files)) + '\n')
    with open(cdp_files[i],"r") as f:
        reader = csv.reader(f,delimiter = ",")
        data = list(reader)
        row_count = len(data)
    if row_count > 61:       
        cdp_pbp = Data()
        cdp_pbp.get_cdp_pbp_data(cdp_files[i], 'C:/Users/mose_mn/Documents/Python Scripts/data-objekt/Holy_CDP_Binning.txt')
        cdp_pbp_data_df = cdp_pbp.data_df
        cdp_pbp_bin_df = cdp_pbp.bin_df
        cdp_pbp_data_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/pkl_data_object_files/cdp_pbp_data_df'+str(cdp_files[i][-22:-8])+'.pkl')
cdp_pbp_bin_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/pkl_data_object_files/cdp_pbp_bin_df.pkl')
'''
#alle pkl files einlesen: 
data_path = (r'C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/pkl_data_object_files').replace('/','\\')
cdp_pkl_files = []
for root, dirs, files in os.walk(data_path):
    for file in files:
        if file.startswith("cdp_pbp_data_df") :
            cdp_pkl_files.append(os.path.join(root, file).replace('\\', '/'))
mosaic_cdp_bin_df = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/pkl_data_object_files/cdp_pbp_bin_df.pkl')

# hier alle pkls zusammen fügen
cdp_mosaic = pd.DataFrame()
for i in cdp_pkl_files:    
    cdp_mosaic = cdp_mosaic.append(pd.read_pickle(i))
cdp_mosaic.index = cdp_mosaic.index.rename('datetime')

#hier sortieren nach datum
cdp_mosaic = cdp_mosaic.sort_values(by = 'datetime')

#hier nur die columns dNdD übernhemen und richtig berechnen, da SA und die TAS bei der Dataobject berechnung falsch sind! (Konstante 40 m/s für die TAS)
dNdD_names = []
for i in cdp_mosaic.columns:
    if i[:2] == 'dN':
        dNdD_names.append(i)
cdp_mosaic = cdp_mosaic[dNdD_names]    
tas = cdp_1Hz_data['Applied PAS (m/s)']
tas.index.name = 'datetime'
tas = tas.replace(-9999.000000, np.nan)
cdp_mosaic = pd.merge_asof(tas,cdp_mosaic, on = 'datetime' , tolerance=pd.Timedelta('1s'))
cdp_mosaic[dNdD_names] = (cdp_mosaic[dNdD_names]*40).divide(list(tas), axis = 0)
cdp_mosaic.index = cdp_mosaic.datetime

# jetzt die unteren bins vom pbp file aus DataDf und die oberen bins aus dem 1Hz file:
# abscheindegrene = 30 mu m
bin_df = mosaic_cdp_bin_df[:14].append(bin_df_cdp[20:]).reset_index()
bin_df.index = bin_df.index +1
bin_df.drop(columns = 'index')
dNdD_names, dn_names = column_names(bin_df)

data_df = pd.merge_asof(cdp_mosaic[dNdD_names].iloc[:,:14],cdp_1Hz_data[dNdD_names_cdp].iloc[:,20:], on = 'datetime' , tolerance=pd.Timedelta('1s'))
data_df.index = data_df.datetime
data_df.drop(columns = 'datetime')
data_df.columns = ['datetime'] + dNdD_names
data_df = data_df.replace(-9999.0, np.nan)


#an manchen stellen sieht das pbp file aus data df keine partikel (sehr selten).
#hier in diesen sekunden: das 1Hz file wird genommen und auf die Bins vom data df file übertragen
#rebin_values = list(bin_df_cdp.bin_mid.value_counts(bins = list(bin_df.bin_min)+[list(bin_df.bin_max)[-1]], sort = False))
cdp_1Hz_data_for_rebinning = cdp_1Hz_data.replace(-9999.0, np.nan)[dNdD_names_cdp]
cdp_1Hz_data_for_rebinning = cdp_1Hz_data_for_rebinning.mul(list(bin_df_cdp.bin_width*1e-6), axis = 1)
data_df_rebin = pd.DataFrame(columns = dNdD_names, index = data_df.index)
data_df_rebin[dNdD_names[0]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[0]])
data_df_rebin[dNdD_names[1]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[1:3]]).sum(axis = 1)
data_df_rebin[dNdD_names[2]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[2:6]]).sum(axis = 1)
data_df_rebin[dNdD_names[3]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[5:8]]).sum(axis = 1)
data_df_rebin[dNdD_names[4]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[7:10]]).sum(axis = 1)
data_df_rebin[dNdD_names[5]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[9:12]]).sum(axis = 1)
data_df_rebin[dNdD_names[6]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[12:13]]).sum(axis = 1)
data_df_rebin[dNdD_names[7]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[13:14]]).sum(axis = 1)
#data_df_rebin[dNdD_names[8]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[1:3]]).sum(axis = 1)
data_df_rebin[dNdD_names[9]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[14:15]]).sum(axis = 1)
data_df_rebin[dNdD_names[10]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[15:16]]).sum(axis = 1)
data_df_rebin[dNdD_names[11]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[16:17]]).sum(axis = 1)
data_df_rebin[dNdD_names[12]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[17:19]]).sum(axis = 1)
data_df_rebin[dNdD_names[13]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[19:20]]).sum(axis = 1)
data_df_rebin[dNdD_names[14]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[20:21]]).sum(axis = 1)
data_df_rebin[dNdD_names[15]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[21:22]]).sum(axis = 1)
data_df_rebin[dNdD_names[16]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[22:23]]).sum(axis = 1)
data_df_rebin[dNdD_names[17]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[23:24]]).sum(axis = 1)
data_df_rebin[dNdD_names[18]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[24:25]]).sum(axis = 1)
data_df_rebin[dNdD_names[19]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[25:26]]).sum(axis = 1)
data_df_rebin[dNdD_names[20]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[26:27]]).sum(axis = 1)
data_df_rebin[dNdD_names[21]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[27:28]]).sum(axis = 1)
data_df_rebin[dNdD_names[22]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[28:29]]).sum(axis = 1)
data_df_rebin[dNdD_names[23]] = (cdp_1Hz_data_for_rebinning[dNdD_names_cdp[29:30]]).sum(axis = 1)
data_df_rebin = data_df_rebin.div(list(bin_df.bin_width*1e-6), axis = 1)
#hier, da wo data_df keine daten sieht die neu gebinnten daten aus dem 1Hz file verwenden
index_for_rebinning = data_df[data_df[dNdD_names[:14]].sum(axis = 1) == 0].index
data_df.loc[index_for_rebinning] = data_df_rebin.loc[index_for_rebinning]

data_df = data_df.drop(columns = 'datetime')
data_df['datetime'] = data_df.index
data_df.index = data_df.index.rename('')
data_df = data_df.drop(columns = 'datetime')


#neu ab dem 16.09.2021:
#rebinning: erst daten ab ca. 3 mu m verwenden:
bin_df = bin_df_from_edges(list(bin_df.bin_max))
dNdD_names_cdp, dn_names_cdp = column_names(bin_df)
data_df = data_df.iloc[:,1:] 
data_df = data_df.set_axis(dNdD_names_cdp, axis='columns', inplace = False)

data_df.insert(0,'datetime',data_df.index)
data_df.insert(1,'N',(data_df[dNdD_names_cdp]).mul(np.array(bin_df.bin_width*1e-6)).sum(axis = 1))
data_df.insert(2, 'MVD', calc_MVD(data_df,bin_df*1e-6))
data_df.insert(3, 'LWC', calc_LWC(get_dN(data_df,bin_df*1e-6), (bin_df['bin_mid']*1e-6).to_numpy())[0]  )
data_df.insert(4, 'CWC', calc_LWC(get_dN(data_df,bin_df*1e-6), (bin_df['bin_mid']*1e-6).to_numpy())[0]  )
data_df.insert(5, 'ED', calc_ED(data_df,bin_df*1e-6))
data_df.insert(6, 'Applied PAS', tas)

data_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/mosaic_cdp_data_df.pkl')
bin_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/mosaic_cdp_bin_df.pkl')
#end: create final cdp datafile
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

#####hier wird das PKL file eingelesen uns ein NASA Ames format daraus gemacht
cdp_data_df = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/mosaic_cdp_data_df.pkl')
cdp_bin_df = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files/mosaic_cdp_bin_df.pkl')

#hier noch eine spalte mit den utc seconds hinzufügen: muss so sein damit das save_icar_cdp funktioniert
Time = []
for i in range(len(cdp_data_df)):
    Time.append(seconds_since_midnight(cdp_data_df.datetime.iloc[i].hour, cdp_data_df.datetime.iloc[i].minute, cdp_data_df.datetime.iloc[i].second))
cdp_data_df.insert(0,'Time', Time)

cdp_data_df = cdp_data_df.replace(np.nan, 0)
cdp_data_df = cdp_data_df.replace(np.inf, 0)

#einzelne tage herausfinden:
days_of_campaign = cdp_data_df.resample('D').sum()[cdp_data_df.resample('D').sum()['Time']>0].index

for i in range(len(days_of_campaign)):
    data_df = cdp_data_df[(cdp_data_df.index.year==days_of_campaign[i].year) & (cdp_data_df.index.month==days_of_campaign[i].month) & (cdp_data_df.index.day==days_of_campaign[i].day)]
    data_df = repair_time(data_df)
    directory = r'C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES/CDP/20210804_CDP_AMES_Files' # directory where NASA-Ames Files get saved
    probe = 'CDP'
    platform = 'Polar5'
    t_start = data_df.index[0]
    bin_df = cdp_bin_df
    campaign = 'MOSAiC-ACA-S'
    flight = None
    Time_start = data_df.datetime.iloc[0]
    t_start = data_df.index[0]
    columns = ['Time','N', 'CWC', 'ED'] + column_names(cdp_bin_df)[0]
    save_icar_cdp(data_df[columns], bin_df, campaign, probe, platform, flight, directory)
    
#end: create NASA AMES files
#############################################################################




