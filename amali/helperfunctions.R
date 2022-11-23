

Date.from.matlab<- function(val){as.POSIXct((val - 719529)*86400, origin = "1970-01-01", tz = "UTC")}

#read nc file
readAmalidataStep1<- function(Pfad){
  library(ncdf4)
  lidar.nc <- nc_open(Pfad)
  
  names(lidar.nc$var)
  Time <- ncvar_get(lidar.nc, "Time")
  Distance <- ncvar_get(lidar.nc, "Distance")
  LidarRatio <- ncvar_get(lidar.nc, "LidarRatio")
  
  P532p_raw <- ncvar_get(lidar.nc, "P532p_raw")
  P532s_raw<- ncvar_get(lidar.nc, "P532s_raw")
  P355_raw<- ncvar_get(lidar.nc, "P355_raw")
  
  P532p_bg<- ncvar_get(lidar.nc, "P532p_bg")
  P532s_bg<- ncvar_get(lidar.nc, "P532s_bg")
  P355_bg<- ncvar_get(lidar.nc, "P355_bg")
  
  P532p_noise<- ncvar_get(lidar.nc, "P532p_noise")
  P532s_noise<- ncvar_get(lidar.nc, "P532s_noise")
  P355_noise<- ncvar_get(lidar.nc, "P355_noise")
  
  B532p<- ncvar_get(lidar.nc, "B532p")
  BSR532p<- ncvar_get(lidar.nc, "BSR532p")
  A532p<- ncvar_get(lidar.nc, "A532p")
  
  Error_Code<- ncvar_get(lidar.nc, "Error_Code")
  Position_UBC<- ncvar_get(lidar.nc, "Position_UBC")
  LC532p<- ncvar_get(lidar.nc, "LC532p")
  
  d <- list(
  
  TIMEDIST = data.table(
    matlabtime = rep(Time, each=length(Distance)),
    dist = rep(Distance, length((Time))),
    P532p_raw = as.vector(P532p_raw),
    P532s_raw = as.vector(P532s_raw),
    P355_raw = as.vector(P355_raw),
    P532p_noise = as.vector(P532p_noise),
    P532s_noise = as.vector(P532s_noise),
    P355_noise = as.vector(P355_noise),
    B532p_LR1 = as.vector(B532p[,,1]),
    B532p_LR2 = as.vector(B532p[,,2]),
    B532p_LR3 = as.vector(B532p[,,3]),
    BSR532p_LR1 = as.vector(BSR532p[,,1]),
    A532p_LR1 = as.vector(A532p[,,1]),
    A532p_LR2 = as.vector(A532p[,,2]),
    A532p_LR3 = as.vector(A532p[,,2]),
    Position_UBC_LR1 = as.vector(Position_UBC[,,1]),
    LC532p = as.vector(LC532p[,,1])
  ),
  
  TIME = data.table(
    matlabtime = Time,
    P532p_bg = P532p_bg,
    P532s_bg = P532s_bg,
    P355_bg  = P355_bg,
    Error_Code_LR1 = Error_Code[,1],
    Error_Code_LR2 = Error_Code[,2],
    Error_Code_LR3 = Error_Code[,3]
    )
  )
  
  d$TIMEDIST$datetime<- Date.from.matlab(d$TIMEDIST$matlabtime)
  d$TIME$datetime <- Date.from.matlab(d$TIME$matlabtime)
  
  return(d)
  
}


readGPS <- function(GPSpfad){
  header <- read.table(GPSpfad, nrows = 1, header = FALSE, sep ='\t', stringsAsFactors = FALSE)
  header2 <-read.table(GPSpfad, nrows = 1, header=FALSE, sep='\t', stringsAsFactors = FALSE, skip=1)
  GPS <- read.table(GPSpfad, header = F, skip = 4, sep = '\t')
  colnames(GPS) <- c(unlist(header)[1:6],unlist(header2)[7:13])
  rm(header, header2)
  
  GPS$datetime <- as.POSIXct( paste(GPS$YYYY,'-',GPS$MM,'-', GPS$DD,' ', GPS$HH,':',GPS$mm,':',GPS$ss, sep=''),tz ='UTC' )
  GPS<- GPS[7:ncol(GPS)]
  
  GPS$Lon_dezdeg <- floor(GPS$Lon/100)+ ((GPS$Lon/100-floor(GPS$Lon/100))/60*100)
  GPS$Lon_dezdeg[which(GPS$`Lon dir` == "W")] <- GPS$Lon_dezdeg[which(GPS$`Lon dir` == "W")] * -1
  GPS$Lat_dezdeg <- floor(GPS$Lat/100)+ ((GPS$Lat/100-floor(GPS$Lat/100))/60*100)
  
  GPS$datetime_fac  <- as.integer( GPS$datetime)
  GPS$datetime <- NULL 
  return(GPS)
}


readINS <- function(INSpfad){
  header <- read.table(INSpfad, nrows = 1, header = FALSE, sep ='\t', stringsAsFactors = FALSE)
  header2 <-read.table(INSpfad, nrows = 1, header=FALSE, sep='\t', stringsAsFactors = FALSE, skip=1)
  INS <- read.table(INSpfad, header = F, skip = 4)
  colnames(INS) <- c(unlist(header)[1:6],unlist(header2)[7:13])
  rm(header, header2)
  
  INS$datetime <- as.POSIXct( paste(INS$YYYY,'-',INS$MM,'-', INS$DD,' ', INS$HH,':',INS$mm,':',INS$ss, sep=''),tz ='UTC' )
  INS<- INS[7:ncol(INS)]
  
  INS$datetime_fac  <- as.integer( INS$datetime)
  INS$Latitude  <- NULL
  INS$Longitude <- NULL
  INS$datetime  <- NULL
  INS$`Inertial Altitude` <- NULL
  INS$`Ground Speed` <- NULL
  return(INS)
}

