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
library(parallel)
ncores <- detectCores()

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

# extract the columns of interest from the flux data
flx <- flux[[1]]
flx <- flx %>% select(timeBgn, data.fluxCo2.nsae.flux, qfqm.fluxCo2.nsae.qfFinl, data.
fluxTemp.nsae.flux,  qfqm.fluxTemp.nsae.qfFinl, data.fluxH2o.nsae.flux, qfqm.fluxH2o.nsae
.qfFinl)
setDT(flx)

# product IDs for soil CO2, Water, and Temp
soilCO2ID <- 'DP1.00095.001'
soilH2OID <- 'DP1.00094.001'
soilTID   <- 'DP1.00041.001'

# download the products
soilCO2 <- loadByProduct(soilCO2ID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F, nCores=ncores)

soilH2O <- loadByProduct(soilH2OID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F, nCores=ncores)

soilT <- loadByProduct(soilTID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F, nCores=ncores)

# join the data for soilT (R is so painful, this would be so much easier in python)


df <- soilCO2$SCO2C_30_minute
# get the positions
positions <- unique(df[c("verticalPosition")])[[1]]
# make an empty list
soilCO2_dfs <-  c()
# put crap in the list
for (position in positions) {
    print(position)
    d <- df["verticalPosition" == position]
    d$timeBgn <- d$startDateTime
    soilCO2_dfs <- c(soilCO2_dfs, setNames(list(d), paste0('d',position)))
}



library(doParallel)

# define a function for merging columns computed in ||
merge_columns <- function(a, b) {
    merge(a, b, by='timeBgn')
}

# define a (very boilerplate) function for getting the data within the loop
scrape_data <- function(pos, soilT) {
    col <- paste0('ST_', pos)
    values <- soilT$ST_30_minute[which(soilT$ST_30_minute$verticalPosition==pos),c("startDateTime", "horizontalPosition", "soilTempMean","soilTempMinimum", "soilTempExpUncert", "soilTempStdErMean", "finalQF", "soilTempMaximum", "soilTempVariance")]
    values$timeBgn <- values$startDateTime
}

p = length(positions)


foreach(i=1:p, .combine=merge_columns) %dopar% {


results = foreach()

for (pos in positions) {
    col <- paste0('ST_', pos)
    values <- soilT$ST_30_minute[which(soilT$ST_30_minute$verticalPosition==pos),c("startDateTime", "horizontalPosition", "soilTempMean","soilTempMinimum", "soilTempExpUncert", "soilTempStdErMean", "finalQF", "soilTempMaximum", "soilTempVariance")]
    values$timeBgn <- values$startDateTime
    
}

