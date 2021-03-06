## parameters
threshold   <- 30
max_year    <- 18
aoi_list    <- c("UGA")
countrycode <- aoi_list[1]
proj        <- '+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs'

# load additional functions and parameters
source('~/uga_activity_data/scripts/get_parameters.R')
source('~/uga_activity_data/scripts/download_global_data/download_tiles_JRC_wastemask.R')
source('~/uga_activity_data/scripts/download_global_data/config.R')

tiles <- calc_gfc_tiles(aoi)

proj4string(tiles) <- proj4string(aoi)

tiles <- tiles[aoi,]

download_tiles(tiles,gfcdwn_dir,images = types)
water_types <- c("occurrence", "change", "seasonality", "recurrence","extent")
download_tiles_water(tiles,gfcdwn_dir,images = water_types)

### Find the suffix of the associated GFC data for each tile
tmp         <- data.frame(1:length(tiles),rep("nd",length(tiles)))
names(tmp)  <- c("tile_id","gfc_suffix")

for (n in 1:length(tiles)) {
  gfc_tile <- tiles[n, ]
  min_x <- bbox(gfc_tile)[1, 1]
  max_y <- bbox(gfc_tile)[2, 2]
  if (min_x < 0) {min_x <- paste0(sprintf("%02i", abs(min_x)), "W")}
  else {min_x <- paste0(sprintf("%02i", min_x), "E")}
  if (max_y < 0) {max_y <- paste0(sprintf("%01i", abs(max_y)), "S")}
  else {max_y <- paste0(sprintf("%01i", max_y), "N")}
  tmp[n,2] <- paste0("_",min_x , "_", max_y, ".tif")
}

### Store the information into a SpatialPolygonDF
df_tiles <- SpatialPolygonsDataFrame(tiles,tmp,match.ID = F)
rm(tmp)

suffix <- df_tiles@data$gfc_suffix
tilesx <- substr(suffix,2,nchar(suffix)-4)

### MERGE THE TILES TOGETHER, FOR EACH LAYER SEPARATELY and CLIP TO THE BOUNDING BOX OF THE COUNTRY
for(type in water_types){
  print(type)
  
  to_merge <- paste0(
                     type,"_",
                     tilesx,
                     ".tif")
  
  if(!file.exists(paste0(gfc_dir,"gfc_",countrycode,"_",type,".tif"))){
    
    
    system(sprintf("gdalbuildvrt -te %s %s %s %s %s %s",
                   floor(bb@xmin),
                   floor(bb@ymin),
                   ceiling(bb@xmax),
                   ceiling(bb@ymax),
                   paste0(tmp_dir,"tmp_merge_",type,".vrt"),
                   paste0(gfcdwn_dir,to_merge,collapse = " ")
    ))
    
    system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                   floor(bb@xmin),
                   ceiling(bb@ymax),
                   ceiling(bb@xmax),
                   floor(bb@ymin),
                   paste0(tmp_dir,"tmp_merge_",type,".vrt"),
                   paste0(gfc_dir,"JRC_",countrycode,"_",type,".tif")
    ))
    
    print(to_merge)
  } #### END OF EXISTS MERGE
  
} #### END OF MERGE TILES BY TYPE

