"""
Read MiRAC-A data and convert to flight files and make the data ready for 
upload on pangaea

For MOSAiC-ACA, a flag is introduced, which marks time when the radar
did not function properly. These times are defined in the very beginning
of the processing and are still on a the raw data's time stamp
"""


import numpy as np
import datetime
import ac3airborne
import xarray as xr
import yaml
import os


if __name__ == '__main__':
        
    # get flights
    meta_all = ac3airborne.get_flight_segments()
    campaigns = ['ACLOUD', 'AFLUX', 'MOSAiC-ACA', 'HALO-AC3']
    meta = {}
    for campaign in campaigns:
        meta.update(meta_all[campaign]['P5'])
    
    # get dictionary of level 3 files for every research flight
    file = os.environ['PATH_PHD']+'/projects/mirac_processing/settings_yaml/files_lev_3.yaml'
    #file = '/home/nrisse/igmk_home/WHK/radar_processing/data/files/files_lev_3.yaml'
    with open(file, 'r') as f:
        file_dct = yaml.safe_load(f)
    
    # get dictionary of times, when radar did not function
    file = os.environ['PATH_PHD']+'/projects/mirac_processing/settings_yaml/measurement_error_times.yaml'
    #file = '/home/nrisse/igmk_home/WHK/radar_processing/data/measurement_error/measurement_error_times.yaml'
    with open(file, 'r') as f:
        err_dct = yaml.safe_load(f)
        
    path_in = os.environ['PATH_SEC']+'/radar_processing/'
    
    #%%
    for flight_id, files in file_dct.items():
        
        print(flight_id)
        
        flight = meta[flight_id]

        # read mirac-a of that flight
        path_in_long = path_in + flight['mission'].lower() + '/mirac_radar/lev_3/' + flight['date'].strftime('%Y/%m/%d/')
        
        if len(files) == 1:
            
            file = files[0]
            ds_mca = xr.open_dataset(path_in_long+file)
            
        elif len(files) > 1:
                        
            # merge files along time dimension
            for i, file in enumerate(files):
                
                if i == 0:
                    ds_mca = xr.open_dataset(path_in_long+file)
                    
                else:
                    ds_mca = xr.concat([ds_mca, xr.open_dataset(path_in_long+file)], dim='time')
        
        #%% change of variables
        #print('Variables:', '\n'.join(sorted(list(ds_mca))))
        #print('Coordinates:', list(ds_mca.coords))
        #print('Dimensions:', list(ds_mca.dims))
        
        # 1: time 
        # remove duplicates (TBs can differ although time step is the same, here just take the 'first' value in the array)
        t_dup, ix = np.unique(ds_mca.time, return_index=True)
        ds_mca = ds_mca.isel(time=ix)
        
        # reduce to flight time using start and landing from flight-phase-separation
        ds_mca = ds_mca.sel(time=(ds_mca.time > np.datetime64(flight['takeoff'])) & (ds_mca.time <= np.datetime64(flight['landing'])))
        
        # 2: variables to be dropped
        drop_vars = ['freq_sb',
                    'cal_mom',
                    'seq_avg',
                    'seq_int_time',
                    'dopp_len',
                    'n_avg',
                    'range_offsets',
                    #'Ze_raw',
                    #'ze',
                    'vm_raw',
                    'v_sigma',
                    'v_skew',
                    'lwp',
                    #'tb',
                    #'Ze_flag',
                    'snr_filter_threshold',
                    'subsurface_reflection_filter_full_width_time',
                    'subsurface_reflection_filter_full_width_range',
                    'subsurface_reflection_filter_min_frac_finite',
                    'subsurface_reflection_filter_min_dist_to_surface',
                    'subsurface_reflection_filter_max_dist_to_surface',
                    'speckle_filter_min_frac_finite',
                    'speckle_filter_full_width_time',
                    'speckle_filter_full_width_range',
                    'platform_name',
                    #'lon_platform',
                    #'lat_platform',
                    #'alt_platform',
                    'platform_head_angle',
                    'platform_pitch_angle',
                    'platform_roll_angle',
                    'sensor_name',
                    'lon_sensor',
                    'lat_sensor',
                    'alt_sensor',
                    'v_sensor_x',
                    'v_sensor_y',
                    'v_sensor_z',
                    'v_sensor_r',
                    'v_sensor',
                    'sensor_course',
                    'sensor_azimuth_angle',
                    'sensor_zenith_angle',
                    'sensor_view_angle',
                    'distance_covered_by_sensor',
                    'effective_vertical_resolution',
                    'secs1970_target',
                    'time_diff_target',
                    'lon',
                    'lat',
                    'range',
                    'horizontal_distance_target',
                    'position_sensor_name',
                    'attitude_sensor_name',
                    'sensor_view_angle_wrt_attitude_sensor',
                    'sensor_azimuth_angle_wrt_attitude_sensor',
                    'time_offset_sensor',
                    'time_offset_position_sensor',
                    'time_offset_attitude_sensor',
                    'beam_fwhm',
                    'wind_averaging_weighted',
                    ]
        
        ds_mca = ds_mca.drop(drop_vars)
        
        ds_mca = ds_mca.rename({'ze': 'Ze',
                                'Ze_raw': 'Ze_unfiltered',
                                'alt_platform': 'alt',
                                'lon_platform': 'lon',
                                'lat_platform': 'lat',
                                'alt': 'height',
                                })
                
        # 3: fill value from nan to zero
        ds_mca['Ze_flag'] = ds_mca['Ze_flag'].where(ds_mca['Ze_flag'] > 0, 0).astype('uint8')
        
        #%% add a flag for times, when radar did not function (MOSAiC-ACA)
        # 0: radar is not working
        # 1: radar is working (default)
        # incomplete radar observations at the left edge (in the past)
        # should be set to nan as well. For this, a 30 second window is 
        # applied to all flights, since no other information is available on
        # when a np.nan was shifted (only for Ze values, times are in time_target variable)
        if flight['mission'] == 'MOSAiC-ACA':
            
            ds_mca['radar_status'] = (('time'), np.ones(len(ds_mca.time), dtype='uint8'))
            ds_mca['radar_status'].attrs = dict(standard_name='radar_status', long_name='instrument status', flag_masks='0 1', 
                                                flag_meanings='radar_not_working radar_working', comment='Radar reflectivity values during status 0 are replaced by missing values. The passive channel is not affected.')
            
            for t0, t1 in err_dct[flight_id]['times']:
                                
                t0 = np.datetime64(t0 - datetime.timedelta(seconds=30))
                t1 = np.datetime64(t1 + datetime.timedelta(seconds=0))
                
                ds_mca['radar_status'] -= ds_mca['radar_status'].where(
                    (ds_mca.time >= t0) & (ds_mca.time <= t1), 0)
            
            # set ze to nan within time interval
            ds_mca['Ze'] = ds_mca['Ze'].where(ds_mca['radar_status'] == 1)
                
        #%% change of attributes
        # global attributes
        #print(ds_mca.attrs)
        global_attrs = dict(title='MiRAC-A observations onboard Polar 5 during %s'%flight['mission'],
                            institution='Institute for Geophysics and Meteorology (IGM), University of Cologne',
                            source='airborne observation',
                            history='measured onboard Polar 5 during ' + flight['mission'] + ' campaign; processed, quality-checked, and reformatted by University of Cologne',
                            references='https://doi.org/10.5194/amt-12-5019-2019',
                            comment='the radar system and the 89 GHz channel were inclined by 25 degrees. However, only Ze is already transformed to nadir.',
                            convention='CF-1.8',
                            featureType='trajectory',
                            mission=flight['mission'],
                            platform='Polar 5',
                            flight_id=flight['name'],
                            instrument='MiRAC-A: Microwave Radar/radiometer for Arctic Clouds (active)',
                            author='Nils Risse',
                            #contact='mario.mech@uni-koeln.de, l.kliesch@uni-koeln.de, n.risse@uni-koeln.de',
                            contact='mario.mech@uni-koeln.de, n.risse@uni-koeln.de',
                            created=datetime.datetime.now().strftime('%Y-%m-%d'),
                            )
        ds_mca.attrs = global_attrs
        
        # variable attributes
        # 1: time
        time_attrs = dict(standard_name='time', long_name='time in seconds since epoch')
        ds_mca['time'].attrs = time_attrs
        ds_mca['time'].encoding = dict(units='seconds since 2017-01-01', calendar='standard')
        #ds_mca['time'].encoding = dict(units='seconds since 1970-01-01', calendar='standard')
    
        # 2: height
        height_attrs = dict(standard_name='height', long_name='radar bin height', units='m', comment='height of radar bins at lower boundary with resolution of 5 m')
        ds_mca['height'].attrs = height_attrs
        
        # 3: lon
        ds_mca['lon'].attrs = dict(standard_name='longitude', long_name='WGS84 datum/longitude', units='degrees_east')
        
        # 4: lat
        ds_mca['lat'].attrs = dict(standard_name='latitude', long_name='WGS84 datum/latitude', units='degrees_north')
        
        # 5: altitude
        ds_mca['alt'].attrs = dict(standard_name='altitude', long_name='aircraft flight altitude above mean sea level', units='m')
        
        # 6: Ze_unfiltered
        if flight['mission'] == 'ACLOUD':
            
            comment = 'original measurements corrected by +3 dB according to radar-manufacturer note '+\
                      '(RPG-Radiometer Physics GmbH, 2018-08-30), unfiltered radar reflectivity '+\
                      'interpolated to regular height grid and transformed to quasi-nadir observations'
        else:
            
            comment = 'unfiltered radar reflectivity interpolated to regular height grid and transformed to quasi-nadir observations'
        
        Ze_unfiltered_attrs = dict(standard_name='equivalent_reflectivity_factor', long_name='equivalent radar reflectivity factor', 
                                   units='mm^6/m^3', 
                                   comment=comment)
        ds_mca['Ze_unfiltered'].attrs = Ze_unfiltered_attrs
        
        # 7: Ze
        if flight['mission'] == 'ACLOUD':
            
            comment = 'original measurements corrected by +3 dB according to radar-manufacturer note '+\
                      '(RPG-Radiometer Physics GmbH, 2018-08-30), radar reflectivity '+\
                      'interpolated to regular height grid, transformed to quasi-nadir observations, and filtered for disturbances (see Ze_flag)'
        else:
            
            comment = 'radar reflectivity interpolated to regular height grid, transformed to quasi-nadir observations, and filtered for disturbances (see Ze_flag)'
        
        Ze_attrs = dict(standard_name='equivalent_reflectivity_factor', long_name='equivalent radar reflectivity factor', 
                                   units='mm^6/m^3', 
                                   comment=comment)
        ds_mca['Ze'].attrs = Ze_attrs

        # 8: Ze_flag
        Ze_flag_attrs = dict(standard_name='Ze_flag', long_name='flag for equivalent radar reflectivity factor', 
                             flag_masks='1 2 4 8', 
                             flag_meanings='defective_gate_filter snr_filter speckle_filter subsurface_reflection_filter',
                             description='mask for filtered radar reflectivity bins during processing')
        ds_mca['Ze_flag'].attrs = Ze_flag_attrs
        
        # 9: tb
        tb_attrs = dict(standard_name='brightness_temperature', long_name='brightness temperature', units='K', description='89 GHz brightness temperature along slanted path',
                        comment='During low-level flights over surfaces with a high backscattering coefficient such as sea ice, the 89 GHz channel might be affected by noise transmitted by the cloud radar.')
        ds_mca['tb'].attrs = tb_attrs
        
        #%% check for errorneous values
        ds_mca['tb'] = ds_mca['tb'].where(ds_mca['tb'] <= 400)
        assert ds_mca.tb.min(['time']) > 100
        assert ds_mca.tb.max(['time']) < 400
        
        #%% check if time is consecutive
        assert np.sum((ds_mca.time.values[1:] - ds_mca.time.values[:-1])/np.timedelta64(1000000000) > 0)
        
        #%% check if all variables (and only these) are inside
        if flight['mission'] == 'MOSAiC-ACA':
            assert set(ds_mca.variables) == {'time', 'tb', 'Ze_unfiltered', 'Ze', 'Ze_flag', 'lon', 'lat', 'height', 'alt', 'radar_status'}
        else:
            assert set(ds_mca.variables) == {'time', 'tb', 'Ze_unfiltered', 'Ze', 'Ze_flag', 'lon', 'lat', 'height', 'alt'}
        
        #%% save file 
        ds_mca.to_netcdf(path_in+flight['mission'].lower()+'/mirac_radar/compact/'+flight['mission']+'_P5_MiRAC-A_'+flight['date'].strftime('%Y%m%d')+'_'+flight['name']+'.nc')
