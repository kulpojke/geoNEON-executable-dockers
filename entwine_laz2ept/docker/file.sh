#!/bin/sh

NCORES=$(grep -c ^processor /proc/cpuinfo)

EPSG = $1
#mkdir ./scan


#entwine info -i /data2
#entwine scan -i /data2 -o ./scan --srs EPSG:26911 -t $NCORES
entwine build -i /data2 -o /data3 --srs $EPSG -t $NCORES



#entwine build --help

 