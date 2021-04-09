#!/bin/sh

while getopts ":hs" option; do
   case $option in
      h) # display Help
        echo "SYNOPSIS"  
        echo "     start.sh [site] [outpath]"
        echo "        -- site is a NEON site abbreviation e.g. BART"
        echo "        -- outpath is the path where you want the h5"
        echo "           to be written, must exist"
        echo "DESCRIPTION"
        echo "     Saves a csv of location and plant observation from"
        echo "     woody vegetation observations (DP1.10098.001) to pwd."
        exit;;
   esac
done

PRODUCTCODE=$1
SITE=$2

if [ "$SHOWDATES" = true ] ; then
   docker build docker -t hyper_docker && \
   docker run --rm -it -v $PWD:/data -e USER=$USER -e HOME=/data -w /data  hyper_docker s
fi

DATAPATH=$1

docker build docker -t pycrown_docker && \
docker run --rm -it -v $PWD:/data -v $DATAPATH:/data2 -e USER=$USER -e HOME=/data -w /data  pycrown_docker 