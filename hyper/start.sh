#!/bin/sh
# usage: 
#./star.sh site outpath
#   -- site is a NEON site abbreviation e.g. BART
#   -- outpath is the path where you want the csv to be written, must exist

while getopts ":h" option; do
   case $option in
      h) # display Help
        echo "SYNOPSIS"  
        echo "     start.sh [site] [outpath]"
        echo "        -- site is a NEON site abbreviation e.g. BART"
        echo "        -- outpath is the path where you want the h5"
        echo "           to be written, must exist"
        echo "DESCRIPTION"
        echo "     Saves a csv of location and plant observation from"
        echo "     woody vegetation observations (DP1.10098.001) to pwd."
        exit;;
     \?) # incorrect option
         echo "Error: Invalid option"
         exit;;
   esac
done

SITE=$1
DIR=$2

echo "args:"
echo $SITE
echo $DIR

docker build docker -t hyper_docker && \
docker run --rm -it -v $PWD:/data -e USER=$USER -e HOME=/data -w /data  hyper_docker bash