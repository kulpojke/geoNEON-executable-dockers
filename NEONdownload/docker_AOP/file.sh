#!/bin/sh

DPID=$1
SITE=$2
YEAR=$3
EASTING=$4
NORTHING=$5
BUFFER=$6
TOKEN=$7

# run the app
Rscript AOPdownload.R  $DPID $SITE $YEAR $EASTING $NORTHING $BUFFER $TOKEN

# make sure permissions are not heinous
#chmod -R 766 /savepath

