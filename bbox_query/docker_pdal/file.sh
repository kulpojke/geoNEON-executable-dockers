#!/bin/sh

BBOX=$1
SRS=$2
echo "------------------------------------------------------------------------"

python app.py --bbox=$BBOX --srs=$SRS --out=/out