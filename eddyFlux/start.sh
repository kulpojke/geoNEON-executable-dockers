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
PACKAGE='basic' 
SITE=$2
STARTDATE=$3
ENDDATE=$4
APITOKEN=$5




docker build docker -t eddyr_docker && \
docker run --rm -it -v $PWD:/data -v $SAVEPATH:/savepath --user $(id -u):$(id -g) -e HOME=/data -w /data eddyr_docker $DPID $PACKAGE $SITE $STARTDATE $ENDDATE 

# NOT THIS ONEEEEE!!!!! ./start.sh /media/data/AOP/eddy TEAK 2019-06 2019-07

# ./start.sh /data/mthuggin/eddy2 TEAK 2017-06 2020-07 apiTokenHere

# -u $(id -u):$(id -g)