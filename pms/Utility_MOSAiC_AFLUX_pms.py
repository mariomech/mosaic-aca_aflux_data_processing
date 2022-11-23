import os
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
from datetime import date

'''NOTE: ALL INPUTS AND OUTPUTS SHOULD BE IN SI UNITS'''

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def average_data_df(data_df,averaging_time=5):
    new_data_df = data_df.resample(str(averaging_time)+'S',
                                   convention='end').mean()
    return new_data_df
            
        
    
#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def bin_df_from_edges(bin_edges):
    ''' Input: Bin edges including lowermost and uppermost bin edge. That means
    for n bins n+1 bin edges must be provided. '''

    bin_df = pd.DataFrame({'bin_min': bin_edges[:-1],
                        'bin_max': bin_edges[1:]},
                        index=np.arange(1,len(bin_edges)))
    
    bin_df['bin_mid'] = (bin_df['bin_min'] + bin_df['bin_max'])/ 2
    bin_df['bin_width'] = bin_df['bin_max'] - bin_df['bin_min']

    return bin_df

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def bin_to_1um_res(dn,dNdD,bin_df,logarithmic=True): 
    '''
    Inputs: 
    Pandas data frames bin_df, dn and dNdD, plus the option to 
    select between logarithmic and linear interpolation    
    
    
    Outputs: 
        
    Pandas data frame bin_df at 1 um resolution and Pandas data frames
    dn_1um (the counts at 1 um resolution) and dNdD_1um, number concentration
    per m^4 at 1 um resolution
    
    '''
    dn = dn.astype('float')
    dNdD = dNdD.astype('float')
    
    # Find upper and lower limit of the 1um bin df
    bottom_edge = np.min(bin_df['bin_min']); 
    top_edge = np.max(bin_df['bin_max']); 
    
    # Compute the bin edges
    edges_bin = np.arange(bottom_edge, top_edge+1)
    # From the bin edges find the new bin_df
    bin_df_1um = bin_df_from_edges(edges_bin)  
    
    # Create empty array for dndD, the counts divided by the bin width
    dndD = np.empty(np.shape(dn))
                                            
    # Create empty arrays for the new dNdD_1um and dn_1um arrays 
    dNdD_1um = np.zeros([len(dNdD.index),len(edges_bin)-1])
    dn_1um = np.zeros([len(dn.index),len(edges_bin)-1]) 

    # Loop along the time axis                                   
    for t in range(0,len(dNdD.index)): 
        # The counts have to be transformed to counts divided by bin width
        # before they can be interpolated to 1um resolution
        dndD[t,:] = dn.to_numpy()[t,:]/bin_df['bin_width'].to_numpy()
        # The data can be interpolated linearly or logarithmically
        if logarithmic == True: 
            dNdD_1um[t,:] = log_interp(bin_df_1um.loc[:,'bin_mid'],
                    bin_df.loc[:,'bin_mid'],dNdD.iloc[t,:])
            dn_1um[t,:] = log_interp(bin_df_1um['bin_mid'].to_numpy(),
                  bin_df['bin_mid'].to_numpy(),dndD[t,:])
        else:
            dNdD_1um[t,:] = np.interp(bin_df_1um.loc[:,'bin_mid'].to_numpy(),
                    bin_df.loc[:,'bin_mid'].to_numpy(),dNdD.iloc[t,:])
            dn_1um[t,:] = np.interp(bin_df_1um['bin_mid'].to_numpy(),
                  bin_df['bin_mid'].to_numpy(),dndD[t,:])
    
    # Remove nan values
    dNdD_1um[np.isnan(dNdD_1um)] = 0; 
    dn_1um[np.isnan(dn_1um)] = 0; 
    
    # Get the column names
    dNdD_1um_names,dn_1um_names = column_names(bin_df_1um)
    
    # Create dNdD data frame at 1 um resolution
    dNdD_1um_df = pd.DataFrame(data = dNdD_1um, index = dNdD.index, 
                               columns = dNdD_1um_names)
    # Create dN data frame at 1 um resolution
    dn_1um_df = pd.DataFrame(data = dn_1um, index = dn.index,
                             columns = dn_1um_names)
    
    return bin_df_1um, dNdD_1um_df, dn_1um_df

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def bin_to_1um_res_new(dNdD,bin_df,logarithmic=False): 
    '''
    Inputs: 
    Pandas data frames bin_df, dn and dNdD, plus the option to 
    select between logarithmic and linear interpolation    
    
    
    Outputs: 
        
    Pandas data frame bin_df at 1 um resolution and Pandas data frames
    dn_1um (the counts at 1 um resolution) and dNdD_1um, number concentration
    per m^4 at 1 um resolution
    
    '''
    dNdD = dNdD.astype('float')
    
    # Find upper and lower limit of the 1um bin df
    bottom_edge = np.min(bin_df['bin_min']); 
    top_edge = np.max(bin_df['bin_max']); 
    
    # Compute the bin edges
    edges_bin = np.arange(bottom_edge, top_edge+1)
    # From the bin edges find the new bin_df
    bin_df_1um = bin_df_from_edges(edges_bin)  
    
    # Create empty array for dndD, the counts divided by the bin width
                                            
    # Create empty arrays for the new dNdD_1um and dn_1um arrays 
    dNdD_1um = np.zeros([len(dNdD.index),len(edges_bin)-1])

    # Loop along the time axis                                   
    for t in range(0,len(dNdD.index)): 
        # The counts have to be transformed to counts divided by bin width
        # before they can be interpolated to 1um resolution
        # The data can be interpolated linearly or logarithmically
        if logarithmic == True: 
            dNdD_1um[t,:] = log_interp(bin_df_1um.loc[:,'bin_mid'],
                    bin_df.loc[:,'bin_mid'],dNdD.iloc[t,:])
        else:
            dNdD_1um[t,:] = np.interp(bin_df_1um.loc[:,'bin_mid'].to_numpy(),
                    bin_df.loc[:,'bin_mid'].to_numpy(),dNdD.iloc[t,:])

    
    # Remove nan values
    dNdD_1um[np.isnan(dNdD_1um)] = 0; 
    
    # Get the column names
    dNdD_1um_names,dn_1um_names = column_names(bin_df_1um)
    
    # Create dNdD data frame at 1 um resolution
    dNdD_1um_df = pd.DataFrame(data = dNdD_1um, index = dNdD.index, 
                               columns = dNdD_1um_names)    
    return bin_df_1um, dNdD_1um_df

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def calc_ED(data_df, bin_df):
    """ Calculate the effective diameter in mu for OAP data
    Parameters
    ----------
    data_df: Must at least contain dNdD
    
    bin_df: bin boundaries, widths and midpoint, all in [m]
    
    Returns
    -------
    ED : float or iterable of floats
         effective diameter in mu
    
    Notes
    -----
    
    References
    ----------
    http://www.dropletmeasurement.com/PADS_Help/ED_(Effective_Diameter)_in_um.htm
    
    """
    dN = get_dN(data_df, bin_df)
    bin_mid = bin_df['bin_mid']
    
    ED = np.empty(np.shape(dN)[0])

    for i in range(len(dN)):
        if np.nansum(dN[i]) != 0.:
            ED[i] = (2 * np.nansum(dN[i] * (bin_mid / 2)**3) / \
                      np.nansum(dN[i] * (bin_mid / 2)**2))
        else:
            ED[i] = 0.

    return ED # in [m]

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def calc_LWC(dN, bin_mid):
    """ Calculate the liquid water content
    Parameters
    ----------
    dN : float or iterable of floats 
         Aerosol particle concentration in each bin in 1/m³
    bin_mid: bin centers in m !
        Can be taken from bin_df['bin_mid'].
        DO NOT FORGET TO CONVERT TO METERS!
          
    Returns
    -------     
    LWC : float or iterable of floats
          total LWC in kg/m³
          
    LWC_i : float or iterable of floats
          LWC in each bin in kg/m³
    Notes
    -----
    Density of water is 1g/cm3
    LWC = sum(dN_i * pi/6*m_i³ * 10^-12)
    
    References
    ----------
    http://www.dropletmeasurement.com/PADS_Help/LWC_(Liquid_Water_Content)_in_g_cm%5E3.htm'
    
    """
    rho_water = 1000 # Density of water [kg/m³]
    LWC_i = np.empty(np.shape(dN))
    LWC = np.empty(np.shape(dN)[0])
    for i in range(np.shape(dN)[0]):           # time axes
        LWC_i[i] = dN[i] * rho_water * np.pi / 6 * bin_mid**3
        LWC[i] = np.nansum(LWC_i[i])

    return LWC, LWC_i




