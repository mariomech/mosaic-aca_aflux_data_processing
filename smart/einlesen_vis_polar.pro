pro einlesen_vis_polar,filename,hh,mm,ss,spec,itime

data=read_ascii(filename)
time=data.(0)(0,*)
hh=data.(0)[1,*]
mm=data.(0)[2,*]
ss=data.(0)[3,*]
spec=data.(0)[4:1027,*]
itime=data.(0)[1028,*]

end