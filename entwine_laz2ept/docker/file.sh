#!/bin/sh

DATAPATH=$1
OUTPATH=$2
NCORES=$(grep -c ^processor /proc/cpuinfo)

entwine build -i $DATAPATH -o $OUTPATH --srs EPSG:26911 -t $NCORES



#entwine build --help

 