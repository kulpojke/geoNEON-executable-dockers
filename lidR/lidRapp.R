#!/usr/bin/env Rscript

#parse args
#args = commandArgs(trailingOnly=TRUE)
#x <- args[1]


# load packages
writeLines("--------------------------------------------------------------
loading packages in R\n")
library(glue)
library(lidR)
library(rgdal)


# Set global option to NOT convert all character variables to factors
options(stringsAsFactors=F)

# Set paths (TODO:probably would be better not to hard code them here)
datapath = "/datapath"
tmp = "/data/tmp"
outpath = "/outpath"

# make LAScatalog
writeLines("-----------------------making LAScatalog----------------------\n")
ctg <- readLAScatalog(datapath)
opt_output_files(ctg) <- paste0(tmp, "/{XCENTER}_{YCENTER}_{ID}")
#las_check(ctg, deep=TRUE)

# make normalized pointcloud
writeLines("-----------------------normalize_height------------------------\n")
ctg_norm <-normalize_height(ctg, knnidw())
opt_output_files(ctg_norm) <- paste0(tmp, "/{XCENTER}_{YCENTER}_n{ID}")

writeLines("-----------------------filter z>0------------------------------\n")
opt_filter(ctg_norm) <- "-drop_z_below 0"

## make tmp chms
opt_output_files(ctg_norm) <- paste0(tmp, "/chm_{*}")
chm <- grid_canopy(ctg_norm, 1, p2r(0.15))

# find tree tops
# first define function for window sizing (TODO: didle with this, it could
#actually be pretty important to tweak)
f <- function(x) {x * 0.8}
writeLines("-----------------------finding tree tops-----------------------\n")
opt_output_files(ctg_norm) <- ""
ttops <- find_trees(ctg_norm, lmf(f), uniqueness = "bitmerge")
writeOGR(obj=ttops, layer="ttops", dsn=outpath, driver="ESRI Shapefile")

# segment trees
writeLines("-----------------------segmenting trees------------------------\n")
opt_output_files(ctg_norm) <- paste0(outpath, "/{*}_segmented")
#algo <- dalponte2016(chm, ttops)
ctg_segmented <- segment_trees(ctg_norm, silva2016(chm, ttops))
crowns <- delineate_crowns(ctg_segmented, func=.stdmetrics)
