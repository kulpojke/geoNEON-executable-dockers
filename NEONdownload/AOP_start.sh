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

DPID=$1
SITE=$2
YEAR=$3
EASTING=$4
NORTHING=$5
BUFFER=$6
TOKEN=$7
SAVEPATH=$8

docker build docker_base -t base_docker && \
docker build docker_AOP -t aop_docker && \
docker run --rm -it -v $PWD:/data -v $SAVEPATH:/savepath --user $(id -u):$(id -g) -e HOME=/data -w /data aop_docker $DPID $SITE $YEAR $EASTING $NORTHING $BUFFER $TOKEN


# ./AOP_start.sh DP3.30010.001 TEAK 2019 321516 4097400 10 $TOKEN /data/mthuggin/eddy2
