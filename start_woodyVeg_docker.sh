#!/bin/sh
# usage: ./start_docker.sh
docker build docker -t woodyveg_docker && \
docker run --rm -v $PWD:/data -e USER=$USER -e HOME=/data -w /data  woodyveg_docker hi there fool
