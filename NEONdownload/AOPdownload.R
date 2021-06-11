#!/usr/bin/env Rscript


# parse args and set path
args = commandArgs(trailingOnly=TRUE)
dpID      <- args[1] 
site      <- args[2] 
year      <- args[3] 
easting   <- as.numeric(args[4])
northing  <- as.numeric(args[5]) 
buffer    <- as.numeric(args[6]) 
api_token <- args[7]
savepath  <-'/savepath'

# we'll need these
library(parallel)
library(dplyr)
library(neonUtilities)
library(doParallel)
ncores <- detectCores()

# do this wierd R thing
options(stringsAsFactors=F)

# check for token
if (class(api_token) != "character"){
  api_token <- NA
}
# download files
byTileAOP(dpID=dpID,
          site=site,
          year=year,
          easting=easting,
          northing=northing,
          buffer=buffer,
          check.size=FALSE,
          savepath=savepath,
          token=api_token)
