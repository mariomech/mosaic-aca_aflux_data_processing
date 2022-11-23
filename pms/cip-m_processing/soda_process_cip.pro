;Example script for running batch jobs without the user interface.
;Copyright © 2016 University Corporation for Atmospheric Research (UCAR). All rights reserved.

PRO mosaic08302020
;Processing details #1
date='08302020'     ;mmddyyyy
starttime=1                ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200830_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200830\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830073754',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830081746',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830081951',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830082418',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830082617',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830082815',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830083013',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830083217',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830083418',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830083619',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830083821',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830084023',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830084225',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830084431',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830084807',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830085009',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830085209',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830085409',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830085609',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830085959',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090003',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090005',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090010',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090014',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090018',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090022',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090026',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090031',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090035',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090043',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090047',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090100',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090104',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090120',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090137',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090141',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090153',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090157',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090214',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090226',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090234',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090238',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090242',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090247',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090251',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090256',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090300',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090304',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090309',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090313',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090317',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090321',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090326',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090330',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090334',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090338',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090342',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090346',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090350',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090354',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090359',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090403',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090407',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090411',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090416',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090420',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090424',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090428',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090437',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090441',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090453',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090457',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090502',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090514',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090531',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090551',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090616',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090624',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090628',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090636',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090641',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090645',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090649',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090653',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090701',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090705',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090710',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090718',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090726',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090738',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090751',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090759',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090812',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090832',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200830_testflight/CCP/imagefiles/Imagefile_1CIP Grayscale_20200830090840']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END

PRO mosaic08312020
;Processing details #1
date='08312020'     ;mmddyyyy
starttime=1                ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200831_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200831\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831095450',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831095451',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831102400',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831102957',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831103200',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831103359',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831103558',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831103758',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831103958',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831104157',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831104357',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200831_certification/CCP/20200831/imagefiles/Imagefile_1CIP Grayscale_20200831104557']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO mosaic09022020
;Processing details #1
date='09022020'     ;mmddyyyy
starttime=1                ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200902_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200902\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902063725',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902065932',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902070354',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902070723',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902070923',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071124',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071346',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071349',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071351',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071355',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071400',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071406',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071414',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071418',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071423',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071428',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071432',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071436',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071441',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071446',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071450',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071454',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071459',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071503',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071507',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071511',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071516',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071520',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071524',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071529',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071533',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902071537',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902072919',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902073306',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902073506',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902073708',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902073906',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902074106',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902074306',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902074506',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902074708',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902074908',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902075108',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902075308',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902075511',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902075715',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902075918',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902085926',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902090143',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902093203',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902093426',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902093701',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902093934',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902094350',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902095933',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100117',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100121',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100125',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100129',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100134',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100139',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100145',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100159',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902100924',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902102208',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902104233',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902105324',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902105659',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902110600',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902112041',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902112429',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902112831',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902113147',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902113913',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902114132',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902114353',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902114606',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902114807',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902115125',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902115349',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902115629',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902115921',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902120156',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902120412',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902120616',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902120830',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902121259',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902121547',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902122030',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200902_F5/CCP/20200902/imagefiles/Imagefile_1CIP Grayscale_20200902130858']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO mosaic09042020
;Processing details #1
date='09042020'     ;mmddyyyy
starttime=1              ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200904_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200904\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904115413',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904121639',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904121847',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904130918',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904131321',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904134527',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904135309',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904140841',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904143728',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904143729',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904144110',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904144519',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904144853',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904145137',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904145645',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904145951',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904150257',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904150559',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904150809',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904151107',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904151312',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904151635',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904151835',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904152035',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904152240',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904152439',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904152723',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904152934',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904153201',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904153412',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904153612',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904153826',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904154634',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904155425',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904155658',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904163118',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904163348',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904163611',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904164251',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904164752',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904165245',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904165509',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904165707',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904165905',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904170106',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904170306',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904170506',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904170706',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904171112',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200904_F6/CCP/20200904/imagefiles/Imagefile_1CIP Grayscale_20200904171501']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END



