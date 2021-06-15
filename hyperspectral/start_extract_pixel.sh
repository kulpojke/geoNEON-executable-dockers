#!/bin/sh

while getopts ":h" option; do
   case $option in
      h) # display Help
        echo "SYNOPSIS"  
        echo "     has args"
        echo "DESCRIPTION"
        echo "     does things"
        exit;;
   esac
done

DATAPATH=$1
OUTPATH=$2
H5FILE=$3
LOCATIONS=$4
TYPE=$5

docker build hyper_docker -t hyper_docker && \
docker run --rm -it -v $PWD:/data -v $DATAPATH:/datapath -v $OUTPATH:/outpath -e USER=$USER -e HOME=/data -w /data hyper_docker $H5FILE $LOCATIONS $TYPE


# ./start_extract_pixel.sh /data/mthuggin/eddy2 /data/mthuggin/eddy3 DP3.30006.001/2019/FullSite/D17/2019_TEAK_4/L3/Spectrometer/Reflectance/NEON_D17_TEAK_DP3_321000_4097000_reflectance.h5 '(321516,4097400,321526,4097410),(321520,4097390,321530,4097400)' boxes

