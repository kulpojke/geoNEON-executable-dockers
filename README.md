# geoNEON-executable-dockers #

Dockers with executable scripts to be called from the command line.  I try to make the scripts as flexible as possible but you should examine the dockerfiles and start scripts before using to ensure they make sense for yor system and application.

## Setup ##

You need to have docker installed (or Singularity).

## Executale dockers ##

Here is the list of executable dockers.  This is a work in progress, more will be added in the future.

### woodyVegLoc ###
Saves a csv of location and plant observation from woody vegetation observations (DP1.10098.001) to pwd.

SYNOPSIS

```./start_woodyVeg_docker.sh [site] [outpath]```

Where: 

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```site``` is a NEON site abbreviation e.g. BART 

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```outpath``` is the path where you want the csv to be written, the path must already exist.