#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def calc_IWC(dN, bin_mid):
    """ Function copied from calc_LWC
        Difference: instead of a = pi/6 and b = 3 --> default Brown and Francis (a=0.00294 & b=1.9)
    
    """
    #alpha =0.00294 #(cgs - SODA)
    alpha = 0.01854 # (kg m s --- units)
    beta = 1.9
    
    #rho_water = 1000 # Density of water [kg/m³]
    LWC_i = np.empty(np.shape(dN))
    LWC = np.empty(np.shape(dN)[0])
    for i in range(np.shape(dN)[0]):           # time axes
        LWC_i[i] = dN[i]  * alpha * np.power(bin_mid,beta) # 
        LWC[i] = np.nansum(LWC_i[i])

    return LWC, LWC_i


#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def calc_MVD(data_df, bin_df):
    """ Calculate the median volume diameter (MVD) in mu. The MVD is the 
    diameter where 50% of the LWC are in particles smaller than this diameter.
    
    Parameters
    ----------
    data_df : Data Frame that contains counts per bin (dn) and counts per 
              cubic meter ber micrometer (dNdD)
    bins : float or iterable of floats 
           Size bin edges in m
    
    Returns
    -------
    MVD : float or iterable of floats
          Median volume diameter in mu
    
    Notes
    -----
    MVD = bi*+ ((0.5 - cumi*-1)/proi*)(bi*+1 - bi*)
    
    """
    
    dN = get_dN(data_df, bin_df)
    width = bin_df['bin_width'].to_numpy()
    bin_mid = bin_df['bin_mid'].to_numpy()
    bin_min = bin_df['bin_min'].to_numpy()
    [LWC, LWC_i] = calc_LWC(dN, bin_mid)
    MVD = np.empty(np.shape(dN)[0])
    pro_i = np.empty(np.shape(LWC_i))
    cum_i = np.empty(np.shape(dN))

    for i in range(np.shape(dN)[0]):           # time axes
        if LWC[i] != 0:
            pro_i[i] = LWC_i[i] / LWC[i]
        else:
            pro_i[i] = 0.
        
        for j in range(np.shape(dN)[1]):
            cum_i[i, j] = np.nansum(pro_i[i, 0:j + 1])
            
        if np.shape(np.where(cum_i[i, :] > 0.5))[1] > 0:
            '''Ind is the bin where the cumulative LWC rises above 0.5 
            That means at the lower bin edge (bin_min[ind]), the LWC is still
            below 0.5. At the upper bin edge (bin_max[ind]), the LWC is larger
            than 0.5. '''
            ind = np.min(np.where(cum_i[i, :] > 0.5))
            if ind > 0:  
                ''' The MVD is assumed to rise linearily across the bin. It is
                calculated from: 
                    bin_min[ind]: lower bin edge of the bin where the LWC rises
                    above 0.5
                    (0.5-cum_i[i,ind-1])/pro_i[i,ind]: Fraction of bin at which
                    the LWC is found (A number between 0 and 1).  '''
                                
                MVD[i] = float(bin_min[ind])\
                        + ((0.5-cum_i[i, ind-1]) / pro_i[i, ind]) * width[ind]
                
                ''' WAS: 
                MVD[i] = float(bins[ind]) + ((0.5-cum_i[i, ind-1]) /
                                    pro_i[i, ind]) * width[ind]
                
                I replaced bins with bin_min, double check if the formula
                is correct please! (Johannes Lucke 21.08.2020)
                '''
            else:
                MVD[i] = bin_min[0]
        else:
            MVD[i] = 0.
    return MVD

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def column_names(bin_df):

    length = len(bin_df)

    dn_names = []
    dNdD_names = []
    for i in range(1,length + 1):
        if i < 10:
            dn_names.append('dn_00' + str(i))
            dNdD_names.append('dNdD_00' + str(i))
        elif 10 <= i < 100:
            dn_names.append('dn_0' + str(i))
            dNdD_names.append('dNdD_0' + str(i))
        elif i >= 100:
            dn_names.append('dn_' + str(i))
            dNdD_names.append('dNdD_' + str(i))

    return dNdD_names, dn_names

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def column_names2(bin_df):
# unterschied zu column_names: nimmt als nummer den index und itteriert nicht von 1 los.
    length = len(bin_df)

    dn_names = []
    dNdD_names = []
    for i in range(0,length):
        if bin_df.index[i] < 10:
            dn_names.append('dn_00' + str(bin_df.index[i]))
            dNdD_names.append('dNdD_00' + str(bin_df.index[i]))
        elif 10 <= bin_df.index[i] < 100:
            dn_names.append('dn_0' + str(i))
            dNdD_names.append('dNdD_0' + str(bin_df.index[i]))
        elif bin_df.index[i] >= 100:
            dn_names.append('dn_' + str(i))
            dNdD_names.append('dNdD_' + str(bin_df.index[i]))

    return dNdD_names, dn_names
    
#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def convert_time(year, days, seconds):
    'Returns the timestamp for the data frame'
    timestamp = pd.Timestamp(int(year),1,1) + pd.Timedelta(days=int(days-1), 
                            seconds=int(seconds),
                            microseconds=int(np.mod(seconds,1)*1e6))

    return timestamp

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def determine_type(probe):
        ''' Determines whether the probe is an OAP or FS probe'''
        if 'CIP' in probe: 
            typ = 'OAP'
        elif 'CDP' in probe: 
            typ = 'FS'        
        elif 'BCPD' in probe: 
            typ = 'BS'  # backscatter
        elif 'CAS' in probe:
            typ = 'FS'
        elif 'CAPS' in probe:
            typ = 'FS'
        return typ

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def get_dN(data_df, bin_df):
    """
    Input:  OAP Daten Dictionary
    Format: dict
    
    Funktion:   gibt die Konzentration per Bin multipliziert mit der jeweiligen
                Binbreite aus. Um von 1/m^4 auf 1/m^3 zu kommen
            
    Output: dN [1/m^3]
    Format: numpy.array
    """
    bin_width = bin_df['bin_width'].to_numpy()
    dNdD = get_dNdD(data_df).to_numpy()
    dN = np.empty(np.shape(dNdD))
    for i in range(len(dN[0])):
        for p in range(len(dN)):
            dN[p, i] = dNdD[p, i] * bin_width[i]
    return dN


