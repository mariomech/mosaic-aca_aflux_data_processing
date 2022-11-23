import os
import numpy as np
import pandas as pd
from datetime import datetime
os.chdir('.../processing/')
from Utility_MOSAiC_AFLUX_pms import save_icar_combined_aflux, calc_IWC, calc_LWC, create_n_endbins, bin_df_from_edges, column_names2, get_dNdD, bin_to_1um_res_new, seconds_since_midnight, datetime_from_utcs, bin_df_from_edges, column_names, calc_LWC, calc_MVD, get_dN, calc_ED, save_icar_cas_aflux
import statistics



#############################################################################
#start: import the processed pkl files from cas, cip and pip; combined pkl file is created


########awi:
cgawi_data = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/CGAWI/aflux_cgawi.pkl')
cgawi_data['datetime'] = cgawi_data.index

#########pip:
pip_data = pd.read_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\PIP\20210811_PIP_AMES_Files\aflux_pip_data_df.pkl')
pip_bin = pd.read_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\PIP\20210811_PIP_AMES_Files\aflux_pip_bin_df.pkl')
bin_df_pip = pip_bin
dNdD_names_pip, dn_names_pip = column_names(bin_df_pip)

#########cip:
cip_data = pd.read_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\CIP\20210811_CIP_AMES_Files\aflux_cip_data_df.pkl')
cip_bin = pd.read_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\CIP\20210811_CIP_AMES_Files\aflux_cip_bin_df.pkl')
bin_df_cip = cip_bin
dNdD_names_cip, dn_names_cip = column_names(cip_bin)


