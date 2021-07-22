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


# ./flux_start.sh /data/mthuggin/eddy2 ABBY 2020-05 2020-05 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2020-04 2020-04 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2020-03 2020-03 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2020-02 2020-02 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2020-01 2020-01 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-12 2019-12 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-11 2019-11 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-10 2019-10 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-09 2019-09 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-08 2019-08 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-07 2019-07 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-06 2019-06 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-05 2019-05 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-04 2019-04 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-03 2019-03 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-02 2019-02 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2019-01 2019-01 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2018-12 2018-12 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2018-11 2018-11 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2018-10 2018-10 $TOKEN ; ./flux_start.sh /data/mthuggin/eddy2 ABBY 2018-09 2018-09 $TOKEN 
