#!/usr/bin/env Rscript

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