#########cdp:
cdp_data = pd.read_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\CAS\20210811_CAS_AMES_Files\aflux_cas_data_df.pkl')
cdp_bin = pd.read_pickle(r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\CAS\20210811_CAS_AMES_Files\aflux_cas_bin_df.pkl')
bin_df_cdp = cdp_bin
dNdD_names_cdp, dn_names_cdp = column_names(bin_df_cdp)



data_cdp = cdp_data
data_cip = cip_data
data_pip = pip_data
cgawi = cgawi_data

#muss aufgeteilt werden da sonst der memory nicht ausreicht die ganze kampagne zu berechnen...
#first part:
end_date = "2019-03-31"
data_cdp = cdp_data.loc[cdp_data["datetime"] <= end_date]
data_cip = cip_data.loc[data_cip["datetime"] <= end_date]
data_pip = pip_data.loc[data_pip["datetime"] <= end_date]
cgawi = cgawi_data.loc[cgawi["datetime"] <= end_date]



#combined area angeben: 
edge1 = 36; edge2 = 48#cdp-cip: 30 - 40 
edge3 = 300; edge4 = 450#cip-pip: 250 - 350

bin_df_1um_cip, dNdD_1um_df_cip = bin_to_1um_res_new(get_dNdD(data_cip), cip_bin, logarithmic=False)
bin_df_1um_pip, dNdD_1um_df_pip = bin_to_1um_res_new(get_dNdD(data_pip), pip_bin, logarithmic=False)
bin_df_1um_cdp, dNdD_1um_df_cdp = bin_to_1um_res_new(get_dNdD(data_cdp), cdp_bin, logarithmic=False)

#alle daten auf den gleichen index bringen:
a = dNdD_1um_df_cdp.copy() #hier cdp und cip
b = dNdD_1um_df_cip.copy()
a['datetime'] = a.index 
b['datetime'] = b.index
merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
merge.index = merge.datetime
merge = merge.drop(columns = 'datetime')
dNdD_1um_df_cdp2 =  merge.iloc[:,:int(len(dNdD_1um_df_cdp.columns))]
dNdD_1um_df_cip2 =  merge.iloc[:,int(len(dNdD_1um_df_cdp.columns)):]

a = dNdD_1um_df_cdp.copy()#hier cdp und pip
b = dNdD_1um_df_pip.copy()
a['datetime'] = a.index
b['datetime'] = b.index
merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
merge.index = merge.datetime
merge = merge.drop(columns = 'datetime')
dNdD_1um_df_cdp2 =  merge.iloc[:,:int(len(dNdD_1um_df_cdp.columns))]
dNdD_1um_df_pip2 =  merge.iloc[:,int(len(dNdD_1um_df_cdp.columns)):]

dNdD_1um_df_cdp2.columns = dNdD_1um_df_cdp.columns
dNdD_1um_df_cip2.columns = dNdD_1um_df_cip.columns
dNdD_1um_df_pip2.columns = dNdD_1um_df_pip.columns

dNdD_1um_df_cdp = dNdD_1um_df_cdp2
dNdD_1um_df_cip = dNdD_1um_df_cip2
dNdD_1um_df_pip = dNdD_1um_df_pip2


#1:
index_cdp_edge1 = bin_df_1um_cdp['bin_max'].sub(edge1).abs().idxmin()
bin_df_1um_cdp[0:index_cdp_edge1]
#2:
index_cdp_edge2 = bin_df_1um_cdp['bin_max'].sub(edge2).abs().idxmin()
bin_df_1um_cdp[index_cdp_edge1:index_cdp_edge2]
#3:
index_cip_edge1 = bin_df_1um_cip['bin_max'].sub(edge1).abs().idxmin()
index_cip_edge2 = bin_df_1um_cip['bin_max'].sub(edge2).abs().idxmin()
bin_df_1um_cip[index_cip_edge1: index_cip_edge2]
#4:
index_cip_edge3 = bin_df_1um_cip['bin_max'].sub(edge3).abs().idxmin()
bin_df_1um_cip[index_cip_edge2: index_cip_edge3]
#5
index_cip_edge4 = bin_df_1um_cip['bin_max'].sub(edge4).abs().idxmin()
bin_df_1um_cip[index_cip_edge3: index_cip_edge4]
#6
index_pip_edge3 = bin_df_1um_pip['bin_max'].sub(edge3).abs().idxmin()
index_pip_edge4 = bin_df_1um_pip['bin_max'].sub(edge4).abs().idxmin()
bin_df_1um_pip[index_pip_edge3: index_pip_edge4]
#7
bin_df_1um_pip[index_pip_edge4: ]



#mean 2-3:
a = dNdD_1um_df_cdp[column_names2(bin_df_1um_cdp[index_cdp_edge1:index_cdp_edge2])[0]]
b = dNdD_1um_df_cip[column_names2(bin_df_1um_cip[index_cip_edge1: index_cip_edge2])[0]]
new_names = column_names(column_names2(bin_df_1um_cdp[index_cdp_edge1:index_cdp_edge2])[0])[0]

a.columns = new_names
b.columns = new_names
#a['datetime'] = a.index
#b['datetime'] = b.index
#merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
#merge.index = merge.datetime
#merge = merge.drop(columns = 'datetime')
#matrixa =  merge.iloc[:,:int(len(merge.columns)/2)]
#matrixb =  merge.iloc[:,int(len(merge.columns)/2):]
matrixa = a
matrixb = b
len_col = int(len(matrixa.columns))
len_rows = int(len(matrixa))
zero_data = np.zeros(shape=(len_rows,len(new_names)))
matrix = pd.DataFrame(zero_data, columns=new_names)
for k in range(len_rows):
    for l in range(len_col):
        if matrixa.iloc[k,l] == 0  or matrixb.iloc[k,l] == 0 or matrixa.iloc[k,l] == np.nan  or matrixb.iloc[k,l] == np.nan:
            matrix.iloc[k,l] = matrixa.iloc[k,l] + matrixb.iloc[k,l]
        else:
            matrix.iloc[k,l] = statistics.mean([matrixa.iloc[k,l], matrixb.iloc[k,l]])
    if k%100 ==0:
        print('calculating overlap 1: ' ,int(k/(len_rows)*100),'%')
matrix.index = matrixa.index
matrix_overlap1 = matrix


#mean 5-6:
a = dNdD_1um_df_cip[column_names2(bin_df_1um_cip[index_cip_edge3: index_cip_edge4])[0]]
b = dNdD_1um_df_pip[column_names2(bin_df_1um_pip[index_pip_edge3: index_pip_edge4])[0]]
new_names = column_names(column_names2(bin_df_1um_cip[index_cip_edge3: index_cip_edge4])[0])[0]

a.columns = new_names
b.columns = new_names
#a['datetime'] = a.index
#b['datetime'] = b.index
#merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
#merge.index = merge.datetime
#merge = merge.drop(columns = 'datetime')
#matrixa =  merge.iloc[:,:int(len(merge.columns)/2)]
#matrixb =  merge.iloc[:,int(len(merge.columns)/2):]
matrixa = a
matrixb = b
len_col = int(len(matrixa.columns))
len_rows = int(len(matrixa))
zero_data = np.zeros(shape=(len_rows,len(new_names)))
matrix = pd.DataFrame(zero_data, columns=new_names)
for k in range(len_rows):
    for l in range(len_col):
        if matrixa.iloc[k,l] == 0  or matrixb.iloc[k,l] == 0 or matrixa.iloc[k,l] == np.nan  or matrixb.iloc[k,l] == np.nan:
            matrix.iloc[k,l] = matrixa.iloc[k,l] + matrixb.iloc[k,l]
        else:
            matrix.iloc[k,l] = statistics.mean([matrixa.iloc[k,l], matrixb.iloc[k,l]])
    if k%100 ==0:
        print('calculating overlap 2: ' ,int(k/(len_rows)*100),'%')
matrix.index = matrixa.index
matrix_overlap2 = matrix

cdp = dNdD_1um_df_cdp[column_names2(bin_df_1um_cdp[0:index_cdp_edge1])[0]]
cip = dNdD_1um_df_cip[column_names2(bin_df_1um_cip[index_cip_edge2: index_cip_edge3])[0]]
pip = dNdD_1um_df_pip[column_names2(bin_df_1um_pip[index_pip_edge4: ])[0]]

combined_1um_res = pd.concat([cdp, matrix_overlap1,cip, matrix_overlap2,pip], axis = 1)
b = bin_df_from_edges(create_n_endbins(1, bin_df_1um_cdp.bin_min.iloc[0], len(a.iloc[0,:])))
bin_df_combined_1um_res = bin_df_from_edges(create_n_endbins(1, 3, len(combined_1um_res.iloc[0,:])))
combined_1um_res.columns = column_names(bin_df_combined_1um_res)[0]


# jetzt wieder zurück auf das original binning: 
#cdp: bins bis untere grenze 1. überlapp, überlapp als ein bin. 
# edge1
bin_df_combined_1 = bin_df_cdp[bin_df_cdp['bin_max'].lt(edge1)]
bin_df_combined_3 = bin_df_cip[bin_df_cip['bin_min'].gt(edge2)][bin_df_cip['bin_max'].lt(edge3)]
bin_df_combined_5 = bin_df_pip[bin_df_pip['bin_min'].gt(edge4)]

bin_df_combined_2_full_res = bin_df_combined_1um_res[bin_df_combined_1um_res['bin_min'].gt(bin_df_combined_1.iloc[-1].bin_max)][bin_df_combined_1um_res['bin_min'].lt(bin_df_combined_3.iloc[0].bin_min)]
bin_df_combined_4_full_res = bin_df_combined_1um_res[bin_df_combined_1um_res['bin_min'].gt(bin_df_combined_3.iloc[-1].bin_max)][bin_df_combined_1um_res['bin_min'].lt(bin_df_combined_5.iloc[0].bin_min)]
bin_df_combined_2 = bin_df_from_edges([bin_df_combined_2_full_res.bin_min.iloc[0], bin_df_combined_2_full_res.bin_max.iloc[-1]])
bin_df_combined_4 = bin_df_from_edges([bin_df_combined_4_full_res.bin_min.iloc[0], bin_df_combined_4_full_res.bin_max.iloc[-1]])

cdp_df = data_cdp[column_names2(bin_df_combined_1)[0]]
cip_df = data_cip[column_names2(bin_df_combined_3)[0]]
pip_df = data_pip[column_names2(bin_df_combined_5)[0]]

overlapp1_df = combined_1um_res[column_names2(bin_df_combined_2_full_res)[0]].sum(axis = 1) /int(bin_df_combined_2.bin_width)
overlapp2_df = combined_1um_res[column_names2(bin_df_combined_4_full_res)[0]].sum(axis = 1) /int(bin_df_combined_4.bin_width)

overlapp1_df = overlapp1_df.to_frame()
overlapp1_df.columns = ['dNdD_001']

overlapp2_df = overlapp2_df.to_frame()
overlapp2_df.columns = ['dNdD_001']


#hier alle daten auf die selbe länge + index bringen:

#alle daten auf den gleichen index bringen:
a = cdp_df.copy() #hier cdp und cip
b = cip_df.copy()
a.index.names = ['datetime']
b.index.names = ['datetime']
#a['datetime'] = a.index 
#b['datetime'] = b.index
merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
merge.index = merge.datetime
merge = merge.drop(columns = 'datetime')
cdp_df =  merge.iloc[:,:int(len(cdp_df.columns))]
cip_df =  merge.iloc[:,int(len(cdp_df.columns)):]

a = cdp_df.copy()#hier cdp und pip
b = pip_df.copy()
a.index.names = ['datetime']
b.index.names = ['datetime']
merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
merge.index = merge.datetime
merge = merge.drop(columns = 'datetime')
cdp_df =  merge.iloc[:,:int(len(cdp_df.columns))]
pip_df =  merge.iloc[:,int(len(cdp_df.columns)):]

cdp_df = cdp_df.replace(np.nan , 0)
cip_df = cip_df.replace(np.nan , 0)
pip_df = pip_df.replace(np.nan , 0)




combined_df = pd.concat([cdp_df, overlapp1_df,cip_df, overlapp2_df,pip_df], axis = 1)
combined_bin_df = pd.concat([bin_df_combined_1,bin_df_combined_2 ,bin_df_combined_3,bin_df_combined_4 ,bin_df_combined_5], axis = 0)
combined_bin_df.index = np.arange(1, len(combined_bin_df) + 1)
combined_df.columns = column_names(combined_bin_df)[0]

print('Combining PMS - done')
print('edge 1: from '+str(float(bin_df_combined_2.bin_min))+ ' - ' + str(float(bin_df_combined_2.bin_max)) + ' micrometer')
print('edge 2: from '+str(float(bin_df_combined_4.bin_min))+ ' - ' + str(float(bin_df_combined_4.bin_max)) + ' micrometer')








combined_columns = column_names(combined_bin_df)[0]
print('calculating N, IWC, LWC,... ')
combined_df.insert(0, 'N', np.nansum((get_dN(combined_df, combined_bin_df*1e-6)),axis = 1))
combined_df.insert(1, 'MVD', calc_MVD(combined_df,combined_bin_df*1e-6))
combined_df.insert(2, 'LWC', calc_LWC(get_dN(combined_df,combined_bin_df*1e-6), (combined_bin_df['bin_mid']*1e-6).to_numpy())[0]  )
combined_df.insert(3, 'IWC', calc_IWC(get_dN(combined_df,combined_bin_df*1e-6), (combined_bin_df['bin_mid']*1e-6).to_numpy())[0]  ) 
combined_df.insert(4, 'LWC_50', calc_LWC(get_dN(combined_df[combined_columns[:9]],combined_bin_df[:9]*1e-6), (combined_bin_df[:9]['bin_mid']*1e-6).to_numpy())[0]  ) #lwc for p. smaller 52
combined_df.insert(5, 'IWC_50', calc_IWC(get_dN(combined_df[combined_columns[9:]],combined_bin_df[9:]*1e-6), (combined_bin_df[9:]['bin_mid']*1e-6).to_numpy())[0]  ) #iwc for p. larger 52
combined_df.insert(6, 'CWC', combined_df.LWC_50 + combined_df.IWC_50)
combined_df.insert(7, 'ED', calc_ED(combined_df,combined_bin_df*1e-6))


combined_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined2_part1.pkl')
combined_bin_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined_bins2.pkl')




#zweiter teil:
data_cdp = cdp_data
data_cip = cip_data
data_pip = pip_data
cgawi = cgawi_data

#muss aufgeteilt werden da sonst der memory nicht ausreicht die ganze kampagne zu berechnen...
start_date = "2019-03-31"
data_cdp = cdp_data.loc[cdp_data["datetime"] >= start_date]
data_cip = cip_data.loc[data_cip["datetime"] >= start_date]
data_pip = pip_data.loc[data_pip["datetime"] >= start_date]
cgawi = cgawi_data.loc[cgawi["datetime"] >= start_date]




#combined area angeben: (wird von oben übernommen)
#edge1 = 36; edge2 = 48#cdp-cip: 30 - 40 
#edge3 = 300; edge4 = 450#cip-pip: 250 - 350

bin_df_1um_cip, dNdD_1um_df_cip = bin_to_1um_res_new(get_dNdD(data_cip), cip_bin, logarithmic=False)
bin_df_1um_pip, dNdD_1um_df_pip = bin_to_1um_res_new(get_dNdD(data_pip), pip_bin, logarithmic=False)
bin_df_1um_cdp, dNdD_1um_df_cdp = bin_to_1um_res_new(get_dNdD(data_cdp), cdp_bin, logarithmic=False)

#alle daten auf den gleichen index bringen:
a = dNdD_1um_df_cdp.copy() #hier cdp und cip
b = dNdD_1um_df_cip.copy()
a['datetime'] = a.index 
b['datetime'] = b.index
merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
merge.index = merge.datetime
merge = merge.drop(columns = 'datetime')
dNdD_1um_df_cdp2 =  merge.iloc[:,:int(len(dNdD_1um_df_cdp.columns))]
dNdD_1um_df_cip2 =  merge.iloc[:,int(len(dNdD_1um_df_cdp.columns)):]

a = dNdD_1um_df_cdp.copy()#hier cdp und pip
b = dNdD_1um_df_pip.copy()
a['datetime'] = a.index
b['datetime'] = b.index
merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
merge.index = merge.datetime
merge = merge.drop(columns = 'datetime')
dNdD_1um_df_cdp2 =  merge.iloc[:,:int(len(dNdD_1um_df_cdp.columns))]
dNdD_1um_df_pip2 =  merge.iloc[:,int(len(dNdD_1um_df_cdp.columns)):]

dNdD_1um_df_cdp2.columns = dNdD_1um_df_cdp.columns
dNdD_1um_df_cip2.columns = dNdD_1um_df_cip.columns
dNdD_1um_df_pip2.columns = dNdD_1um_df_pip.columns

dNdD_1um_df_cdp = dNdD_1um_df_cdp2
dNdD_1um_df_cip = dNdD_1um_df_cip2
dNdD_1um_df_pip = dNdD_1um_df_pip2


#1:
index_cdp_edge1 = bin_df_1um_cdp['bin_max'].sub(edge1).abs().idxmin()
bin_df_1um_cdp[0:index_cdp_edge1]
#2:
index_cdp_edge2 = bin_df_1um_cdp['bin_max'].sub(edge2).abs().idxmin()
bin_df_1um_cdp[index_cdp_edge1:index_cdp_edge2]
#3:
index_cip_edge1 = bin_df_1um_cip['bin_max'].sub(edge1).abs().idxmin()
index_cip_edge2 = bin_df_1um_cip['bin_max'].sub(edge2).abs().idxmin()
bin_df_1um_cip[index_cip_edge1: index_cip_edge2]
#4:
index_cip_edge3 = bin_df_1um_cip['bin_max'].sub(edge3).abs().idxmin()
bin_df_1um_cip[index_cip_edge2: index_cip_edge3]
#5
index_cip_edge4 = bin_df_1um_cip['bin_max'].sub(edge4).abs().idxmin()
bin_df_1um_cip[index_cip_edge3: index_cip_edge4]
#6
index_pip_edge3 = bin_df_1um_pip['bin_max'].sub(edge3).abs().idxmin()
index_pip_edge4 = bin_df_1um_pip['bin_max'].sub(edge4).abs().idxmin()
bin_df_1um_pip[index_pip_edge3: index_pip_edge4]
#7
bin_df_1um_pip[index_pip_edge4: ]



#mean 2-3:
a = dNdD_1um_df_cdp[column_names2(bin_df_1um_cdp[index_cdp_edge1:index_cdp_edge2])[0]]
b = dNdD_1um_df_cip[column_names2(bin_df_1um_cip[index_cip_edge1: index_cip_edge2])[0]]
new_names = column_names(column_names2(bin_df_1um_cdp[index_cdp_edge1:index_cdp_edge2])[0])[0]

a.columns = new_names
b.columns = new_names
#a['datetime'] = a.index
#b['datetime'] = b.index
#merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
#merge.index = merge.datetime
#merge = merge.drop(columns = 'datetime')
#matrixa =  merge.iloc[:,:int(len(merge.columns)/2)]
#matrixb =  merge.iloc[:,int(len(merge.columns)/2):]
matrixa = a
matrixb = b
len_col = int(len(matrixa.columns))
len_rows = int(len(matrixa))
zero_data = np.zeros(shape=(len_rows,len(new_names)))
matrix = pd.DataFrame(zero_data, columns=new_names)
for k in range(len_rows):
    for l in range(len_col):
        if matrixa.iloc[k,l] == 0  or matrixb.iloc[k,l] == 0 or matrixa.iloc[k,l] == np.nan  or matrixb.iloc[k,l] == np.nan:
            matrix.iloc[k,l] = matrixa.iloc[k,l] + matrixb.iloc[k,l]
        else:
            matrix.iloc[k,l] = statistics.mean([matrixa.iloc[k,l], matrixb.iloc[k,l]])
    if k%100 ==0:
        print('calculating overlap 1: ' ,int(k/(len_rows)*100),'%')
matrix.index = matrixa.index
matrix_overlap1 = matrix


#mean 5-6:
a = dNdD_1um_df_cip[column_names2(bin_df_1um_cip[index_cip_edge3: index_cip_edge4])[0]]
b = dNdD_1um_df_pip[column_names2(bin_df_1um_pip[index_pip_edge3: index_pip_edge4])[0]]
new_names = column_names(column_names2(bin_df_1um_cip[index_cip_edge3: index_cip_edge4])[0])[0]

a.columns = new_names
b.columns = new_names
#a['datetime'] = a.index
#b['datetime'] = b.index
#merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
#merge.index = merge.datetime
#merge = merge.drop(columns = 'datetime')
#matrixa =  merge.iloc[:,:int(len(merge.columns)/2)]
#matrixb =  merge.iloc[:,int(len(merge.columns)/2):]
matrixa = a
matrixb = b
len_col = int(len(matrixa.columns))
len_rows = int(len(matrixa))
zero_data = np.zeros(shape=(len_rows,len(new_names)))
matrix = pd.DataFrame(zero_data, columns=new_names)
for k in range(len_rows):
    for l in range(len_col):
        if matrixa.iloc[k,l] == 0  or matrixb.iloc[k,l] == 0 or matrixa.iloc[k,l] == np.nan  or matrixb.iloc[k,l] == np.nan:
            matrix.iloc[k,l] = matrixa.iloc[k,l] + matrixb.iloc[k,l]
        else:
            matrix.iloc[k,l] = statistics.mean([matrixa.iloc[k,l], matrixb.iloc[k,l]])
    if k%100 ==0:
        print('calculating overlap 2: ' ,int(k/(len_rows)*100),'%')
matrix.index = matrixa.index
matrix_overlap2 = matrix

cdp = dNdD_1um_df_cdp[column_names2(bin_df_1um_cdp[0:index_cdp_edge1])[0]]
cip = dNdD_1um_df_cip[column_names2(bin_df_1um_cip[index_cip_edge2: index_cip_edge3])[0]]
pip = dNdD_1um_df_pip[column_names2(bin_df_1um_pip[index_pip_edge4: ])[0]]

combined_1um_res = pd.concat([cdp, matrix_overlap1,cip, matrix_overlap2,pip], axis = 1)
b = bin_df_from_edges(create_n_endbins(1, bin_df_1um_cdp.bin_min.iloc[0], len(a.iloc[0,:])))
bin_df_combined_1um_res = bin_df_from_edges(create_n_endbins(1, 3, len(combined_1um_res.iloc[0,:])))
combined_1um_res.columns = column_names(bin_df_combined_1um_res)[0]


# jetzt wieder zurück auf das original binning: 
#cdp: bins bis untere grenze 1. überlapp, überlapp als ein bin. 
# edge1
bin_df_combined_1 = bin_df_cdp[bin_df_cdp['bin_max'].lt(edge1)]
bin_df_combined_3 = bin_df_cip[bin_df_cip['bin_min'].gt(edge2)][bin_df_cip['bin_max'].lt(edge3)]
bin_df_combined_5 = bin_df_pip[bin_df_pip['bin_min'].gt(edge4)]

bin_df_combined_2_full_res = bin_df_combined_1um_res[bin_df_combined_1um_res['bin_min'].gt(bin_df_combined_1.iloc[-1].bin_max)][bin_df_combined_1um_res['bin_min'].lt(bin_df_combined_3.iloc[0].bin_min)]
bin_df_combined_4_full_res = bin_df_combined_1um_res[bin_df_combined_1um_res['bin_min'].gt(bin_df_combined_3.iloc[-1].bin_max)][bin_df_combined_1um_res['bin_min'].lt(bin_df_combined_5.iloc[0].bin_min)]
bin_df_combined_2 = bin_df_from_edges([bin_df_combined_2_full_res.bin_min.iloc[0], bin_df_combined_2_full_res.bin_max.iloc[-1]])
bin_df_combined_4 = bin_df_from_edges([bin_df_combined_4_full_res.bin_min.iloc[0], bin_df_combined_4_full_res.bin_max.iloc[-1]])

cdp_df = data_cdp[column_names2(bin_df_combined_1)[0]]
cip_df = data_cip[column_names2(bin_df_combined_3)[0]]
pip_df = data_pip[column_names2(bin_df_combined_5)[0]]

overlapp1_df = combined_1um_res[column_names2(bin_df_combined_2_full_res)[0]].sum(axis = 1) /int(bin_df_combined_2.bin_width)
overlapp2_df = combined_1um_res[column_names2(bin_df_combined_4_full_res)[0]].sum(axis = 1) /int(bin_df_combined_4.bin_width)

overlapp1_df = overlapp1_df.to_frame()
overlapp1_df.columns = ['dNdD_001']

overlapp2_df = overlapp2_df.to_frame()
overlapp2_df.columns = ['dNdD_001']


#hier alle daten auf die selbe länge + index bringen:

#alle daten auf den gleichen index bringen:
a = cdp_df.copy() #hier cdp und cip
b = cip_df.copy()
a.index.names = ['datetime']
b.index.names = ['datetime']
#a['datetime'] = a.index 
#b['datetime'] = b.index
merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
merge.index = merge.datetime
merge = merge.drop(columns = 'datetime')
cdp_df =  merge.iloc[:,:int(len(cdp_df.columns))]
cip_df =  merge.iloc[:,int(len(cdp_df.columns)):]

a = cdp_df.copy()#hier cdp und pip
b = pip_df.copy()
a.index.names = ['datetime']
b.index.names = ['datetime']
merge = pd.merge_asof(a,b, on = 'datetime' , tolerance=pd.Timedelta('1s'))
merge.index = merge.datetime
merge = merge.drop(columns = 'datetime')
cdp_df =  merge.iloc[:,:int(len(cdp_df.columns))]
pip_df =  merge.iloc[:,int(len(cdp_df.columns)):]

cdp_df = cdp_df.replace(np.nan , 0)
cip_df = cip_df.replace(np.nan , 0)
pip_df = pip_df.replace(np.nan , 0)




combined_df = pd.concat([cdp_df, overlapp1_df,cip_df, overlapp2_df,pip_df], axis = 1)
combined_bin_df = pd.concat([bin_df_combined_1,bin_df_combined_2 ,bin_df_combined_3,bin_df_combined_4 ,bin_df_combined_5], axis = 0)
combined_bin_df.index = np.arange(1, len(combined_bin_df) + 1)
combined_df.columns = column_names(combined_bin_df)[0]

print('Combining PMS - done')
print('edge 1: from '+str(float(bin_df_combined_2.bin_min))+ ' - ' + str(float(bin_df_combined_2.bin_max)) + ' micrometer')
print('edge 2: from '+str(float(bin_df_combined_4.bin_min))+ ' - ' + str(float(bin_df_combined_4.bin_max)) + ' micrometer')








combined_columns = column_names(combined_bin_df)[0]
print('calculating N, IWC, LWC,... ')
combined_df.insert(0, 'N', np.nansum((get_dN(combined_df, combined_bin_df*1e-6)),axis = 1))
combined_df.insert(1, 'MVD', calc_MVD(combined_df,combined_bin_df*1e-6))
combined_df.insert(2, 'LWC', calc_LWC(get_dN(combined_df,combined_bin_df*1e-6), (combined_bin_df['bin_mid']*1e-6).to_numpy())[0]  )
combined_df.insert(3, 'IWC', calc_IWC(get_dN(combined_df,combined_bin_df*1e-6), (combined_bin_df['bin_mid']*1e-6).to_numpy())[0]  ) 
combined_df.insert(4, 'LWC_50', calc_LWC(get_dN(combined_df[combined_columns[:9]],combined_bin_df[:9]*1e-6), (combined_bin_df[:9]['bin_mid']*1e-6).to_numpy())[0]  ) #lwc for p. smaller 52
combined_df.insert(5, 'IWC_50', calc_IWC(get_dN(combined_df[combined_columns[9:]],combined_bin_df[9:]*1e-6), (combined_bin_df[9:]['bin_mid']*1e-6).to_numpy())[0]  ) #iwc for p. larger 52
combined_df.insert(6, 'CWC', combined_df.LWC_50 + combined_df.IWC_50)
combined_df.insert(7, 'ED', calc_ED(combined_df,combined_bin_df*1e-6))


combined_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined2_part2.pkl')
combined_bin_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined_bins2.pkl')



combined_df1 = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined2_part1.pkl')
combined_df2 = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined2_part2.pkl')



combined_df = pd.concat([combined_df1, combined_df2])
combined_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined.pkl')
combined_bin_df.to_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined_bins.pkl')


with open(r'C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/overlaps_for_pkl.txt', 'w') as f:
    f.writelines('edge 1: from '+str(float(bin_df_combined_2.bin_min))+ ' - ' + str(float(bin_df_combined_2.bin_max)) + ' micrometer \n')
    f.writelines('edge 2: from '+str(float(bin_df_combined_4.bin_min))+ ' - ' + str(float(bin_df_combined_4.bin_max)) + ' micrometer \n')


#end: import the processed pkl files from cas, cip and pip; combined pkl file is created
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


pms_combined = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined.pkl')
pms_combined_bins = pd.read_pickle('C:/Users/mose_mn/Documents/Kampagnen/AFLUX/Auswertung/NASA-AMES/pms_combined/aflux_pms_combined_bins.pkl')


#hier noch eine spalte mit den utc seconds hinzufügen: muss so sein damit das save_icar_cdp funktioniert
pms_combined['datetime'] = pms_combined.index
Time = []
for i in range(len(pms_combined)):
    Time.append(seconds_since_midnight(pms_combined.datetime.iloc[i].hour, pms_combined.datetime.iloc[i].minute, pms_combined.datetime.iloc[i].second))
pms_combined.insert(0,'Time', Time)


pms_combined = pms_combined.replace(np.nan, 0)
pms_combined = pms_combined.replace(np.inf, 0)


#einzelnen tage herausfinden:
days_of_campaign = pms_combined.resample('D').sum()[pms_combined.resample('D').sum()['Time']>0].index

directory = r'C:\Users\mose_mn\Documents\Kampagnen\AFLUX\Auswertung\NASA-AMES\pms_combined'

for i in range(len(days_of_campaign)):
    data_df = pms_combined[(pms_combined.index.year==days_of_campaign[i].year) & (pms_combined.index.month==days_of_campaign[i].month) & (pms_combined.index.day==days_of_campaign[i].day)]
    data_df.index.name = ''
    data_df = repair_time(data_df)
    data_df = data_df[['Time', 'N', 'CWC', 'ED', 'MVD', 'datetime']+column_names(pms_combined_bins)[0]]    
    directory = directory
    probe = 'PMS combined'
    platform = 'Polar5'
    t_start = data_df.index[0]
    bin_df = pms_combined_bins
    campaign = 'AFLUX'
    flight = None
    Time_start = data_df.datetime.iloc[0]
    t_start = data_df.index[0]
    save_icar_combined_aflux(data_df, bin_df, campaign, probe, platform, flight, directory)
    
#end: create NASA AMES files
#############################################################################