PRO mosaic09072020
;Processing details #1
date='09072020'     ;mmddyyyy
starttime=1                ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200907_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200907\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907074542',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907082822',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907083128',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907083329',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907083632',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907083851',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907084107',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907084323',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907084535',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907084739',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907084941',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907085143',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907085345',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907085548',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907085756',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907090014',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907090231',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907090523',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907091055',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907092411',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907094305',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907094715',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907095232',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907095639',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907100512',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907102250',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907102253',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907103059',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907103841',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907104542',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907105029',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907105751',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907110548',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907112224',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907113047',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907115930',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907120606',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907120909',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907121147',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907121415',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907121908',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907122509',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907122713',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907122917',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907123122',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907123330',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907123532',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907123802',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907124013',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907124220',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907124421',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907124623',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907124844',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907125047',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907125320',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907125618',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907125833',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907130100',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907130335',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907130620',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907130939',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907131233',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907131604',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907131607',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907131808',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907132008',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907132207',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907132407',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907132615',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907132821',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907133023',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907133251',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907133451',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907133652',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907133852',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907134100',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907134302',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907134522',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907135106',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200907_F7_remote_sensing/CCP/20200907/Imagefiles/Imagefile_1CIP Grayscale_20200907135344']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END

PRO mosaic09082020
;Processing details #1
date='09082020'     ;mmddyyyy
starttime=1                ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200908_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200908\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908074038',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908074039',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908080429',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908080632',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908081459',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908081817',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908082140',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908082456',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908082738',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908083010',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908083224',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908083435',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908083638',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908083844',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908084051',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908084255',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908084502',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908084710',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908084916',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908085117',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908085334',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908085548',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908085757',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908090022',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908090259',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908090510',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908090758',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908091015',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908091240',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908091459',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908091721',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908091959',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908092244',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908092622',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908092855',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908093103',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908093417',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908094650',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908095029',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908095032',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908095521',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908095922',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908100327',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908100603',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908103937',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908104227',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908104436',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908104826',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908105041',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908105957',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908110205',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908110527',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908110915',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908111328',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908112908',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908112909',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908113912',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908114733',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908115316',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908120623',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908121210',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908121725',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908122004',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908122256',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908122504',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908122924',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908123527',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908123845',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908134845',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908135053',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908135733',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200908_F8_insitu_over_ice/CCP/20200908/imagefiles/Imagefile_1CIP Grayscale_20200908140144']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO mosaic09102020
;Processing details #1
date='09102020'     ;mmddyyyy
starttime=1                ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200910_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200910\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910080926',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910081336',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910084326',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910084545',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910084918',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910085316',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910090223',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910090851',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910091327',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910091937',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910092334',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910092654',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910093048',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910094010',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910095426',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910102048',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910102347',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910102705',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910102938',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910103214',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910103453',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910103713',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910103914',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910104113',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910104312',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910104512',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910104826',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910105849',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910105850',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910110804',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910111101',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910111454',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112250',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112253',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112254',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112258',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112303',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112309',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112313',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112320',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112325',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112506',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910112944',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910113322',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910113531',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910113731',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910113943',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910114147',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910114418',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910114754',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910115227',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910115705',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910115908',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910120106',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910120304',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910120506',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910121108',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910121638',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910123100',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910123259',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910123458',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910123702',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910124512',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910124842',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910125917',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910130123',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910130344',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910130645',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910131309',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910131650',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910131932',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910132212',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910132616',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910132821',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133422',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133427',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133429',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133434',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133439',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133444',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133449',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133453',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133458',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910133502',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910134515',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910134519',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910135741',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910142650',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910142905',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200910_F9_insitu_cover_ice/CCP/20200910/imagefiles/Imagefile_1CIP Grayscale_20200910143154']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO mosaic09112020
;Processing details #1
date='09112020'     ;mmddyyyy
starttime=1                ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200911_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200911\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911075818',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911080321',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911080322',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911082943',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911084131',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911093738',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911095944',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911100400',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911101055',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911101614',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911102035',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911102655',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911103952',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911104908',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911105111',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911105311',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911105316',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911105520',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911105724',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911105933',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911110157',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911110700',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911110858',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911111231',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911111858',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911112835',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911113335',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911113740',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911114233',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911114551',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911115031',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911115241',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911115626',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911120139',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911120543',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911120833',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121033',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121035',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121036',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121040',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121045',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121049',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121055',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121100',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121143',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121146',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121147',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121152',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121156',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121201',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121419',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121422',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121423',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121427',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121431',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121639',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121642',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121645',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121649',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121653',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121700',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121705',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121716',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121718',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121721',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121726',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911121945',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911122150',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911122652',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911133854',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200911_F10_insitu_over_ice/CCP/20200911/imagefiles/Imagefile_1CIP Grayscale_20200911134649']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END