#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def get_dNdD(df):
    """
    Input:  OAP dataframe
    Format  pandas.Dataframe
    
    Funktion:   gibt die Konzentration per Bin als Dataframe aus
    
    Output: dNdD dataframe
    Format: pandas.Dataframe
    """
    dNdD_names = []
    for i in df.columns:
        if i[:2] == 'dN':
            dNdD_names.append(i)
    dNdD = df.loc[:, dNdD_names]
    return dNdD

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def get_dlogD(bin_df):
    """
    Input: bin_df
    
    Output: list of logarithmic bin widths
    """
    bin_min = bin_df['bin_min'].to_numpy()
    bin_max = bin_df['bin_max'].to_numpy()
    
    dlogD = []
    for x in range(len(bin_min)):
        dlogD.append(np.log10(bin_max[x] / bin_min[x]))
    
    return dlogD

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def get_dNdlogD(data_df, bin_df):
    """
    
    """
    dlogD = get_dlogD(bin_df)
    dN = get_dN(data_df, bin_df)
    
    pdN = get_pandas_dN(data_df, dN)
    dNdlogD = pd.DataFrame().reindex_like(pdN)
    
    for i in range(len(pdN.columns)):
        dNdlogD[dNdlogD.columns[i]] = pdN[pdN.columns[i]] / dlogD[i]
        
    return dNdlogD

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def get_dNdlogD_mean(data_df, bin_df, t_start, t_end):
    """
    Input:
    data_df: pandas.DataFrame 
    t_start: datetime.datetime
    t_end: datetime.datetime
    
    Funktion: Berechnet die gemittelte Anzahlkonzentration [#/m³]
              
    Output:
    dN_mean: numpy.array mit Anzahl Bin Einträge
    """
    dNdlogD = get_dNdlogD(data_df, bin_df)
    
    dNdlogD_mean = np.zeros(np.shape(dNdlogD)[1])
                
    for x in range(len(dNdlogD.columns)):
        dNdlogD_mean[x] = np.mean(dNdlogD[dNdlogD.columns[x]][t_start:t_end])
                        
    return dNdlogD_mean

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def get_dNdD_mean(data_df, t_start, t_end):
    """
    Input:
    data_df: pandas.DataFrame 
    t_start: datetime.datetime
    t_end: datetime.datetime
    
    Funktion: Berechnet die gemittelte Anzahlkonzentration [#/m³] pro m über 
              Zeitraum.
              
    Output:
    dNdD_mean: numpy.array mit Anzahl Bin Einträge
    """
    dNdD = get_dNdD(data_df)
    
    dNdD_mean = np.zeros(np.shape(dNdD)[1])
    
    for x in range(len(dNdD.columns)):
        dNdD_mean[x] = np.mean(dNdD[dNdD.columns[x]][t_start:t_end])
        
    return dNdD_mean

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def get_pandas_dN(data_df, dN):
    """
    
    """
    dNdD = get_dNdD(data_df)

    pdN = pd.DataFrame().reindex_like(dNdD)
    for i in range(len(pdN.columns)):
        pdN[pdN.columns[i]] = dN[:, i]  
    
    return pdN

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def timestamp_dmt(df_raw, typ=None):
    '''
    Input: Data frame with timestamp in DMT format (Year, Day of Year, End 
    Seconds)
    
    Output: Timestamp in datetime format
    '''
    if typ=='CAPS':
        return df_raw.apply(lambda x: convert_time(x['Year'], x['Day Of Year'], 
                                                   x['End Seconds']), axis=1, 
                                                    result_type='expand')    
    else:
        return df_raw.apply(lambda x: convert_time(x['Year'], x['Day of Year'], 
                                                   x['End Seconds']), axis=1, 
                                                    result_type='expand')

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def load_data(data_object, path): 
    ''' 
    Loads data from the data files contained in 'path' into the Data object
    data_object.
    
    Output: Data object with attributes, bin_df and data_df
    '''
    
    # Get the names of all the files in the directory (third argument 
    # of os.walk)
    filenames = [f for f in os.listdir(path) 
                if os.path.isfile(os.path.join(path, f))]
    # Get the names of the info, bin and data files
    for filename in filenames: 
        if 'INFO' in filename:
            infofile = filename
        elif 'BIN_DF' in filename:
            binfile = filename
        elif 'DATA_DF' in filename:
            datafile = filename
    
    # Get the data from the info file
    f = open(path + '/' + infofile,'r')
    for line in f.readlines(): 
        if 'PATH' in line: 
            data_object.path = line.split('=')[1].strip()
        elif 'NAME' in line: 
            data_object.name = line.split('=')[1].strip()
        elif 'PROBE' in line: 
            data_object.probe = line.split('=')[1].strip()
        elif 'TYPE' in line: 
            data_object.type = line.split('=')[1].strip()
        elif 'STARTTIME' in line: 
            try: 
                data_object.t_start = datetime.strptime(line.split('=')[1].strip(),
                                                        '%Y-%m-%d %H:%M:%S.%f')
            except ValueError: 
                data_object.t_start = datetime.strptime(line.split('=')[1].strip(),
                                                        '%Y-%m-%d %H:%M:%S')
        elif 'ENDTIME' in line: 
            try: 
                data_object.t_end = datetime.strptime(line.split('=')[1].strip(),
                                                      '%Y-%m-%d %H:%M:%S.%f')
            except ValueError: 
                data_object.t_end = datetime.strptime(line.split('=')[1].strip(),
                                                      '%Y-%m-%d %H:%M:%S')
        elif 'MINBIN' in line: 
            data_object.min_bin = float(line.split('=')[1].strip())
        elif 'MAXBIN' in line: 
            data_object.max_bin = float(line.split('=')[1].strip())
        else: 
            continue
    
    f.close()
    
    # Read in the bin_df
    data_object.bin_df = pd.read_csv(path + '/' + binfile, index_col=0)
    
    # Read in the data_df
    data_object.data_df = pd.read_csv(path + '/' + datafile, index_col=0, 
                                      parse_dates=True)
    
    return data_object


#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def log_interp(zz, xx, yy):
    ''' Logaritmic interpolation at the locations zz, of the data (xx,yy)''' 
    logz = np.log10(zz)
    logx = np.log10(xx)
    logy = np.log10(yy)
    return np.power(10.0, np.interp(logz, logx, logy))

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def save_data(data):
    '''
    The user has the possibility to set a path and a name for the data 
    object. If no path is set, a new folder containing files related to the 
    data object will be created in the current working directory. If no name is
    set the timestamp of the beginning of the measurement will be used as 
    the name. A probe identifier (e.g. 'CDP') will always be added to the 
    beginning of the directory and filename. 
    '''
    if data.path == '':
        path = ''
    else: 
        path = data.path + '/'
        
    if data.name == '':
        name = data.probe + '_' \
                + data.data_df.index[0].strftime('%Y%m%d%H%M%S')                
    else: 
        name = data.probe + '_' + data.name
        
    # Create the directory where the data will be saved
    if not os.path.exists(path+name): 
        os.mkdir(path+name)
    
    ''' 
    Three files will be created: 
        1. A file containing information about the data object such as start 
            time, end time, min bin and max bin. 
        2. A file containing the bin_df
        3. A file containing the data_df
    '''
    
    # Write Info to file
    f = open(path+name+'/'+name+'_'+'INFO'+'.csv','w')
    f.write('PATH='+ data.path +'\n')
    f.write('NAME='+ data.name +'\n')
    f.write('STARTTIME=' + data.t_start.strftime('%Y-%m-%d %H:%M:%S.%f'+'\n'))
    f.write('ENDTIME=' + data.t_end.strftime('%Y-%m-%d %H:%M:%S.%f'+'\n'))
    f.write('MINBIN='+str(data.min_bin)+'\n')
    f.write('MAXBIN='+str(data.max_bin)+'\n')
    f.write('PROBE='+str(data.probe+'\n'))
    f.write('TYPE='+str(data.type+'\n'))
    f.write('N='+str(data.get_mean_value('N'))+'\n')
    f.write('LWC='+str(data.get_mean_value('LWC'))+'\n')
    f.write('MVD='+str(data.get_mean_value('MVD'))+'\n')
    f.write('ED='+str(data.get_mean_value('ED'))+'\n')
    f.close()
    print('MVD='+str(data.get_mean_value('MVD')))
    
    # Write bin_df to file
    data.bin_df.to_csv(path_or_buf = path + name + '/' + name + '_'\
                       + 'BIN_DF' + '.csv')
            
    # Write data_df to file
    data.data_df.to_csv(path_or_buf = path + name + '/' + name + '_'\
                        + 'DATA_DF' + '.csv')
                 
    
    # Save the quicklook
    fig = data.plot_quicklook()
    plt.savefig(path + name + '/' + name + '_' + 'quicklook' + '.png')
    plt.close(fig)

#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def save_psd(psd): 
    try:
        psd.path
    except: 
        psd.path = psd.Data[list(psd.Data.keys())[0]].path
        
    try:
        psd.name 
        if psd.name == '':
            psd.name = 'PSD' + '_' + psd.Data[list(psd.Data.keys())[0]].name
    except:
        psd.name = 'PSD' + '_' + psd.Data[list(psd.Data.keys())[0]].name
        
    path = psd.path
    name = psd.name
    
    
    # Create the directory where the data will be saved
    if not os.path.exists(path+'/' + name): 
        os.mkdir(path+ '/' + name)
    
    ''' 
    Three files will be created: 
        1. A file containing information about the data object such as start 
            time, end time, min bin and max bin. 
        2. A file containing the bin_df
        3. A file containing the data_df
    '''
    
    # Write Info to file
    f = open(path+'/' + name + '/'+name+'_'+'INFO'+'.csv','w')
    f.write('PATH='+ psd.path +'\n')
    f.write('NAME='+ psd.name +'\n')
    f.write('STARTTIME=' + psd.t_start.strftime('%Y-%m-%d %H:%M:%S.%f'+'\n'))
    f.write('ENDTIME=' + psd.t_end.strftime('%Y-%m-%d %H:%M:%S.%f'+'\n'))
    f.write('N='+str(psd.N)+'\n')
    f.write('LWC='+str(np.mean(psd.LWC))+'\n')
    f.write('MVD='+str(np.mean(psd.mvd))+'\n')
    f.write('ED='+str(np.mean(psd.ed))+'\n')
    for probe in psd.Data.keys(): 
        f.write(probe + ' MINBIN=' + str(psd.Data[probe].min_bin) + '\n')
        f.write(probe + ' MAXBIN=' + str(psd.Data[probe].max_bin) + '\n')   
    f.close()
    
    # Write bin_df to file
    psd.bin_df.to_csv(path_or_buf = path + '/' +  name + '/' + name + '_'\
                       + 'BIN_DF' + '.csv')
            
    # Write data_df to file
    psd.data_df.to_csv(path_or_buf = path + '/' +  name + '/' + name + '_'\
                        + 'DATA_DF' + '.csv')
                 
    
    # Save the quicklook
    fig = psd.plot_combined()
    plt.savefig(path + '/' +  name + '/' + name + '_' \
                + 'PSD_COMBINED' + '.png')
    plt.close(fig)
    fig_cum = psd.plot_cumulative_distribution()
    plt.savefig(path + '/' +  name + '/' + name + '_' \
                + 'MASS_DISTRIBUTION' + '.png')
    plt.close(fig_cum)
    fig_port = psd.plot_pdf_distribution()
    plt.savefig(path + '/' + name + '/' + name + '_' + 'PDF' + '.png')
    plt.close(fig_port)
    
    fig_sep,ts,te = psd.plot()
    plt.savefig(path + '/' + name + '/' + name + '_' + 'PSD_SEPERATE' + '.png')
    plt.close(fig_sep)
    
    
