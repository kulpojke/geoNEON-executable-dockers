#!/bin/sh


WORKDIR=$1
DATAPATH=$2

docker build docker -t py_general_docker && \
docker run --rm -it  -v $WORKDIR:/work -v $DATAPATH:/data -e USER=$USER -e HOME=/work -w /work  py_general_docke $PRODUCTCODE $SITE $DATE