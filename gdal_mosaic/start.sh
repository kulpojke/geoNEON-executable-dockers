#!/bin/sh

while getopts ":h" option; do
   case $option in
      h) # display Help
        echo "SYNOPSIS"  
        echo "     Finds all CHMs, DTMs and DSMs in a directory (must follow naming convention below)"
        echo "     and creates a mosaic (vrt) for each"
        echo "USAGE: ./start.sh <datapath> "
        echo "     Files must end with a suffix identifying which dataset they belong to, e.g. all CHMs"
        echo "     must be named following '*_CHM.tif'.  DHMS and DSMs =folow the same convention with"
        echo "     their appropriate suffix"
        echo "     "
        echo "     outpath       path in which source rasters reside, and into which vrt will be written. "
        exit;;
   esac
done

DATAPATH=$1

docker build docker -t gdal_docker && \
docker run --rm -it -v $PWD:/data -v $DATAPATH:/datapath -v $OUTPATH:/outpath -e USER=$USER -e HOME=/data -w /data gdal_docker

# ./start.sh /media/data/AOP/data/ /media/data/AOP/mosaic