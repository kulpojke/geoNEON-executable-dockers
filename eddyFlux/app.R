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

# we'll need these
library(parallel)
ncores <- detectCores()
library(dplyr)
library(neonUtilities)

# product IDs for soil CO2, Water, and Temp
soilCO2ID <- 'DP1.00095.001'
soilH2OID <- 'DP1.00094.001'
soilTID   <- 'DP1.00041.001'


# -------------- function definitions --------------------------------------

sep_vertical <- function(sensor_data) {
    #' function to seperate sensor data into a list of dfs by verticalPosition
    #' @param sensor_data -- the sensor data as returned by neonUtilities::loadByProduct()

    # find the index of the 30_minute data for this data product
    idx <- which(grepl('30_minute', names(sensor_data)), arr.ind=TRUE)
    # now get the data using the index
    df <- sensor_data[[idx]]
    # get the positions
    positions <- unique(df[c("verticalPosition")])[[1]]
    # make an empty list
    df_list <-  c()
    # seperate df by verticalPosition and put new dfs in list
    for (position in positions) {
        d <- df[df$verticalPosition == position,]
        # change timestamps to timeBgn to harmonize with flux data
        d$timeBgn <- d$startDateTime
        # drop some unneeded columns
        d <- select(d,-startDateTime, -endDateTime, -domainID, -verticalPosition, -release, -publicationDate, -siteID)
        # concat to list
        df_list <- c(df_list, setNames(list(d), paste0("z", position)))
    }
    return(df_list)
}


sep_horizontal <- function(list_of_dfs) {
    #' function to seperate each df in a list of dfs by horizontalPosition
    #' @param list_of_dfs -- the list of dfs

    # make an empty list
    df_list <- c()
    # seperate data by horizontalPosition for each df in list_of_dfs
    for (i in seq_along(list_of_dfs)) {
        z <- names(list_of_dfs)[i]
        df <- list_of_dfs[[i]]
        # get the positions
        positions <- unique(df[c("horizontalPosition")])[[1]]
        for (position in positions) {
            d <- df[df$horizontalPosition == position,]
            # drop some unneeded columns
            d <- select(d, -horizontalPosition)
            df_list <- c(df_list, setNames(list(d), paste0(z, "h", position)))
        }
    }
    return(df_list)
}

# --------end of function definitions --------------------------------------

#-------------- flux -------------------------
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

# get just the dataframe
flx <- flux[[1]]
# cast it to a data.table type
setDT(flx)
# extract the columns of interest from the flux data
flx <- flx %>% select(timeBgn, data.fluxCo2.nsae.flux, qfqm.fluxCo2.nsae.qfFinl, data.fluxTemp.nsae.flux,  qfqm.fluxTemp.nsae.qfFinl, data.fluxH2o.nsae.flux, qfqm.fluxH2o.nsae.qfFinl)

#------------ soilCO2 ------------------------
# download the soilCO2 product
soilCO2 <- loadByProduct(soilCO2ID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F, nCores=ncores)

# seperate data by verticalPosition for soilCO2
soilCO2_dfs <- sep_vertical(soilCO2)

# seperate soilCO2 by horizontalPosition  
soilCO2_dfs <- sep_horizontal(soilCO2_dfs)

#------------ soilH2O ------------------------
# download the soilH2O product
soilH2O <- loadByProduct(soilH2OID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F, nCores=ncores)

# seperate data by verticalPosition for soilH2O 
soilH2O_dfs <- sep_vertical(soilH2O)

# seperate soilH2O by horizontalPosition  
soilH2O_dfs <- sep_horizontal(soilH2O_dfs)

#------------- soilT -------------------------
# download the soilT product
soilT <- loadByProduct(soilTID, site=site, 
                    timeIndex=30, package="basic", 
                    startdate=startdate, enddate=enddate,
                    check.size=F, nCores=ncores)

# seperate data by verticalPosition for soilT
soilT_dfs <- sep_vertical(soilT)

# seperate soilT by horizontalPosition  
soilT_dfs <- sep_horizontal(soilT_dfs)

#------------- merge -------------------------

merge_dfs_list <- function(list_of_dfs) {
    for (i in 1:length(list_of_dfs)) {
        loc <- names(list_of_dfs)[[i]]
        df <- list_of_dfs[[i]]
        if (i==1) {
            setnames(df, names, rename_by_loc(df))
            data <- df
        } else {
            setnames(df, names, rename_by_loc(df))
            data <- inner_join(data, df, by="timeBgn")
        }
    } 
    return(data)
}


rename_by_loc <- function(df, loc) {
    #' concatenates the sensor loc to the column name.
    #' This function is used by merge_dfs_list()

    old_names <- names(df)
    new_names <- c()
    for (name in old_names) {
        if (name == "timeBgn") {
            new_names <- c(new_names, name)
        } else {
            new_names <- c(new_names, paste(name, loc, sep="_"))
        }
    return(new_names)
    }
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

