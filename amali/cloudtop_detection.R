---
title: "AMALi cloud top retrieval"
author: "Birte Solveig Kulla"
output:
  html_document:
    df_print: paged
    
---
# now reads in ncfile



# rmls blabla
```{r general settings}
rm(list=ls())
gc()

#####################
campaign = "AFLUX"
#campaign = "MOSAiC_ACA"
#####################

Sys.setenv(LANGUAGE="en")
Sys.setlocale("LC_TIME", "English")
Sys.setenv(TZ='UTC')

library(dplyr)
library("R.matlab")
library(data.table)
library(ncdf4)
library(ggplot2)
library(roll)
```
#what do you want to look at? sets which chunks are to be run, which data is supposed to be loaded

```{r set variables}
campaign <- "MOSAIC_ACA" #or "AFLUX"


nameOutput <- "MOSAIC_ACA"


```



#read lidar Now reading the lidar data into R set data source for lidar data
```{r data source lidar, eval=loadnewInput}
if(campaign == "MOSAIC_ACA"){
  Pfad <- '/atm_meas/polar_5_6/amali/data/nadir_processed/cloud/2020/' #????
  Dateiliste <- list.files(Pfad, pattern="mosaic_aca_*", recursive=F)
}else if(campaign == "AFLUX"){
  Pfad <- '/atm_meas/polar_5_6/amali/data/nadir_processed/cloud/2019/' #????
  Dateiliste <- list.files(Pfad, pattern="AFLUX_*", recursive=F)
  #print("AFLUX-Pfad fehlt noch")
}else{print("which campaign?")
  break()
  }

Dateiliste<- Dateiliste[grepl(".nc", Dateiliste, fixed=TRUE)]
print(Dateiliste)

```
#read ncfile and turn it into a nice data table
```{r}
source('helperfunctions.R')
for(i in 1:length(Dateiliste)){
  
d <- readAmalidataStep1(paste(Pfad,Dateiliste[i], sep=""))
  
  if (exists("dataset")==F){
    print(i)
    dataset=d$TIMEDIST
    datasettime <- d$TIME # herafter datasettime is all data with one value per timestamp
  }else{
    print(i)
    dataset=rbind(dataset,d$TIMEDIST)
    datasettime <- rbind(datasettime,d$TIME)
  }
  rm(d)
  closeAllConnections()
  
}

dataset[,'datetime_fac':= as.integer(datetime)]
datasettime$datetime_fac <- as.integer(datasettime$datetime)
setkey(dataset,datetime_fac)
setkey(datasettime,datetime_fac)


dataset[,'mogelID' := paste(dataset$datetime_fac, as.character(dataset$dist))]
dataset <- dataset[!duplicated(mogelID)]

rm(Dateiliste,i)
invisible(gc())
```
#geometric Correction
##GPS

# find GPS data 
```{r list gps data, eval=loadnewInput}
if(campaign=="MOSAIC_ACA"){
 Dateiliste <- list.files('AFLUX_gps_folder') 
}

if(campaign=="AFLUX"){
 Dateiliste <- list.files('MOSAiC_ACA_gps_folder') 
  
}

print(Dateiliste)
```
actually reading the GPS data
```{r read GPS, eval=loadnewInput}
if (exists("GPS")==T){rm(GPS)}

for(i in c(1:length(Dateiliste))){
   if(campaign=="MOSAIC_ACA"){
  GPS_temp <- readGPS(paste('AFLUX_gps_folder', Dateiliste[i], sep=""))
 }
 if(campaign=="AFLUX"){
  GPS_temp <- readGPS(paste('MOSAiC_ACA_gps_folder', Dateiliste[i], sep=""))
 }
 if (exists("GPS")==F){
   print(i)
   GPS <- GPS_temp
 }else{
   print(i)
   GPS <- rbind(GPS,GPS_temp)
 }
 rm(GPS_temp)
}
GPS <- as.data.table(GPS)

GPS$Lon <- NULL
GPS$Lat <- NULL
GPS$`Lon dir` <- NULL
GPS$`Lat dir` <- NULL

setkey(GPS,datetime_fac)

```
for some reason the datasets are not properly joined if I use the date as a key so I produce a factor in both datasets
```{r merge GPS to dataset, eval=loadnewInput}

dataset <- merge(dataset, GPS, all=FALSE, by ='datetime_fac')

datasettime <- merge(datasettime, GPS, all=FALSE, by ='datetime_fac')

rm(GPS,Dateiliste,  i, readGPS)
invisible(gc())
```


##INS
# the INS data also comes from dship. everything similar to GPS

