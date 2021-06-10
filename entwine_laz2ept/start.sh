#!/bin/sh

while getopts ":h" option; do
   case $option in
      h) # display Help
        echo "SYNOPSIS"  
        echo "     start.sh [datapath] [outpath] [epsg]"
        echo "        -- datapath is the directory containing point cloud files"
        echo "        -- outpath is the path where the ept will be written"
        echo "           to be written, must exist"
        echo "        -- epsg is the EPSG for the ept will use"
        echo "DESCRIPTION"
        echo "     Creates an ept from a directory of las or laz files"
        exit;;
     \?) # incorrect option
         echo "Error: Invalid option"
         exit;;
   esac
done

DATAPATH=$1
OUTPATH=$2
EPSG=$3

docker build docker -t entwine_docker && \
docker run --rm -it -v $PWD:/data -v $DATAPATH:/data2 -v $OUTPATH:/data3 -e USER=$USER -e HOME=/data -w /data entwine_docker $EPSG

# ./start.sh /home/kulpojke/data/laz /home/kulpojke/entwine EPSG:26911