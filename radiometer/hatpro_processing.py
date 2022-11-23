

import numpy as np
import datetime
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import ac3airborne
import xarray as xr


"""
Read HATPRO data and convert to a format matching CF conventions
Additional cleaning of the dataset is done, see the following changes:

Change of variables/coordinates
    - time in seconds since 1970-01-01 (additionally not unlimited dimension anymore)
    - removal of azimuth angle, elevation angle, rain flag (not needed for fixed downward view)
    - removal of integration time per sample, time reference
    - rename of number_frequencies to channel
    - rename of frequencies to frequency
    - rename of TBs to tb
    - integration time per sample is put into attributes of tb

Other changes:
    - removal of duplicate times (keep first)
    - reduction to flight time
    - global and variable attributes are adapted (e.g. time reference is attribute of time coordinate)
"""


if __name__ == '__main__':
    
    # set paths
    path_base = '/data/obs/campaigns/'
    
    # get flights
    cat = ac3airborne.get_intake_catalog()
    meta = ac3airborne.get_flight_segments()
    
    mission = 'HALO-AC3'
    platform = 'P5'
    
    meta = meta[mission][platform]
    
    #%%
    for flight_id, flight in meta.items():

        if flight_id == 'MOSAiC-ACA_P5_RF03':
            continue  # no hatpro measurements during MOSAiC-ACA RF03
        
        print(flight_id)
        
        # read hatpro tb of that flight
        platform_dir = ''
        if flight['mission'] == 'HALO-AC3':
            platform_dir = '/'+platform.lower()
            
        file = path_base + flight['mission'].lower() + platform_dir + '/hatpro/' + flight['date'].strftime('%Y/%m/%d/%y%m%d.BRT.NC')
        ds_hat = xr.open_dataset(file)
        
        #%% change of variables
        print('Variables:', list(ds_hat))
        print('Coordinates:', list(ds_hat.coords))
        print('Dimensions:', list(ds_hat.dims))
        
        # 1: time 
        # remove duplicates (TBs can differ although time step is the same, here just take the 'first' value in the array)
        t_dup, ix = np.unique(ds_hat.time, return_index=True)
        ds_hat = ds_hat.isel(time=ix)
        
        # reduce to flight time using start and landing from flight-phase-separation
        ds_hat = ds_hat.sel(time=(ds_hat.time > np.datetime64(flight['takeoff'])) & (ds_hat.time <= np.datetime64(flight['landing'])))
        
        # 2: time_reference: UTC or local time
        # print(ds_hat.time_reference)
        # warning: this says local time, which means we need to convert to UTC?
        # check if it is really local time by looking at map of tb together with gps_ins data
        
        # read gps data
        file_gps = path_base + flight['mission'].lower() + platform_dir + '/gps_ins/' +\
                   flight['date'].strftime('%Y/%m/%d/') + flight['mission'] + \
                   '_polar5_gps_ins_' + flight['date'].strftime('%Y%m%d') + '_' + \
                   flight['name']+'.nc'
        ds_gps = xr.open_dataset(file_gps)
        ds_gps = ds_gps.reindex(time=ds_hat.time)
        
        # assign to dataset
        ds_hat['lon'] = (('time'), ds_gps.lon.values)
        ds_hat['lat'] = (('time'), ds_gps.lat.values)
        
        #fig, ax = plt.subplots(1, 1, figsize=(4, 4), subplot_kw=dict(projection=ccrs.NorthPolarStereo(central_longitude=7.5)))
        #ax.coastlines()
        #ax.scatter(lon, lat, c=ds_hat.TBs.isel(number_frequencies=7), cmap='jet',
        #           transform=ccrs.PlateCarree())
        
        # comment: check shows that it is UTC, therefore remove the time_reference variable
        ds_hat = ds_hat.drop('time_reference')
        
        # 3: integration_time_per_sample
        # put in global attributes instead!
        assert ds_hat.integration_time_per_sample == np.timedelta64(1000000000)
        ds_hat = ds_hat.drop('integration_time_per_sample')
        
        # 4: frequencies
        #print(ds_hat.frequencies)
        
        # 5: rain_flag
        # this is probably always 0, therefore remove it
        #assert np.sum(ds_hat.rain_flag) == 0
        ds_hat = ds_hat.drop('rain_flag')
        
        # 6: elevation angle
        assert np.sum((ds_hat.elevation_angle < 89) | (ds_hat.elevation_angle > 91)) == 0 
        ds_hat = ds_hat.drop('elevation_angle')
        
        # 7: azimuth angle
        assert np.sum((ds_hat.azimuth_angle < -1) | (ds_hat.azimuth_angle > 1)) == 0 
        ds_hat = ds_hat.drop('azimuth_angle')
        
        # 8: frequencies
        print(ds_hat.frequencies)
        ds_hat = ds_hat.rename({'frequencies': 'frequency'})    
            
        # 9: TBs
        ds_hat = ds_hat.rename({'TBs': 'tb'})   
        
        # 10: number_frequencies
        ds_hat = ds_hat.rename({'number_frequencies': 'channel'})
        
        # create a channel variable
        ds_hat.coords['channel'] = np.arange(0, len(ds_hat.frequency), dtype='int')
        
        # remove unlimited dimensions
        ds_hat.encoding['unlimited_dims'] = dict()
        
        #%% change of attributes
        # global attributes
        print(ds_hat.attrs)    
        
        global_attrs = dict(institution='Institute for Geophysics and Meteorology (IGM), University of Cologne',
                            source='airborne observation',
                            references='https://doi.org/10.1016/j.atmosres.2004.12.005',
                            author='Nils Risse',
                            convention='CF-1.8',
                            featureType='trajectory',
                            mission=flight['mission'],
                            platform='Polar 5',
                            flight_id=flight['name'],
                            title='HATPRO brightness temperature',
                            instrument='HATPRO: Humidity and Temperature Profiler',
                            history='measured onboard Polar 5 during ' + flight['mission'] + ' campaign; processed, quality-checked, and reformatted by University of Cologne',
                            contact='mario.mech@uni-koeln.de, n.risse@uni-koeln.de',
                            created=datetime.datetime.now().strftime('%Y-%m-%d'),
                            )
        ds_hat.attrs = global_attrs
    
        # variable attributes
        # 1: time
        time_attrs = dict(standard_name='time', long_name='time in seconds since epoch')
        ds_hat['time'].attrs = time_attrs
        
        if flight['mission'] == 'HALO-AC3':
            units = 'seconds since 2017-01-01'
        else:
            units = 'seconds since 1970-01-01'
        
        ds_hat['time'].encoding = dict(units=units, calendar='standard')
    
        # 2: channel
        channel_attrs = dict(standard_name='channel', long_name='HATPRO radiometer channel number')
        ds_hat['channel'].attrs = channel_attrs
        
        # 3: frequency
        frequency_attrs = dict(standard_name='frequency', long_name='HATPRO radiometer channel center frequency', units='GHz')
        ds_hat['frequency'].attrs = frequency_attrs
        
        # 4: tb
        tb_attrs = dict(standard_name='brightness_temperature', long_name='HATPRO brightness temperature', units='K', description='HATPRO brightness temperature measured with 1 second integration time')
        ds_hat['tb'].attrs = tb_attrs
        
        # 5: lon
        lon_attrs = dict(standard_name='longitude', long_name='WGS84 datum/longitude', units='degrees_east')
        ds_hat['lon'].attrs = lon_attrs
        
        # 6: lat
        lat_attrs = dict(standard_name='latitude', long_name='WGS84 datum/latitude', units='degrees_north')
        ds_hat['lat'].attrs = lat_attrs
        
        #%% check for errorneous values
        assert ds_hat.tb.min(['channel', 'time']) > 100
        assert ds_hat.tb.max(['channel', 'time']) < 310
        assert np.sum(np.isnan(ds_hat.tb)) == 0
    
        #%% check if time is consecutive
        assert np.sum((ds_hat.time.values[1:] - ds_hat.time.values[:-1])/np.timedelta64(1000000000) > 0)

        #%% check if all variables (and only these) are inside
        assert set(list(ds_hat.variables)) == {'frequency', 'time', 'tb', 'channel', 'lon', 'lat'}
        
        #%% save file 
        ds_hat.to_netcdf('/net/secaire/nrisse/data_preparation/ac3/' + flight['mission'].lower() + '/p5/hatpro/' + flight['mission'] + '_P5_HATPRO_' + flight['date'].strftime('%Y%m%d') + '_' + flight['name'] + '.nc')
        