PRO mosaic09132020
;Processing details #1
date='09132020'     ;mmddyyyy
starttime=1                ;seconds
stoptime=80000                ;seconds
pthfile='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\TAS_files\20200913_TAS.txt'                 ;Name of file with TAS data
outdir='E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\20200913\'            ;Output directory
fn=[$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913085835',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913085836',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913092925',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913093340',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913093611',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913093852',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913094216',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913095425',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913100432',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913101249',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913101552',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913105036',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913110839',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913111221',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913111504',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913111716',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913114003',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913114621',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913114827',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913115029',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913115238',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913115454',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913115657',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913115900',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913120130',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913120607',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913120938',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913121521',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913121822',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913122035',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913122624',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913122840',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913123215',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913123418',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913123621',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913123834',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913124054',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913124429',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913124715',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913124725',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913125620',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913130532',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913130856',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913132657',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913132901',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913133103',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913133307',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913133515',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913133717',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913133925',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913134126',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913134335',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913134537',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913134837',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913135108',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913135404',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913135611',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913135925',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913140141',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913140610',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913141407',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913144737',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913145307',$ 
'E:/Backup MOSAiC Daten_nicht die Enddaten 20200925/MOSAiC_ACAS/Daten/20200913_F11_ice_next_to_Greenland/CCP/20200913/imagefiles/Imagefile_1CIP Grayscale_20200913145533']
batch_process, fn, date, starttime, stoptime, pthfile, outdir
END

