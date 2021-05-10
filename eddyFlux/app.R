#!/usr/bin/env Rscript

# TODO: find ncores and pass it to the stacking functions

# parse args and set path
args = commandArgs(trailingOnly=TRUE)
dpID      <- args[1]
package   <- args[2]
site      <- args[3]
startdate <- args[4]
enddate   <- args[5]
savepath  <- '/savepath'

# do this wierd R thing
options(stringsAsFactors=F)

# we'll need this
library(dplyr)
library(neonUtilities)

# bag the data from the API
zipsByProduct(dpID=dpID, package=package, 
              site=site, 
              startdate=startdate, enddate=enddate,
              savepath=savepath, 
              check.size=F)

# extract the level 4 data
filepath <- file.path(savepath, 'filesToStack00200')
flux <- stackEddy(filepath=filepath,
                  level="dp04")

# porudct IDs for soil CO2, Water, and Temp
soilCO2ID <- 'DP1.00095.001'
soilH2OID <- 'DP1.00094.001'
soilTID   <- 'DP1.00041.001'

# download the products
soilCO2 <- loadByProduct(soilCO2ID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F)

soilH2O <- loadByProduct(soilH2OID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F)

soilT <- loadByProduct(soilTID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F)

# join the data for soilT (R is so painful, this would be so much easier in python)
positions <- unique(soilT$ST_30_minute[c("verticalPosition")])[[1]]

df <- flux[[1]]

for (pos in positions) {
    col <- paste0('ST_', pos)
    values <- soilT$ST_30_minute[which(soilT$ST_30_minute$verticalPosition==pos),c("startDateTime", "horizontalPosition", "soilTempMean","soilTempMinimum", "soilTempExpUncert", "soilTempStdErMean", "finalQF", "soilTempMaximum", "soilTempVariance")]
    values$timeBgn <- values$startDateTime
    df <- merge(values, df, by="timeBgn")
}