#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def get_nlogD(data_df, bin_df):
        
        nlogD = get_dNdlogD(data_df, bin_df)

        new_names = []
        for i in range(len(nlogD.columns)):
            new_names.append('dNdlogD'+nlogD.columns[i][2:])

        nlogD.columns = new_names
        return nlogD


#function defined by Simon Kirschler (simon.kirschler@dlr.de)
def save_icar_cdp(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'In-situ measurements from the DMT Cloud Droplet Probe on Polar 5',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 5, BT-67 C-GAWI',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'LWC' or v == 'CWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep = ' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(47)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de); V. Hahn (Valerian.Hahn@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d  ')+date.today().strftime(' %Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1 '
            missing_data_indicator = missing_data_indicator + '9.99e+30 '
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            #elif variable == 'IWC':
            #    f.write(variable +', kg/m^3, ice water content \n')
            elif variable == 'CWC':
                f.write(variable +', kg/m^3, cloud water content (assuming droplets) \n')
            elif variable == 'LWC':
                f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'MVD':
                f.write(variable +', m, mean volume diameter \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes:  \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)
                

def save_icar_cdp_haloac3(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'In-situ measurements from the DMT Cloud Droplet Probe on Polar 6',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 6, BT-67 C-GHGF',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'LWC' or v == 'CWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep = ' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(51)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de); J. Lucke (Johannes.Lucke@dlr.de); E. De La Torre Castro (Elena.delaTorreCastro@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d  ')+date.today().strftime(' %Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1 '
            missing_data_indicator = missing_data_indicator + '9.99e+30 '
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            #elif variable == 'IWC':
            #    f.write(variable +', kg/m^3, ice water content \n')
            elif variable == 'CWC':
                f.write(variable +', kg/m^3, cloud water content (assuming droplets) \n')
            elif variable == 'LWC':
                f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'MVD':
                f.write(variable +', m, mean volume diameter \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes:  \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)

def save_icar_cip_mosaic(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'In-situ measurements from the DMT Cloud Imaging Probe on Polar 5',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 5, BT-67 C-GAWI',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'IWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep = ' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(88)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de); V. Hahn (Valerian.Hahn@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d   ')+date.today().strftime('%Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1'
            missing_data_indicator = missing_data_indicator + '9.99e+30'
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            #elif variable == 'IWC':
            #    f.write(variable +', kg/m^3, ice water content \n')
            elif variable == 'LWC':
                f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'IWC':
                f.write(variable +', kg/m^3, ice water content (calculated using mass-dimension relation by Brown and Francis, 1995; assuming ice phase) \n')
            elif variable == 'MVD':
                f.write(variable +', m, mean volume diameter, based on LWC calculations \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes:  \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)

def save_icar_pip_mosaic(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'In-situ measurements from the DMT Precipitation Imaging Probe on Polar 5',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 5, BT-67 C-GAWI',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'IWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep=' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(88)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de); V. Hahn (Valerian.Hahn@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d   ')+date.today().strftime('%Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1 '
            missing_data_indicator = missing_data_indicator + '9.99e+30 '
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            #elif variable == 'IWC':
            #    f.write(variable +', kg/m^3, ice water content \n')
            elif variable == 'LWC':
                f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'IWC':
                f.write(variable +', kg/m^3, ice water content (calculated using mass-dimension relation by Brown and Francis, 1995; assuming ice phase) \n')
            elif variable == 'MVD':
                f.write(variable +', m, mean volume diameter, based on LWC calculations \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes:  \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)

def save_icar_cas_aflux(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'In-situ measurements from the DMT Cloud Aerosol Spectrometer on Polar 5',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 5, BT-67 C-GAWI',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'LWC' or v == 'CWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep=' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(35)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d   ')+date.today().strftime('%Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1 '
            missing_data_indicator = missing_data_indicator + '9.99e+30 '
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            #elif variable == 'IWC':
            #    f.write(variable +', kg/m^3, ice water content \n')
            elif variable == 'CWC':
                f.write(variable +', kg/m^3, cloud water content (assuming droplets) \n')
            elif variable == 'LWC':
                f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'MVD':
                f.write(variable +', m, mean volume diameter \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes: - \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)



def save_icar_cip_aflux(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'In-situ measurements from the DMT Cloud Imaging Probe on Polar 5',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 5, BT-67 C-GAWI',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'IWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep=' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(88)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d   ')+date.today().strftime('%Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1 '
            missing_data_indicator = missing_data_indicator + '9.99e+30 '
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            #elif variable == 'IWC':
            #    f.write(variable +', kg/m^3, ice water content \n')
            elif variable == 'LWC':
                f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'IWC':
                f.write(variable +', kg/m^3, ice water content (calculated using mass-dimension relation by Brown and Francis, 1995; assuming ice phase) \n')
            elif variable == 'MVD':
                f.write(variable +', m, mean volume diameter, based on LWC calculations \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes:  \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)



def save_icar_pip_aflux(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'In-situ measurements from the DMT Precipitation Imaging Probe on Polar 5',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 5, BT-67 C-GAWI',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'IWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep = ' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(88)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d   ')+date.today().strftime('%Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1 '
            missing_data_indicator = missing_data_indicator + '9.99e+30 '
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            #elif variable == 'IWC':
            #    f.write(variable +', kg/m^3, ice water content \n')
            elif variable == 'LWC':
                f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'IWC':
                f.write(variable +', kg/m^3, ice water content (calculated using mass-dimension relation by Brown and Francis, 1995; assuming ice phase) \n')
            elif variable == 'MVD':
                f.write(variable +', m, mean volume diameter, based on LWC calculations \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes:  \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)


def save_icar_combined_mosaic(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'Combined in-situ file: Cloud Droplet Probe, Cloud Imaging Probe and Precipitation Imaging Probe. Switchover size is 34 - 52 micrometer and 293 - 463 micrometer: in between mean value is given.',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 5, BT-67 C-GAWI',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'CWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep = ' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(118)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de); V. Hahn (Valerian.Hahn@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d   ')+date.today().strftime('%Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1 '
            missing_data_indicator = missing_data_indicator + '9.99e+30 '
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            #elif variable == 'IWC':
            #    f.write(variable +', kg/m^3, ice water content \n')
            elif variable == 'LWC':
                f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'CWC':
                f.write(variable +', kg/m^3, cloud water content (particles smaller 50 microns assumed as droplets; particles larger 50 microns: mass-dimension relation by Brown and Francis, 1995 - assuming ice) \n')
            elif variable == 'MVD':
                f.write(variable +', m, median volume diameter \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes:  \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)
                
def save_icar_combined_aflux(data_df, bin_df, campaign, probe, platform, flight, directory):
    header = {'format': '1001',  
          'last_name': 'Voigt',
          'first_name': 'Christiane',
          'organisation': 'DLR e.V., JGU Mainz',
          'description': 'Combined in-situ file: Cloud Aerosol Spectrometer, Cloud Imaging Probe and Precipitation Imaging Probe. Switchover size is 32 - 52 micrometer and 293 - 463 micrometer: in between mean value is given.',
          'campaign': campaign,
          'volume': '1',
          'volume_number': '1',
          'start_time': '',
          'end_time': '',
          'interval': '1',
          'start_utc': 'Time_start, Secs after midnight, Time of aquisition',
          'number_variables': '',
          'scalefactors': [],
          'missing_data_indicator': [],
          'variables': '',
          'number_comment_lines_special': '0',
          'comment_special': '',
          'number_comment_lines_normal': '7',
          'comment_normal': '',
          'PI': 'PI_CONTACT_INFO: Christiane.Voigt@dlr.de',
          'platform': 'PLATFORM: AWI-Polar 5, BT-67 C-GAWI',
          'location': 'LOCATION: Latitude, Longitude and Altitude included in data records',
          'associated': 'ASSOCIATED_DATA: N/A',
          'instrument_info': '-',
          'data_info': 'CDP Data...',
          'uncertainty': 'UNCERTAINTY: contact PI',
          'ulod_flag': 'ULOD_FLAG: -7777',
          'ulod_value': 'ULOD_VALUE: N/A',
          'llod_flag': 'LLOD_FLAG: -8888',
          'llod_value': 'LLOD_VALUE: N/A',
          'contact': 'DM_CONTACT_INFO: Manuel Moser (manuel.moser@dlr.de)',
          'project_info': 'PROJECT_INFO: ' + campaign,
          'stipulation': 'STIPULATIONS_ON_USE: This is prelimenary Data only for quicklook use',
          'other_comments': 'OTHER_COMMENTS: Bin Edges(in um) = [',
          'revision': 'REVISION: RA',
          'R0': 'RA: Field Data'
         }
    t_start = data_df.index[0]
    t_end = data_df.index[-1]
    
    os.chdir(directory)
    if flight is None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+ '.ict'
    if flight is not None:
        icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+'_F'+str(flight)+ '.1Hz'
        #icar_name = campaign +'-'+probe +'_'+platform+'_'+t_start.strftime('%Y%m%d')+'_'+header['revision'][-2:]+'_L'+str(flight)+ '.ict'


    #nlogD = self.get_nlogD()
    #variables_data = self.data_df.join(nlogD)
    variables_data = data_df
    variables_data = variables_data.rename(columns={'Time':'Time_start'})
    variables_all = list(variables_data.columns)
    variables = []
    for v in variables_all:
        if v[:5] == 'dNdD_':
            variables.append(v)
        elif v == 'Time_start' or v == 'N' or v == 'MVD' or v == 'ED' or v == 'CWC':
            variables.append(v)
        elif v == 'Applied PAS (m/s)':
            variables.append(v)
    number_variables = len(variables) - 1
    new_time = []
    for t in variables_data['Time_start']:
        new_time.append(int(t))

    variables_data['Time_start'] = new_time
    while variables_data.index.is_unique is not True:
        variables_data = variables_data.loc[~variables_data.index.duplicated(keep='last')]
    variables_data[variables][t_start:t_end].to_csv(directory +'/Icar_variables.csv',
                                     header=True, index=False, na_rep='9.99e+30', sep = ' ')
    #lines = str(14 + number_variables + int(header['number_comment_lines_normal'])+ int(header['number_comment_lines_special']))
    lines = str(111)

    with open(icar_name, 'w') as f:
        # write top header
        f.write(lines+' '+header['format']+'\n')
        #f.write(header['last_name']+', '+header['first_name']+'\n')
        f.write('C. Voigt (Christiane.Voigt@dlr.de); M. Moser (Manuel.Moser@dlr.de)'+'\n')
        f.write(header['organisation']+'\n')
        f.write(header['description']+'\n')
        f.write(header['campaign']+'\n')
        f.write(header['volume']+' '+header['volume_number']+'\n')
        f.write(t_start.strftime('%Y %m %d   ')+date.today().strftime('%Y %m %d')+'\n')
        f.write(header['interval']+'\n')
        f.write(header['start_utc']+'\n')
        f.write(str(number_variables)+'\n')
        scalefactors = str()
        missing_data_indicator = str()
        for v in variables[:-1]:
            scalefactors = scalefactors + '1 '
            missing_data_indicator = missing_data_indicator + '9.99e+30 '
        scalefactors = scalefactors[:-1]
        missing_data_indicator = missing_data_indicator[:-1]
        f.write(scalefactors +'\n')
        f.write(missing_data_indicator +'\n')
        for variable in variables:
            if variable == 'ED':
                f.write(variable +', m, effective diameter (ratio of the 3rd and 2nd moments of the distribution of the particles maximum dimension) \n')
            elif variable == 'N':
                f.write(variable +', #/m^3, total counts \n')
            elif variable == 'IWC':
                f.write(variable +', kg/m^3, ice water content \n')
            #elif variable == 'LWC':
            #    f.write(variable +', kg/m^3, liquid water content \n')
            elif variable == 'CWC':
                f.write(variable +', kg/m^3, cloud water content (particles smaller 50 microns assumed as droplets; particles larger 50 microns: mass-dimension relation by Brown and Francis, 1995 - assuming ice) \n')
            elif variable == 'MVD':
                f.write(variable +', m, median volume diameter \n')
            #elif variable[:3] == 'dN_':
            #    f.write(variable +', 1/m^4, number concentration per bin times bin width \n')
            #elif variable[:3] == 'dn_':
            #    f.write(variable +', 1/m^3, number concentration per bin log normalized \n')
            elif variable[:5] == 'dNdD_':
                f.write(variable +', #/m^4, concentration per bin \n')
            elif variable == 'Applied PAS (m/s)':
                f.write(variable + ', Applied Speed in m/s \n')
        f.write(header['number_comment_lines_special']+'\n')
        special_numb = int(header['number_comment_lines_special'])
        if  header['number_comment_lines_special'] != '0':
            f.write(header['comment_special']+'\n')
        f.write(header['number_comment_lines_normal']+'\n')
        f.write(header['PI']+'\n')
        f.write(header['platform']+'\n')
        #f.write(header['location']+'\n')
        #f.write(header['associated']+'\n')
        #f.write(header['instrument_info']+'\n')
        #f.write(header['data_info']+'\n')
        f.write(header['uncertainty']+'\n')
        #f.write(header['ulod_flag']+'\n')
        #f.write(header['ulod_value']+'\n')
        #f.write(header['llod_flag']+'\n')
        #f.write(header['llod_value']+'\n')
        f.write(header['contact']+'\n')
        #f.write(header['project_info']+'\n')
        #f.write(header['stipulation']+ '\n')
        bin_edges = bin_df['bin_min']
        bin_edges_str = ''
        for b in bin_edges:
            bin_edges_str = bin_edges_str + str(b) + ', '
        bin_edges_str = bin_edges_str + str(list(bin_df['bin_max'])[-1])
        f.write('Notes:  \n' \
                + '    Bin Edges(in micrometer) = [' +bin_edges_str+'] \n' )
        #f.write(header['revision']+'\n')
        #f.write(header['R0']+'\n')
        with open(directory +'/Icar_variables.csv', 'r') as d:
            for line in d:
                f.write(line)                





# plottet die psd
def plot_psd(data_df, bin_df, year, month, day, hour, minute,second, delta):
    dNdD_names = []
    for i in data_df.columns:
        if i[:2] == 'dN':
            dNdD_names.append(i)
    
    dt = str(year)+'-'+"{0:0=2d}".format(month)+'-'+"{0:0=2d}".format(day)+' '+"{0:0=2d}".format(hour)+':'+"{0:0=2d}".format(minute)+':'+"{0:0=2d}".format(second)
    dt = pd.to_datetime(dt)
    dt_end = dt + datetime.timedelta(seconds=delta-1)
    index_start = data_df.index[data_df.index.get_loc(dt, method='nearest')]
    index_end = data_df.index[data_df.index.get_loc(dt_end, method='nearest')]
    x = bin_df.bin_mid
    y = (data_df[dNdD_names].loc[index_start:index_end].sum(axis = 0, skipna = True) / len(data_df[dNdD_names].loc[index_start:index_end])).values
    
    #the plot:
    plt.semilogy(x, y, drawstyle='steps-mid', color = 'r',  label = '')
    plt.semilogy(x, y, 's', markersize=3, color = 'r')
    
    plt.ylabel(r'blblblaldsjkfhjsdk')
    plt.xlabel('D [$\mu m$]') 
    plt.title("size distribution")
    plt.legend(loc=1)
    plt.xscale('log')
    return 0




# plottet die psd
def plot_psd(data_df, bin_df, year, month, day, hour, minute,second, delta, color):
    dNdD_names = []
    for i in data_df.columns:
        if i[:2] == 'dN':
            dNdD_names.append(i)
    
    dt = str(year)+'-'+"{0:0=2d}".format(month)+'-'+"{0:0=2d}".format(day)+' '+"{0:0=2d}".format(hour)+':'+"{0:0=2d}".format(minute)+':'+"{0:0=2d}".format(second)
    dt = pd.to_datetime(dt)
    dt_end = dt + datetime.timedelta(seconds=delta-1)
    data_df = data_df[(data_df.index.month == month) & (data_df.index.day == day)]
    index_start = data_df.at_time(dt).index[0]
    index_end = data_df.at_time(dt_end).index[0]
    x = bin_df.bin_mid
    y = (data_df[dNdD_names].loc[index_start:index_end].sum(axis = 0, skipna = True) / len(data_df[dNdD_names].loc[index_start:index_end])).values
    
    #the plot:
    plt.semilogy(x, y, drawstyle='steps-mid', color = color,  label = '')
    plt.semilogy(x, y, 's', markersize=3, color = color)
    
    plt.ylabel(r'blblblaldsjkfhjsdk')
    plt.xlabel('D [$\mu m$]') 
    plt.title("size distribution")
    plt.legend(loc=1)
    plt.xscale('log')
    return 0










#from datetime import datetime
import datetime as dt
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
os.chdir('C:/Users/mose_mn/Documents/Kampagnen/MOSAiC_ACAS/Auswertung/NASA-AMES')
from Utility_MOSAiC import get_dNdD
from matplotlib.colors import LogNorm
from pylab import cm
#from metpy.calc import dewpoint_from_relative_humidity
#from metpy.calc import equivalent_potential_temperature, mixing_ratio_from_relative_humidity, potential_temperature
#from metpy.units import units




#berechnet seconds from midnight
def seconds_since_midnight(hour,minute,second):
    time = dt.datetime(1994,5,4,hour,minute,second)
    seconds_since_midnight = (time - time.replace(hour=0, minute=0, second=0, microsecond=0)).total_seconds()
    return seconds_since_midnight

#macht aus utcs einen datetime format, man muss das datum mit übergeben 
def datetime_from_utcs(year, month, day, utc_s):
    time = dt.datetime.utcfromtimestamp(utc_s).replace(year = year,month = month, day = day)
    return time


#importiert dasa_ames dateien in ein pandas Dataframe
#erste spalte im datensatz auch gleichzeitig als index (sollte UTC time sein)
def read_nasa_ames(directory, data_name): 
    os.chdir(directory)
    f=open(data_name)
    lines=f.readlines()
    position_header = int(lines[0][0:-1][0:2])
    header = lines[position_header][0:-1]
    data = np.genfromtxt(data_name, skip_header = position_header)
    data_columns = np.genfromtxt(data_name, dtype = 'str',skip_header = position_header-2, skip_footer = len(data)+1)
    data_columns_units = np.genfromtxt(data_name,comments='asdasdasdasda' ,dtype = 'str',skip_header = position_header-1, skip_footer = len(data))
    df = pd.DataFrame(data=data, columns=data_columns, index = data[:,0])
    df_units = pd.DataFrame(columns=data_columns, data = np.array(data_columns_units, ndmin = 2))
    
    timestamp = []
    year = int(lines[6][0:4])
    month = int(lines[6][5:7])
    day = int(lines[6][8:10])
    for i in range(len(df.Time)):
        #timestamp.append(datetime_from_utcs(2015, 12, 13, df.Time.iloc[i]))
        timestamp.append(datetime_from_utcs(year, month, day, df.Time.iloc[i]))
    df.insert(0, 'datetime',timestamp)
    df.index = df.datetime
    
    return df, df_units

def read_DMT_csv_file(directory, data_name, row_header):
    os.chdir(directory)
    f=open(data_name)
    lines=f.readlines()
    position_header = int(row_header)
    data = np.genfromtxt(data_name, skip_header = position_header+1, comments = 'commentsdfkfsdjkllkjl', delimiter = ',', invalid_raise = False)
    data_columns = np.genfromtxt(data_name,comments='comments..' ,dtype = 'str',delimiter=',',skip_header = position_header, max_rows = 1)
    if len(data) > 0:
        df = pd.DataFrame(data=data, columns=data_columns, index = data[:,0])
        return df
    else:
        return 0


#seaches line in pads 1Hz file where data starts
def seach_pads_startline(file):
    lookup = '***'
    with open(file) as myFile:
        for num, line in enumerate(myFile, 1):
            if lookup in line:
                start_line = num   
    return start_line


#suche nach allen pip files im ordner, dann zu einem dataframe zusammen fügen
def import_1Hz_pip_files_as_pd(data_path, year, month, day):
    pip_file = []
    for root, dirs, files in os.walk(data_path):
        for file in files:
            if file.startswith("00PIP") and file.endswith(".csv"):
                pip_file.append(os.path.join(root, file).replace('\\', '/'))
    pip_1Hz = pd.DataFrame()
    for i in range(len(pip_file)):
        data_1hz = read_DMT_csv_file(pip_file[i][:-38], pip_file[i][-38:], seach_pads_startline(pip_file[i]))#### wenn eine andere campagne muss hier die 38 angepasst werden
        if type(data_1hz) == type(pd.DataFrame()):
            pip_1Hz = pip_1Hz.append(data_1hz)
    #zeit ins richtige format bringen:
    time = pip_1Hz['UTC Seconds']
    datetime = []
    for i in range(len(time)):
        datetime.append(datetime_from_utcs(year, month, day, time.iloc[i]))
    pip_1Hz.index = datetime
    pip_1Hz['count_all_1Hz'] = pip_1Hz['Particle Count'] # ==     pip_1Hz['count_all_1Hz'] = pip_1Hz['Over Reject Counts']+pip_1Hz['DOF Reject Counts']+pip_1Hz['End Reject Counts']+pip_1Hz[pip_1Hz.columns[45:107]].sum(axis = 1)


    pip_1Hz.index.name = 'datetime'
    pip_1Hz = pip_1Hz.sort_values(by='datetime')
    pip_1Hz = pip_1Hz.drop_duplicates(keep = 'first')
    return pip_1Hz

#suche nach allen cip files im ordner, dann zu einem dataframe zusammen fügen
def import_1Hz_cip_files_as_pd(data_path, year, month, day):
    cip_file = []
    #data_path = eval(r'path_1Hz_cip_'+str(year)+str(month).zfill(2)+str(day).zfill(2))
    for root, dirs, files in os.walk(data_path):
        for file in files:
            if file.startswith("00CIP Grayscale") and file.endswith(".csv") and not file.endswith("cal.csv"):
                cip_file.append(os.path.join(root, file).replace('\\', '/'))
    pip_1Hz = pd.DataFrame()
    for i in range(len(cip_file)):
        data_1hz = read_DMT_csv_file(cip_file[i][:-33], cip_file[i][-33:], seach_pads_startline(cip_file[i])) #### wenn eine andere campagne muss hier die 33 angepasst werden
        if type(data_1hz) == type(pd.DataFrame()):
            pip_1Hz = pip_1Hz.append(data_1hz)
    #pip_1Hz=pip_1Hz[pip_1Hz['UTC Seconds'].notna()]
    #pip_1Hz=pip_1Hz[~pip_1Hz.isin([np.nan, np.inf, -np.inf]).any(1)]
    pip_1Hz=pip_1Hz[~pip_1Hz['UTC Seconds'].isin([np.nan, np.inf, -np.inf])]
    pip_1Hz=pip_1Hz[pip_1Hz['UTC Seconds'].notna()]
    #zeit ins richtige format bringen:
    time = pip_1Hz['UTC Seconds']
    datetime = []
    for i in range(len(time)):
        datetime.append(datetime_from_utcs(year, month, day, time.iloc[i]))
    pip_1Hz.index = datetime
    pip_1Hz['count_all_1Hz'] = pip_1Hz['Particle Count'] 
    pip_1Hz['counts_rejected'] = pip_1Hz['Over Reject Counts'] + pip_1Hz['DOF Reject Counts'] + pip_1Hz['End Reject Counts'] 
    bins_name = ['Bin 1', 'Bin 2', 'Bin 3', 'Bin 4', 'Bin 5', 'Bin 6', 'Bin 7', 'Bin 8', 'Bin 9', 'Bin 10', 'Bin 11', 'Bin 12', 'Bin 13', 'Bin 14', 'Bin 15', 'Bin 16', 'Bin 17', 'Bin 18', 'Bin 19', 'Bin 20', 'Bin 21', 'Bin 22', 'Bin 23', 'Bin 24', 'Bin 25', 'Bin 26', 'Bin 27', 'Bin 28', 'Bin 29', 'Bin 30', 'Bin 31', 'Bin 32', 'Bin 33', 'Bin 34', 'Bin 35', 'Bin 36', 'Bin 37', 'Bin 38', 'Bin 39', 'Bin 40', 'Bin 41', 'Bin 42', 'Bin 43', 'Bin 44', 'Bin 45', 'Bin 46', 'Bin 47', 'Bin 48', 'Bin 49', 'Bin 50', 'Bin 51', 'Bin 52', 'Bin 53', 'Bin 54', 'Bin 55', 'Bin 56', 'Bin 57', 'Bin 58', 'Bin 59', 'Bin 60', 'Bin 61', 'Bin 62']
    pip_1Hz['counts_accepted'] = pip_1Hz[bins_name].sum(axis = 1)

    pip_1Hz.index.name = 'datetime'
    pip_1Hz = pip_1Hz.sort_values(by='datetime')
    pip_1Hz = pip_1Hz.drop_duplicates(keep = 'first')
    return pip_1Hz


#import csv
#input_file = open(cip_file[i][:-33] + cip_file[i][-33:],"r+")
#reader_file = csv.reader(input_file)
#value = len(list(reader_file))




def import_1Hz_cip_files_as_pd_aflux(data_path, year, month, day):
    cip_file = []
    #data_path = eval(r'path_1Hz_cip_'+str(year)+str(month).zfill(2)+str(day).zfill(2))
    for root, dirs, files in os.walk(data_path):
        for file in files:
            if file.startswith("03CIP Grayscale") and file.endswith(".csv") and not file.endswith("cal.csv"):
                cip_file.append(os.path.join(root, file).replace('\\', '/'))
    pip_1Hz = pd.DataFrame()
    for i in range(len(cip_file)):
        data_1hz = read_DMT_csv_file(cip_file[i][:-33], cip_file[i][-33:], seach_pads_startline(cip_file[i])) #### wenn eine andere campagne muss hier die 33 angepasst werden
        if type(data_1hz) == type(pd.DataFrame()):
            pip_1Hz = pip_1Hz.append(data_1hz)
    #pip_1Hz=pip_1Hz[pip_1Hz['UTC Seconds'].notna()]
    #pip_1Hz=pip_1Hz[~pip_1Hz.isin([np.nan, np.inf, -np.inf]).any(1)]
    pip_1Hz=pip_1Hz[~pip_1Hz['UTC Seconds'].isin([np.nan, np.inf, -np.inf])]
    pip_1Hz=pip_1Hz[pip_1Hz['UTC Seconds'].notna()]
    #zeit ins richtige format bringen:
    time = pip_1Hz['UTC Seconds']
    datetime = []
    for i in range(len(time)):
        datetime.append(datetime_from_utcs(year, month, day, time.iloc[i]))
    pip_1Hz.index = datetime
    #entweder:
    #pip_1Hz['count_all_1Hz2'] = pip_1Hz['Particle Count']
    #oder:
    # bei alfux werden im CIP 1Hz file zu viele partikel gesehen. Grund: greylevel für cip1hz ist falsch. hier wird jetzt der erste bin ausgelassen: 
    bins_name = ['Bin 1', 'Bin 2', 'Bin 3', 'Bin 4', 'Bin 5', 'Bin 6', 'Bin 7', 'Bin 8', 'Bin 9', 'Bin 10', 'Bin 11', 'Bin 12', 'Bin 13', 'Bin 14', 'Bin 15', 'Bin 16', 'Bin 17', 'Bin 18', 'Bin 19', 'Bin 20', 'Bin 21', 'Bin 22', 'Bin 23', 'Bin 24', 'Bin 25', 'Bin 26', 'Bin 27', 'Bin 28', 'Bin 29', 'Bin 30', 'Bin 31', 'Bin 32', 'Bin 33', 'Bin 34', 'Bin 35', 'Bin 36', 'Bin 37', 'Bin 38', 'Bin 39', 'Bin 40', 'Bin 41', 'Bin 42', 'Bin 43', 'Bin 44', 'Bin 45', 'Bin 46', 'Bin 47', 'Bin 48', 'Bin 49', 'Bin 50', 'Bin 51', 'Bin 52', 'Bin 53', 'Bin 54', 'Bin 55', 'Bin 56', 'Bin 57', 'Bin 58', 'Bin 59', 'Bin 60', 'Bin 61', 'Bin 62']
    pip_1Hz['count_all_1Hz'] = pip_1Hz['Over Reject Counts']+pip_1Hz['DOF Reject Counts']+pip_1Hz['End Reject Counts']+pip_1Hz[bins_name[1:]].sum(axis = 1)
    
    
    pip_1Hz.index.name = 'datetime'
    pip_1Hz = pip_1Hz.sort_values(by='datetime')
    pip_1Hz = pip_1Hz.drop_duplicates(keep = 'first')
    return pip_1Hz



#make fn input for SODA
#inputs:
def seach_all_imagefiles(data_path):
    image_files = []
    soda_str = ''
    for root, dirs, files in os.walk(data_path):
        for file in files:
            if file.startswith("Imagefile"):
                image_files.append(os.path.join(root, file).replace('\\', '/'))
    soda_str+='fn=[$ \n'
    for i in image_files:
        soda_str+=('\''+i + '\'' +','+ '$ \n')
    soda_str = soda_str[:-4]
    soda_str+=(']')
    return (soda_str)
data_path = (r'S:\MOSAiC\Data\CIP\09022020')
path_fn = seach_all_imagefiles(data_path)



def create_endbins(resolution):
# create entbind
    resolution = resolution
    n_bins = 64
    endbins = []
    for i in range(n_bins+1):
        endbins.append(resolution/2 + i*resolution)
    return ((endbins))

def create_n_endbins(resolution, start, n):
# create entbind
    resolution = resolution
    n_bins = n
    endbins = []
    for i in range(n_bins+1):
        endbins.append(resolution/2 + i*resolution + start)
    return ((endbins))





##################################################
#function to check if particle gets rejected from pbp file 
#input rejectionflag number from pbp file
#output: 1 gets rejected, 0 accepted
# settings: 1 = switched on, 0 switched off (low_ar, scatter_correct, size_range, all_in, cluster, water, irr , dof)
def check_rejection(rejectionflag ,low_ar, scatter_correct, size_range, all_in, cluster, water, irr , dof ):
    #bin(1)[2:] = Low area ratio
    #bin(2)[2:] = Below interarrival
    #bin(4)[2:] = Out of size range
    #bin(8)[2:] = All-in rejection + Center-in rejection
    #bin(16)[2:] = Cluster rejection
    #bin(32)[2:] = Water rejection
    #bin(64)[2:] = Irregular-only (non-water) rejection
    #bin(128)[2:] = Depth of field flag rejection, 66% threshold flagged for CIP/PIP/F2DC, or level 3 pixel on CIP-G
    # rejectionflag wird mit 256 addiert um dann beim konvertieren in binary zahl eine konstante string länge zu bekommen
    rejectionflag = rejectionflag + 256
    rjection_binary = low_ar*1 + scatter_correct *2 + size_range * 4 + all_in * 8 + cluster * 16 + water *32 + irr*64 + dof*128 + 1*256
    
    if int(bin(rjection_binary)[-1]) == 1 and int(bin(rejectionflag)[-1]) == 1: 
        return 1
    else:
        if int(bin(rjection_binary)[-2]) == 1 and int(bin(rejectionflag)[-2]) == 1: 
            return 1
        else:
            if int(bin(rjection_binary)[-3]) == 1 and int(bin(rejectionflag)[-3]) == 1:
                return 1
            else:
                if int(bin(rjection_binary)[-4]) == 1 and int(bin(rejectionflag)[-4]) == 1:
                    return 1
                else:
                    if int(bin(rjection_binary)[-5]) == 1 and int(bin(rejectionflag)[-5]) == 1:
                        return 1
                    else:
                        if int(bin(rjection_binary)[-6]) == 1 and int(bin(rejectionflag)[-6]) == 1:
                            return 1
                        else:
                            if int(bin(rjection_binary)[-7]) == 1 and int(bin(rejectionflag)[-7]) == 1:
                                return 1
                            else:
                                if int(bin(rjection_binary)[-8]) == 1 and int(bin(rejectionflag)[-8]) == 1:
                                    return 1
                                else:
                                    return 0 
##################################################     

# returns a array of the numers which get rejected. Used then to sort out the pandas df 
def reject_numbers(low_ar, scatter_correct, size_range, all_in, cluster, water, irr, dof):
    reject_numbers = []
    for i in range(256-1):
        if check_rejection( i+1,low_ar, scatter_correct, size_range, all_in, cluster, water, irr, dof) == 1:
            reject_numbers.append(i+1)
    return reject_numbers   
##################################################              
            


##################################################
#input_ auflösung probe in mu m, armiwidth in m!
# gibt samplingarea pro bin in m^2 aus
#all in methode
def oap_dmt_sa_allin(resolution, armwidth):
    C = 8.18
    #C = 3
    x = np.arange(0.0,30000e-6,0.02e-6)
    y = []
    for i in range(len(x)):    
        if (C * 2*(x[i]/2*x[i]/2)/(658e-9)) < armwidth:
            y.append(C * 2*(x[i]/2*x[i]/2)/(658e-9))
        else:
            y.append(armwidth)
    y = np.array(y)
    
    dof = y
    w_eff = resolution *1e-6*63-x
    sv = w_eff * dof
    bin_end_points = []
    for i in range(65):
        bin_end_points.append(resolution/2+ i*resolution)
    sa_per_bin = []
    for i in range(64):
        sa_per_bin.append(np.mean(sv[(np.abs(x - bin_end_points[i]*1e-6)).argmin():(np.abs(x - bin_end_points[i+1]*1e-6)).argmin()]))
    sa_per_bin = np.array(sa_per_bin)

    
    sa_per_bin = np.where(sa_per_bin<0, 0, sa_per_bin) 
    sa_per_bin[-1] = np.nan
    sa_per_bin[-2] = np.nan # da all in und um /0 zu vermeiden
    return sa_per_bin

##################################################
#input_ auflösung probe in mu m, armiwidth in m!
# gibt samplingarea pro bin in m^2 aus
#center - in in methode
def oap_dmt_sa_centerin(resolution, armwidth):
    C = 8.18
    #C = 3
    x = np.arange(0.0,30000e-6,0.02e-6)
    y = []
    for i in range(len(x)):    
        if (C * 2*(x[i]/2*x[i]/2)/(658e-9)) < armwidth:
            y.append(C * 2*(x[i]/2*x[i]/2)/(658e-9))
        else:
            y.append(armwidth)
    y = np.array(y)
    
    dof = y
    w_eff = resolution *1e-6*64
    sv = w_eff * dof
    bin_end_points = []
    for i in range(65):
        bin_end_points.append(resolution/2+ i*resolution)
    sa_per_bin = []
    for i in range(64):
        sa_per_bin.append(np.mean(sv[(np.abs(x - bin_end_points[i]*1e-6)).argmin():(np.abs(x - bin_end_points[i+1]*1e-6)).argmin()]))
    sa_per_bin = np.array(sa_per_bin)

    
    sa_per_bin = np.where(sa_per_bin<0, 0, sa_per_bin) 
    return sa_per_bin


# input samlingarea in m^2 pro bin, tas in m/s und sampingzeit in s
# gibt samplingvolumen pro bin in m^3 aus pro bin
def sv_per_bin(sampling_area, v_aircraft, t_sample):
    sv = sampling_area * v_aircraft * t_sample
    return sv
##################################################



from netCDF4 import Dataset
import os

def import_netcdf(file):
    filee = (file).replace('\\','/')
    file_nc = Dataset(filee,'r') 
    return file_nc


###2ds:
def create_endbins_2ds(resolution):
# create entbind
    resolution = resolution
    n_bins = 256
    endbins = []
    for i in range(n_bins+1):
        endbins.append(resolution/2 + i*resolution)
    return ((endbins))


#plottet timeframes in einen plot:
def plot_timeframes(a):
    #a = [combined['T'], combined.TWC_nev]
    fig, axs = plt.subplots(len(a), 1, sharex=True,figsize=(11,9))
    for i in range(len(a)):
        axs[i].plot(a[i])
        axs[i].set_ylabel(a[i].name)
        axs[len(a)-1].set_xlabel('UTC [s]') 
    return(0)




def plot_psd(data_df, bin_df, year, month, day, hour, minute,second, delta, color):
    dNdD_names = []
    for i in data_df.columns:
        if i[:2] == 'dN':
            dNdD_names.append(i)
    
    dt = str(year)+'-'+"{0:0=2d}".format(month)+'-'+"{0:0=2d}".format(day)+' '+"{0:0=2d}".format(hour)+':'+"{0:0=2d}".format(minute)+':'+"{0:0=2d}".format(second)
    dt = pd.to_datetime(dt)
    dt_end = dt + datetime.timedelta(seconds=delta-1)
    data_df = data_df[(data_df.index.month == month) & (data_df.index.day == day)]
    index_start = data_df.at_time(dt).index[0]
    index_end = data_df.at_time(dt_end).index[0]
    x = bin_df.bin_mid
    y = (data_df[dNdD_names].loc[index_start:index_end].sum(axis = 0, skipna = True) / len(data_df[dNdD_names].loc[index_start:index_end])).values
    
    #the plot:
    plt.semilogy(x, y, drawstyle='steps-mid', color = color,  label = '')
    plt.semilogy(x, y, 's', markersize=3, color = color)
    
    plt.ylabel(r'blblblaldsjkfhjsdk')
    plt.xlabel('D [$\mu m$]') 
    plt.title("size distribution")
    plt.legend(loc=1)
    plt.xscale('log')
    return 0





# plot whole date in df as psd
def plot_psd_df(data_df, bin_df, label ,color):
    dNdD_names = []
    for i in data_df.columns:
        if i[:2] == 'dN':
            dNdD_names.append(i)
    
    #data_df = data_df[(data_df.index.month == month) & (data_df.index.day == day)]
    x = bin_df.bin_mid
    y = (data_df[dNdD_names].loc[:].sum(axis = 0, skipna = True) / len(data_df[dNdD_names].loc[:])).values
    
    #the plot:
    plt.semilogy(x, y, drawstyle='steps-mid', color = color,  label = label)
    plt.semilogy(x, y, 's', markersize=3, color = color)
    plt.ylabel(r'n ($\mathrm{m}^{-4}$)')
    plt.xlabel('D (µm)') 
    plt.title("size distribution")
    plt.legend(loc=1)
    plt.xscale('log')
    return 0


# plot whole date in df as psd
def plot_psd_df_line(data_df, bin_df, label ,color):
    dNdD_names = []
    for i in data_df.columns:
        if i[:2] == 'dN':
            dNdD_names.append(i)
    
    #data_df = data_df[(data_df.index.month == month) & (data_df.index.day == day)]
    x = bin_df.bin_mid
    y = (data_df[dNdD_names].loc[:].sum(axis = 0, skipna = True) / len(data_df[dNdD_names].loc[:])).values
    
    #the plot:
    plt.semilogy(x, y, color = color,  label = label)
   # plt.semilogy(x, y, 's', markersize=3, color = color)
    plt.ylabel(r'n [$m^{-4}$]')
    plt.xlabel('D [$\mu m$]') 
    plt.title("size distribution")
    plt.legend(loc=1)
    plt.grid(True)
    plt.xscale('log')
    return 0


def plot_color_psd(data_df, bin_df):
    edges = bin_df.bin_min.to_numpy()
    dNdD = get_dNdD(data_df)
    dNdD = dNdD.transpose()
    t = [dNdD.replace(0,np.nan).min().min(), dNdD.max().max()]
    dNdD = dNdD.replace(np.nan,np.nan)
    dNdD[dNdD <= t[0]] = t[0]
    dNdD = dNdD.replace(np.nan,t[0])
    im = plt.pcolormesh(data_df.index, edges, dNdD, norm=LogNorm(vmin=t[0], vmax=t[-1]), cmap=cm.jet, rasterized=True, shading='flat')
    plt.yscale('log')
    cb = plt.colorbar(im)
    cb.set_label(r'number concentration [$\#/m^4$]')
    plt.ylabel('D [$\mu m$]')
    plt.xlabel('Time (UTC)')






#Wolkenfilter: N größer 1000 partikel pro m^3
# um Rauschen ausschließen zu können: mehr als 3 bins müssen daten sehen!
def filter_clouds(data_df, bin_df):
    data_df = data_df.replace(np.nan, 0)
    data_df = data_df[(data_df[column_names(bin_df)[0]].T[data_df[column_names(bin_df)[0]].T != 0].count())>3]
    data_df = data_df[data_df.N > 1000]
    return data_df




def calc_rh_i(rh, temp):
    # input: rh in Series (reletive humidity)
    # temp in series (Temoperature)
    # output: rh bezüglich Eis
    
    #https://www.schweizer-fn.de/lueftung/feuchte/feuchte.php
    rh_i = []
    for i in range(len(temp)):
        e_sat_w_i = 611.2 * np.exp(17.62 * temp[i] /(243.12 +  temp[i]))
        e_sat_i_i = 611.2 * np.exp(22.46 *  temp[i] /(272.62 +  temp[i]))
        rh_i_i = rh[i] * e_sat_w_i / e_sat_i_i
        rh_i.append(rh_i_i)
    rh_i = pd.Series(rh_i,rh.index)
    return rh_i

