#!/bin/sh

SITE=$1
SAVEPATH=$2
SENSORPOS=$3  # relative to the savepath
PERPLOT=$4    # relative to the savepath
PARSIZE=$5    # relative to the savepath
PLOTPATH=$6   # relative to the savepath

docker build docker_base -t model1_docker && \
docker build docker_matric -t matric_docker && \
docker run --rm -it --runtime=nvidia -v $PWD:/data -v $SAVEPATH:/savepath --user $(id -u):$(id -g) -e HOME=/data -w /data matric_docker $SITE $ENSORPOS $PERPLOT $PARSIZE $PLOTPATH

# ./matric_start.sh SITE SAVEPATH SENSORPOS PERPLOT PARSIZE PLOTPATH
#
#SITE=SOAP
#SAVEPATH=/data/mthuggin/eddy2
#SENSORPOS=SOAP_DP1.10047.001
#PERPLOT=$4    # relative to the savepath
#PARSIZE=$5    # relative to the savepath
#PLOTPATH=$6 
#
#
#
# ./matric_start.sh   