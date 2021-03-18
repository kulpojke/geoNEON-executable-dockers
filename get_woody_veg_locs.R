#!/usr/bin/env Rscript

# parse args
args = commandArgs(trailingOnly=TRUE)
site <- args[1]
write_path <- args[2]

# load packages
library(neonUtilities)
library(raster)
library(devtools)
library(data.table)
library(geoNEON)

# Set global option to NOT convert all character variables to factors
options(stringsAsFactors=F)

# load woody plant veg structure for site
veg_str <- loadByProduct(dpID="DP1.10098.001", site=site, 
                         package="expanded", check.size=F)

# add all of the cryptic items in veg_str to the env
list2env(veg_str, .GlobalEnv)

# Use geoNEON to retrieve precise easting and northing for each tree
vegmap <- geoNEON::getLocTOS(vst_mappingandtagging, "vst_mappingandtagging")

# veg is a df. typeof(veg) says list though because R is stupid and confusing 
veg <- merge(vst_apparentindividual, vegmap, by=c("individualID","namedLocation",
                                                  "domainID","siteID","plotID"))

# write veg to csv
fname <- paste(site, "_woodyVeg.csv", sep="")
fwrite(veg, paste(write_path, fname,sep='/'))

