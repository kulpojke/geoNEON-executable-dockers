#!/bin/sh

docker build docker_base -t model1_docker && \
docker build docker_matric -t matric_docker && \
docker run --rm -it --runtime=nvidia -v $PWD:/data -v $SAVEPATH:/savepath --user $(id -u):$(id -g) -e HOME=/data -w /data matric_docker

# ./matric_start.sh 