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






docker build docker_AOP -t neon_utils_r_docker && \
docker run --rm -it -v $PWD:/data -v $SAVEPATH:/savepath --user $(id -u):$(id -g) -e HOME=/data -w /data neon_utils_r_docker 'Rscript AOPdownload.R'

# NOT THIS ONEEEEE!!!!! ./start.sh /media/data/AOP/eddy TEAK 2019-06 2019-07

# ./AOP_start.sh /data/mthuggin/eddy2 TEAK 2017-06 2020-07 apiTokenHere

# -u $(id -u):$(id -g)