PRO batch_process, fn, date, starttime, stoptime, pthfile, outdir
   ;Probe parameters, most are stored in soda2_probespecs
   probe=soda2_probespecs(name='CAPS-Grey')
   
   ;Processing details and options
   ;endbins=[0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.5, 17.5, 18.5, 19.5, 20.5, 21.5, 22.5, 23.5, 24.5, 25.5, 26.5, 27.5, 28.5, 29.5, 30.5, 31.5, 32.5, 33.5, 34.5, 35.5, 36.5, 37.5, 38.5, 39.5, 40.5, 41.5, 42.5, 43.5, 44.5, 45.5, 46.5, 47.5, 48.5, 49.5, 50.5, 51.5, 52.5, 53.5, 54.5, 55.5, 56.5, 57.5, 58.5, 59.5, 60.5, 61.5, 62.5, 63.5, 64.5]
   endbins=[7.5, 22.5, 37.5, 52.5, 67.5, 82.5, 97.5, 112.5, 127.5, 142.5, 157.5, 172.5, 187.5, 202.5, 217.5, 232.5, 247.5, 262.5, 277.5, 292.5, 307.5, 322.5, 337.5, 352.5, 367.5, 382.5, 397.5, 412.5, 427.5, 442.5, 457.5, 472.5, 487.5, 502.5, 517.5, 532.5, 547.5, 562.5, 577.5, 592.5, 607.5, 622.5, 637.5, 652.5, 667.5, 682.5, 697.5, 712.5, 727.5, 742.5, 757.5, 772.5, 787.5, 802.5, 817.5, 832.5, 847.5, 862.5, 877.5, 892.5, 907.5, 922.5, 937.5, 952.5, 967.5]
   arendbins=[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
   
   project='MOSAiC-ACAS' ;Project name
   rate=1               ;Averaging time
   smethod='fastcircle' ;Sizing method, default is 'fastcircle'
   particlefile=1       ;Flag to output particle-by-particle data
   savfile=1            ;Flag to output sav file
   inttime_reject=1     ;Flag to turn shattering correction on/off
   reconstruct=0        ;Flag to turn particle reconstruction on/off
   stuckbits=1          ;Flag to turn stuck bit detection on/off
   water=0              ;Flag to turn water processing on/off
   fixedtas=10         ;Use a fixed TAS (m/s)
   timeoffset=0.0       ;Time correction
   greythresh=2         ;Grey threshold (for CIPG)
  ; outdir=''            ;Output directory
   output_dir_images = outdir
   pthfile= pthfile          ;File with state variables
   stretchcorrect = 1
   ncdfparticlefile = 1
   juelichfilter = 1
   eawmethod = 'centerin'
   
   ;Build structure and process data
   ;Fields not specified here will be updated with defaults in soda2_update_op.pro
   op={fn:fn, date:date, starttime:starttime, stoptime:stoptime, project:project,$
     outdir:outdir, timeoffset:timeoffset, format:probe.format, $
     subformat:probe.subformat, probetype:probe.probetype, res:probe.res, $
     armwidth:probe.armwidth, numdiodes:probe.numdiodes, probeid:probe.probeid,$
     shortname:probe.shortname,  wavelength:probe.wavelength, $
     seatag:probe.seatag, endbins:endbins, arendbins:arendbins, rate:rate, $
     smethod:smethod, pth:pthfile, particlefile:particlefile, savfile:savfile, $
     inttime_reject:inttime_reject, reconstruct:reconstruct, stuckbits:stuckbits,stretchcorrect:stretchcorrect,$
     water:water, fixedtas:fixedtas, greythresh:greythresh, ncdfparticlefile:ncdfparticlefile, juelichfilter:juelichfilter,  eawmethod:eawmethod}
   
   soda2_process_2d, op
END

;mosaic08302020
;mosaic08312020
;mosaic09022020
;mosaic09042020
;mosaic09072020
;mosaic09082020
;mosaic09102020
;mosaic09112020
;mosaic09132020



day = '02'
month = '09'
year = '2020'
restore, 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG.dat'
soda2_export_ncdf, data, outfile = 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG'+'.nc'


day = '04'
month = '09'
year = '2020'
restore, 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG.dat'
soda2_export_ncdf, data, outfile = 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG'+'.nc'

day = '07'
month = '09'
year = '2020'
restore, 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG.dat'
soda2_export_ncdf, data, outfile = 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG'+'.nc'

day = '08'
month = '09'
year = '2020'
restore, 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG.dat'
soda2_export_ncdf, data, outfile = 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG'+'.nc'

day = '10'
month = '09'
year = '2020'
restore, 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG.dat'
soda2_export_ncdf, data, outfile = 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG'+'.nc'

day = '11'
month = '09'
year = '2020'
restore, 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG.dat'
soda2_export_ncdf, data, outfile = 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG'+'.nc'

day = '13'
month = '09'
year = '2020'
restore, 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG.dat'
soda2_export_ncdf, data, outfile = 'E:\Backup MOSAiC Daten_nicht die Enddaten 20200925\MOSAiC_ACAS\Auswertung\NASA-AMES\CIP\'+year+month+day+'\'+month+day+year+'_000001_CIPG'+'.nc'





END

