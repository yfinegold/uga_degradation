######################################################
##   download data for BFAST workshop 26 Feb 2019   ##
######################################################

####################################################################################################
####################################################################################################
## DOWNLOAD DATA
## Contact yelena.finegold@fao.org
####################################################################################################
####################################################################################################

## user parameters to get directory names
source('~/uga_degradation/scripts/get_parameters.R')
## download data 
system(sprintf("wget -O %s  https://www.dropbox.com/s/wd31qdkzgee062f/bfast_westlbert_co.tif", paste0(bfast_dir,'bfast_westlbert_co.tif')))
system(sprintf("wget -O %s  https://www.dropbox.com/s/ubqidvnpcwu9blv/Ug2017_CW_gEdits4_co.tif", paste0(lc_dir,'Ug2017_CW_gEdits4_co.tif')))
system(sprintf("wget -O %s https://www.dropbox.com/s/z9lvjyttxy04i2q/field_points_feb.zip", paste0(ref_dir,'field_points_feb.zip')))
system(sprintf("unzip -o %s  -d %s ",paste0(ref_dir,'field_points_feb.zip'),paste0(ref_dir,'field_points_feb/')))
system(sprintf("rm %s",paste0(ref_dir,'field_points_feb.zip')))