#!/bin/sh

CHM=$1
DTM=$2
DSM=$3
EPT=$4
BBOX=$5
SRS=$6
echo "------------------------------------------------------------------------"

python app.py --bbox=$BBOX --chm=$CHM --dtm=$DTM --dsm=$DSM --ept=$EPT --srs=$SRS --out=/out