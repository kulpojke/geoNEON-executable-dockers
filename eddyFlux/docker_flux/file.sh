#!/bin/sh

DPID=$1
PACKAGE=$2 
SITE=$3
STARTDATE=$4
ENDDATE=$5

# run the app
Rscript fluxdownload.R  $DPID $PACKAGE $SITE $STARTDATE $ENDDATE

chmod -R 766 /savepath