# find and list the INS data
```{r find INSdata, eval=loadnewInput}
if(campaign=='MOSAIC_ACA'){
  Dateiliste <- list.files('MOSAiC_ACA_ins_folder')
}
if(campaign=='AFLUX'){
  Dateiliste <- list.files('AFLUX_ins_folder')
}

print(Dateiliste)
```
```{r read ins, eval=loadnewInput}
for(i in c(1:length(Dateiliste))){
if(campaign=='MOSAIC_ACA'){
    INS_temp <- readINS(paste('MOSAiC_ACA_ins_folder', Dateiliste[i], sep=""))
  
}
  if(campaign=='AFLUX'){
    INS_temp <- readINS(paste('AFLUX_ins_folder', Dateiliste[i], sep=""))
  
}
  
  if (exists("INS")==F){
    print(i)
    INS <- INS_temp
  }else{
    print(i)
    INS <- rbind(INS,INS_temp)
  }
  rm(INS_temp)
  #INS$Lon_dezdeg <- NULL
}

INS <- as.data.table(INS)
```
```{r merge ins und dataset, eval=loadnewInput}
dataset <- merge(dataset, INS,all = FALSE, by ='datetime_fac')
datasettime <- merge(datasettime, INS,all = FALSE, by ='datetime_fac')

rm(INS, Dateiliste, readINS,i)

invisible(gc())
print('ok')
```
with all geometric data from the airplane known we correct the height of the bins
```{r correct height, eval=loadnewInput}

dataset[,'h':= abs(cos(`Roll Angle`*pi/180)) *dist]
dataset[,h:= abs(cos(`Pitch Angle`*pi/180))*h]


dataset$height <- dataset$Altitude-dataset$h
dataset$h <- NULL


dataset[`Pitch Angle`>10, 'height':= NA]
dataset[`Pitch Angle`< -10, 'height':= NA]
dataset[`Roll Angle`>10, 'height':= NA]
dataset[`Roll Angle`< -10, 'height':= NA]

dataset$height_rounded <- round(dataset$height/7.5)*7.5

dataset[,`Roll Angle` := NULL]
dataset[,`Pitch Angle` := NULL]
dataset[,`True Heading` := NULL]

dataset <- dataset[height_rounded> -50]
dataset<-distinct(dataset)
datasettime<-distinct(datasettime)
invisible(gc())
print('ok')
getwd()
```

#calcuate SNR
```{r SNR}
gc()
#add background to each bin


dataset <- merge(dataset, 
                  datasettime[,.(datetime_fac,P532p_bg, P532s_bg, P355_bg, Error_Code_LR1)] , 
                  all=F,  
                  by='datetime_fac',
                  allow.cartesian = T)

#calculate SNR
dataset[,'P532p_snr':=(P532p_raw - P532p_bg) / P532p_noise]
dataset[,'P532s_snr':=(P532s_raw - P532s_bg) / P532s_noise]
dataset[,'P355_snr' :=(P355_raw  - P355_bg)  / P355_noise]

```

```{r}
#save.image(file=paste('data',nameOutput,campaign,'.RData', sep=""))#warum dauert das so lange?
```

#Analysis

##Lidar constant
# very low LC --> air was very clear

# very high LC very likely a cloud in calibration area

```{r}


dataset[,'LC532p_adjusted':=LC532p]
dataset[Error_Code_LR1>0,'LC532p_adjusted':=NA] 
dataset[LC532p_adjusted<0, LC532p_adjusted := NA]
sd(dataset$LC532p_adjusted)
quantile(dataset$LC532p_adjusted, c(.01,.90, .98, .99,.999), na.rm=T) 
dataset[LC532p_adjusted>quantile(dataset$LC532p_adjusted, .99, na.rm=T), LC532p_adjusted := NA]
dataset[LC532p_adjusted<quantile(dataset$LC532p_adjusted, .01, na.rm=T), LC532p_adjusted := NA]

#background-corrected signals
dataset[,'P532p_bc':=  P532p_raw - P532p_bg]
dataset[,'P532s_bc':=  P532s_raw - P532s_bg]
dataset[,'P355_bc':=  P355_raw - P355_bg]

#dataset[,'attB532p':= ( P532p_raw - P532_bg)*LC532p_adjusted]
dataset[,'attB532p':= ( P532p_bc)*LC532p_adjusted]


```


##Cloud top

####Top/bottom liquid layer

