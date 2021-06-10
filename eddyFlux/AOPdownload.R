#!/usr/bin/env Rscript


# parse args and set path
args = commandArgs(trailingOnly=TRUE)
dpID      <- args[1] 
site      <- args[2] 
year      <- args[3] 
easting   <- args[4]
northing  <- args[5] 
buffer    <- args[6] 
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

if (class(api_token) != "character"){
  api_token <- NA
}

byTileAOP(dpID=dpID,
          site=site,
          year=year,
          easting=easting,
          northing=northing,
          buffer=buffer,
          check.size=FALSE,
          savepath=savepath,
          token=api_token)
