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

docker build docker -t entwine_docker && \
docker run --rm -it -v $PWD:/data -v $DATAPATH:/data2 -e USER=$USER -e HOME=/data -w /data  entwine_docker 