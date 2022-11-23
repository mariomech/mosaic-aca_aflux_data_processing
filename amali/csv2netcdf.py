

import numpy as np
import pandas as pd
import xarray as xr
import datetime
import ac3airborne


"""
Script to transfer .csv files of cloud top height to netcdf files
Original files: one for each campaign
Output files: one for each research flight (from github flight-phase-separation) 

attributes based on /srv/www/atmos/ac3/acloud/p5/amsr2_sea_ice_concentration/ files (on server moon)

file names: cloud_top_height_campaign_aircraftName_YYYYMMDD_flightNumber.nc
"""


if __name__ == '__main__':
    
    # select a campaign
    campaign_path = 'mosaic'  # ACLOUD or AFLUX or mosaic
    campaign = 'MOSAiC-ACA'
    
    # select paths
    path = '/home/nrisse/uniWork/cloudtop/'
    
    #%% flight segments of the campaign
    flights = {}
    for flight_id, flight in ac3airborne.get_flight_segments()['P5'].items():
        if flight['mission'] == campaign:
            flights[flight_id] = flight
    
    #%% read csv file as pandas dataframe and prepare columns
    file = path+'cloudtop_1s_resolution_'+campaign_path+'.csv'
    df_cth = pd.read_csv(file, sep=',', dtype={'datetime_seconds_since_1970-01-01': 'int32',
                                               'datetime_string': 'str',
                                               'cloudtopheight_m': 'float64',
                                               'longitude_decimaldegree': 'float64',
                                               'latitude_decimaldegree': 'float64'})
    df_cth['time'] = pd.to_datetime(df_cth['datetime_string'], format='%Y-%m-%d %H:%M:%S')
    df_cth = df_cth.set_index('time')
    df_cth = df_cth.drop(columns=['datetime_seconds_since_1970-01-01', 'datetime_string'])
    df_cth = df_cth.rename(columns={'longitude_decimaldegree': 'lon', 'latitude_decimaldegree': 'lat', 'cloudtopheight_m': 'cloud_top_height'})
        
    #%% convert to xarray
    ds_cth = df_cth.to_xarray()
    
    #%% define layers if multilayer clouds
    # times, where clouds are multilayered
    # return_index: indices that result in the unique array
    # return_inverse: indices of unique array in original array
    # return_counts: number of times each unique item appears in original array
    # cnt also contains -999 and -1, therefore cnt != n_cloud_layer
    time_ml, ix_ml, ix_or, cnt = np.unique(ds_cth.time.values, return_index=True, return_inverse=True, return_counts=True)
    
    max_count = 10  # maximum number of cloud layers
    
    ds_cth_ml = xr.Dataset()
    ds_cth_ml.coords['time'] = time_ml
    ds_cth_ml.coords['cloud_layer'] = np.arange(1, max_count+1, 1, dtype='int8')
    #ds_cth_ml['lon'] = (('time'), ds_cth.lon.isel(time=ix_ml).values)
    #ds_cth_ml['lat'] = (('time'), ds_cth.lat.isel(time=ix_ml).values)
    ds_cth_ml['n_cloud_layer'] = (('time'), np.zeros(shape=len(ds_cth_ml.time), dtype='int8'))
    ds_cth_ml['cloud_top_height'] = (('time', 'cloud_layer'), np.full(shape=(len(ds_cth_ml.time), len(ds_cth_ml.cloud_layer)), fill_value=np.nan))
    ds_cth_ml['cloud_mask'] = (('time'), np.full(shape=len(ds_cth_ml.time), fill_value=-1, dtype='int8'))
    
    #%% loop over every index in multilayer cloud data (time x cloud_layer)
    # comment by Birte on the flags in -csv files:
    # altitude -1: there is some thin cloud or haze. The optical depth of the 
    # column is between 1 and 0.3 (certainty of optical depth here 
    # approximately +/- 100 %) maybe no cloud top was detected, though it is 
    # not necessarily cloud-free. altitude -999: there are no clouds (optical 
    # depth over the entire column below 0.3)
    # summary: in cloud_top_height: -999: no cloud, -1: thin cloud or fog, float: thick cloud
    
    for i, time in enumerate(ds_cth_ml.time.values):
        
        # get list of values at this time (-999, -1, cloud top height)
        values = ds_cth.cloud_top_height.values[ix_or == i]
        
        # fill cloud_mask
        if -999. in values and not -1. in values:
            ds_cth_ml['cloud_mask'][i] = 1
        elif not -999. in values and -1. in values:
            ds_cth_ml['cloud_mask'][i] = 2
        elif not -999. in values and not -1. in values:
            ds_cth_ml['cloud_mask'][i] = 3
        else:
            print('Warning, no cloud_mask from optical depth observation can be assigned')
        
        # fill cloud_top_height
        cloud_top_height_sorted = np.sort(values[values >= 0])[::-1]
        ds_cth_ml['n_cloud_layer'][i] = len(cloud_top_height_sorted)
        ds_cth_ml['cloud_top_height'][i, 0:len(cloud_top_height_sorted)] = cloud_top_height_sorted
        
        if i % 1000 == 0:
            print('{} %'.format(i/len(ds_cth_ml.time.values)*100))
    
    # change datatypes again
    ds_cth_ml['n_cloud_layer'] = ds_cth_ml['n_cloud_layer'].astype('int8')
    ds_cth_ml['cloud_mask'] = ds_cth_ml['cloud_mask'].astype('int8')

    #%% include non-working times
    # define time step of 1 second for each flight
    times_regular = pd.DatetimeIndex([])
    for flight_id, flight in flights.items():
        
        times_regular_flight = pd.date_range(flight['takeoff'], flight['landing'], freq='1S')
        times_regular = np.append(times_regular, times_regular_flight)
    
    ds_cth_ml_reg = xr.Dataset()
    ds_cth_ml_reg.coords['time'] = times_regular
    ds_cth_ml_reg = xr.merge([ds_cth_ml_reg, ds_cth_ml], join='left')  # attributes are already contained
    
    # define flag for non-working times and working times
    ds_cth_ml_reg['instrument_status'] = (ds_cth_ml_reg['cloud_mask'] > 0).astype('int8')
    
    assert len(ds_cth_ml.time) == np.sum(ds_cth_ml_reg.instrument_status)
    
    #%% add lat, lon and gps data by reading all data of the campaign and joining them on the timestamp
    # these are the same lat and lon as in the .csv file
    gps_var = ['alt', 'lat', 'lon']
    i = 0
    for flight_id, flight in flights.items():
        
        # read gps data (processed data from dship)
        file = '/media/nrisse/data/university/master/pwork/data/gps_ins/'+flight['mission'].lower()+'/'+flight['mission']+'_polar5_'+flight['date'].strftime('%Y%m%d')+'_'+flight['name']+'.nc'
        if i == 0:
            ds_gps = xr.open_dataset(file)[gps_var]
        else:
            ds_gps = xr.concat([ds_gps, xr.open_dataset(file)[gps_var]], dim='time')
        i += 1
    
    ds_cth_ml_reg = xr.merge([ds_cth_ml_reg, ds_gps], join='left')  # attributes are already contained
    
    #import matplotlib.pyplot as plt
    #fig = plt.figure()
    #plt.plot(ds_cth_ml_reg.time, ds_cth_ml_reg.lon)
    #plt.plot(ds_gps.time, ds_gps.lon)

    #%% add attributes
    # global attributes
    ds_cth_ml_reg.attrs = dict(description='Cloud top height along flight path based on AMALi observations',
                        contact='birte.kulla@uni-koeln.de, mario.mech@uni-koeln.de',
                        institution='Alfred Wegener Institute - Research Unit Potsdam, University of Cologne',
                        instruments='AMALi',
                        version='v0.1',
                        author='Birte Kulla birte.kulla@uni-koeln.de',
                        #source='',
                        title='Cloud top height along flight path',
                        #history=''
                        )
    
    # variable attributes
    ds_cth_ml_reg.time.encoding = dict(units='seconds since 1970-01-01', calendar='standard')
    ds_cth_ml_reg['time'].attrs = dict(standard_name='time', long_name='time in seconds since epoch', axis='T')#, units='Seconds since 1970-01-01 00:00:00', calendar='standard')
    
    ds_cth_ml_reg['cloud_layer'].attrs = dict(standard_name='cloud_layer', long_name='cloud layer', description='cloud layer counted from instrument towards surface (1 = highest cloud layer)')
    ds_cth_ml_reg['n_cloud_layer'].attrs = dict(standard_name='n_cloud_layer', long_name='number of cloud layers', description='number of cloud layers (> 1 for multilayer clouds)')

    ds_cth_ml_reg['lon'].attrs = dict(standard_name='longitude', long_name='WGS84 datum/longitude', units='degrees_east', axis='X')
    ds_cth_ml_reg['lat'].attrs = dict(standard_name='latitude', long_name='WGS84 datum/latitude', units='degrees_north', axis='Y')
    ds_cth_ml_reg['lon'].encoding = dict(_FillValue='NaN')
    ds_cth_ml_reg['lat'].encoding = dict(_FillValue='NaN')
    ds_cth_ml_reg['alt'].encoding = dict(_FillValue='NaN')

    ds_cth_ml_reg['cloud_top_height'].attrs = dict(standard_name='cloud_top_height', long_name='cloud top height', units= 'm', description='cloud top height derived from AMALi instrument for clouds within thick_cloud class', comment='cloud top most likely from liquid layer')
    
    ds_cth_ml_reg['cloud_mask'].attrs = dict(flag_masks='1, 2, 3',
                                      flag_meanings='no_cloud thin_cloud_or_haze thick_cloud',
                                      description='no_cloud: optical depth of column below 0.3, ' +\
                                                  'thin_cloud_or_haze: optical depth of column between 0.3 and 1 (uncertainty +/- 100 %), ' +\
                                                  'thick_cloud: optical depth greater than 1'
                                      )
    ds_cth_ml_reg['instrument_status'].attrs = dict(flag_masks='0, 1',
                                                    flag_meanings='off on',
                                                    description='Status of AMALi instrument')
        
    #%% loop over each flight and save as netcdf
    for flight_id, flight in flights.items():
        
        print(flight['name'])
        print(flight['date'].strftime('%Y%m%d'))
        print(flight['mission'])
        print(flight['takeoff'])
        print(flight['landing'])
        
        # reduce data to flight time
        ds_cth_ml_reg_rf = ds_cth_ml_reg.sel(time=(ds_cth_ml_reg.time >= np.datetime64(flight['takeoff'])) & (ds_cth_ml_reg.time < np.datetime64(flight['landing'])))
        
        if np.sum(ds_cth_ml_reg_rf['instrument_status']) == 0: print('skip'); continue
        
        # save as netcdf
        outfile = path+'cloud_top_height/'+flight['mission'].lower()+'/cloud_top_height_'+flight['mission']+'_polar5_'+flight['date'].strftime('%Y%m%d')+'_'+flight['name']+'.nc'
        ds_cth_ml_reg_rf.to_netcdf(outfile)