```{r liquid layer}
dataset <- dataset[!duplicated(mogelID)]

dataset[,'dif5':= log(A532p_LR1)]
dataset[is.na(dif5),'dif5':= -25]
dataset[,'dif5':= c(rep(0,5),diff(dif5, lag=5))]

# find 5 consequtive positive / negative bins
dataset[,'dif':= dif5 > 0]
test <- rle(dataset$dif)#???
dataset[,'increaselength':= rep(test$lengths,test$lengths)]
dataset[,'liquidtop':= 0]
dataset[increaselength>4 & # min 5 zusammenhaengende bins
        dif ==TRUE & #zunahmen
        BSR532p_LR1 > 3 & #nicht luft 
        dif5 >2 & # zunahme groesser als 2dB
        height>15 & #exclude ground return
        P532p_snr >2, 'liquidtop' := 10 ]
#now finding the top of each blob of min 5
dataset[,'liquidtop':= c(0,diff(dataset$liquidtop))]
dataset[,'liquidtoptop':= as.logical(NA)]
dataset[liquidtop==10, 'liquidtoptop' := TRUE] #Oberrand von den zusammenhaengenden, die als top identifiziert wurden

#cloudbase
dataset[,liquidtop:=0]
dataset[increaselength>4 & 
                    dif == FALSE & 
                    BSR532p_LR1 > 3 &
                     P532p_snr >2 &
                    dif5 < -2, liquidtop:= 3]
dataset[,liquidtop:= c(0,diff(liquidtop))]
dataset[liquidtop== 3, 'liquidtoptop' := FALSE] # nur den Unterrand von den zusammenhaengenden
gc()


dataset[liquidtoptop==T, 'liquidtoptop2':=5]
dataset[liquidtoptop==F, 'liquidtoptop2':= -5]
dataset[is.na(liquidtoptop), 'liquidtoptop2':=0]


# first sum over columns

dataset[,'col':= roll_sum(liquidtoptop2, 5)]#this takes forever
hist(dataset$col, breaks=20)

# sum over rows
dataset[order(height_rounded,datetime), 'line':= as.numeric(roll_sum(col, 5))]

dataset[as.numeric(line)<6& as.numeric(line)> -6, liquidtoptop := NA]

dataset[,col:=NULL]
dataset[,line:=NULL]
dataset[,liquidtop:=NULL]
dataset[,liquidtoptop2:=NULL]
dataset[,dif5:=NULL]
dataset[,dif:=NULL]


```

```{r export cloudtop dataset}
cloudtop<- dataset[liquidtoptop==T,.(datetime_fac, datetime, height, Lon_dezdeg, Lat_dezdeg)]
#get columns with no cloud top 

# check number of cloud tops
sumcloudtop<- dataset[liquidtoptop==T| is.na(liquidtoptop),.(datetime_fac, datetime, height, Lon_dezdeg, Lat_dezdeg,liquidtoptop)]
sumcloudtop[liquidtoptop==T,'blub' :=1]  
sumcloudtop[is.na(liquidtoptop),'blub' :=0] 
sumcloudtop<-  sumcloudtop[,.(ct.Sum=sum(blub)),   by=datetime_fac]  

View(sumcloudtop[ct.Sum==0])
#besser die Faelle mit accOD <0.2 finden. das sind save keine Wolken dann
distinct(dataset)
setorder(dataset, dist)
setorder(dataset, datetime)
accOD_column <- dataset[height>15&dist>100&!is.na(dist)& !duplicated(mogelID)&P532p_snr>2 & A532p_LR1>0, 
                 .(accOD=sum(A532p_LR1*7.5), 
                   datetime=first(datetime),
                   height=5,
                   Lon_dezdeg=first(Lon_dezdeg),
                   Lat_dezdeg=first(Lat_dezdeg)
                   ),
                 by=datetime_fac] 


SNR_column <- dataset[dist<500&dist>100&!is.na(dist)& !duplicated(mogelID), 
                 .(
                   SNR = sum(P532p_snr),
                   datetime=first(datetime)
                  
                   ),
                 by=datetime_fac] 

thincloud <- accOD_column[accOD<1 & accOD>0.3]
thincloud$height<- -1
thincloud$accOD<- NULL
nocloud<- accOD_column[accOD<0.3]
nocloud$height <- -999
nocloud$accOD<- NULL

cloudtop<- rbind(cloudtop, nocloud)
cloudtop<- rbind(cloudtop, thincloud)

nodata <- SNR_column[SNR< 2*53] 
cloudtop <- cloudtop[! datetime_fac %in% nodata$date]

setorder(cloudtop, height)
setorder(cloudtop, datetime)
gc()
names(cloudtop)<- c('datetime_seconds_since_1970-01-01', 'datetime_string', 'cloudtopheight_m', 'longitude_decimaldegree', 'latitude_decimaldegree')
write.table(cloudtop,'cloudtop_1s_resolution_mosaic.csv',row.names = F, sep = ",")
getwd()
```

