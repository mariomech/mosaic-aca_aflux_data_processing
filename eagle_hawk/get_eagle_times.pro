;***************************************************************************************************************************************************************************
;Calculates the times vector (in decimal format) correspondent to an Eagle or Hawk measurement
;
;INPUTS:
;     inp_file = String containing the path of the measurement to be analysed
;
;OUTPUTS:
;     times = Array containing the start times of every frame acquired by Eagle or Hawk during one scanner
;***************************************************************************************************************************************************************************

FUNCTION get_eagle_times,inp_file

    read_eagle,inp_file,img,xs,ys,nwl,type,offset, mapinfo, wl, interleave, fodis, himg, tint, darkstart, date, tstart, tstop, fps, /info
;       read_eagle,hawk_files(f), img_hawk, xs, ys, nwl_hawk, type, offset, mapinfo, hawk_wl, interleave, fodis,himg, tint, darkstart,date, tstart, tstop, fps

    t_start=strsplit(tstart,':',/EXTRACT)
    t_start=double(t_start(1))+double(t_start(2))/60.+double(t_start(3))/3600.

    t_stop=strsplit(tstop,':',/EXTRACT)
    t_stop=double(t_stop(1))+double(t_stop(2))/60. + double(t_stop(3))/3600.

    time_step=(t_stop - t_start)/xs

    times=t_start+dindgen(xs)*time_step

    times= times(0:darkstart-1)

    RETURN,double(times)
END

;The elements stored in tiems corresponds to the starting time of every pixel (therefore, the last element of times is not the final measurement time, but the
;pixel starting time. The final measurement time is stored in tstop and coems given by the header file.