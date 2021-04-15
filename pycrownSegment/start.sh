#!/bin/sh

while getopts ":h" option; do
   case $option in
      h) # display Help
        echo "SYNOPSIS"  
        echo "     start.sh [site] [datapath]"
        echo "        -- site is a NEON site abbreviation e.g. BART"
        echo "        -- datapath is the path where CHM, DSM, DTM and laz"
        echo "           are stored"
        echo "        -- prefix - prefix to determine which files in datapath"
        echo "           will be used.  See description for more details."
        echo "DESCRIPTION"
        echo "     Uses PyCrown to delineate tree canopies.  Writes two shapefiles;"
        echo "     one with crown polygons, and one with crown peaks as points; as"
        echo "     well as a laz file with each tree containing a unique ID"
        echo "     "
        echo "     globs files from the directory designated by datapath with"
        echo "     *prefix*.tif, and *prefix*.laz (or *prefix*.las)  "
        exit;;
   esac
done


echo "Using:"
echo "PyCrown - Fast raster-based individual tree segmentation for LiDAR data"
echo "-----------------------------------------------------------------------"
echo "Copyright: 2018, Jan Zörner"
echo "Licence: GNU GPLv3"


PRODUCTCODE=$1
SITE=$2

if [ "$SHOWDATES" = true ] ; then
   docker build docker -t hyper_docker && \
   docker run --rm -it -v $PWD:/data -e USER=$USER -e HOME=/data -w /data  hyper_docker s
fi

DATAPATH=$1

docker build docker -t pycrown_docker && \
docker run --rm -it -v $PWD:/data -v $DATAPATH:/data2 -e USER=$USER -e HOME=/data -w /data  pycrown_docker 