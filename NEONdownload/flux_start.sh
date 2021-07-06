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

SAVEPATH=$1
DPID='DP4.00200.001'
PACKAGE='expanded' 
SITE=$2
STARTDATE=$3
ENDDATE=$4
APITOKEN=$5



docker build docker_base -t base_docker && \
docker build docker_flux -t flux_docker && \
docker run --rm -it -v $PWD:/data -v $SAVEPATH:/savepath --user $(id -u):$(id -g) -e HOME=/data -w /data flux_docker $DPID $PACKAGE $SITE $STARTDATE $ENDDATE 

# ./flux_start.sh /data/mthuggin/eddy2 TEAK 2017-06 2020-07 apiTokenHere

# ./flux_start.sh /data/mthuggin/eddy2 SOAP 2017-06 2020-07 $TOKEN


# -u $(id -u):$(id -g)